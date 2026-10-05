import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:shiroikumanojisho/dictionary.dart';
import 'package:shiroikumanojisho/models.dart';

/// FNV-1a 64-bit hash algorithm optimised for Dart Strings.
///
/// Used to generate deterministic integer ids for entities whose natural
/// keys are strings (currently only [DictionaryTag]). Collision risk is
/// negligible for the cardinalities involved (a few hundred tags per
/// dictionary).
int fastHash(String string) {
  var hash = 0xcbf29ce484222325;

  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }

  return hash;
}

/// Top-level helper invoked through `compute()` for dictionary import.
///
/// Opens Isar in the worker isolate, then asks the format implementation to
/// write its tags, entries, pitch and frequency rows. Each prepare\* step
/// is responsible for its own write transactions and batching — this
/// function no longer wraps everything in a single transaction because
/// compression is asynchronous and `writeTxnSync` does not honour async
/// callbacks.
Future<void> depositDictionaryDataHelper(PrepareDictionaryParams params) async {
  try {
    final Isar isar = await Isar.open(
      globalSchemas,
      directory: params.directoryPath,
      maxSizeMiB: 8192,
    );

    isar.writeTxnSync(() {
      isar.dictionarys.putSync(params.dictionary);
    });

    await params.dictionaryFormat.prepareTags(params: params, isar: isar);
    await params.dictionaryFormat.prepareEntries(params: params, isar: isar);
    await params.dictionaryFormat.preparePitches(params: params, isar: isar);
    await params.dictionaryFormat
        .prepareFrequencies(params: params, isar: isar);

    // After entries are in the database, build a bloom filter over this
    // dictionary's terms and persist it on the Dictionary row. The
    // search pipeline consults this filter before issuing a per-
    // dictionary term query, which lets it skip dictionaries that
    // definitely don't contain the term — a significant win for
    // multi-language installs where most candidate prefixes miss in
    // most dictionaries.
    //
    // The query uses the composite `(dictionaryId, term)` index so
    // the scan is O(entries_in_this_dict), not O(entries_total). We
    // materialise the full term list (strings only, cheap) and feed it
    // straight to `TermBloom.build`. No extra Isar round-trip at
    // runtime.
    final List<String> terms = isar.dictionaryEntrys
        .where()
        .dictionaryIdEqualTo(params.dictionary.id)
        .termProperty()
        .findAllSync();
    final bloom = TermBloom.build(terms);
    params.dictionary.bloomBits = bloom.toBytes();
    isar.writeTxnSync(() {
      isar.dictionarys.putSync(params.dictionary);
    });
  } catch (e, stack) {
    debugPrint('$e');
    debugPrint('$stack');
    params.send('$stack');
    rethrow;
  }
}

/// Clears all dictionary data from the database.
///
/// Used both by the user-facing "delete all dictionaries" action and by
/// the schema migration on first launch under the v2 schema.
Future<void> deleteDictionariesHelper(DeleteDictionaryParams params) async {
  final Isar database = await Isar.open(
    globalSchemas,
    directory: params.directoryPath,
    maxSizeMiB: 8192,
  );

  database.writeTxnSync(() {
    database.dictionaryTags.clearSync();
    database.dictionaryEntrys.clearSync();
    database.dictionaryGloss.clearSync();
    database.dictionaryPitchs.clearSync();
    database.dictionaryFrequencys.clearSync();
    database.dictionarys.clearSync();
  });
}

/// Clears a single dictionary's data from the database.
///
/// Uses indexed `dictionaryId` field on each collection — fast even at
/// scale because no link tables need walking.
Future<void> deleteDictionaryHelper(DeleteDictionaryParams params) async {
  final Isar database = await Isar.open(
    globalSchemas,
    directory: params.directoryPath,
    maxSizeMiB: 8192,
  );

  final int id = params.dictionaryId!;
  final Dictionary dictionary = database.dictionarys.getSync(id)!;

  database.writeTxnSync(() {
    database.dictionaryEntrys
        .where()
        .dictionaryIdEqualTo(id)
        .deleteAllSync();
    database.dictionaryTags
        .where()
        .dictionaryIdEqualTo(id)
        .deleteAllSync();
    database.dictionaryGloss
        .where()
        .dictionaryIdEqualTo(id)
        .deleteAllSync();
    database.dictionaryPitchs
        .where()
        .dictionaryIdEqualTo(id)
        .deleteAllSync();
    database.dictionaryFrequencys
        .where()
        .dictionaryIdEqualTo(id)
        .deleteAllSync();
    database.dictionarys.deleteSync(dictionary.id);
  });
}

