import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:spaces/spaces.dart';
import 'package:shiroikumanojisho/dictionary.dart';
import 'package:shiroikumanojisho/pages.dart';
import 'package:shiroikumanojisho/utils.dart';

/// Lists the dictionaries in [AppModel.dictionaryCatalog] with a checkbox
/// each, then downloads and imports the ticked ones in order. Shown from the
/// dictionary menu, and once after first-time setup so a fresh install can
/// look words up without the user finding dictionary zips first.
class DictionaryDownloadDialogPage extends BasePage {
  /// Create an instance of this page.
  const DictionaryDownloadDialogPage({
    this.isFirstTimeSetup = false,
    super.key,
  });

  /// Whether this is the offer made after first-time setup, which can be
  /// skipped, rather than the dialog opened from the dictionary menu.
  final bool isFirstTimeSetup;

  @override
  BasePageState createState() => _DictionaryDownloadDialogPageState();
}

class _DictionaryDownloadDialogPageState
    extends BasePageState<DictionaryDownloadDialogPage> {
  late final Set<CatalogDictionary> _selected = appModel.dictionaryCatalog
      .where((entry) =>
          entry.recommended && !appModel.isCatalogDictionaryInstalled(entry))
      .toSet();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isFirstTimeSetup
          ? t.download_dictionaries_first_time
          : t.download_dictionaries),
      contentPadding: Spacing.of(context).insets.exceptBottom.big,
      content: buildContent(),
      actions: [
        TextButton(
          child: Text(widget.isFirstTimeSetup ? t.dialog_skip : t.dialog_cancel),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          onPressed: _selected.isEmpty ? null : download,
          child: Text(t.dialog_download),
        ),
      ],
    );
  }

  Widget buildContent() {
    final int megabytes = _selected.fold<int>(
        0, (sum, entry) => sum + entry.approximateMegabytes);

    return SizedBox(
      width: double.maxFinite,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.download_dictionaries_explanation,
              style: TextStyle(
                fontSize: textTheme.bodySmall?.fontSize,
                color: theme.unselectedWidgetColor,
              ),
            ),
            const Space.normal(),
            ...appModel.dictionaryCatalog.map(buildEntry),
            const Space.normal(),
            Text(
              t.download_dictionaries_total(megabytes: megabytes),
              style: TextStyle(fontSize: textTheme.bodySmall?.fontSize),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEntry(CatalogDictionary entry) {
    final bool installed = appModel.isCatalogDictionaryInstalled(entry);

    // An installed dictionary gets no checkbox at all: a ticked box, even
    // a disabled one, reads as "will be downloaded". An invisible checkbox
    // keeps its text aligned with the others.
    if (installed) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        enabled: false,
        leading: const Visibility(
          visible: false,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: Checkbox(value: false, onChanged: null),
        ),
        title: Text(t.download_dictionary_installed(name: entry.name)),
        subtitle: Text(entry.description),
      );
    }

    // CheckboxListTile wraps title and subtitle, so long descriptions fit
    // the ~720 px Palma screen instead of clipping.
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      value: _selected.contains(entry),
      onChanged: (value) {
        setState(() {
          if (value ?? false) {
            _selected.add(entry);
          } else {
            _selected.remove(entry);
          }
        });
      },
      title: Text(t.download_dictionary_entry(
          name: entry.name, megabytes: entry.approximateMegabytes)),
      subtitle: Text(entry.description),
    );
  }

  Future<void> download() async {
    final List<CatalogDictionary> queue = appModel.dictionaryCatalog
        .where(_selected.contains)
        .toList();

    final ValueNotifier<String> progressNotifier =
        ValueNotifier<String>(t.import_start);
    final ValueNotifier<int?> countNotifier = ValueNotifier<int?>(null);
    final ValueNotifier<int?> totalNotifier =
        ValueNotifier<int?>(queue.length);

    // The progress dialog goes on top of this one, and both close only when
    // every download has finished — the caller refreshes the dictionary
    // list when this dialog's route completes.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DictionaryDialogImportPage(
        progressNotifier: progressNotifier,
        countNotifier: countNotifier,
        totalNotifier: totalNotifier,
      ),
    );

    int failures = 0;
    for (int i = 0; i < queue.length; i++) {
      countNotifier.value = i + 1;
      final bool imported = await appModel.downloadAndImportCatalogDictionary(
        entry: queue[i],
        progressNotifier: progressNotifier,
        onImportSuccess: () {},
      );
      if (!imported) {
        failures++;
      }
    }

    if (failures > 0) {
      Fluttertoast.showToast(
        msg: t.download_dictionaries_failed(n: failures),
        toastLength: Toast.LENGTH_LONG,
      );
    }

    if (mounted) {
      Navigator.pop(context);
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }
}
