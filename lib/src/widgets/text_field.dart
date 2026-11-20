import 'dart:ui' as ui show BoxHeightStyle, BoxWidthStyle;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/prime_theme.dart';
import '../theme/prime_theme_data.dart';
import 'text_selection.dart';

/// An undecorated, editable run of text: the editing behavior of a text field
/// with none of its chrome.
///
/// It handles what [EditableText] leaves to its host: tap, double-tap, drag
/// and long-press selection, selection handles, the copy/paste menu, the
/// magnifier, the caret's platform look, the mouse cursor, and focus on tap.
/// [Input] and [CodeEditor] are built on it. Reach for it when you need a text
/// field with a look of your own; otherwise use [Input].
///
/// [decorationBuilder] wraps the text in a border, padding or icons. Taps
/// anywhere on the decoration focus the field.
class PrimeTextField extends StatefulWidget {
  const PrimeTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.undoController,
    this.style,
    this.strutStyle,
    this.placeholder,
    this.placeholderStyle,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.obscureText = false,
    this.obscuringCharacter = '•',
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect,
    this.enableSuggestions = true,
    this.smartDashesType,
    this.smartQuotesType,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,
    this.showCursor,
    this.minLines,
    this.maxLines = 1,
    this.expands = false,
    this.inputFormatters,
    this.autofillHints = const <String>[],
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.onTap,
    this.onTapOutside,
    this.cursorColor,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.selectionColor,
    this.selectionHeightStyle,
    this.selectionWidthStyle,
    this.keyboardAppearance,
    this.scrollController,
    this.scrollPhysics,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.enableInteractiveSelection = true,
    this.selectionControls,
    this.contextMenuBuilder = PrimeTextSelectionToolbar.editableText,
    this.magnifierConfiguration,
    this.mouseCursor,
    this.clipBehavior = Clip.hardEdge,
    this.decorationBuilder,
  }) : assert(maxLines == null || maxLines > 0),
       assert(minLines == null || minLines > 0),
       assert(!obscureText || maxLines == 1, 'Obscured fields cannot be multiline.');

  /// The text being edited. The field keeps a controller of its own when null.
  final TextEditingController? controller;

  /// The focus of the field. The field keeps a node of its own when null.
  final FocusNode? focusNode;

  final UndoHistoryController? undoController;

  /// The text style. Defaults to the theme's `bodyDefault` in the input color.
  final TextStyle? style;

  final StrutStyle? strutStyle;

  /// Shown while the field is empty.
  final String? placeholder;

  /// Defaults to [style] in the theme's tertiary text color.
  final TextStyle? placeholderStyle;

  final TextAlign textAlign;
  final TextDirection? textDirection;
  final bool obscureText;
  final String obscuringCharacter;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool? autocorrect;
  final bool enableSuggestions;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final bool autofocus;

  /// When false the field cannot be focused, edited or selected.
  final bool enabled;

  /// Keeps the field focusable and selectable but not editable.
  final bool readOnly;

  final bool? showCursor;
  final int? minLines;

  /// The most lines to show before scrolling. Null grows without limit.
  final int? maxLines;

  final bool expands;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;

  /// Called for each tap on the field, not for taps on its selection handles.
  final VoidCallback? onTap;

  /// Called for a tap outside the field while it has focus. By default such a
  /// tap unfocuses the field on desktop and on the mobile web.
  final TapRegionCallback? onTapOutside;

  /// Defaults to the [DefaultSelectionStyle], then the theme's `inputFocus`.
  final Color? cursorColor;

  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;

  /// Defaults to the [DefaultSelectionStyle], then a tint of the theme's `inputFocus`.
  final Color? selectionColor;

  final ui.BoxHeightStyle? selectionHeightStyle;
  final ui.BoxWidthStyle? selectionWidthStyle;

  /// The look of the on-screen keyboard on iOS. Defaults to the theme's brightness.
  final Brightness? keyboardAppearance;

  final ScrollController? scrollController;
  final ScrollPhysics? scrollPhysics;
  final EdgeInsets scrollPadding;

  /// Whether the user can select text, and with it copy, cut and paste.
  final bool enableInteractiveSelection;

  /// The selection handles. Defaults to [primeAdaptiveTextSelectionControls].
  final TextSelectionControls? selectionControls;

  /// Builds the copy/paste menu. Null shows none.
  final EditableTextContextMenuBuilder? contextMenuBuilder;

  /// Defaults to [primeTextMagnifierConfiguration].
  final TextMagnifierConfiguration? magnifierConfiguration;

  /// Defaults to the text cursor, or the basic one when disabled.
  final MouseCursor? mouseCursor;

  final Clip clipBehavior;

  /// Wraps the editable text, e.g. in a border and padding. The whole result
  /// responds to taps and shows the text mouse cursor.
  final Widget Function(BuildContext context, Widget editable)? decorationBuilder;

  @override
  State<PrimeTextField> createState() => PrimeTextFieldState();
}

class PrimeTextFieldState extends State<PrimeTextField> implements TextSelectionGestureDetectorBuilderDelegate {
  TextEditingController? _internalController;
  TextEditingController get _controller => widget.controller ?? (_internalController ??= TextEditingController());

