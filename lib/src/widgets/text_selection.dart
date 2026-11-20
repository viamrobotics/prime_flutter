import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../theme/prime_colors.dart';
import '../theme/prime_theme.dart';
import '../theme/prime_theme_data.dart';
import 'internal/pressable.dart';

const double _kHandleSize = 22.0;
const double _kToolbarGap = 8.0;
const double _kToolbarScreenPadding = 8.0;

/// Draws Prime's text selection handles: the draggable drops at each end of a
/// selection on touch platforms.
///
/// The copy/paste menu is not built here. It comes from a
/// `contextMenuBuilder`, see [PrimeTextSelectionToolbar].
class PrimeTextSelectionControls extends TextSelectionControls with TextSelectionHandleControls {
  @override
  Size getHandleSize(double textLineHeight) => const Size.square(_kHandleSize);

  @override
  Widget buildHandle(BuildContext context, TextSelectionHandleType type, double textLineHeight, [VoidCallback? onTap]) {
    final Color color =
        DefaultSelectionStyle.of(context).cursorColor ?? PrimeTheme.maybeOf(context)?.colorScheme.inputFocus ?? PrimeColors.focusBlue;
    final Widget handle = SizedBox.square(
      dimension: _kHandleSize,
      child: CustomPaint(
        painter: _HandlePainter(color),
        child: GestureDetector(onTap: onTap, behavior: HitTestBehavior.translucent),
      ),
    );
    // The drop is a circle with a square top-left corner. Rotated, that corner
    // points at the end of the selection the handle belongs to.
    return switch (type) {
      TextSelectionHandleType.left => Transform.rotate(angle: math.pi / 2, child: handle),
      TextSelectionHandleType.right => handle,
      TextSelectionHandleType.collapsed => Transform.rotate(angle: math.pi / 4, child: handle),
    };
  }

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) {
    return switch (type) {
      TextSelectionHandleType.collapsed => const Offset(_kHandleSize / 2, -4),
      TextSelectionHandleType.left => const Offset(_kHandleSize, 0),
      TextSelectionHandleType.right => Offset.zero,
    };
  }
}

class _HandlePainter extends CustomPainter {
  const _HandlePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    final double radius = size.width / 2;
    canvas.drawCircle(Offset(radius, radius), radius, paint);
    canvas.drawRect(Rect.fromLTWH(0, 0, radius, radius), paint);
  }

  @override
  bool shouldRepaint(_HandlePainter oldDelegate) => color != oldDelegate.color;
}

/// Selection controls for platforms with a mouse: there are no handles.
class PrimeDesktopTextSelectionControls extends TextSelectionControls with TextSelectionHandleControls {
  @override
  Size getHandleSize(double textLineHeight) => Size.zero;

  @override
  Widget buildHandle(BuildContext context, TextSelectionHandleType type, double textLineHeight, [VoidCallback? onTap]) {
    return const SizedBox.shrink();
  }

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) => Offset.zero;
}

/// The handles for touch platforms.
final TextSelectionControls primeTextSelectionControls = PrimeTextSelectionControls();

/// The (absent) handles for desktop platforms.
final TextSelectionControls primeDesktopTextSelectionControls = PrimeDesktopTextSelectionControls();

/// The selection controls that suit [platform], by default the current one.
TextSelectionControls primeAdaptiveTextSelectionControls([TargetPlatform? platform]) {
  return switch (platform ?? defaultTargetPlatform) {
    TargetPlatform.android || TargetPlatform.iOS || TargetPlatform.fuchsia => primeTextSelectionControls,
    TargetPlatform.macOS || TargetPlatform.linux || TargetPlatform.windows => primeDesktopTextSelectionControls,
  };
}

/// The Prime copy/paste menu for text fields and selectable text.
///
/// On touch platforms it is a row of actions above the selection. On desktop
/// it is a menu at the pointer. Pass [editableText] or [selectableRegion] as
/// a `contextMenuBuilder`:
///
/// ```dart
/// EditableText(contextMenuBuilder: PrimeTextSelectionToolbar.editableText, ...)
/// ```
///
/// To add or remove actions, build the toolbar with your own [buttonItems]:
///
/// ```dart
/// contextMenuBuilder: (context, state) => PrimeTextSelectionToolbar(
///   anchors: state.contextMenuAnchors,
///   buttonItems: [
///     ...state.contextMenuButtonItems,
///     ContextMenuButtonItem(label: 'Format', onPressed: format),
///   ],
/// ),
/// ```
class PrimeTextSelectionToolbar extends StatelessWidget {
  const PrimeTextSelectionToolbar({super.key, required this.anchors, required this.buttonItems});

