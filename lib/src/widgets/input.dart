import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../prime_flutter.dart';

/// The validation state of an [Input], shown through its border and a
/// trailing status icon.
enum InputState { none, info, warn, error }

/// A text input widget. Lightly wraps a [TextField] with a [Material] widget.
class Input extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return PrimeTheme.consumer(
      builder: (context, theme) {
        final colors = theme.colorScheme;
        // Inside a Field, the field's disabled flag and state apply unless set here.
        final field = Field.maybeOf(context);
        final disabled = this.disabled || (field?.disabled ?? false);
        final state = this.state != InputState.none ? this.state : (field?.state ?? InputState.none);
        final textStyle = dense ? theme.textTheme.bodySmall.copyWith(fontSize: 13, height: 1.2) : theme.textTheme.bodyDefault;
        final iconBox = dense ? const BoxConstraints(minWidth: 24, minHeight: 28) : const BoxConstraints(minWidth: 44, minHeight: 40);
        final iconPadding = EdgeInsets.symmetric(horizontal: dense ? 6 : 12);
        final (Color? stateColor, Color? stateIconColor, IconData? stateIcon) = switch (state) {
          InputState.none => (null, null, null),
          InputState.info => (null, colors.statusInfoDark, PrimeIcons.information),
          InputState.warn => (colors.statusWarningDark, PrimeColors.warningBright, PrimeIcons.alert),
          InputState.error => (colors.statusDangerDark, colors.statusDangerDark, PrimeIcons.alertCircle),
        };
        final Widget? trailing =
            this.trailing ?? (stateIcon != null ? IconTheme.merge(data: IconThemeData(color: stateIconColor), child: Icon(stateIcon)) : null);
        final fillColor = disabled ? colors.surfaceHighlight : (readOnly ? colors.surfaceOffset : colors.surfaceBase);

        return Material(
          type: MaterialType.transparency,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            onChanged: onChanged,
            onSubmitted: (_) => onSubmitted?.call(),
            autofocus: autofocus,
            autocorrect: autocorrect,
            focusNode: focusNode,
            autofillHints: autofillHints,
            enabled: !disabled,
            readOnly: readOnly,
            inputFormatters: inputFormatters,
            onTap: onTap,
            minLines: minLines,
            maxLines: maxLines,
            style: textStyle.copyWith(color: disabled ? colors.textPlaceholder : colors.inputText),
            cursorColor: theme.colorScheme.inputFocus,
            decoration: InputDecoration(
              isDense: true,
              hintText: placeholder,
              hintStyle: textStyle.copyWith(color: theme.colorScheme.textTertiary),
              prefixIcon: leading != null
                  ? Padding(
                      padding: iconPadding,
                      child: IconTheme(
                        data: IconThemeData(color: theme.colorScheme.textTertiary, size: dense ? 16 : 20),
                        child: leading!,
                      ),
                    )
                  : null,
              prefixIconConstraints: iconBox,
              suffixIcon: trailing != null
                  ? Padding(
                      padding: iconPadding,
                      child: IconTheme(
                        data: IconThemeData(color: theme.colorScheme.textTertiary, size: dense ? 16 : 20),
                        child: trailing,
                      ),
                    )
                  : null,
              suffixIconConstraints: iconBox,
              filled: true,
              fillColor: fillColor,
              contentPadding: dense ? const EdgeInsets.symmetric(horizontal: 8, vertical: 6) : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(theme.cornerRadius),
                borderSide: BorderSide(color: stateColor ?? theme.colorScheme.borderSubtle),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(theme.cornerRadius),
                borderSide: BorderSide(color: theme.colorScheme.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(theme.cornerRadius),
                borderSide: BorderSide(color: stateColor ?? theme.colorScheme.inputFocus, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(theme.cornerRadius),
                borderSide: BorderSide(color: theme.colorScheme.statusDangerDark),
              ),
              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(theme.cornerRadius)),
            ),
          ),
        );
      },
    );
  }
}
