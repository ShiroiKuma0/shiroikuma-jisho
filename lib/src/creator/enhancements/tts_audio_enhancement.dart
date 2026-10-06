import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shiroikumanojisho/creator.dart';
import 'package:shiroikumanojisho/models.dart';

/// Word audio spoken by the phone's own text-to-speech engine: offline
/// with a downloaded Japanese voice, and available for any word. It reads
/// the reading rather than the headword, so a kanji with several readings
/// is never misread.
class TtsAudioEnhancement extends AudioEnhancement {
  /// Initialise this enhancement with the hardset parameters.
  TtsAudioEnhancement()
      : super(
          uniqueKey: key,
          label: 'Text-to-Speech Audio',
          description: 'Speak the word with the device text-to-speech '
              'engine (offline with a Japanese voice installed).',
          icon: Icons.record_voice_over_outlined,
          field: AudioField.instance,
        );

  /// Used to identify this enhancement and to allow a constant value for the
  /// default mappings value of [AnkiMapping].
  static const String key = 'tts_audio';

  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  Future<bool> _prepare(AppModel appModel) async {
    if (_ready) return true;
    final String locale = appModel.targetLanguage.locale.toLanguageTag();
    if (await _tts.isLanguageAvailable(locale) != true) return false;
    await _tts.setLanguage(locale);
    await _tts.awaitSynthCompletion(true);
    _ready = true;
    return true;
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
      if (!await _prepare(appModel)) return null;
      final String text = reading.trim().isNotEmpty ? reading : term;

      final Directory dir = Directory(
          path.join((await getTemporaryDirectory()).path, 'ttsAudio'));
      dir.createSync(recursive: true);
      final File out = File(path.join(dir.path, '$term-$reading.wav'));
      if (out.existsSync()) out.deleteSync();

      final result = await _tts.synthesizeToFile(text, out.path, true);
      if (result != 1 || !out.existsSync() || out.lengthSync() == 0) {
        return null;
      }
      return out;
    } catch (e) {
      debugPrint('TTS audio failed: $e');
      return null;
    }
  }
}
