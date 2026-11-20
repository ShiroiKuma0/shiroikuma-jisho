import 'package:flutter/material.dart';
import 'package:shiroikumanojisho/i18n/strings.g.dart';

/// The black-yellow look every 白い熊 app shares, in one place: outlined
/// pill buttons, the outlined switch, and menu rows drawn as full-width
/// pills with an icon coloured by what the row does.
///
/// Nothing here is ever filled. A main action is told from the others by
/// weight only — a 3 dp frame and a bold label against 1.25 dp and normal.

/// What a menu row does; its icon takes the colour of the role.
enum MenuRole {
  /// Starts or connects something: play, load, launch, download.
  call,

  /// Writes or marks: edit, rename, add.
  message,

  /// About a person or profile.
  contact,

  /// Copies, shares, exports, backs up.
  share,

  /// Views, opens a page or settings. The accent.
  view,

  /// Hides, mutes, stops, closes.
  block,

  /// Deletes or clears. Lends its colour to frame and label too.
  delete,
}

/// The colour roles the pill widgets draw with, carried by the theme so
/// every screen follows the 白い熊 辞書 UI page without asking for it.
@immutable
class PillTheme extends ThemeExtension<PillTheme> {
  /// Initialise the roles.
  const PillTheme({
    required this.frame,
    required this.label,
    required this.background,
    required this.switchOn,
    required this.switchOff,
    required this.roles,
  });

  /// Pill outlines.
  final Color frame;

  /// Pill labels.
  final Color label;

  /// What shows through a pill.
  final Color background;

  /// A switch that is on.
  final Color switchOn;

  /// A switch that is off: a darker, opaque shade — never a faded one.
  final Color switchOff;

  /// Icon colour per role.
  final Map<MenuRole, Color> roles;

  /// The group divider of a menu: 70 % of the way from the background
  /// to the frame colour, opaque.
  Color get divider => Color.lerp(background, frame, 0.7)!;

  /// Icon colour for [role]; the label colour when it has none.
  Color role(MenuRole? role) => roles[role] ?? label;

  /// The roles of the surrounding theme.
  static PillTheme of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<PillTheme>() ??
        PillTheme(
          frame: theme.colorScheme.primary,
          label: theme.colorScheme.primary,
          background: theme.colorScheme.surface,
          switchOn: theme.colorScheme.primary,
          switchOff: theme.colorScheme.primary.withValues(alpha: 0.55),
          roles: const {},
        );
  }

  @override
  PillTheme copyWith() => this;

  @override
  PillTheme lerp(ThemeExtension<PillTheme>? other, double t) =>
      other is PillTheme && t >= 0.5 ? other : this;
}

/// Frame width of the main action of a block.
const double kPillMainWidth = 3;

/// Frame width of every other action.
const double kPillRegularWidth = 1.25;

/// The style of a pill button. [base] is the full label style — a
/// button's text style replaces the inherited one rather than merging
/// with it, so the family has to come along. [color] recolours frame and
/// label alike: a destructive action stays unfilled, just red.
ButtonStyle pillButtonStyle({
  required PillTheme pills,
  required TextStyle? base,
  bool main = false,
  Color? color,
}) {
  final frame = color ?? pills.frame;
  final label = color ?? pills.label;
  final width = main ? kPillMainWidth : kPillRegularWidth;
  return TextButton.styleFrom(
    foregroundColor: label,
    disabledForegroundColor: label.withValues(alpha: 0.38),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    minimumSize: const Size(0, 36),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    shape: const StadiumBorder(),
    textStyle: (base ?? const TextStyle()).copyWith(
      fontWeight: main ? FontWeight.bold : FontWeight.normal,
    ),
  ).copyWith(
    side: WidgetStateProperty.resolveWith(
      (states) => BorderSide(
        color: states.contains(WidgetState.disabled)
            ? frame.withValues(alpha: 0.38)
            : frame,
        width: width,
      ),
    ),
    overlayColor: WidgetStateProperty.all(label.withValues(alpha: 0.3)),
  );
}