  /// Where the selection is, in global coordinates.
  final TextSelectionToolbarAnchors anchors;

  /// The actions to show, in order.
  final List<ContextMenuButtonItem> buttonItems;

  /// A `contextMenuBuilder` for [EditableText].
  ///
  /// Where iOS can show its own menu this builds a [SystemContextMenu], which
  /// lets the user paste without the system asking for permission each time.
  static Widget editableText(BuildContext context, EditableTextState editableTextState) {
    if (SystemContextMenu.isSupportedByField(editableTextState)) {
      return SystemContextMenu.editableText(editableTextState: editableTextState);
    }
    return PrimeTextSelectionToolbar(anchors: editableTextState.contextMenuAnchors, buttonItems: editableTextState.contextMenuButtonItems);
  }

  /// A `contextMenuBuilder` for [SelectableRegion].
  static Widget selectableRegion(BuildContext context, SelectableRegionState selectableRegionState) {
    return PrimeTextSelectionToolbar(
      anchors: selectableRegionState.contextMenuAnchors,
      buttonItems: selectableRegionState.contextMenuButtonItems,
    );
  }

  /// The label for [item]: its own, or the localized one for its kind.
  static String labelFor(BuildContext context, ContextMenuButtonItem item) {
    if (item.label != null) return item.label!;
    final WidgetsLocalizations localizations = WidgetsLocalizations.of(context);
    return switch (item.kind) {
      ContextMenuButtonKind.cut => localizations.cutButtonLabel,
      ContextMenuButtonKind.copy => localizations.copyButtonLabel,
      ContextMenuButtonKind.paste => localizations.pasteButtonLabel,
      ContextMenuButtonKind.selectAll => localizations.selectAllButtonLabel,
      ContextMenuButtonKind.lookUp => localizations.lookUpButtonLabel,
      ContextMenuButtonKind.searchWeb => localizations.searchWebButtonLabel,
      ContextMenuButtonKind.share => localizations.shareButtonLabel,
      ContextMenuButtonKind.delete => 'Delete',
      ContextMenuButtonKind.liveTextInput => 'Scan text',
      _ => item.kind.name,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (buttonItems.isEmpty) return const SizedBox.shrink();
    final PrimeThemeData theme = PrimeTheme.maybeOf(context) ?? PrimeThemeData.light();
    final bool desktop = switch (defaultTargetPlatform) {
      TargetPlatform.macOS || TargetPlatform.linux || TargetPlatform.windows => true,
      TargetPlatform.android || TargetPlatform.iOS || TargetPlatform.fuchsia => false,
    };

    final List<Widget> buttons = [
      for (final ContextMenuButtonItem item in buttonItems) _ToolbarButton(item: item, theme: theme, desktop: desktop),
    ];
    final BorderRadius radius = BorderRadius.circular(theme.cornerRadius);
    Widget surface(Widget child) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceBase,
          borderRadius: radius,
          border: Border.all(color: theme.colorScheme.borderSubtle),
        ),
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: ClipRRect(borderRadius: BorderRadius.circular(math.max(0, theme.cornerRadius - 1)), child: child),
        ),
      );
    }

    if (desktop) {
      return Padding(
        padding: const EdgeInsets.all(_kToolbarScreenPadding),
        child: CustomSingleChildLayout(
          delegate: DesktopTextSelectionToolbarLayoutDelegate(
            anchor: anchors.primaryAnchor - const Offset(_kToolbarScreenPadding, _kToolbarScreenPadding),
          ),
          child: surface(
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 160),
              child: IntrinsicWidth(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: buttons),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Above the selection when there is room, below it (clear of the handles) when not.
    final double paddingAbove = MediaQuery.paddingOf(context).top + _kToolbarScreenPadding;
    final Offset origin = Offset(_kToolbarScreenPadding, paddingAbove);
    final Offset anchorAbove = anchors.primaryAnchor - const Offset(0, _kToolbarGap);
    final Offset anchorBelow = (anchors.secondaryAnchor ?? anchors.primaryAnchor) + const Offset(0, _kHandleSize + _kToolbarGap);
    return Padding(
      padding: EdgeInsets.fromLTRB(_kToolbarScreenPadding, paddingAbove, _kToolbarScreenPadding, _kToolbarScreenPadding),
      child: CustomSingleChildLayout(
        delegate: TextSelectionToolbarLayoutDelegate(anchorAbove: anchorAbove - origin, anchorBelow: anchorBelow - origin),
        child: surface(
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < buttons.length; i++) ...[
                  if (i > 0) SizedBox(width: 1, height: 20, child: ColoredBox(color: theme.colorScheme.borderSubtle)),
                  buttons[i],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({required this.item, required this.theme, required this.desktop});

  final ContextMenuButtonItem item;
  final PrimeThemeData theme;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;
    final bool disabled = item.onPressed == null;
    return Pressable(
      onTap: item.onPressed,
      disabled: disabled,
      builder: (context, hovered, pressed) {
        return ColoredBox(
          color: pressed ? colors.surfaceHighlight : (hovered ? colors.surfaceHover : colors.surfaceBase),
          child: Padding(
            padding: desktop
                ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
                : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Text(
              PrimeTextSelectionToolbar.labelFor(context, item),
              maxLines: 1,
              style: theme.textTheme.bodySmall.copyWith(color: disabled ? colors.textPlaceholder : colors.textPrimary, height: 1.2),
            ),
          ),
        );
      },
    );
  }
}

/// The magnifier shown above the finger while dragging the caret or a
/// selection handle on touch platforms. There is none on desktop.
TextMagnifierConfiguration get primeTextMagnifierConfiguration => _magnifierConfiguration;

final TextMagnifierConfiguration _magnifierConfiguration = TextMagnifierConfiguration(
  shouldDisplayHandlesInMagnifier: false,
  magnifierBuilder: (BuildContext context, MagnifierController controller, ValueNotifier<MagnifierInfo> info) {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => _TextMagnifier(info: info),
      _ => null,
    };
  },
);

class _TextMagnifier extends StatelessWidget {
  const _TextMagnifier({required this.info});

  final ValueListenable<MagnifierInfo> info;

  static const Size _size = Size(84, 44);
  static const double _gap = 12;

  @override
  Widget build(BuildContext context) {
    final PrimeThemeData theme = PrimeTheme.maybeOf(context) ?? PrimeThemeData.light();
    final Size screen = MediaQuery.sizeOf(context);
    return ValueListenableBuilder<MagnifierInfo>(
      valueListenable: info,
      builder: (context, value, _) {
        // Follow the finger along the line, and stay on the line vertically.
        final Rect line = value.currentLineBoundaries;
        final double focusX = line.right > line.left
            ? clampDouble(value.globalGesturePosition.dx, line.left, line.right)
            : value.globalGesturePosition.dx;
        final Offset focus = Offset(focusX, value.caretRect.center.dy);

        final double left = clampDouble(focusX - _size.width / 2, 0, math.max(0, screen.width - _size.width));
        final double top = math.max(0, value.caretRect.top - _size.height - _gap);
        final Offset center = Offset(left + _size.width / 2, top + _size.height / 2);

        return Positioned(
          left: left,
          top: top,
          child: IgnorePointer(
            child: RawMagnifier(
              size: _size,
              focalPointOffset: focus - center,
              magnificationScale: 1.25,
              clipBehavior: Clip.antiAlias,
              decoration: MagnifierDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(theme.cornerRadius),
                  side: BorderSide(color: theme.colorScheme.borderSubtle),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Makes the text beneath it selectable, with Prime's handles and copy menu.
///
/// Wrap a screen, or a single [Text], to let the user select and copy from it:
///
/// ```dart
/// SelectionArea(child: Text(log))
/// ```
class SelectionArea extends StatefulWidget {
  const SelectionArea({
    super.key,
    required this.child,
    this.focusNode,
    this.selectionControls,
    this.contextMenuBuilder = PrimeTextSelectionToolbar.selectableRegion,
    this.magnifierConfiguration,
    this.onSelectionChanged,
  });

  final Widget child;
  final FocusNode? focusNode;

  /// The handles to draw. Defaults to [primeAdaptiveTextSelectionControls].
  final TextSelectionControls? selectionControls;

  /// Builds the copy menu. Null shows none.
  final SelectableRegionContextMenuBuilder? contextMenuBuilder;

  /// Defaults to [primeTextMagnifierConfiguration].
  final TextMagnifierConfiguration? magnifierConfiguration;

  final ValueChanged<SelectedContent?>? onSelectionChanged;

  @override
  State<SelectionArea> createState() => _SelectionAreaState();
}

class _SelectionAreaState extends State<SelectionArea> {
  FocusNode? _internalNode;
  FocusNode get _focusNode => widget.focusNode ?? (_internalNode ??= FocusNode(debugLabel: 'SelectionArea'));

  @override
  void dispose() {
    _internalNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SelectableRegion(
      focusNode: _focusNode,
      selectionControls: widget.selectionControls ?? primeAdaptiveTextSelectionControls(),
      contextMenuBuilder: widget.contextMenuBuilder,
      magnifierConfiguration: widget.magnifierConfiguration ?? primeTextMagnifierConfiguration,
      onSelectionChanged: widget.onSelectionChanged,
      child: widget.child,
    );
  }
}
