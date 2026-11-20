import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'field.dart';
import 'input.dart';
import 'label.dart';

/// An [Input] that takes part in a [Form]: the Prime counterpart of Material's `TextFormField`.
///
/// [validator] runs when the enclosing [FormState.validate] is called, or as the user types when [autovalidateMode]
/// says so. A non-null result puts the field in [InputState.error] and shows the message under the input in place of
/// [hint].
///
/// ```dart
/// final formKey = GlobalKey<FormState>();
///
/// Form(
///   key: formKey,
///   child: InputFormField(
///     controller: ssid,
///     label: const Text('Network name'),
///     validator: (value) => (value ?? '').isEmpty ? 'Enter a network name' : null,
///   ),
/// );
///
/// if (formKey.currentState!.validate()) { ... }
/// ```
class InputFormField extends FormField<String> {
  /// Controls the text. When null the field keeps its own, starting from [initialValue].
  final TextEditingController? controller;

  InputFormField({
    super.key,
    this.controller,
    String? initialValue,
    super.validator,
    super.onSaved,
    super.autovalidateMode = AutovalidateMode.disabled,
    super.enabled = true,
    super.restorationId,
    Widget? label,
    Widget? hint,
    bool required = false,
    String? placeholder,
    Widget? leading,
    Widget? trailing,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    ValueChanged<String>? onChanged,
    VoidCallback? onSubmitted,
    bool autofocus = false,
    bool? autocorrect,
    FocusNode? focusNode,
    Iterable<String>? autofillHints,
    bool readOnly = false,
    List<TextInputFormatter>? inputFormatters,
    VoidCallback? onTap,
    bool dense = false,
  }) : assert(controller == null || initialValue == null, 'Pass a controller or an initialValue, not both.'),
       super(
         initialValue: controller?.text ?? initialValue ?? '',
         builder: (field) {
           final state = field as _InputFormFieldState;
           final message = field.errorText;
           return Field(
             required: required,
             disabled: !field.widget.enabled,
             state: message != null ? InputState.error : InputState.none,
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.stretch,
               mainAxisSize: MainAxisSize.min,
               spacing: 4,
               children: [
                 if (label != null) Label(label: label),
                 Input(
                   controller: state._effectiveController,
                   placeholder: placeholder,
                   leading: leading,
                   trailing: trailing,
                   obscureText: obscureText,
                   keyboardType: keyboardType,
                   textInputAction: textInputAction,
                   onChanged: (value) {
                     field.didChange(value);
                     onChanged?.call(value);
                   },
                   onSubmitted: onSubmitted,
                   autofocus: autofocus,
                   autocorrect: autocorrect,
                   focusNode: focusNode,
                   autofillHints: autofillHints,
                   readOnly: readOnly,
                   inputFormatters: inputFormatters,
                   onTap: onTap,
                   dense: dense,
                 ),
                 if (message != null) Hint(child: Text(message)) else if (hint != null) Hint(child: hint),
               ],
             ),
           );
         },
       );

  @override
  FormFieldState<String> createState() => _InputFormFieldState();
}

class _InputFormFieldState extends FormFieldState<String> {
  TextEditingController? _controller;

  InputFormField get _field => super.widget as InputFormField;

  TextEditingController get _effectiveController => _field.controller ?? _controller!;

  @override
  void initState() {
    super.initState();
    if (_field.controller == null) _controller = TextEditingController(text: _field.initialValue);
    _effectiveController.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(InputFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_field.controller == oldWidget.controller) return;
    (oldWidget.controller ?? _controller)?.removeListener(_handleControllerChanged);
    if (oldWidget.controller != null && _field.controller == null) {
      _controller = TextEditingController(text: oldWidget.controller!.text);
    }
    if (_field.controller != null) {
      _controller?.dispose();
      _controller = null;
      setValue(_field.controller!.text);
    }
    _effectiveController.addListener(_handleControllerChanged);
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_handleControllerChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void reset() {
    _effectiveController.text = _field.initialValue ?? '';
    super.reset();
  }

  // Keeps the form value in step with text set on the controller from outside the input.
  void _handleControllerChanged() {
    if (_effectiveController.text != value) didChange(_effectiveController.text);
  }
}
