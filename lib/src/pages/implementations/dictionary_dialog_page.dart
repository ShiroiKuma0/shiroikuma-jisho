import 'dart:io';

import 'package:change_notifier_builder/change_notifier_builder.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:spaces/spaces.dart';
import 'package:shiroikumanojisho/dictionary.dart';
import 'package:shiroikumanojisho/media.dart';
import 'package:shiroikumanojisho/pages.dart';
import 'package:shiroikumanojisho/utils.dart';
import 'package:collection/collection.dart';

/// The content of the dialog used for managing dictionaries.
class DictionaryDialogPage extends BasePage {
  /// Create an instance of this page.
  const DictionaryDialogPage({super.key});

  @override
  BasePageState createState() => _DictionaryDialogPageState();
}

class _DictionaryDialogPageState extends BasePageState with ChangeNotifier {
  final ScrollController _scrollController = ScrollController();
  int? _selectedOrder;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: MediaQuery.of(context).orientation == Orientation.portrait
          ? Spacing.of(context).insets.exceptBottom.big
          : Spacing.of(context).insets.exceptBottom.normal.copyWith(
                left: Spacing.of(context).spaces.semiBig,
                right: Spacing.of(context).spaces.semiBig,
              ),
      actionsPadding: Spacing.of(context).insets.exceptBottom.normal.copyWith(
            left: Spacing.of(context).spaces.normal,
            right: Spacing.of(context).spaces.normal,
            bottom: Spacing.of(context).spaces.normal,
            top: Spacing.of(context).spaces.extraSmall,
          ),
      content: buildContent(),
      actions: actions,
    );
  }

  List<Widget> get actions => [
        buildClearButton(),
        buildImportButton(),
        buildCloseButton(),
      ];

  Future<void> showDictionaryClearDialog() async {
    Widget alertDialog = AlertDialog(
      title: Text(t.dialog_title_dictionary_clear),
      content: Text(
        t.dialog_content_dictionary_clear,
        textAlign: TextAlign.justify,
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            t.dialog_clear,
            style: TextStyle(color: theme.colorScheme.primary),
          ),
          onPressed: () async {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => const DictionaryDialogDeletePage(),
            );

            await appModel.deleteDictionaries();

            if (mounted) {
              Navigator.pop(context);
            }

            if (mounted) {
              Navigator.pop(context);
            }

            _selectedOrder = -1;
            setState(() {});
          },
        ),
        TextButton(
          child: Text(t.dialog_cancel),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (context) => alertDialog,
    );
  }

  /// Build [dictionary]'s English index behind the import progress
  /// dialog, which cannot be dismissed until it is done.
  Future<void> buildGlossIndex(Dictionary dictionary) async {
    final ValueNotifier<String> progressNotifier =
        ValueNotifier<String>(t.import_start);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DictionaryDialogImportPage(
        progressNotifier: progressNotifier,
        countNotifier: ValueNotifier<int?>(null),
        totalNotifier: ValueNotifier<int?>(null),
      ),
    );

    final bool done = await appModel.buildGlossIndex(
      dictionary: dictionary,
      progressNotifier: progressNotifier,
    );

    if (mounted) {
      Navigator.pop(context);
      setState(() {});
    }
    if (done) {
      Fluttertoast.showToast(
        msg: t.gloss_index_done(name: dictionary.name),
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  Future<void> showDictionaryDeleteDialog(Dictionary dictionary) async {
    Widget alertDialog = AlertDialog(
      title: Text(t.dialog_title_dictionary_delete(name: dictionary.name)),
      content: Text(
        t.dialog_content_dictionary_delete,
        textAlign: TextAlign.justify,
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            t.dialog_delete,
            style: TextStyle(color: theme.colorScheme.primary),
          ),
          onPressed: () async {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) =>
                  DictionaryDialogDeletePage(name: dictionary.name),
            );

            await appModel.deleteDictionary(dictionary);

            if (mounted) {
              Navigator.pop(context);
            }

            if (mounted) {
              Navigator.pop(context);
            }

            _selectedOrder = -1;
            setState(() {});
          },
        ),
        TextButton(
          child: Text(t.dialog_cancel),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (context) => alertDialog,
    );
  }

  Widget buildImportButton() {
    return TextButton(
      child: Text(t.dialog_import),
      onPressed: () async {
        /// A [ValueNotifier] that will update a message based on the progress
        /// of the ongoing dictionary file import. See
        /// [DictionaryImportProgressPage].
        ValueNotifier<String> progressNotifier =
            ValueNotifier<String>(t.import_start);
        ValueNotifier<int?> countNotifier = ValueNotifier<int?>(null);
        ValueNotifier<int?> totalNotifier = ValueNotifier<int?>(null);
        progressNotifier.addListener(() {
          debugPrint('[Dictionary Import] ${progressNotifier.value}');
        });

        await FilePicker.clearTemporaryFiles();

        FileType type = appModel.lastSelectedDictionaryFormat.fileType;
        FilePickerResult? result = await FilePicker.pickFiles(
          /// Change when adding multiple dictionary formats.
          type: type,
          allowedExtensions: type == FileType.any
              ? null
              : appModel.lastSelectedDictionaryFormat.allowedExtensions,
          onFileLoading: (status) {
            if (status == FilePickerStatus.done) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => DictionaryDialogImportPage(
                  progressNotifier: progressNotifier,
                  countNotifier: countNotifier,
                  totalNotifier: totalNotifier,
                ),
              );
            }
          },
        );
        if (result == null) {
          if (mounted) {
            Navigator.pop(context);
          }
          return;
        }

        totalNotifier.value = result.files.length;
        for (int i = 0; i < result.files.length; i++) {
          countNotifier.value = i + 1;

          PlatformFile platformFile = result.files[i];
          File file = File(platformFile.path!);

          await appModel.importDictionary(
            progressNotifier: progressNotifier,
            file: file,
            onImportSuccess: () {
              _selectedOrder = appModel.dictionaries.last.order;
              setState(() {});
            },
          );
        }

        await FilePicker.clearTemporaryFiles();

        if (mounted) {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget buildClearButton() {
    return TextButton(
      onPressed: showDictionaryClearDialog,
      child: Text(
        t.dialog_clear,
        style: const TextStyle(
          color: Colors.red,
        ),
      ),
    );
  }

  Widget buildCloseButton() {
    return TextButton(
      child: Text(t.dialog_close),
      onPressed: () => Navigator.pop(context),
    );
  }

  Widget buildContent() {
    List<Dictionary> dictionaries = appModel.dictionaries;
    List<Dictionary> visible = dictionaries
        .where((dictionary) => !dictionary.isHidden(appModel.targetLanguage))
        .toList();
    List<Dictionary> hidden = dictionaries
        .where((dictionary) => dictionary.isHidden(appModel.targetLanguage))
        .toList();

    _notifiersByDictionary = {};
    _selectedOrder ??= dictionaries.firstOrNull?.order;

    // One CustomScrollView rather than a list nested in a scroll view: the
    // reorderable sliver then auto-scrolls the whole dialog while a row is
    // dragged towards its edge, which a long list needs.
    return SizedBox(
      width: double.maxFinite,
      child: RawScrollbar(
        thickness: 3,
        thumbVisibility: true,
        controller: _scrollController,
        child: CustomScrollView(
          controller: _scrollController,
          shrinkWrap: true,
          slivers: [
            // A content button rather than a fifth action: four
            // actions already fill the ~720 px Palma width.
            if (appModel.dictionaryCatalog.isNotEmpty)
              SliverToBoxAdapter(child: buildDownloadButton()),
            if (dictionaries.isEmpty)
              SliverToBoxAdapter(child: buildEmptyMessage())
            else ...[
              buildDictionaryList(visible),
              if (hidden.isNotEmpty)
                SliverToBoxAdapter(child: buildHiddenHeader()),
              if (hidden.isNotEmpty)
                SliverList.list(
                  children: hidden
                      .map((dictionary) => buildDictionaryTile(
                            dictionary,
                            _notifierFor(dictionary),
                          ))
                      .toList(),
                ),
            ],
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const JidoujishoDivider(),
                  Padding(
                    padding: Spacing.of(context).insets.onlyLeft.small,
                    child: Row(
                      children: [
                        Icon(Icons.language,
                            size: 14, color: theme.unselectedWidgetColor),
                        const SizedBox(width: 4),
                        Text(
                          t.import_for_language(language: appModel.targetLanguage.languageName),
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.unselectedWidgetColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  buildImportDropdown(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Divides the dictionaries shown for the target language from those
  /// hidden for it, which cannot be dragged: their position only matters
  /// for the languages they are shown in.
  Widget buildHiddenHeader() {
    return Padding(
      padding: EdgeInsets.only(
        left: Spacing.of(context).spaces.small,
        top: Spacing.of(context).spaces.normal,
        bottom: Spacing.of(context).spaces.small,
      ),
      child: Text(
        t.dictionaries_hidden_for_language(
            language: appModel.targetLanguage.languageName),
        style: TextStyle(
          fontSize: 12,
          color: theme.unselectedWidgetColor,
        ),
      ),
    );
  }

  Widget buildDownloadButton() {
    return Padding(
      padding: EdgeInsets.only(bottom: Spacing.of(context).spaces.normal),
      // A TextButton, so the 白い熊 UI theme draws it as the same pill as
      // the dialog's CLEAR / IMPORT / CLOSE actions.
      child: TextButton.icon(
        icon: const Icon(Icons.download),
        label: Text(t.download_dictionaries),
        onPressed: () async {
          await appModel.showDictionaryDownloadMenu();
          _selectedOrder = appModel.dictionaries.lastOrNull?.order;
          if (mounted) {
            setState(() {});
          }
        },
      ),
    );
  }

  Widget buildEmptyMessage() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: Spacing.of(context).spaces.normal,
      ),
      child: JidoujishoPlaceholderMessage(
        icon: DictionaryMediaType.instance.outlinedIcon,
        message: t.dictionaries_menu_empty,
      ),
    );
  }

  Map<Dictionary, ValueNotifier<bool>> _notifiersByDictionary = {};

  ValueNotifier<bool> _notifierFor(Dictionary dictionary) =>
      _notifiersByDictionary.putIfAbsent(
        dictionary,
        () => ValueNotifier<bool>(dictionary.order == _selectedOrder),
      );

  /// The dictionaries shown for the target language, in priority order.
  /// Drag a row by its handle, or long-press anywhere on it.
  Widget buildDictionaryList(List<Dictionary> visible) {
    return SliverReorderableList(
      itemCount: visible.length,
      // The dragged row is lifted into the overlay, away from the dialog's
      // background; give it one so it does not float as bare text.
      proxyDecorator: (child, index, animation) => Material(
        elevation: 4,
        color: theme.dialogTheme.backgroundColor ?? theme.colorScheme.surface,
        child: child,
      ),
      itemBuilder: (context, index) {
        Dictionary dictionary = visible[index];
        return ReorderableDelayedDragStartListener(
          key: ValueKey(dictionary.name),
          index: index,
          child: buildDictionaryTile(
            dictionary,
            _notifierFor(dictionary),
            dragIndex: index,
          ),
        );
      },
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        _selectedOrder = appModel.reorderDictionariesForLanguage(
          visible: visible,
          oldIndex: oldIndex,
          newIndex: newIndex,
        );
        setState(() {});
      },
    );
  }

  Icon getIcon({
    required Dictionary dictionary,
    required DictionaryFormat dictionaryFormat,
  }) {
    if (dictionary.isHidden(appModel.targetLanguage)) {
      return Icon(
        Icons.visibility_off,
        size: textTheme.titleLarge?.fontSize,
        color: theme.unselectedWidgetColor,
      );
    } else if (dictionary.isCollapsed(appModel.targetLanguage)) {
      return Icon(
        Icons.close_fullscreen,
        size: textTheme.titleLarge?.fontSize,
        color: theme.unselectedWidgetColor,
      );
    } else {
      return Icon(
        dictionaryFormat.icon,
        size: textTheme.titleLarge?.fontSize,
      );
    }
  }

  Widget buildDictionaryTile(
    Dictionary dictionary,
    ValueNotifier<bool> notifier, {
    int? dragIndex,
  }) {
    DictionaryFormat dictionaryFormat =
        appModel.dictionaryFormats[dictionary.formatKey]!;

    return ValueListenableBuilder<bool>(
      key: ValueKey(dictionary.name),
      valueListenable: notifier,
      builder: (context, value, _) {
        return Material(
          type: MaterialType.transparency,
          child: ListTile(
            selected: _selectedOrder == dictionary.order,
            leading: getIcon(
              dictionary: dictionary,
              dictionaryFormat: dictionaryFormat,
            ),
            title: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      JidoujishoMarquee(
                        text: dictionary.name,
                        style: TextStyle(
                          fontSize: textTheme.bodyMedium?.fontSize,
                          color: dictionary.isHidden(appModel.targetLanguage)
                              ? theme.unselectedWidgetColor
                              : null,
                        ),
                      ),
                      JidoujishoMarquee(
                        text: dictionaryFormat.name,
                        style: TextStyle(
                          fontSize: textTheme.bodySmall?.fontSize,
                          color: dictionary.isHidden(appModel.targetLanguage)
                              ? theme.unselectedWidgetColor
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const Space.normal(),
                if (_selectedOrder == dictionary.order)
                  buildDictionaryTileTrailing(dictionary),
                if (dragIndex != null)
                  ReorderableDragStartListener(
                    index: dragIndex,
                    child: Padding(
                      padding: Spacing.of(context).insets.onlyLeft.small,
                      child: Icon(
                        Icons.drag_handle,
                        color: theme.unselectedWidgetColor,
                      ),
                    ),
                  ),
              ],
            ),
            onTap: () {
              _selectedOrder = dictionary.order;

              for (int i = 0; i < _notifiersByDictionary.length; i++) {
                _notifiersByDictionary.entries.elementAt(i).value.value = false;
              }
              notifier.value = true;
            },
          ),
        );
      },
    );
  }

  Widget buildDictionaryTileTrailing(Dictionary dictionary) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Material(
        color: Colors.transparent,
        child: PopupMenuButton<VoidCallback>(
          splashRadius: 20,
          padding: EdgeInsets.zero,
          tooltip: t.show_options,
          color: Theme.of(context).popupMenuTheme.color,
          onSelected: (value) => value(),
          itemBuilder: (context) => getMenuItems(dictionary),
          child: Container(
            height: 30,
            width: 30,
            alignment: Alignment.center,
            child: Icon(
              Icons.more_vert,
              color: theme.iconTheme.color,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  PopupMenuItem<VoidCallback> buildPopupItem({
    required String label,
    required Function() action,
    IconData? icon,
    Color? color,
  }) {
    return PopupMenuItem<VoidCallback>(
      value: action,
      child: Row(
        children: [
          if (icon != null)
            Icon(
              icon,
              size: textTheme.bodyMedium?.fontSize,
              color: color,
            ),
          if (icon != null) const Space.normal(),
          Text(
            label,
            style: TextStyle(color: color),
          ),
        ],
      ),
    );
  }

  void openDictionaryOptionsMenu(
      {required TapDownDetails details, required Dictionary dictionary}) async {
    RelativeRect position = RelativeRect.fromLTRB(
        details.globalPosition.dx, details.globalPosition.dy, 0, 0);
    Function()? selectedAction = await showMenu(
      context: context,
      position: position,
      items: getMenuItems(dictionary),
    );

    selectedAction?.call();
  }

  List<PopupMenuItem<VoidCallback>> getMenuItems(Dictionary dictionary) {
    return [
      buildPopupItem(
        label: dictionary.isCollapsed(appModel.targetLanguage)
            ? t.options_expand
            : t.options_collapse,
        icon: dictionary.isCollapsed(appModel.targetLanguage)
            ? Icons.open_in_full
            : Icons.close_fullscreen,
        action: () {
          appModel.toggleDictionaryCollapsed(dictionary);
          _notifiersByDictionary[dictionary]!.value =
              !_notifiersByDictionary[dictionary]!.value;
          _notifiersByDictionary[dictionary]!.value =
              !_notifiersByDictionary[dictionary]!.value;
        },
      ),
      buildPopupItem(
        label: dictionary.isHidden(appModel.targetLanguage)
            ? t.options_show
            : t.options_hide,
        icon: dictionary.isCollapsed(appModel.targetLanguage)
            ? Icons.visibility
            : Icons.visibility_off,
        action: () {
          appModel.toggleDictionaryHidden(dictionary);
          _notifiersByDictionary[dictionary]!.value =
              !_notifiersByDictionary[dictionary]!.value;
          _notifiersByDictionary[dictionary]!.value =
              !_notifiersByDictionary[dictionary]!.value;
        },
      ),
      // Dictionaries installed before English search existed: a one-time
      // build of their English index. Imports from now on index
      // themselves, so this disappears once done.
      if (appModel.needsGlossIndex(dictionary))
        buildPopupItem(
          label: t.gloss_index_option,
          icon: Icons.translate,
          action: () => buildGlossIndex(dictionary),
        ),
      buildPopupItem(
        label: t.options_delete,
        icon: Icons.delete,
        action: () {
          showDictionaryDeleteDialog(dictionary);
        },
        color: theme.colorScheme.primary,
      ),
    ];
  }

  final _formatNotifier = ChangeNotifier();

  Widget buildImportDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: Spacing.of(context).insets.onlyLeft.small,
          child: Text(
            t.import_format,
            style: TextStyle(
              fontSize: 10,
              color: theme.unselectedWidgetColor,
            ),
          ),
        ),
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ChangeNotifierBuilder(
              notifier: _formatNotifier,
              builder: (_, _, _) => JidoujishoDropdown<DictionaryFormat>(
                options: appModel.dictionaryFormats.values.toList(),
                initialOption: appModel.lastSelectedDictionaryFormat,
                generateLabel: (format) => format.name,
                onChanged: (format) {
                  appModel.setLastSelectedDictionaryFormat(format!);
                  _formatNotifier.notifyListeners();
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border.fromBorderSide(
                  BorderSide(
                    width: 0.5,
                    color: Theme.of(context).unselectedWidgetColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
