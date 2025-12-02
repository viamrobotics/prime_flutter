import 'package:flutter/material.dart';
import '../../prime_flutter.dart';

class Input extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final Widget? leading;
  final Widget? trailing;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final bool autofocus;

  const Input({
    super.key,
    this.controller,
    this.placeholder,
    this.leading,
    this.trailing,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return PrimeTheme.consumer(
      builder: (context, theme) {
        return Material(
          type: MaterialType.transparency,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: onChanged,
            onSubmitted: (_) => onSubmitted?.call(),
            autofocus: autofocus,
            style: theme.textTheme.bodyDefault.copyWith(color: theme.colorScheme.textDefault),
            cursorColor: theme.colorScheme.infoDark,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: theme.textTheme.bodyDefault.copyWith(color: theme.colorScheme.textSubtle2),
              prefixIcon: leading != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: IconTheme(
                        data: IconThemeData(color: theme.colorScheme.textSubtle2, size: 20),
                        child: leading!,
                      ),
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 40),
              suffixIcon: trailing != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: IconTheme(
                        data: IconThemeData(color: theme.colorScheme.textSubtle2, size: 20),
                        child: trailing!,
                      ),
                    )
                  : null,
              suffixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 40),
              filled: true,
              fillColor: theme.colorScheme.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(theme.cornerRadius),
                borderSide: BorderSide(color: theme.colorScheme.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(theme.cornerRadius),
                borderSide: BorderSide(color: theme.colorScheme.infoDark, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(theme.cornerRadius),
                borderSide: BorderSide(color: theme.colorScheme.danger),
              ),
              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(theme.cornerRadius)),
            ),
          ),
        );
      },
    );
  }
}
