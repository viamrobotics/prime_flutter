import 'package:flutter/widgets.dart';

import '../theme/prime_theme.dart';
import 'floating.dart';
import 'internal/pressable.dart';
import 'prime_icons.dart';

enum MenuItemVariant { normal, danger }

/// Lets items close the menu they sit in.
class _MenuScope extends InheritedWidget {
  final VoidCallback close;

  const _MenuScope({required this.close, required super.child});

  static VoidCallback? closeOf(BuildContext context) => context.getInheritedWidgetOfExactType<_MenuScope>()?.close;

  @override
  bool updateShouldNotify(_MenuScope oldWidget) => false;
}

class _MenuPanel extends StatelessWidget {
  final List<Widget> children;
  final VoidCallback close;

  const _MenuPanel({required this.children, required this.close});

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    return _MenuScope(
      close: close,
      child: Semantics(
        container: true,
        child: Container(
          constraints: const BoxConstraints(minWidth: 160, maxWidth: 320),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceBase,
            borderRadius: BorderRadius.circular(theme.cornerRadius),
            border: Border.all(color: theme.colorScheme.iconDisabled),
          ),
          child: IntrinsicWidth(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
          ),
        ),
      ),
    );
  }
}

/// The shared look of every tappable menu row.
class _MenuRow extends StatelessWidget {
  final Widget child;
  final Widget? leading;
  final Widget? trailing;
  final MenuItemVariant variant;
  final bool disabled;
  final bool highlighted;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onHover;

