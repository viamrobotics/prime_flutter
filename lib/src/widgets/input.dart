import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../prime_flutter.dart';

/// The validation state of an [Input], shown through its border and a
/// trailing status icon.
enum InputState { none, info, warn, error }

/// A text input widget: a [RawInput] in Prime's bordered box, with
/// optional leading and trailing icons and a validation state.
class Input extends StatefulWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final Widget? leading;
  final Widget? trailing;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final bool autofocus;
  final bool? autocorrect;
  final FocusNode? focusNode;
  final Iterable<String>? autofillHints;

  /// Renders the input dimmed and rejects all interaction.
  final bool disabled;

  /// Keeps the input focusable and selectable but not editable.
  final bool readOnly;

  /// The validation state. Anything other than [InputState.none] recolors the
  /// border and, when [trailing] is null, shows a status icon.
  final InputState state;

  /// Formatters applied to every edit, e.g. to restrict input to digits.
  final List<TextInputFormatter>? inputFormatters;

  /// Called when the input is tapped.
  final VoidCallback? onTap;

  /// The fewest lines to show. Above 1 the input becomes a multi-line field.
  final int? minLines;

  /// The most lines to show before scrolling. Null grows without limit.
  final int? maxLines;

  /// A compact 28px-tall variant for tool panels and dense layouts.
  final bool dense;

  const Input({
    super.key,
    this.controller,
    this.placeholder,
    this.leading,
    this.trailing,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.autocorrect,
    this.focusNode,
    this.autofillHints,
    this.disabled = false,
    this.readOnly = false,
    this.state = InputState.none,
    this.inputFormatters,
    this.onTap,
    this.minLines,
    this.maxLines = 1,
    this.dense = false,
  });

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  FocusNode? _internalFocusNode;
  FocusNode get _focusNode => widget.focusNode ?? (_internalFocusNode ??= FocusNode(debugLabel: 'Input'));

  @override
  void didUpdateWidget(Input oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != null && _internalFocusNode != null) {
      _internalFocusNode!.dispose();
      _internalFocusNode = null;
    }
  }

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final colors = theme.colorScheme;
    final dense = widget.dense;
    // Inside a Field, the field's disabled flag and state apply unless set here.
    final field = Field.maybeOf(context);
    final disabled = widget.disabled || (field?.disabled ?? false);
    final state = widget.state != InputState.none ? widget.state : (field?.state ?? InputState.none);
    final textStyle = dense ? theme.textTheme.bodySmall.copyWith(fontSize: 13, height: 1.2) : theme.textTheme.bodyDefault;
    final iconBox = dense ? const BoxConstraints(minWidth: 24, minHeight: 28) : const BoxConstraints(minWidth: 44, minHeight: 40);
    final iconPadding = EdgeInsets.symmetric(horizontal: dense ? 6 : 12);
    final (Color? stateColor, Color? stateIconColor, IconData? stateIcon) = switch (state) {
      InputState.none => (null, null, null),
      InputState.info => (null, colors.statusInfoDark, PrimeIcons.information),
      InputState.warn => (colors.statusWarningDark, colors.statusWarningBright, PrimeIcons.alert),
      InputState.error => (colors.statusDangerDark, colors.statusDangerDark, PrimeIcons.alertCircle),
    };
    final Widget? leading = widget.leading;
    final Widget? trailing =
        widget.trailing ??
        (stateIcon != null
            ? IconTheme.merge(
                data: IconThemeData(color: stateIconColor),
                child: Icon(stateIcon),
              )
            : null);
    final fillColor = disabled ? colors.surfaceHighlight : (widget.readOnly ? colors.surfaceOffset : colors.surfaceBase);
    final contentPadding = dense
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 6)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    final focusNode = _focusNode;

    Widget iconSlot(Widget icon) {
      return ConstrainedBox(
        constraints: iconBox,
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: Padding(
            padding: iconPadding,
            child: IconTheme(
              data: IconThemeData(color: colors.textTertiary, size: dense ? 16 : 20),
              child: icon,
            ),
          ),
        ),
      );
    }

    return RawInput(
      controller: widget.controller,
      focusNode: focusNode,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType ?? (widget.maxLines == 1 ? null : TextInputType.multiline),
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onSubmitted: (_) => widget.onSubmitted?.call(),
      autofocus: widget.autofocus,
      autocorrect: widget.autocorrect,
      autofillHints: widget.autofillHints,
      enabled: !disabled,
      readOnly: widget.readOnly,
      inputFormatters: widget.inputFormatters,
      onTap: widget.onTap,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      style: textStyle.copyWith(color: disabled ? colors.textPlaceholder : colors.inputText),
      placeholder: widget.placeholder,
      placeholderStyle: textStyle.copyWith(color: colors.textTertiary),
      cursorColor: colors.inputFocus,
      decorationBuilder: (context, editable) {
        return ListenableBuilder(
          listenable: focusNode,
          builder: (context, child) {
            // The border is painted over the box rather than laid out around
            // it, so the text does not shift when focus thickens it.
            final BorderSide side = disabled
                ? BorderSide(color: colors.borderSubtle)
                : focusNode.hasFocus
                ? BorderSide(color: stateColor ?? colors.inputFocus, width: 2)
                : BorderSide(color: stateColor ?? colors.borderSubtle);
            return Container(
              decoration: BoxDecoration(color: fillColor, borderRadius: BorderRadius.circular(theme.cornerRadius)),
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(theme.cornerRadius),
                border: Border.fromBorderSide(side),
              ),
              child: child,
            );
          },
          child: Row(
            children: [
              if (leading != null) iconSlot(leading),
              Expanded(
                child: Padding(
                  padding: contentPadding.copyWith(left: leading != null ? 0 : null, right: trailing != null ? 0 : null),
                  child: editable,
                ),
              ),
              if (trailing != null) iconSlot(trailing),
            ],
          ),
        );
      },
    );
  }
}
