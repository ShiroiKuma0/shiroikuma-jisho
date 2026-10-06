import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shiroikumanojisho/dictionary.dart';
import 'package:shiroikumanojisho/models.dart';

/// Offline example sentences: the Tanaka Corpus (Tatoeba, CC BY 2.0 FR),
/// as EDRDG publishes it in examples.utf — about 148,000 Japanese–English
/// pairs, each with a line giving the dictionary forms of its words.
/// Downloaded once on request (9.7 MB) into [ExampleSentence] rows.
class ExampleSentences {
  ExampleSentences._();

  /// EDRDG's copy of the corpus.
  static const String sourceUrl =
      'https://www.edrdg.org/pub/Nihongo/examples.utf.gz';

  /// Download size, for the download list.
  static const int approximateMegabytes = 10;

  static Future<File> _marker() async => File(path.join(
      (await getApplicationSupportDirectory()).path,
      'example_sentences.installed'));

  /// Whether the sentences have been downloaded.
  static Future<bool> isInstalled() async => (await _marker()).existsSync();

  /// Download and index the corpus into the database at [directoryPath],
  /// reporting progress through [progress].
  static Future<void> download({
    required String directoryPath,
    required ValueNotifier<String> progress,
  }) async {
    progress.value = 'Downloading example sentences…';
    final response = await http.get(Uri.parse(sourceUrl));
    if (response.statusCode != 200) {
      throw Exception(
          'Example sentence download failed (HTTP ${response.statusCode})');
    }

    final port = ReceivePort();
    port.listen((m) => progress.value = '$m');
    try {
      await compute(
          _index, (response.bodyBytes, directoryPath, port.sendPort));
    } finally {
      port.close();
    }
    (await _marker()).writeAsStringSync(sourceUrl);
  }

  static Future<void> _index((Uint8List, String, SendPort) args) async {
    final (bytes, directoryPath, send) = args;
    final Isar isar = Isar.getInstance() ??
        await Isar.open(globalSchemas,
            directory: directoryPath, maxSizeMiB: 8192);

    final lines = const LineSplitter()
        .convert(utf8.decode(GZipCodec().decode(bytes), allowMalformed: true));
    isar.writeTxnSync(() => isar.exampleSentences.clearSync());

    final batch = <ExampleSentence>[];
    int done = 0;
    for (int i = 0; i + 1 < lines.length; i++) {
      final a = lines[i];
      if (!a.startsWith('A: ') || !lines[i + 1].startsWith('B: ')) continue;
      final sentence = parse(a, lines[i + 1]);
      i++;
      if (sentence == null) continue;
      batch.add(sentence);
      if (batch.length >= 2000) {
        isar.writeTxnSync(() => isar.exampleSentences.putAllSync(batch));
        done += batch.length;
        batch.clear();
        send.send('Indexing example sentences: $done');
      }
    }
    isar.writeTxnSync(() => isar.exampleSentences.putAllSync(batch));
  }

  static final RegExp _token = RegExp(
      r'^([^(\[{~]+)(?:\(([^)]*)\))?(?:\[\d+\])?(?:\{([^}]*)\})?~?$');

  /// One pair from its A-line (`A: 日本語<TAB>English#ID=…`) and B-line
  /// (`B: 会う[01]{会えない} 事(こと){こと} …`).
  @visibleForTesting
  static ExampleSentence? parse(String aLine, String bLine) {
    final body = aLine.substring(3);
    final tab = body.indexOf('\t');
    if (tab < 0) return null;
    final japanese = body.substring(0, tab).trim();
    var english = body.substring(tab + 1);
    final id = english.indexOf('#ID=');
    if (id >= 0) english = english.substring(0, id);
    english = english.trim();

    final words = <String>{};
    final surfaces = <String>[];
    for (final token in bLine.substring(3).split(' ')) {
      final m = _token.firstMatch(token.trim());
      if (m == null) continue;
      final word = m.group(1)!;
      words.add(word);
      final reading = m.group(2);
      if (reading != null && !reading.startsWith('#')) words.add(reading);
      final surface = m.group(3);
      if (surface != null && surface != word) surfaces.add('$word\t$surface');
    }
    if (japanese.isEmpty || english.isEmpty || words.isEmpty) return null;
    return ExampleSentence(
      japanese: japanese,
      english: english,
      words: words.toList(),
      surfaces: surfaces,
    );
  }

  /// Up to [limit] sentences using [term] (or, failing that, [reading]),
  /// shortest first — short sentences show the word most plainly.
  static List<ExampleSentence> forWord(Isar db, String term, String reading,
      {int limit = 20}) {
    var rows = db.exampleSentences
        .where()
        .wordsElementEqualTo(term)
        .limit(200)
        .findAllSync();
    if (rows.isEmpty && reading.isNotEmpty && reading != term) {
      rows = db.exampleSentences
          .where()
          .wordsElementEqualTo(reading)
          .limit(200)
          .findAllSync();
    }
    rows.sort((a, b) => a.japanese.length.compareTo(b.japanese.length));
    return rows.take(limit).toList();
  }

  /// How [term] is written in [sentence]: the surface the corpus gives,
  /// else the term itself.
  static String surfaceIn(ExampleSentence sentence, String term) {
    for (final s in sentence.surfaces) {
      if (s.startsWith('$term\t')) return s.substring(term.length + 1);
    }
    return term;
  }
}