/// An [AlertDialog] whose buttons follow the pill rule without each call
/// site saying so: the one action that is not a way out (Cancel, Close,
/// No…) is the main pill, the rest are regular, and an action whose
/// label was given a colour keeps it on frame and label.
class PillDialog extends AlertDialog {
  /// Same arguments as [AlertDialog].
  PillDialog({
    super.key,
    super.icon,
    super.iconPadding,
    super.iconColor,
    super.title,
    super.titlePadding,
    super.titleTextStyle,
    super.content,
    super.contentPadding,
    super.contentTextStyle,
    List<Widget>? actions,
    super.actionsPadding,
    super.actionsAlignment,
    super.actionsOverflowAlignment,
    super.actionsOverflowDirection,
    super.actionsOverflowButtonSpacing = 6,
    super.buttonPadding,
    super.backgroundColor,
    super.elevation,
    super.shadowColor,
    super.surfaceTintColor,
    super.semanticLabel,
    super.insetPadding,
    super.clipBehavior,
    super.shape,
    super.alignment,
    super.constraints,
    super.scrollable,
  }) : super(actions: pillActions(actions));

  /// Labels that only leave the dialog; such a button is never the main
  /// one.
  static bool _isWayOut(String label) {
    final upper = label.trim().toUpperCase();
    return const {
          'CANCEL',
          'CLOSE',
          'NO',
          'BACK',
          'SKIP',
          'LATER',
          'NOT NOW',
          'DISMISS',
        }.contains(upper) ||
        upper == t.dialog_cancel.toUpperCase() ||
        upper == t.dialog_close.toUpperCase() ||
        upper == t.dialog_skip.toUpperCase();
  }

  /// Labels that destroy something; such a button is drawn in the
  /// delete colour, frame and label alike.
  static bool _isDestructive(String label) {
    final upper = label.trim().toUpperCase();
    return const {
          'DELETE',
          'CLEAR',
          'PURGE',
          'REMOVE',
          'WIPE',
          'RESET',
          'DISCARD',
          'OVERWRITE',
        }.contains(upper) ||
        upper == t.dialog_delete.toUpperCase() ||
        upper == t.dialog_clear.toUpperCase();
  }

  static String? _labelOf(Widget action) {
    if (action is! ButtonStyleButton) {
      return null;
    }
    final child = action.child;
    return child is Text ? child.data : null;
  }

  static Color? _colorOf(Widget action) {
    if (action is! ButtonStyleButton) {
      return null;
    }
    final child = action.child;
    return child is Text ? child.style?.color : null;
  }

  /// Wraps each of [actions] so it draws as the pill its role calls for.
  static List<Widget>? pillActions(List<Widget>? actions) {
    if (actions == null) {
      return null;
    }
    final candidates = actions.where((action) {
      final label = _labelOf(action);
      return label != null && !_isWayOut(label);
    }).toList();
    final main = candidates.length == 1 ? candidates.single : null;
    return [
      for (final action in actions)
        if (action is ButtonStyleButton)
          _PillAction(
            main: identical(action, main),
            color: _colorOf(action),
            destructive: _isDestructive(_labelOf(action) ?? ''),
            child: action,
          )
        else
          action,
    ];
  }
}

class _PillAction extends StatelessWidget {
  const _PillAction({
    required this.child,
    required this.main,
    required this.destructive,
    this.color,
  });

  final ButtonStyleButton child;
  final bool main;
  final bool destructive;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (destructive) {
      // Rebuilt rather than wrapped: the label often carries a colour
      // of its own, which a surrounding style cannot take back.
      final label = child.child;
      return TextButton(
        onPressed: child.onPressed,
        onLongPress: child.onLongPress,
        style: pillButtonStyle(
          pills: PillTheme.of(context),
          base: Theme.of(context).textTheme.labelLarge,
          main: main,
          color: PillTheme.of(context).role(MenuRole.delete),
        ),
        child: Text(label is Text ? label.data ?? '' : ''),
      );
    }
    return TextButtonTheme(
      data: TextButtonThemeData(
        style: pillButtonStyle(
          pills: PillTheme.of(context),
          base: Theme.of(context).textTheme.labelLarge,
          main: main,
          color: color,
        ),
      ),
      child: child,
    );
  }
}

/// The theme's switch: an outlined pill with the background showing
/// through and a solid dot inside it — right when on, left when off.
/// Only the brightness and the dot's side change between the states.
class PillSwitch extends StatelessWidget {
  /// Same contract as [Switch]: a null [onChanged] disables it.
  const PillSwitch({
    required this.value,
    required this.onChanged,
    this.compact = false,
    super.key,
  });

  /// Whether the switch is on.
  final bool value;

  /// Called with the new value on a tap.
  final ValueChanged<bool>? onChanged;

