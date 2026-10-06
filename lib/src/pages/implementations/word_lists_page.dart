import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shiroikumanojisho/creator.dart';
import 'package:shiroikumanojisho/dictionary.dart';
import 'package:shiroikumanojisho/models.dart';
import 'package:shiroikumanojisho/utils.dart';

/// Ask for a list name; null when cancelled.
Future<String?> _askName(BuildContext context,
    {required String title, String initial = ''}) {
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(hintText: t.word_list_name),
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.dialog_cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: Text(t.dialog_done),
        ),
      ],
    ),
  );
}

void _toast(String message) => Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );

/// The ★ action's dialog: tick the lists [term] / [reading] belongs in.
/// Each tick takes effect at once; NEW LIST makes a list and puts the
/// word in it.
class WordListPickerDialog extends ConsumerStatefulWidget {
  /// Create the dialog for one word.
  const WordListPickerDialog({
    required this.term,
    required this.reading,
    super.key,
  });

  /// The headword.
  final String term;

  /// Its reading.
  final String reading;

  @override
  ConsumerState<WordListPickerDialog> createState() =>
      _WordListPickerDialogState();
}

class _WordListPickerDialogState extends ConsumerState<WordListPickerDialog> {
  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appProvider).database;
    final lists = WordLists.all(db);
    final holding = WordLists.listsContaining(db, widget.term, widget.reading);
    final heading = widget.reading.isEmpty || widget.reading == widget.term
        ? widget.term
        : '${widget.term}【${widget.reading}】';

    return AlertDialog(
      title: Text(heading),
      contentPadding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: lists
              .map((list) => CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: holding.contains(list.id),
                    title: Text(list.name),
                    onChanged: (value) => setState(() => WordLists.set(
                          db,
                          list.id!,
                          widget.term,
                          widget.reading,
                          present: value ?? false,
                        )),
                  ))
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final name =
                await _askName(context, title: t.word_list_new);
            if (name == null) return;
            final list = WordLists.create(db, name);
            if (list == null) {
              _toast(t.word_list_name_taken);
              return;
            }
            setState(() => WordLists.set(
                db, list.id!, widget.term, widget.reading,
                present: true));
          },
          child: Text(t.word_list_new),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.dialog_done),
        ),
      ],
    );
  }
}

/// Every word list, with its size; tap one to open it.
class WordListsPage extends ConsumerStatefulWidget {
  /// Create the page.
  const WordListsPage({super.key});

  /// Push the page.
  static Future<void> open(BuildContext context) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const WordListsPage()));

  @override
  ConsumerState<WordListsPage> createState() => _WordListsPageState();
}

class _WordListsPageState extends ConsumerState<WordListsPage> {
  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appProvider).database;
    final lists = WordLists.all(db);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.word_lists),
        actions: [
          IconButton(
            tooltip: t.word_list_new,
            icon: const Icon(Icons.add),
            onPressed: () async {
              final name = await _askName(context, title: t.word_list_new);
              if (name == null) return;
              if (WordLists.create(db, name) == null) {
                _toast(t.word_list_name_taken);
              }
              setState(() {});
            },
          ),
        ],
      ),
      body: ListView(
        children: lists
            .map((list) => ListTile(
                  leading: const Icon(Icons.star),
                  title: Text(list.name),
                  trailing: Text('${WordLists.count(db, list)}'),
                  onTap: () async {
                    await WordListPage.open(context, list);
                    if (mounted) setState(() {});
                  },
                ))
            .toList(),
      ),
    );
  }
}

/// One word list: its words in the order added, each with the first
/// dictionary's meaning. Tap a word to look it up, swipe it away to
/// remove it. The menu exports the list as CSV or TSV, sends it to
/// Anki, renames or deletes it.
class WordListPage extends ConsumerStatefulWidget {
  /// Create the page for [list].
  const WordListPage({required this.list, super.key});

  /// The list shown.
  final WordList list;

  /// Push the page for [list].
  static Future<void> open(BuildContext context, WordList list) =>
      Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => WordListPage(list: list)));

  @override
  ConsumerState<WordListPage> createState() => _WordListPageState();
}

enum _Menu { csv, tsv, anki, rename, delete }

class _WordListPageState extends ConsumerState<WordListPage> {
  final Map<int, Future<DictionaryHeading?>> _headings = {};

  AppModel get appModel => ref.read(appProvider);

