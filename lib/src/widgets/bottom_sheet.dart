import 'package:flutter/material.dart' show showModalBottomSheet;
import 'package:flutter/widgets.dart';

import '../../prime_flutter.dart';

class BottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final Color? backgroundColor;
  final bool isScrollable;

  const BottomSheet({super.key, required this.child, this.title, this.backgroundColor, this.isScrollable = true});

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    Color? backgroundColor,
    bool isScrollable = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: const Color(0x00000000),
      builder: (context) => BottomSheet(title: title, backgroundColor: backgroundColor, isScrollable: isScrollable, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PrimeTheme.consumer(
      builder: (context, theme) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor ?? theme.colorScheme.bgExtraLight,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [BoxShadow(color: const Color(0x1A000000), blurRadius: 10, offset: const Offset(0, -2))],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(color: theme.colorScheme.gray3, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  if (title != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Text(title!, style: theme.textTheme.bodyDefault.copyWith(fontWeight: FontWeight.w600, fontSize: 18)),
                    ),
                  Flexible(child: isScrollable ? SingleChildScrollView(child: child) : child),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
