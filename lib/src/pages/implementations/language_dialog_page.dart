import 'package:flutter/material.dart';
import 'package:spaces/spaces.dart';
import 'package:shiroikumanojisho/language.dart';
import 'package:shiroikumanojisho/pages.dart';
import 'package:shiroikumanojisho/utils.dart';

/// The content of the dialog used for changing the target language or app
/// locale.
class LanguageDialogPage extends BasePage {
  /// Create an instance of this page.
  const LanguageDialogPage({
    required this.isFirstTimeSetup,
    super.key,
  });

  /// Whether or not it is the first time setup.
  final bool isFirstTimeSetup;

  @override
  BasePageState createState() => _LanguageDialogPageState();
}

class _LanguageDialogPageState extends BasePageState<LanguageDialogPage> {
  @override
  Widget build(BuildContext context) {
    return PillDialog(
      title: widget.isFirstTimeSetup ? Text(t.first_time_setup) : null,
      titlePadding: Spacing.of(context)
          .insets
          .all
          .big
          .copyWith(bottom: Spacing.of(context).spaces.semiBig),
      contentPadding: widget.isFirstTimeSetup
          ? Spacing.of(context).insets.horizontal.big
          : MediaQuery.of(context).orientation == Orientation.portrait
              ? Spacing.of(context).insets.exceptBottom.big
              : Spacing.of(context).insets.exceptBottom.normal,
      content: buildContent(),
      actions: actions,
    );
  }

  List<Widget> get actions => [
        buildCloseButton(),
      ];

  Widget buildCloseButton() {
    return TextButton(
      child: Text(t.dialog_close),
      onPressed: () => Navigator.pop(context),
    );
  }

  void _showCustomLanguageDialog() async {
    final result = await showDialog<CustomLanguage>(
      context: context,
      builder: (ctx) => _CustomLanguageConfigDialog(
        existing: appModel.targetLanguage is CustomLanguage
            ? appModel.targetLanguage as CustomLanguage
            : null,
      ),
    );
    if (result != null) {
      await CustomLanguage.saveConfig(
          appModel.preferences, result);
      appModel.populateLanguages();
      appModel.setTargetLanguage(result);
      appModel.clearDictionaryResultsCache();
      if (mounted) setState(() {});
    }
  }

