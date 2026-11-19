import 'package:flutter/widgets.dart';

import 'banner.dart';

/// Returned from every [Notify] call so the caller can dismiss early.
class NotificationHandle {
  /// Removes the notification. Safe to call more than once.
  final VoidCallback dismiss;

  const NotificationHandle(this.dismiss);
}

/// Sends notifications to the nearest [NotificationContainer].
///
/// ```dart
/// Notify.of(context).success('Saved', message: 'Your changes are live.');
///
/// final pending = Notify.of(context).pending('Uploading', persist: true);
/// await upload();
/// pending.dismiss();
/// ```
class Notify {
  final NotificationHandle Function(
    BannerVariant variant,
    String title, {
    String? message,
    bool persist,
    VoidCallback? onDismiss,
    Widget? content,
  })
  _add;

  const Notify._(this._add);

  /// The sender for the [NotificationContainer] above [context].
  static Notify of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<_NotifyScope>();
    assert(scope != null, 'No NotificationContainer found in context');
    return scope!.notify;
  }

  /// Like [of], but returns null when there is no [NotificationContainer].
  static Notify? maybeOf(BuildContext context) => context.getInheritedWidgetOfExactType<_NotifyScope>()?.notify;

  /// Push an info notification.
  ///
  /// Unless [persist] is true it dismisses itself after the container's
  /// duration. [content] renders under [message].
  NotificationHandle info(String title, {String? message, bool persist = false, VoidCallback? onDismiss, Widget? content}) =>
      _add(BannerVariant.info, title, message: message, persist: persist, onDismiss: onDismiss, content: content);

  /// Push a warning notification.
  NotificationHandle warn(String title, {String? message, bool persist = false, VoidCallback? onDismiss, Widget? content}) =>
      _add(BannerVariant.warning, title, message: message, persist: persist, onDismiss: onDismiss, content: content);

  /// Push a danger notification.
  NotificationHandle danger(String title, {String? message, bool persist = false, VoidCallback? onDismiss, Widget? content}) =>
      _add(BannerVariant.danger, title, message: message, persist: persist, onDismiss: onDismiss, content: content);

  /// Push a success notification.
  NotificationHandle success(String title, {String? message, bool persist = false, VoidCallback? onDismiss, Widget? content}) =>
      _add(BannerVariant.success, title, message: message, persist: persist, onDismiss: onDismiss, content: content);

  /// Push an in-progress notification, shown with a spinner.
  NotificationHandle pending(String title, {String? message, bool persist = false, VoidCallback? onDismiss, Widget? content}) =>
      _add(BannerVariant.pending, title, message: message, persist: persist, onDismiss: onDismiss, content: content);
}

class _NotifyScope extends InheritedWidget {
  final Notify notify;

  const _NotifyScope({required this.notify, required super.child});

  @override
  bool updateShouldNotify(_NotifyScope oldWidget) => false;
}

class _Entry {
  final int id;
  final BannerVariant variant;
  final String title;
  final String? message;
  final Widget? content;
  final bool persist;
  final VoidCallback? onDismiss;

  const _Entry({
    required this.id,
    required this.variant,
    required this.title,
    this.message,
    this.content,
    required this.persist,
    this.onDismiss,
  });
}

/// Hosts the notifications pushed through [Notify].
///
/// Place it near the root of the app, above the screens that send
/// notifications. They stack in the top trailing corner, each counting down
/// on its accent bar; hovering or holding one pauses its countdown.
///
/// ```dart
/// PrimeApp(
///   builder: (context, child) => NotificationContainer(child: child!),
///   home: const HomeScreen(),
/// )
/// ```
///
/// For a brief message at the bottom of the screen, use [Toast] instead.
class NotificationContainer extends StatefulWidget {
  final Widget child;

  /// How long a non-persistent notification stays up.
  final Duration duration;

  const NotificationContainer({super.key, required this.child, this.duration = const Duration(seconds: 4)});

  @override
  State<NotificationContainer> createState() => _NotificationContainerState();
}

class _NotificationContainerState extends State<NotificationContainer> {
  final List<_Entry> _entries = [];
  int _nextId = 0;
  late final Notify _notify = Notify._(_add);

  NotificationHandle _add(
    BannerVariant variant,
    String title, {
    String? message,
    bool persist = false,
    VoidCallback? onDismiss,
    Widget? content,
  }) {
    final entry = _Entry(
      id: _nextId++,
      variant: variant,
      title: title,
      message: message,
      content: content,
      persist: persist,
      onDismiss: onDismiss,
    );
    if (mounted) setState(() => _entries.add(entry));
    return NotificationHandle(() => _remove(entry));
  }

  void _remove(_Entry entry) {
    if (!mounted || !_entries.contains(entry)) return;
    setState(() => _entries.remove(entry));
    entry.onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    return _NotifyScope(
      notify: _notify,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 640;
          final inset = isNarrow ? 16.0 : 24.0;
          final width = isNarrow ? constraints.maxWidth - inset * 2 : 420.0;
          final topPadding = MediaQuery.maybePaddingOf(context)?.top ?? 0;

          return Stack(
            children: [
              widget.child,
              if (_entries.isNotEmpty)
                Positioned(
                  top: topPadding + inset,
                  right: inset,
                  width: width,
                  child: Semantics(
                    container: true,
                    label: 'Notifications',
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final entry in _entries)
                          _NotificationItem(
                            key: ValueKey(entry.id),
                            entry: entry,
                            duration: widget.duration,
                            onDismiss: () => _remove(entry),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _NotificationItem extends StatefulWidget {
  final _Entry entry;
  final Duration duration;
  final VoidCallback onDismiss;

  const _NotificationItem({super.key, required this.entry, required this.duration, required this.onDismiss});

  @override
  State<_NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<_NotificationItem> with TickerProviderStateMixin {
  /// Remaining time, from 1 down to 0.
  late final AnimationController _countdown = AnimationController(vsync: this, duration: widget.duration, value: 1);
  late final AnimationController _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));

  @override
  void initState() {
    super.initState();
    _enter.forward();
    _countdown.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) widget.onDismiss();
    });
    _resume();
  }

  void _pause() => _countdown.stop();

  void _resume() {
    if (!widget.entry.persist) _countdown.reverse();
  }

  @override
  void dispose() {
    _countdown.dispose();
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final hasMessage = entry.message?.isNotEmpty ?? false;
    final Widget? subtitle = !hasMessage && entry.content == null
        ? null
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasMessage) Text(entry.message!, maxLines: 10, overflow: TextOverflow.ellipsis),
              ?entry.content,
            ],
          );

    return FadeTransition(
      opacity: _enter,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.5, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _enter, curve: Curves.easeOut)),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: MouseRegion(
            onEnter: (_) => _pause(),
            onExit: (_) => _resume(),
            child: Listener(
              onPointerDown: (_) => _pause(),
              onPointerUp: (_) => _resume(),
              onPointerCancel: (_) => _resume(),
              child: AnimatedBuilder(
                animation: _countdown,
                builder: (context, _) => PrimeBanner(
                  variant: entry.variant,
                  loading: entry.variant == BannerVariant.pending,
                  progress: _countdown.value,
                  title: Text(entry.title),
                  subtitle: subtitle,
                  onClose: widget.onDismiss,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