  const _MenuRow({
    required this.child,
    this.leading,
    this.trailing,
    this.variant = MenuItemVariant.normal,
    this.disabled = false,
    this.highlighted = false,
    this.onTap,
    this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final c = theme.colorScheme;
    final isDanger = variant == MenuItemVariant.danger;
    final foreground = disabled ? c.textPlaceholder : (isDanger ? c.statusDangerDark : c.textPrimary);
    final iconColor = disabled ? c.iconDisabled : (isDanger ? c.statusDangerDark : c.iconSecondary);

    return MouseRegion(
      onEnter: onHover == null ? null : (_) => onHover!(true),
      onExit: onHover == null ? null : (_) => onHover!(false),
      child: Pressable(
        disabled: disabled,
        onTap: onTap,
        builder: (context, hovered, pressed) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: hovered || pressed || highlighted ? (isDanger ? c.statusDangerLight : c.surfaceHover) : null,
            borderRadius: BorderRadius.circular(4),
          ),
          child: IconTheme(
            data: IconThemeData(size: 18, color: iconColor),
            child: DefaultTextStyle(
              style: theme.textTheme.bodySmall.copyWith(height: 1.3, color: foreground),
              child: Row(
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: 8)],
                  Expanded(child: child),
                  if (trailing != null) ...[const SizedBox(width: 16), trailing!],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A button that opens a menu of actions anchored to it.
///
/// The menu closes after an item is activated, on a press outside, and when
/// the trigger is tapped again.
///
/// ```dart
/// Menu(
///   trigger: const Icon(PrimeIcons.dotsHorizontal),
///   items: [
///     MenuItem(icon: PrimeIcons.pencilOutline, onTap: rename, child: const Text('Rename')),
///     MenuCheckboxItem(checked: showHidden, onChanged: setShowHidden, child: const Text('Show hidden')),
///     const MenuSeparator(),
///     MenuItem(variant: MenuItemVariant.danger, onTap: delete, child: const Text('Delete')),
///   ],
/// )
/// ```
class Menu extends StatefulWidget {
  /// The widget that toggles the menu.
  final Widget trigger;

  /// [MenuItem], [MenuCheckboxItem], [MenuRadioGroup], [MenuGroup],
  /// [MenuSub] and [MenuSeparator] parts.
  final List<Widget> items;

  final FloatingPlacement placement;

  /// Gap between the trigger and the menu.
  final double offset;

  /// Controls the open state. Null lets the menu manage it.
  final bool? open;
  final ValueChanged<bool>? onOpenChanged;

  /// Accessible label of the trigger.
  final String? label;

  final bool disabled;

  const Menu({
    super.key,
    required this.trigger,
    required this.items,
    this.placement = FloatingPlacement.bottomStart,
    this.offset = 4,
    this.open,
    this.onOpenChanged,
    this.label,
    this.disabled = false,
  });

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  bool _open = false;

  bool get _isOpen => widget.open ?? _open;

  void _setOpen(bool open) {
    if (open == _isOpen) return;
    if (widget.open == null) setState(() => _open = open);
    widget.onOpenChanged?.call(open);
  }

  @override
  Widget build(BuildContext context) {
    return Floating(
      visible: _isOpen && !widget.disabled,
      placement: widget.placement,
      offset: widget.offset,
      onTapOutside: () => _setOpen(false),
      onEscape: () => _setOpen(false),
      floatingBuilder: (context) => _MenuPanel(close: () => _setOpen(false), children: widget.items),
      child: Semantics(
        button: true,
        expanded: _isOpen,
        label: widget.label,
        child: MouseRegion(
          cursor: widget.disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
          child: TapListener(onTap: widget.disabled ? null : () => _setOpen(!_isOpen), child: widget.trigger),
        ),
      ),
    );
  }
}

/// An action in a [Menu]. The menu closes after it is activated.
class MenuItem extends StatelessWidget {
  final Widget child;
  final IconData? icon;

  /// A keyboard shortcut hint shown at the end, such as `⌘S`. Decorative:
  /// binding the key is the app's job.
  final String? shortcut;

  final MenuItemVariant variant;
  final bool disabled;
  final VoidCallback? onTap;

  const MenuItem({
    super.key,
    required this.child,
    this.icon,
    this.shortcut,
    this.variant = MenuItemVariant.normal,
    this.disabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _MenuRow(
      variant: variant,
      disabled: disabled,
      leading: icon != null ? Icon(icon) : null,
      trailing: shortcut != null ? MenuShortcut(shortcut!) : null,
      onTap: () {
        _MenuScope.closeOf(context)?.call();
        onTap?.call();
      },
      child: child,
    );
  }
}

/// A keyboard shortcut hint for the end of a menu row.
class MenuShortcut extends StatelessWidget {
  final String keys;

  const MenuShortcut(this.keys, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    return ExcludeSemantics(
      child: Text(keys, style: theme.textTheme.bodySmall.copyWith(fontSize: 12, height: 1.3, color: theme.colorScheme.textPlaceholder)),
    );
  }
}

/// A toggle in a [Menu]. A check leads the label while checked.
class MenuCheckboxItem extends StatelessWidget {
  final Widget child;
  final bool checked;
  final ValueChanged<bool>? onChanged;
  final bool disabled;

  const MenuCheckboxItem({super.key, required this.child, required this.checked, this.onChanged, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: checked,
      child: _MenuRow(
        disabled: disabled,
        leading: SizedBox(width: 18, child: checked ? const Icon(PrimeIcons.check) : null),
        onTap: () {
          _MenuScope.closeOf(context)?.call();
          onChanged?.call(!checked);
        },
        child: child,
      ),
    );
  }
}

class _MenuRadioScope<T> extends InheritedWidget {
  final T? value;
  final ValueChanged<T>? onChanged;

  const _MenuRadioScope({required this.value, required this.onChanged, required super.child});

  @override
  bool updateShouldNotify(_MenuRadioScope<T> oldWidget) => value != oldWidget.value;
}

/// A set of mutually exclusive [MenuRadioItem]s in a [Menu].
class MenuRadioGroup<T> extends StatelessWidget {
  final T? value;
  final ValueChanged<T>? onChanged;

  /// Optional heading above the items.
  final Widget? heading;

  /// [MenuRadioItem]s of the same type argument.
  final List<Widget> children;

  const MenuRadioGroup({super.key, required this.value, this.onChanged, this.heading, required this.children});

  @override
  Widget build(BuildContext context) {
    return _MenuRadioScope<T>(
      value: value,
      onChanged: onChanged,
      child: MenuGroup(heading: heading, children: children),
    );
  }
}

/// A choice in a [MenuRadioGroup]. A check leads the label while selected.
class MenuRadioItem<T> extends StatelessWidget {
  final T value;
  final Widget child;
  final bool disabled;

  const MenuRadioItem({super.key, required this.value, required this.child, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    final group = context.dependOnInheritedWidgetOfExactType<_MenuRadioScope<T>>();
    assert(group != null, 'MenuRadioItem<$T> must be inside a MenuRadioGroup<$T>');
    final selected = group?.value == value;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: _MenuRow(
        disabled: disabled,
        leading: SizedBox(width: 18, child: selected ? const Icon(PrimeIcons.check) : null),
        onTap: () {
          _MenuScope.closeOf(context)?.call();
          group?.onChanged?.call(value);
        },
        child: child,
      ),
    );
  }
}

/// A labelled group of rows in a [Menu].
class MenuGroup extends StatelessWidget {
  final Widget? heading;
  final List<Widget> children;

  const MenuGroup({super.key, this.heading, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (heading != null) MenuGroupHeading(child: heading!),
        ...children,
      ],
    );
  }
}

/// A non-interactive heading inside a [Menu].
class MenuGroupHeading extends StatelessWidget {
  final Widget child;

  const MenuGroupHeading({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: DefaultTextStyle(
        style: theme.textTheme.bodySmall.copyWith(
          fontSize: 12,
          height: 1.3,
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.textTertiary,
        ),
        child: child,
      ),
    );
  }
}

/// A horizontal divider inside a [Menu].
class MenuSeparator extends StatelessWidget {
  const MenuSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(margin: const EdgeInsets.symmetric(vertical: 4), height: 1, color: PrimeTheme.of(context).colorScheme.borderSubtle);
  }
}

/// A row that opens a nested menu beside it, on tap or hover.
class MenuSub extends StatefulWidget {
  final Widget child;
  final IconData? icon;
  final List<Widget> items;
  final bool disabled;

  const MenuSub({super.key, required this.child, this.icon, required this.items, this.disabled = false});

  @override
  State<MenuSub> createState() => _MenuSubState();
}

class _MenuSubState extends State<MenuSub> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final closeParent = _MenuScope.closeOf(context);
    return Floating(
      visible: _open && !widget.disabled,
      placement: FloatingPlacement.right,
      offset: 4,
      onTapOutside: () => setState(() => _open = false),
      onEscape: () => setState(() => _open = false),
      floatingBuilder: (context) => _MenuPanel(
        // Activating a nested item closes the whole menu.
        close: () {
          setState(() => _open = false);
          closeParent?.call();
        },
        children: widget.items,
      ),
      child: _MenuRow(
        disabled: widget.disabled,
        highlighted: _open,
        leading: widget.icon != null ? Icon(widget.icon) : null,
        trailing: const Icon(PrimeIcons.menuRight),
        onTap: () => setState(() => _open = !_open),
        onHover: (hovering) {
          if (hovering && !_open) setState(() => _open = true);
        },
        child: widget.child,
      ),
    );
  }
}

/// One menu of a [Menubar].
class MenubarMenu {
  /// The text of the trigger, such as `File`.
  final Widget label;
  final List<Widget> items;

  const MenubarMenu({required this.label, required this.items});
}

/// A horizontal bar of menus, such as an application's File, Edit, and View.
///
/// While one menu is open, hovering another trigger switches to its menu.
///
/// ```dart
/// Menubar(
///   menus: [
///     MenubarMenu(label: const Text('File'), items: [MenuItem(onTap: open, shortcut: '⌘O', child: const Text('Open'))]),
///     MenubarMenu(label: const Text('Edit'), items: [MenuItem(onTap: undo, child: const Text('Undo'))]),
///   ],
/// )
/// ```
class Menubar extends StatefulWidget {
  final List<MenubarMenu> menus;

  const Menubar({super.key, required this.menus});

  @override
  State<Menubar> createState() => _MenubarState();
}

class _MenubarState extends State<Menubar> {
  int? _openIndex;

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final c = theme.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 2,
      children: [
        for (int i = 0; i < widget.menus.length; i++)
          Floating(
            visible: _openIndex == i,
            onTapOutside: () {
              if (_openIndex == i) setState(() => _openIndex = null);
            },
            onEscape: () => setState(() => _openIndex = null),
            floatingBuilder: (context) => _MenuPanel(close: () => setState(() => _openIndex = null), children: widget.menus[i].items),
            child: MouseRegion(
              onEnter: (_) {
                if (_openIndex != null && _openIndex != i) setState(() => _openIndex = i);
              },
              child: Pressable(
                onTap: () => setState(() => _openIndex = _openIndex == i ? null : i),
                builder: (context, hovered, pressed) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: hovered || pressed || _openIndex == i ? c.surfaceHover : null,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DefaultTextStyle(
                    style: theme.textTheme.bodySmall.copyWith(height: 1.3, color: c.textPrimary),
                    child: widget.menus[i].label,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Opens a menu at the pointer on a right click or a long press of [child].
///
/// ```dart
/// ContextMenuRegion(
///   items: [MenuItem(onTap: copy, child: const Text('Copy'))],
///   child: const Text('Right-click or long-press me'),
/// )
/// ```
class ContextMenuRegion extends StatefulWidget {
  final Widget child;
  final List<Widget> items;
  final bool disabled;

  const ContextMenuRegion({super.key, required this.child, required this.items, this.disabled = false});

  @override
  State<ContextMenuRegion> createState() => _ContextMenuRegionState();
}

class _ContextMenuRegionState extends State<ContextMenuRegion> {
  Offset? _position;

  void _openAt(Offset local) {
    if (!widget.disabled) setState(() => _position = local);
  }

  @override
  Widget build(BuildContext context) {
    final position = _position;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onSecondaryTapUp: (details) => _openAt(details.localPosition),
          onLongPressStart: (details) => _openAt(details.localPosition),
          child: widget.child,
        ),
        // A zero-size anchor at the press point for the menu to hang from.
        Positioned(
          left: position?.dx ?? 0,
          top: position?.dy ?? 0,
          child: Floating(
            visible: position != null,
            offset: 0,
            onTapOutside: () => setState(() => _position = null),
            onEscape: () => setState(() => _position = null),
            floatingBuilder: (context) => _MenuPanel(close: () => setState(() => _position = null), children: widget.items),
            child: const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