  /// The smaller size that sits in a menu row.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final pills = PillTheme.of(context);
    final size = compact ? const Size(44, 24) : const Size(52, 28);
    final enabled = onChanged != null;
    return Semantics(
      toggled: value,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? () => onChanged!(!value) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Opacity(
            opacity: enabled ? 1 : 0.38,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: value ? 1 : 0),
              duration: const Duration(milliseconds: 180),
              curve: Curves.decelerate,
              builder: (context, position, _) => CustomPaint(
                size: size,
                painter: _PillSwitchPainter(
                  position: position,
                  color: Color.lerp(
                      pills.switchOff, pills.switchOn, position)!,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PillSwitchPainter extends CustomPainter {
  _PillSwitchPainter({required this.position, required this.color});

  final double position;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 2.0;
    final track = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(stroke / 2),
      Radius.circular(size.height / 2),
    );
    canvas.drawRRect(
      track,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = color,
    );
    final radius = size.height * 0.46 / 2;
    // The dot keeps the same gap to the frame all round.
    final edge = size.height / 2;
    final x = edge + (size.width - 2 * edge) * position;
    canvas.drawCircle(Offset(x, size.height / 2), radius, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_PillSwitchPainter old) =>
      old.position != position || old.color != color;
}

/// What a menu row does, told from the icon it was given. Call sites
/// mostly name only an icon, so this is the one table that colours every
/// menu; a row can still pass its role outright.
MenuRole menuRoleForIcon(IconData? icon) {
  if (icon == null) {
    return MenuRole.view;
  }
  if (_deleteIcons.contains(icon)) {
    return MenuRole.delete;
  }
  if (_shareIcons.contains(icon)) {
    return MenuRole.share;
  }
  if (_callIcons.contains(icon)) {
    return MenuRole.call;
  }
  if (_messageIcons.contains(icon)) {
    return MenuRole.message;
  }
  if (_contactIcons.contains(icon)) {
    return MenuRole.contact;
  }
  if (_blockIcons.contains(icon)) {
    return MenuRole.block;
  }
  return MenuRole.view;
}

final Set<IconData> _deleteIcons = <IconData>{
  Icons.delete,
  Icons.delete_outline,
  Icons.delete_forever,
  Icons.delete_sweep,
  Icons.clear_all,
  Icons.cleaning_services,
  Icons.remove_circle,
  Icons.remove_circle_outline,
  Icons.playlist_remove,
};

final Set<IconData> _shareIcons = <IconData>{
  Icons.copy,
  Icons.copy_all,
  Icons.share,
  Icons.ios_share,
  Icons.backup,
  Icons.restore,
  Icons.save,
  Icons.save_alt,
  Icons.file_upload,
  Icons.file_download,
  Icons.upload,
  Icons.upload_file,
  Icons.import_export,
  Icons.send,
  Icons.note_add,
  Icons.sd_card,
  Icons.table_rows,
  Icons.table_chart,
  Icons.style,
};

final Set<IconData> _callIcons = <IconData>{
  Icons.play_arrow,
  Icons.play_circle,
  Icons.download,
  Icons.cloud_download,
  Icons.refresh,
  Icons.sync,
  Icons.launch,
  Icons.open_in_new,
  Icons.open_in_browser,
  Icons.search,
  Icons.volume_up,
  Icons.record_voice_over,
  Icons.code,
  Icons.document_scanner,
};

final Set<IconData> _messageIcons = <IconData>{
  Icons.edit,
  Icons.edit_note,
  Icons.mode_edit,
  Icons.drive_file_rename_outline,
  Icons.add,
  Icons.add_circle,
  Icons.add_circle_outline,
  Icons.playlist_add,
  Icons.bookmark,
  Icons.bookmark_add,
  Icons.star,
  Icons.translate,
  Icons.auto_fix_high,
  Icons.text_fields,
  Icons.format_color_text,
  Icons.auto_stories_rounded,
};

final Set<IconData> _contactIcons = <IconData>{
  Icons.person,
  Icons.switch_account,
  Icons.account_circle,
  Icons.account_box,
  Icons.group,
};

final Set<IconData> _blockIcons = <IconData>{
  Icons.visibility_off,
  Icons.hide_source,
  Icons.block,
  Icons.volume_off,
  Icons.stop,
  Icons.close,
  Icons.cancel,
  Icons.unfold_less,
  Icons.timer_off,
};

/// A menu row. An action row is an outlined pill as wide as the menu,
/// its icon inside at the left and a › at the right when it opens
/// something; a row with [checked] set is a toggle and stays plain, with
/// the outlined switch at its right.
class PillMenuItem<T> extends PopupMenuItem<T> {
  /// [role] defaults to what [icon] suggests — see [menuRoleForIcon].
  const PillMenuItem({
    required this.label,
    super.key,
    super.value,
    super.onTap,
    super.enabled,
    this.icon,
    this.role,
    this.opens = false,
    this.checked,
    this.iconColumn = true,
    this.trailing,
  }) : super(
          child: null,
          padding: EdgeInsets.zero,
          height: 0,
        );

  /// The row's words. Long ones wrap inside the pill.
  final String label;

  /// The row's icon, coloured by [role].
  final IconData? icon;

  /// What the row does. [MenuRole.delete] also colours frame and label.
  final MenuRole? role;

  /// Whether the row opens a screen, dialog, picker or submenu.
  final bool opens;

  /// Non-null makes this a toggle row showing this state.
  final bool? checked;

  /// Keep the icon column when [icon] is null, so labels share one
  /// edge. False only for lists where no row has an icon.
  final bool iconColumn;

  /// Something to show at the row's right end instead of the ›.
  final Widget? trailing;

  @override
  PopupMenuItemState<T, PillMenuItem<T>> createState() =>
      _PillMenuItemState<T>();
}

class _PillMenuItemState<T>
    extends PopupMenuItemState<T, PillMenuItem<T>> {
  @override
  Widget build(BuildContext context) {
    final pills = PillTheme.of(context);
    final role = widget.role ?? menuRoleForIcon(widget.icon);
    final destructive = role == MenuRole.delete;
    final rowColor = destructive ? pills.role(MenuRole.delete) : pills.label;
    final frame = destructive ? rowColor : pills.frame;
    final toggle = widget.checked != null;
    final base = Theme.of(context).textTheme.bodyMedium;
    final size = (base?.fontSize ?? 14) + 6;

    final content = Row(
      children: [
        if (widget.icon != null)
          Icon(widget.icon, size: size, color: pills.role(role))
        else if (widget.iconColumn)
          SizedBox(width: size),
        if (widget.icon != null || widget.iconColumn)
          const SizedBox(width: 10),
        Expanded(
          child: Text(
            widget.label,
            softWrap: true,
            style: base?.copyWith(
              color: rowColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        if (toggle) ...[
          const SizedBox(width: 8),
          IgnorePointer(
            child: PillSwitch(
              value: widget.checked!,
              onChanged: (_) {},
              compact: true,
            ),
          ),
        ] else if (widget.trailing != null) ...[
          const SizedBox(width: 8),
          widget.trailing!,
        ] else if (widget.opens) ...[
          const SizedBox(width: 8),
          Text('›',
              style: TextStyle(fontSize: size + 2, height: 1, color: rowColor)),
        ],
      ],
    );

    const shape = StadiumBorder();
    final Widget row;
    if (toggle) {
      row = InkWell(
        onTap: widget.enabled ? handleTap : null,
        customBorder: shape,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 36),
          child: Padding(
            padding: const EdgeInsets.only(left: 14, right: 0),
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
          onTap: widget.enabled ? handleTap : null,
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

    return Semantics(
      enabled: widget.enabled,
      button: true,
      child: Opacity(
        opacity: widget.enabled ? 1 : 0.38,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: row,
        ),
      ),
    );
  }
}

/// The line between two groups of a menu: 1 dp, a clear darker accent,
/// its ends on the pill edges.
class PillMenuDivider extends PopupMenuEntry<Never> {
  /// Create the divider.
  const PillMenuDivider({super.key});

  @override
  double get height => 9;

  @override
  bool represents(void value) => false;

  @override
  State<PillMenuDivider> createState() => _PillMenuDividerState();
}

class _PillMenuDividerState extends State<PillMenuDivider> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Container(height: 1, color: PillTheme.of(context).divider),
    );
  }
}

/// An icon coloured by what its row does — the leading icon of a list
/// row, a drawer entry or a sheet option. See [menuRoleForIcon].
class RoleIcon extends StatelessWidget {
  /// [role] defaults to what [icon] suggests.
  const RoleIcon(this.icon, {this.role, this.size, super.key});

  /// The glyph.
  final IconData icon;

  /// What the row does.
  final MenuRole? role;

  /// Icon size; the surrounding icon theme's when null.
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size,
      color: PillTheme.of(context).role(role ?? menuRoleForIcon(icon)),
    );
  }
}