/// Entries decoded and indexed per write transaction while building the
/// English gloss index.
const int _kGlossBatch = 2000;

/// Entries sampled before deciding a dictionary has no Latin glosses.
const int _kGlossSample = 500;

/// Top-level helper invoked through `compute()`: build [DictionaryGloss]
/// rows for every dictionary that has no current marker row. Returns the
/// number of dictionaries indexed.
///
/// Dictionaries whose first [_kGlossSample] entries have no Latin glosses
/// (monolingual Japanese, kanji, frequency and pitch dictionaries) are
/// marked without a full scan. The rest are decoded in batches; Jitendex
/// takes a minute or so on a phone, once. Runs beside the UI isolate, which
/// keeps searching normally meanwhile, just without English results for
/// the dictionary being indexed.
Future<int> buildGlossIndexHelper(IsolateParams params) async {
  final Isar isar = Isar.getInstance() ??
      await Isar.open(
        globalSchemas,
        directory: params.directoryPath,
        maxSizeMiB: 8192,
      );

  int indexed = 0;
  for (final Dictionary dictionary in isar.dictionarys.where().findAllSync()) {
    final markers = isar.dictionaryGloss
        .where()
        .entryIdEqualTo(DictionaryGloss.markerEntryId)
        .filter()
        .dictionaryIdEqualTo(dictionary.id)
        .findAllSync();
    if (markers.any((m) => m.glosses.contains(DictionaryGloss.indexVersion))) {
      continue;
    }

    // Start from nothing: a stale index (older version, or a build that was
    // interrupted) is dropped rather than patched.
    isar.writeTxnSync(() {
      isar.dictionaryGloss
          .where()
          .dictionaryIdEqualTo(dictionary.id)
          .deleteAllSync();
    });

    final List<int> entryIds = isar.dictionaryEntrys
        .where()
        .dictionaryIdEqualTo(dictionary.id)
        .idProperty()
        .findAllSync();

    bool anyGloss = false;
    for (int start = 0; start < entryIds.length; start += _kGlossBatch) {
      if (start >= _kGlossSample && !anyGloss) break;

      final int end = (start + _kGlossBatch).clamp(0, entryIds.length);
      final entries = isar.dictionaryEntrys
          .getAllSync(entryIds.sublist(start, end))
          .whereType<DictionaryEntry>();

      final rows = <DictionaryGloss>[];
      for (final DictionaryEntry entry in entries) {
        List<String> definitions;
        try {
          definitions =
              await DefinitionCodec.decode(entry.compressedDefinitions);
        } catch (_) {
          continue;
        }
        final row = DictionaryGloss.forEntry(
          entryId: entry.id!,
          dictionaryId: dictionary.id,
          definitions: definitions,
        );
        if (row != null) rows.add(row);
      }

      if (rows.isNotEmpty) {
        anyGloss = true;
        isar.writeTxnSync(() => isar.dictionaryGloss.putAllSync(rows));
      }
    }

    // The dictionary may have been deleted while it was being indexed.
    if (isar.dictionarys.getSync(dictionary.id) == null) {
      isar.writeTxnSync(() {
        isar.dictionaryGloss
            .where()
            .dictionaryIdEqualTo(dictionary.id)
            .deleteAllSync();
      });
      continue;
    }

    isar.writeTxnSync(() {
      isar.dictionaryGloss.putSync(DictionaryGloss(
        entryId: DictionaryGloss.markerEntryId,
        dictionaryId: dictionary.id,
        words: const [],
        glosses: const [DictionaryGloss.indexVersion],
      ));
    });
    indexed++;
  }

  return indexed;
}
