import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shiroikumanojisho/creator.dart';
import 'package:shiroikumanojisho/models.dart';

/// Word audio from a local, offline collection: the `android.db` that
/// local-audio-yomichan builds for AnkiConnect Android (the desktop
/// add-on exports it). It holds an `entries` table (expression,
/// reading, source, speaker, file) and an `android` table with each
/// file's audio bytes, keyed by file and source.
class LocalAudioEnhancement extends AudioEnhancement {
  /// Initialise this enhancement with the hardset parameters.
  LocalAudioEnhancement()
      : super(
          uniqueKey: key,
          label: 'Local Audio',
          description: 'Word audio from a local audio collection (the '
              'android.db of local-audio-yomichan / AnkiConnect Android), '
              'offline.',
          icon: Icons.sd_storage_outlined,
          field: AudioField.instance,
        );

  /// Used to identify this enhancement and to allow a constant value for the
  /// default mappings value of [AnkiMapping].
  static const String key = 'local_audio';

  /// Sources in AnkiConnect Android's default order: best recordings
  /// first.
  static const List<String> sourceOrder = [
    'nhk16',
    'shinmeikai8',
    'forvo',
    'jpod',
    'jpod_alternate',
  ];

  Database? _database;
  String? _databasePath;

  Future<Database?> _open(String dbPath) async {
    if (_database != null && _databasePath == dbPath) return _database;
    await _database?.close();
    _database = null;
    if (!File(dbPath).existsSync()) return null;
    _database = await openDatabase(dbPath, readOnly: true);
    _databasePath = dbPath;
    return _database;
  }

  @override
  Future<void> enhanceCreatorParams({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required EnhancementTriggerCause cause,
  }) async {
    AudioExportField audioField = field as AudioExportField;
    String? searchTerm;

    if (cause != EnhancementTriggerCause.auto) {
      searchTerm = audioField.getSearchTermWithFallback(
        appModel: appModel,
        creatorModel: creatorModel,
        fallbackSearchTerms: [
          TermField.instance,
          ReadingField.instance,
        ],
      );
    } else {
      searchTerm = creatorModel.getFieldController(TermField.instance).text;
      if (searchTerm.trim().isEmpty) {
        return;
      }
    }

    await audioField.setAudio(
      appModel: appModel,
      creatorModel: creatorModel,
      searchTerm: searchTerm,
      newAutoCannotOverride: false,
      cause: cause,
      generateAudio: () async => fetchAudio(
        appModel: appModel,
        context: context,
        term: searchTerm!,
        reading: creatorModel.getFieldController(ReadingField.instance).text,
      ),
    );
  }

  @override
  Future<File?> fetchAudio({
    required AppModel appModel,
    required BuildContext context,
    required String term,
    required String reading,
  }) async {
    try {
      final db = await _open(appModel.localAudioDatabasePath);
      if (db == null) return null;

      final order = StringBuffer('CASE source ');
      for (int i = 0; i < sourceOrder.length; i++) {
        order.write("WHEN '${sourceOrder[i]}' THEN $i ");
      }
      order.write('ELSE ${sourceOrder.length} END');

      final rows = await db.query(
        'entries',
        columns: ['source', 'file'],
        where: 'expression = ? AND (reading IS NULL OR reading = ?)',
        whereArgs: [term, reading.isEmpty ? term : reading],
        orderBy: '$order, reading',
        limit: 1,
      );
      if (rows.isEmpty) return null;

      final String source = rows.first['source']! as String;
      final String file = rows.first['file']! as String;
      final data = await db.query(
        'android',
        columns: ['data'],
        where: 'file = ? AND source = ?',
        whereArgs: [file, source],
        limit: 1,
      );
      if (data.isEmpty) return null;

      final Directory dir = Directory(path.join(
          (await getTemporaryDirectory()).path, 'localAudio'));
      dir.createSync(recursive: true);
      final String extension = path.extension(file).isEmpty
          ? '.mp3'
          : path.extension(file);
      final out = File(path.join(dir.path, '$term-$reading$extension'));
      out.writeAsBytesSync(data.first['data']! as List<int>, flush: true);
      return out;
    } catch (e) {
      debugPrint('Local audio lookup failed: $e');
      return null;
    }
  }
}
