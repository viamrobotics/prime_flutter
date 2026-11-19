import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A keyboard shortcut: the press that fires it and how a listing shows it.
///
/// [key] is the key's name, lowercased and without spaces: `k`, `enter`,
/// `arrowup`, `/`. [shift] and [mod] are part of the press when set, so `h`
/// and `Shift+H` stay separate shortcuts. Alt/Option is never part of a
/// shortcut, because macOS rewrites the character it reports.
@immutable
class Keybinding {
  /// Unique among the shortcuts present at once.
  final String id;

  /// What the shortcut does, for a listing.
  final String description;

  /// The heading a listing files the shortcut under.
  final String group;

  final String key;

  /// Whether held Shift is part of the press.
  final bool shift;

  /// Whether the platform's command key is part of the press: Command on
  /// Apple devices, Control elsewhere.
  final bool mod;

  const Keybinding({required this.id, required this.description, this.group = '', required this.key, this.shift = false, this.mod = false});
}

/// A key press reduced to the parts a shortcut matches on.
@immutable
class KeyPress {
  final String key;
  final bool shift;
  final bool mod;

  const KeyPress({required this.key, this.shift = false, this.mod = false});

  bool matches(Keybinding binding) => binding.key.toLowerCase() == key && binding.shift == shift && binding.mod == mod;
}

bool get _isApple => defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.iOS;

const Map<String, String> _keyNames = {
  'arrowup': '↑',
  'arrowdown': '↓',
  'arrowleft': '←',
  'arrowright': '→',
  'enter': '↵',
  'escape': 'Esc',
  'backspace': '⌫',
  'delete': 'Del',
  'tab': 'Tab',
  'space': 'Space',
  ' ': 'Space',
};

/// A single key as it should be printed. `w` reads as `W`, `arrowup` as `↑`.
String formatKey(String key) {
  final lower = key.toLowerCase();
  final named = _keyNames[lower];
  if (named != null) return named;
  return lower.length == 1 ? lower.toUpperCase() : '${lower[0].toUpperCase()}${lower.substring(1)}';
}

/// The printed keys of a binding, one entry per key, for rendering a [Kbd]
/// each. Apple keyboards label the modifiers with symbols, so Mod reads `⌘`
/// there and `Ctrl` elsewhere.
List<String> keybindingParts(Keybinding binding) => [
  if (binding.mod) _isApple ? '⌘' : 'Ctrl',
  if (binding.shift) _isApple ? '⇧' : 'Shift',
  formatKey(binding.key),
];

/// A binding as one run of text: `⌘⇧Z` on Apple devices, `Ctrl+Shift+Z`
/// elsewhere.
String formatKeybinding(Keybinding binding) => keybindingParts(binding).join(_isApple ? '' : '+');

class _Registration {
  final Keybinding binding;
  final VoidCallback? run;
  final bool Function()? when;

  const _Registration(this.binding, this.run, this.when);
}

/// The shortcuts registered under a [Keybindings] widget.
class KeybindingsRegistry extends ChangeNotifier {
  final List<_Registration> _registrations = [];

  /// Every shortcut present right now, in registration order.
  List<Keybinding> get bindings => [for (final registration in _registrations) registration.binding];

  /// Adds a shortcut and returns the function that removes it. Without [run]
  /// it is listed and never run. [when] is read when the key is pressed.
  VoidCallback register(Keybinding binding, {VoidCallback? run, bool Function()? when}) {
    final registration = _Registration(binding, run, when);
    _registrations.add(registration);
    _notifyLater();
    return () {
      _registrations.remove(registration);
      _notifyLater();
    };
  }

  /// The handlers a press should run, in registration order.
  List<VoidCallback> matching(KeyPress press) => [
    for (final registration in _registrations)
      if (registration.run != null && press.matches(registration.binding) && (registration.when?.call() ?? true)) registration.run!,
  ];

  bool _pending = false;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // Registrations happen during build and dispose, when listeners cannot rebuild.
  void _notifyLater() {
    if (_pending || _disposed) return;
    _pending = true;
    scheduleMicrotask(() {
      _pending = false;
      // Shortcuts unregister as the tree comes down, after the registry itself may be gone.
      if (!_disposed) notifyListeners();
    });
  }
}