  Widget buildContent() {
    ScrollController contentController = ScrollController();

    return SizedBox(
      width: double.maxFinite,
      child: RawScrollbar(
        thumbVisibility: true,
        thickness: 3,
        controller: contentController,
        child: SingleChildScrollView(
          controller: contentController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isFirstTimeSetup)
                Text(
                  t.first_time_setup_description,
                  style: TextStyle(
                    fontSize: textTheme.bodySmall?.fontSize,
                  ),
                  textAlign: TextAlign.justify,
                ),
              if (widget.isFirstTimeSetup) const Space.semiBig(),
              Padding(
                padding: Spacing.of(context).insets.onlyLeft.small,
                child: Text(
                  t.target_language,
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.unselectedWidgetColor,
                  ),
                ),
              ),
              JidoujishoDropdown<Language>(
                options: appModel.languages.values.toList(),
                initialOption: appModel.targetLanguage,
                generateLabel: (language) => language.languageName,
                onChanged: (language) {
                  appModel.setTargetLanguage(language!);
                  appModel.clearDictionaryResultsCache();
                  setState(() {});
                },
              ),
              const Space.small(),
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add custom language'),
                  onPressed: _showCustomLanguageDialog,
                ),
              ),
              const Space.small(),
              Padding(
                padding: Spacing.of(context).insets.onlyLeft.small,
                child: Text(
                  t.app_locale,
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.unselectedWidgetColor,
                  ),
                ),
              ),
              JidoujishoDropdown<String>(
                options: JidoujishoLocalisations.localeNames.keys.toList(),
                initialOption: appModel.appLocale.toLanguageTag(),
                generateLabel: (languageTag) =>
                    JidoujishoLocalisations.localeNames[languageTag]!,
                onChanged: (languageTag) {
                  appModel.setAppLocale(languageTag!);
                  setState(() {});
                },
              ),
              const Space.small(),
              ListTile(
                dense: true,
                title: Text.rich(
                  TextSpan(
                    text: '',
                    children: <InlineSpan>[
                      WidgetSpan(
                        child: Icon(
                          Icons.info,
                          size: textTheme.bodySmall?.fontSize,
                        ),
                      ),
                      const WidgetSpan(
                        child: SizedBox(width: 8),
                      ),
                      TextSpan(
                        text: t.app_locale_warning,
                        style: TextStyle(
                          fontSize: textTheme.bodySmall?.fontSize,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog for configuring a custom language.
class _CustomLanguageConfigDialog extends StatefulWidget {
  const _CustomLanguageConfigDialog({this.existing});
  final CustomLanguage? existing;

  @override
  State<_CustomLanguageConfigDialog> createState() =>
      _CustomLanguageConfigDialogState();
}

class _CustomLanguageConfigDialogState
    extends State<_CustomLanguageConfigDialog> {
  late TextEditingController _nameCtrl;
  late TextEditingController _codeCtrl;
  late TextEditingController _countryCtrl;
  late TextEditingController _threeCtrl;
  late TextEditingController _helloCtrl;
  late TextEditingController _fontCtrl;
  bool _rtl = false;
  bool _vertical = false;
  bool _spaceDelimited = true;
  bool _ideographic = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.languageName ?? '');
    _codeCtrl = TextEditingController(text: e?.languageCode ?? '');
    _countryCtrl = TextEditingController(text: e?.countryCode ?? '');
    _threeCtrl = TextEditingController(text: e?.threeLetterCode ?? '');
    _helloCtrl = TextEditingController(text: e?.helloWorld ?? '');
    _fontCtrl = TextEditingController(
        text: e?.defaultFontFamily ?? 'Roboto');
    if (e != null) {
      _rtl = e.textDirection == TextDirection.rtl;
      _vertical = e.preferVerticalReading;
      _spaceDelimited = e.isSpaceDelimited;
      _ideographic = e.textBaseline == TextBaseline.ideographic;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _countryCtrl.dispose();
    _threeCtrl.dispose();
    _helloCtrl.dispose();
    _fontCtrl.dispose();
    super.dispose();
  }

  void _applyPreset(LanguagePreset p) {
    setState(() {
      _nameCtrl.text = p.name.split('(').last.replaceAll(')', '').trim();
      _codeCtrl.text = p.code;
      _countryCtrl.text = p.country;
      _threeCtrl.text = p.threeLetterCode;
      _helloCtrl.text = p.hello;
      _fontCtrl.text = p.font;
      _rtl = p.rtl;
      _vertical = p.vertical;
      _spaceDelimited = p.spaceDelimited;
      _ideographic = p.ideographic;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PillDialog(
      title: const Text('Custom language'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preset picker
              DropdownButton<LanguagePreset>(
                isExpanded: true,
                hint: const Text('Load from preset...'),
                items: LanguagePreset.presets
                    .map((p) => DropdownMenuItem(
                        value: p, child: Text(p.name, overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (p) {
                  if (p != null) _applyPreset(p);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Language name',
                  helperText: 'e.g. Français, Español',
                ),
              ),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _codeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'ISO 639-1',
                      helperText: 'e.g. fr, es',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _countryCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Country',
                      helperText: 'e.g. FR, ES',
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _threeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'ISO 639-3',
                      helperText: 'e.g. fra, spa',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _fontCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Default font',
                      helperText: 'e.g. Roboto',
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              TextField(
                controller: _helloCtrl,
                decoration: const InputDecoration(
                  labelText: 'Test text',
                  helperText: 'e.g. Hello world',
                ),
              ),
              const SizedBox(height: 12),
              // Boolean toggles
              _toggle('Right-to-left', _rtl, (v) => setState(() => _rtl = v)),
              _toggle('Prefer vertical reading', _vertical,
                  (v) => setState(() => _vertical = v)),
              _toggle('Space-delimited', _spaceDelimited,
                  (v) => setState(() => _spaceDelimited = v)),
              _toggle('Ideographic baseline', _ideographic,
                  (v) => setState(() => _ideographic = v)),
              const SizedBox(height: 8),
              Text(
                'Locale: ${_codeCtrl.text}-${_countryCtrl.text}',
                style: TextStyle(
                    fontSize: 12, color: Theme.of(context).hintColor),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_nameCtrl.text.trim().isEmpty ||
                _codeCtrl.text.trim().isEmpty) {
              return;
            }
            final lang = CustomLanguage(
              languageName: _nameCtrl.text.trim(),
              languageCode: _codeCtrl.text.trim().toLowerCase(),
              countryCode: _countryCtrl.text.trim().toUpperCase(),
              threeLetterCode: _threeCtrl.text.trim().toLowerCase(),
              textDirection: _rtl ? TextDirection.rtl : TextDirection.ltr,
              preferVerticalReading: _vertical,
              isSpaceDelimited: _spaceDelimited,
              textBaseline: _ideographic
                  ? TextBaseline.ideographic
                  : TextBaseline.alphabetic,
              helloWorld: _helloCtrl.text.trim(),
              defaultFontFamily: _fontCtrl.text.trim(),
            );
            Navigator.pop(context, lang);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontSize: 13)),
      trailing: PillSwitch(value: value, onChanged: onChanged),
      onTap: () => onChanged(!value),
    );
  }
}
