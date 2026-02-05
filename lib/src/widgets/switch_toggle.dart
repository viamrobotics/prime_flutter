import 'package:flutter/widgets.dart';

import '../theme/prime_theme.dart';

/// A switch toggle widget.
///
/// Used to toggle a boolean state on or off.
class SwitchToggle extends StatelessWidget {
  /// Whether the switch is on or off.
  final bool value;

  /// Called when the user toggles the switch.
  final ValueChanged<bool>? onChanged;

  /// Whether the switch is disabled.
  final bool disabled;

  /// Custom color for the track when the switch is on.
  final Color? activeColor;

  /// Custom color for the track when the switch is off.
  final Color? inactiveColor;

  const SwitchToggle({super.key, required this.value, this.onChanged, this.disabled = false, this.activeColor, this.inactiveColor});

  @override
  Widget build(BuildContext context) {
    return PrimeTheme.consumer(
      builder: (context, theme) {
        final colors = theme.colorScheme;
        final cornerRadius = theme.cornerRadius;
        final isInteractive = !disabled && onChanged != null;

        // Colors
        // Off state: surfaceHighlight (gray)
        // On state: actionPrimaryBg (black/primary)
        // Disabled: reduce opacity
        Color trackColor;
        Color knobColor;

        if (value) {
          trackColor = activeColor ?? colors.actionPrimaryBg;
          knobColor = colors.actionPrimaryFg;
        } else {
          trackColor = inactiveColor ?? colors.surfaceHighlight;
          knobColor = colors.surfaceBase;
        }

        if (disabled) {
          trackColor = trackColor.withValues(alpha: 0.5);
          knobColor = knobColor.withValues(alpha: 0.5);
        }

        return MouseRegion(
          cursor: isInteractive ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: isInteractive ? () => onChanged!(!value) : null,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 44,
              height: 24,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: trackColor,
                borderRadius: BorderRadius.circular(cornerRadius),
                border: Border.all(color: value ? trackColor : colors.borderSubtle, width: 1),
              ),
              child: Stack(
                children: [
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: knobColor,
                        borderRadius: BorderRadius.circular(cornerRadius - 2),
                        boxShadow: [BoxShadow(color: const Color(0x1F000000), blurRadius: 1, offset: const Offset(0, 1))],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