/// Owns the shortcut registry for everything below it and the one keyboard
/// listener that runs the registered shortcuts.
///
/// Repeats and Alt/Option presses are ignored, and an unmodified press typed
/// into a text field belongs to the field.
///
/// ```dart
/// Keybindings(
///   child: Hotkey(
///     binding: const Keybinding(id: 'save', description: 'Save', group: 'File', key: 's', mod: true),
///     onInvoke: save,
///     child: const Editor(),
///   ),
/// )
/// ```
///
/// List the shortcuts with `Keybindings.of(context).bindings`, and print one
/// with [formatKeybinding] or [keybindingParts].
class Keybindings extends StatefulWidget {
  final Widget child;

  const Keybindings({super.key, required this.child});

  /// The registry from the nearest [Keybindings]. Rebuilds the caller when
  /// the set of shortcuts changes.
  static KeybindingsRegistry of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_KeybindingsScope>();
    assert(scope != null, 'No Keybindings found in context');
    return scope!.notifier!;
  }

  static KeybindingsRegistry? maybeOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<_KeybindingsScope>()?.notifier;

  @override
  State<Keybindings> createState() => _KeybindingsState();
}

class _KeybindingsScope extends InheritedNotifier<KeybindingsRegistry> {
  const _KeybindingsScope({required KeybindingsRegistry registry, required super.child}) : super(notifier: registry);
}

class _KeybindingsState extends State<Keybindings> {
  final KeybindingsRegistry _registry = KeybindingsRegistry();

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKey);
    _registry.dispose();
    super.dispose();
  }

  bool _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final keyboard = HardwareKeyboard.instance;
    if (keyboard.isAltPressed) return false;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.shiftLeft ||
        key == LogicalKeyboardKey.shiftRight ||
        key == LogicalKeyboardKey.metaLeft ||
        key == LogicalKeyboardKey.metaRight ||
        key == LogicalKeyboardKey.controlLeft ||
        key == LogicalKeyboardKey.controlRight) {
      return false;
    }

    final mod = _isApple ? keyboard.isMetaPressed : keyboard.isControlPressed;
    // An unmodified press typed into a field belongs to the field.
    if (!mod) {
      final focused = FocusManager.instance.primaryFocus?.context;
      if (focused != null && (focused.widget is EditableText || focused.findAncestorWidgetOfExactType<EditableText>() != null)) {
        return false;
      }
    }

    final name = key.keyLabel.toLowerCase().replaceAll(' ', '');
    final press = KeyPress(key: name.isEmpty ? ' ' : name, shift: keyboard.isShiftPressed, mod: mod);
    final handlers = _registry.matching(press);
    for (final run in handlers) {
      run();
    }
    return handlers.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) => _KeybindingsScope(registry: _registry, child: widget.child);
}

/// Declares a shortcut and its behavior for as long as this widget is
/// mounted under a [Keybindings].
class Hotkey extends StatefulWidget {
  final Keybinding binding;

  /// What the shortcut does. Null lists the shortcut without running
  /// anything, for a key something else acts on.
  final VoidCallback? onInvoke;

  /// Whether the shortcut applies right now. Read when the key is pressed.
  final bool Function()? when;

  final Widget child;

  const Hotkey({super.key, required this.binding, this.onInvoke, this.when, required this.child});

  @override
  State<Hotkey> createState() => _HotkeyState();
}

class _HotkeyState extends State<Hotkey> {
  KeybindingsRegistry? _registry;
  VoidCallback? _unregister;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final registry = context.getInheritedWidgetOfExactType<_KeybindingsScope>()?.notifier;
    assert(registry != null, 'Hotkey must be inside a Keybindings');
    if (registry != _registry) {
      _unregister?.call();
      _registry = registry;
      _register();
    }
  }

  @override
  void didUpdateWidget(Hotkey oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.binding != oldWidget.binding) {
      _unregister?.call();
      _register();
    }
  }

  // The closures read the widget at press time, so a new callback needs no re-registration.
  void _register() {
    _unregister = _registry?.register(
      widget.binding,
      run: () => widget.onInvoke?.call(),
      when: () => widget.onInvoke != null && (widget.when?.call() ?? true),
    );
  }

  @override
  void dispose() {
    _unregister?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