  FocusNode? _internalFocusNode;
  FocusNode get _focusNode => widget.focusNode ?? (_internalFocusNode ??= FocusNode(debugLabel: 'PrimeTextField'));

  late final _GestureBuilder _gestures = _GestureBuilder(this);
  bool _showSelectionHandles = false;

  /// The state of the underlying [EditableText], for showing the toolbar,
  /// bringing the caret into view, and reaching the `renderEditable`.
  EditableTextState? get editableText => editableTextKey.currentState;

  // --- TextSelectionGestureDetectorBuilderDelegate ---

  @override
  final GlobalKey<EditableTextState> editableTextKey = GlobalKey<EditableTextState>();

  @override
  bool get forcePressEnabled => defaultTargetPlatform == TargetPlatform.iOS;

  @override
  bool get selectionEnabled => widget.enableInteractiveSelection && widget.enabled;

  // ---

  @override
  void initState() {
    super.initState();
    _focusNode.canRequestFocus = widget.enabled;
    _focusNode.addListener(_handleFocusChanged);
    _controller.addListener(_handleTextChanged);
  }

  @override
  void didUpdateWidget(PrimeTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      (oldWidget.controller ?? _internalController)?.removeListener(_handleTextChanged);
      if (widget.controller != null) {
        _internalController?.dispose();
        _internalController = null;
      }
      _controller.addListener(_handleTextChanged);
    }
    if (widget.focusNode != oldWidget.focusNode) {
      (oldWidget.focusNode ?? _internalFocusNode)?.removeListener(_handleFocusChanged);
      if (widget.focusNode != null) {
        _internalFocusNode?.dispose();
        _internalFocusNode = null;
      }
      _focusNode.addListener(_handleFocusChanged);
    }
    _focusNode.canRequestFocus = widget.enabled;
    if (_focusNode.hasFocus && widget.readOnly != oldWidget.readOnly && widget.enabled) {
      if (_controller.selection.isCollapsed) _showSelectionHandles = !widget.readOnly;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChanged);
    _controller.removeListener(_handleTextChanged);
    _internalFocusNode?.dispose();
    _internalController?.dispose();
    super.dispose();
  }

  bool _wasEmpty = true;

  // The placeholder comes and goes with the text.
  void _handleTextChanged() {
    final bool empty = _controller.text.isEmpty;
    if (empty != _wasEmpty) setState(() => _wasEmpty = empty);
  }

  // The selection is only painted while focused.
  void _handleFocusChanged() => setState(() {});

  void _requestKeyboard() => editableText?.requestKeyboard();

  bool _shouldShowSelectionHandles(SelectionChangedCause? cause) {
    // No handles when the field was activated by something that shows no toolbar, e.g. a mouse.
    if (!_gestures.shouldShowSelectionToolbar || !_gestures.shouldShowSelectionHandles) return false;
    if (cause == SelectionChangedCause.keyboard) return false;
    if (widget.readOnly && _controller.selection.isCollapsed) return false;
    if (!widget.enabled) return false;
    if (cause == SelectionChangedCause.longPress || cause == SelectionChangedCause.stylusHandwriting) return true;
    return _controller.text.isNotEmpty;
  }

  void _handleSelectionChanged(TextSelection selection, SelectionChangedCause? cause) {
    final bool show = _shouldShowSelectionHandles(cause);
    if (show != _showSelectionHandles) setState(() => _showSelectionHandles = show);

    if (cause == SelectionChangedCause.longPress) editableText?.bringIntoView(selection.extent);
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS || TargetPlatform.linux || TargetPlatform.windows:
        if (cause == SelectionChangedCause.drag) editableText?.hideToolbar();
      case TargetPlatform.iOS || TargetPlatform.android || TargetPlatform.fuchsia:
        break;
    }
  }

  void _handleSelectionHandleTapped() {
    if (_controller.selection.isCollapsed) editableText?.toggleToolbar();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    final PrimeThemeData theme = PrimeTheme.of(context);
    final DefaultSelectionStyle selectionStyle = DefaultSelectionStyle.of(context);
    final TextStyle style = theme.textTheme.bodyDefault.copyWith(color: theme.colorScheme.inputText).merge(widget.style);
    final Color cursorColor = widget.cursorColor ?? selectionStyle.cursorColor ?? theme.colorScheme.inputFocus;
    final Color selectionColor =
        widget.selectionColor ?? selectionStyle.selectionColor ?? theme.colorScheme.inputFocus.withValues(alpha: 0.3);
    final FocusNode focusNode = _focusNode;
    final TextEditingController controller = _controller;
    _wasEmpty = controller.text.isEmpty;

    // The caret follows each platform's conventions; everything else is Prime's.
    final bool apple = defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS;
    final bool desktop = switch (defaultTargetPlatform) {
      TargetPlatform.macOS || TargetPlatform.linux || TargetPlatform.windows => true,
      TargetPlatform.android || TargetPlatform.iOS || TargetPlatform.fuchsia => false,
    };

    Widget child = RepaintBoundary(
      child: EditableText(
        key: editableTextKey,
        controller: controller,
        focusNode: focusNode,
        undoController: widget.undoController,
        readOnly: widget.readOnly || !widget.enabled,
        showCursor: widget.showCursor,
        showSelectionHandles: _showSelectionHandles,
        style: style,
        strutStyle: widget.strutStyle,
        textAlign: widget.textAlign,
        textDirection: widget.textDirection,
        obscureText: widget.obscureText,
        obscuringCharacter: widget.obscuringCharacter,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        textCapitalization: widget.textCapitalization,
        autocorrect: widget.autocorrect,
        enableSuggestions: widget.enableSuggestions,
        smartDashesType: widget.smartDashesType,
        smartQuotesType: widget.smartQuotesType,
        autofocus: widget.autofocus,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        expands: widget.expands,
        inputFormatters: widget.inputFormatters,
        autofillHints: widget.enabled ? widget.autofillHints : null,
        onChanged: widget.onChanged,
        onEditingComplete: widget.onEditingComplete,
        onSubmitted: widget.onSubmitted,
        onSelectionChanged: _handleSelectionChanged,
        onSelectionHandleTapped: _handleSelectionHandleTapped,
        onTapOutside: widget.onTapOutside,
        // The gesture detector below owns pointer handling and the mouse cursor.
        rendererIgnoresPointer: true,
        mouseCursor: MouseCursor.defer,
        cursorColor: cursorColor,
        backgroundCursorColor: theme.colorScheme.textPlaceholder,
        cursorWidth: widget.cursorWidth,
        cursorHeight: widget.cursorHeight,
        cursorRadius: widget.cursorRadius ?? (apple ? const Radius.circular(2.0) : null),
        cursorOpacityAnimates: defaultTargetPlatform == TargetPlatform.iOS,
        cursorOffset: apple ? Offset(-2 / MediaQuery.devicePixelRatioOf(context), 0) : null,
        paintCursorAboveText: apple,
        selectionColor: focusNode.hasFocus ? selectionColor : null,
        selectionHeightStyle: widget.selectionHeightStyle,
        selectionWidthStyle: widget.selectionWidthStyle,
        autocorrectionTextRectColor: defaultTargetPlatform == TargetPlatform.iOS ? selectionColor : null,
        selectionControls: selectionEnabled ? (widget.selectionControls ?? primeAdaptiveTextSelectionControls()) : null,
        enableInteractiveSelection: widget.enableInteractiveSelection,
        contextMenuBuilder: widget.contextMenuBuilder,
        magnifierConfiguration: widget.magnifierConfiguration ?? primeTextMagnifierConfiguration,
        keyboardAppearance: widget.keyboardAppearance ?? theme.brightness,
        scrollController: widget.scrollController,
        scrollPhysics: widget.scrollPhysics,
        scrollPadding: widget.scrollPadding,
        clipBehavior: widget.clipBehavior,
        dragStartBehavior: DragStartBehavior.start,
      ),
    );

    final String? placeholder = widget.placeholder;
    if (placeholder != null) {
      final TextStyle placeholderStyle = style.copyWith(color: theme.colorScheme.textTertiary).merge(widget.placeholderStyle);
      child = Stack(
        fit: widget.expands ? StackFit.expand : StackFit.passthrough,
        children: [
          if (controller.text.isEmpty)
            // Positioned, so that the placeholder never sizes the field.
            Positioned.fill(
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: Text(
                    placeholder,
                    style: placeholderStyle,
                    strutStyle: widget.strutStyle,
                    textAlign: widget.textAlign,
                    textDirection: widget.textDirection,
                    maxLines: widget.maxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          child,
        ],
      );
    }

    if (widget.decorationBuilder != null) child = widget.decorationBuilder!(context, child);

    // On desktop, assistive focus is input focus.
    final VoidCallback? onGainAccessibilityFocus = desktop
        ? () {
            if (!focusNode.hasFocus && focusNode.canRequestFocus) focusNode.requestFocus();
          }
        : null;

    return MouseRegion(
      cursor: widget.mouseCursor ?? (widget.enabled ? SystemMouseCursors.text : SystemMouseCursors.basic),
      child: TextFieldTapRegion(
        child: IgnorePointer(
          ignoring: !widget.enabled,
          child: Semantics(
            enabled: widget.enabled,
            hint: controller.text.isEmpty ? placeholder : null,
            onTap: widget.readOnly || !widget.enabled
                ? null
                : () {
                    if (!controller.selection.isValid) {
                      controller.selection = TextSelection.collapsed(offset: controller.text.length);
                    }
                    _requestKeyboard();
                  },
            onDidGainAccessibilityFocus: onGainAccessibilityFocus,
            onDidLoseAccessibilityFocus: desktop ? focusNode.unfocus : null,
            child: _gestures.buildGestureDetector(behavior: HitTestBehavior.translucent, child: child),
          ),
        ),
      ),
    );
  }
}

class _GestureBuilder extends TextSelectionGestureDetectorBuilder {
  _GestureBuilder(PrimeTextFieldState state) : _state = state, super(delegate: state);

  final PrimeTextFieldState _state;

  @override
  void onUserTap() => _state.widget.onTap?.call();
}