  Future<DictionaryHeading?> _heading(WordListEntry entry) =>
      _headings[entry.id!] ??= WordLists.heading(appModel, entry);

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appProvider).database;
    final entries = WordLists.entries(db, widget.list).reversed.toList();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.list.name} (${entries.length})'),
        actions: [
          PopupMenuButton<_Menu>(
            onSelected: _onMenu,
            itemBuilder: (context) => [
              PopupMenuItem(value: _Menu.csv, child: Text(t.word_list_csv)),
              PopupMenuItem(value: _Menu.tsv, child: Text(t.word_list_tsv)),
              PopupMenuItem(value: _Menu.anki, child: Text(t.word_list_anki)),
              PopupMenuItem(
                  value: _Menu.rename, child: Text(t.word_list_rename)),
              PopupMenuItem(
                  value: _Menu.delete, child: Text(t.word_list_delete)),
            ],
          ),
        ],
      ),
      body: entries.isEmpty
          ? Center(child: Text(t.word_list_empty))
          : ListView.separated(
              itemCount: entries.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Dismissible(
                  key: ValueKey(entry.id),
                  onDismissed: (_) {
                    WordLists.remove(db, entry);
                    setState(() {});
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                        content: Text(t.word_list_removed(term: entry.term)),
                        action: SnackBarAction(
                          label: t.word_list_undo,
                          onPressed: () {
                            WordLists.restore(db, entry);
                            if (mounted) setState(() {});
                          },
                        ),
                      ));
                  },
                  child: ListTile(
                    dense: true,
                    title: Text.rich(TextSpan(children: [
                      TextSpan(
                        text: entry.term,
                        style: theme.textTheme.titleMedium,
                      ),
                      if (entry.reading.isNotEmpty &&
                          entry.reading != entry.term)
                        TextSpan(
                          text: '  ${entry.reading}',
                          style: theme.textTheme.bodyMedium,
                        ),
                    ])),
                    subtitle: FutureBuilder<DictionaryHeading?>(
                      future: _heading(entry),
                      builder: (context, snapshot) => Text(
                        snapshot.data == null
                            ? ''
                            : WordLists.meaning(appModel, snapshot.data!),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    onTap: () => appModel.openRecursiveDictionarySearch(
                      searchTerm: entry.term,
                      killOnPop: false,
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _onMenu(_Menu item) async {
    final db = appModel.database;
    switch (item) {
      case _Menu.csv:
        await _export(tab: false);
      case _Menu.tsv:
        await _export(tab: true);
      case _Menu.anki:
        await _sendToAnki();
      case _Menu.rename:
        final name = await _askName(context,
            title: t.word_list_rename, initial: widget.list.name);
        if (name == null) return;
        if (!WordLists.rename(db, widget.list, name)) {
          _toast(t.word_list_name_taken);
        }
        setState(() {});
      case _Menu.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(t.word_list_delete),
            content: Text(t.word_list_delete_description(
                name: widget.list.name,
                count: WordLists.count(db, widget.list))),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(t.dialog_delete),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(t.dialog_cancel),
              ),
            ],
          ),
        );
        if (confirmed != true || !mounted) return;
        WordLists.delete(db, widget.list);
        Navigator.pop(context);
    }
  }

  /// Run [work] over every word behind a progress dialog showing
  /// `done / total`.
  Future<void> _withProgress(
    String label,
    Future<void> Function(ValueNotifier<int> done) work,
  ) async {
    final total = WordLists.count(appModel.database, widget.list);
    final done = ValueNotifier<int>(0);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: ValueListenableBuilder<int>(
            valueListenable: done,
            builder: (context, value, _) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$label $value / $total'),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                    value: total == 0 ? null : value / total),
              ],
            ),
          ),
        ),
      ),
    );
    try {
      await work(done);
    } finally {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Future<void> _export({required bool tab}) async {
    final entries = WordLists.entries(appModel.database, widget.list);
    if (entries.isEmpty) return;
    final rows = <List<String>>[];
    await _withProgress(t.word_list_preparing, (done) async {
      for (final entry in entries) {
        final heading = await _heading(entry);
        rows.add([
          entry.term,
          entry.reading,
          heading == null ? '' : WordLists.meaning(appModel, heading),
        ]);
        done.value++;
      }
    });

    final safeName =
        widget.list.name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final file = File(path.join((await getTemporaryDirectory()).path,
        '$safeName.${tab ? 'tsv' : 'csv'}'));
    // A BOM so spreadsheet apps read the Japanese as UTF-8.
    await file.writeAsString('﻿${WordLists.delimited(rows, tab: tab)}');
    await SharePlus.instance.share(ShareParams(
      files: [
        XFile(file.path,
            mimeType: tab ? 'text/tab-separated-values' : 'text/csv'),
      ],
      subject: widget.list.name,
    ));
  }

  /// Make one card per word with the current export profile and deck,
  /// as the card's own Instant Export button would; words Anki already
  /// has are skipped.
  Future<void> _sendToAnki() async {
    final entries = WordLists.entries(appModel.database, widget.list);
    if (entries.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.word_list_anki),
        content: Text(t.word_list_anki_description(
          count: entries.length,
          deck: appModel.lastSelectedDeckName,
          profile: appModel.lastSelectedMapping.label,
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.word_list_send),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.dialog_cancel),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    int added = 0, skipped = 0, missing = 0;
    await _withProgress(t.word_list_sending, (done) async {
      for (final entry in entries) {
        final heading = await _heading(entry);
        if (heading == null) {
          missing++;
        } else if (await appModel.checkForDuplicates(entry.term)) {
          skipped++;
        } else if (mounted) {
          await InstantExportAction().executeAction(
            context: context,
            ref: ref,
            appModel: appModel,
            creatorModel: ref.read(instantExportProvider),
            heading: heading,
            dictionaryName: null,
          );
          added++;
        }
        done.value++;
      }
    });
    _toast(t.word_list_anki_done(
        added: added, skipped: skipped, missing: missing));
  }
}
