import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiroikumanojisho/creator.dart';
import 'package:shiroikumanojisho/dictionary.dart';
import 'package:shiroikumanojisho/models.dart';
import 'package:shiroikumanojisho/pages.dart';
import 'package:shiroikumanojisho/utils.dart';

/// Put the word in one or more named word lists (★); red when it is
/// already in one.
class AddToListAction extends QuickAction {
  /// Initialise this action with the hardset parameters.
  AddToListAction()
      : super(
          uniqueKey: key,
          label: 'Add To List',
          description: 'Save the word to one or more named word lists.',
          icon: Icons.star,
        );

  /// Used to identify this action and to allow a constant value for the
  /// default mappings value of [AnkiMapping].
  static const String key = 'add_to_list';

  @override
  Future<Color?> getIconColor({
    required AppModel appModel,
    required DictionaryHeading heading,
  }) async {
    return WordLists.listsContaining(
                appModel.database, heading.term, heading.reading)
            .isEmpty
        ? null
        : Colors.red;
  }

  @override
  Future<void> executeAction({
    required BuildContext context,
    required WidgetRef ref,
    required AppModel appModel,
    required CreatorModel creatorModel,
    required DictionaryHeading heading,
    required String? dictionaryName,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => WordListPickerDialog(
        term: heading.term,
        reading: heading.reading,
      ),
    );
  }
}
