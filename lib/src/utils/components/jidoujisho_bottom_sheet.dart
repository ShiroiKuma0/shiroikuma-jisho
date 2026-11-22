import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shiroikumanojisho/src/utils/components/pills.dart';

/// An option to show in a bottom sheet.
class JidoujishoBottomSheetOption {
  /// Defines an option in a bottom sheet.
  JidoujishoBottomSheetOption({
    required this.label,
    required this.icon,
    required this.action,
    this.active = false,
    this.iconColor,
    this.role,
    this.opens = false,
    this.toggle = false,
  });

  /// Label to display in the option.
  String label;

  /// Icon to display left of the label.
  IconData icon;

  /// In a list of choices, whether this is the chosen one; on a
  /// [toggle] row, whether the setting is on.
  bool active;

  /// Overrides the role colour of the icon — e.g. the green tick on
  /// an already-OCRed subtitle track.
  Color? iconColor;

  /// What the option does; its icon takes the colour of the role. Told
  /// from [icon] when not given — see [menuRoleForIcon].
  MenuRole? role;

  /// Whether the option opens a dialog, a picker or another sheet; the
  /// row then ends in a ›.
  bool opens;

  /// Whether the option switches a setting on or off in place. Such a
  /// row is plain, with the outlined switch at its right showing
  /// [active], instead of a pill.
  bool toggle;

  /// Action to perform upon selecting the option.
  FutureOr<void> Function() action;
}

/// A bottom sheet of options in the black-yellow look: every action a
/// pill as wide as the sheet with its icon coloured by what it does,
/// every toggle a plain row with the outlined switch.
///
/// The sheet is only as wide as its longest row needs — on a wide
/// screen a column of short labels stretched from edge to edge read as
/// a banner (白い熊, 2026-11-22). Show it with a transparent
/// `backgroundColor` and no elevation, since it draws its own panel.
class JidoujishoBottomSheet extends StatelessWidget {
  /// Initialise a bottom sheet.
  const JidoujishoBottomSheet({
    required this.options,
    this.scrollToExtent = true,
    super.key,
  });

  /// Options to show in the bottom sheet.
  final List<JidoujishoBottomSheetOption> options;

  /// Whether or not to scroll to bottom.
  final bool scrollToExtent;

  /// The sheet is never narrower than this, so a list of two-word
  /// options is still an easy target.
  static const double _minWidth = 280;

  @override
  Widget build(BuildContext context) {
    final PillTheme pills = PillTheme.of(context);

    ScrollController scrollController = ScrollController();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients && scrollToExtent) {
        scrollController.jumpTo(
          scrollController.position.maxScrollExtent,
        );
      }
    });

    // The sheet carries the black/yellow identity like dialogs do: a
    // frame in the pill colour around the whole panel (dark theme).
    final Widget panel = Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Theme.of(context).brightness == Brightness.dark
            ? Border.all(color: pills.frame, width: 2)
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: IntrinsicWidth(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: _minWidth),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final option in options)
                  _SheetRow(option: option, pills: pills),
              ],
            ),
          ),
        ),
      ),
    );

    // The modal sheet spans the screen; what is left beside the panel
    // behaves like the barrier above it and closes the sheet.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).maybePop(),
      child: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1,
          child: GestureDetector(
            onTap: () {},
            child: panel,
          ),
        ),
      ),
    );
  }
}

/// One option of the sheet.
class _SheetRow extends StatelessWidget {
  const _SheetRow({required this.option, required this.pills});

  final JidoujishoBottomSheetOption option;
  final PillTheme pills;

  Future<void> _run(BuildContext context) async {
    Navigator.of(context).pop();
    await option.action();
  }

  @override
  Widget build(BuildContext context) {
    final MenuRole role = option.role ?? menuRoleForIcon(option.icon);
    final bool destructive = role == MenuRole.delete;
    // A chosen row of a choice list keeps the red 白い熊 picked for it,
    // on label, icon and tick; the frame stays in the pill colour.
    final bool chosen = option.active && !option.toggle;
    final Color rowColor = chosen || destructive
        ? pills.role(MenuRole.delete)
        : pills.label;
    final Color frame = destructive ? rowColor : pills.frame;
    final TextStyle? base = Theme.of(context).textTheme.bodyMedium;
    final double size = (base?.fontSize ?? 14) + 6;

    final Widget content = Row(
      children: [
        Icon(
          option.icon,
          size: size,
          color: option.iconColor ?? (chosen ? rowColor : pills.role(role)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            option.label,
            softWrap: true,
            style: base?.copyWith(
              color: rowColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        if (option.toggle) ...[
          const SizedBox(width: 12),
          IgnorePointer(
            child: PillSwitch(
              value: option.active,
              onChanged: (_) {},
              compact: true,
            ),
          ),
        ] else if (chosen) ...[
          const SizedBox(width: 12),
          Icon(Icons.check, size: size, color: rowColor),
        ] else if (option.opens) ...[
          const SizedBox(width: 12),
          Text('›',
              style: TextStyle(fontSize: size + 2, height: 1, color: rowColor)),
        ],
      ],
    );

    const shape = StadiumBorder();
    final Widget row;
    if (option.toggle) {
      row = InkWell(
        onTap: () => _run(context),
        customBorder: shape,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 36),
          child: Padding(
            padding: const EdgeInsets.only(left: 14),
            child: content,
          ),
        ),
      );
    } else {
      row = Material(
        type: MaterialType.transparency,
        shape: StadiumBorder(
          side: BorderSide(color: frame, width: kPillRegularWidth),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _run(context),
          customBorder: shape,
          splashColor: rowColor.withValues(alpha: 0.3),
          highlightColor: rowColor.withValues(alpha: 0.15),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 42),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: content,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: row,
    );
  }
}
