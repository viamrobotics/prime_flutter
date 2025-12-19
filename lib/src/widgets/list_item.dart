import 'package:flutter/widgets.dart';
import '../theme/prime_theme.dart';

enum _ListItemVariant { standard, card }

/// A widget for building lists of items.
class ListItem extends StatefulWidget {
  /// The leading widget of the list item. A widget to be displayed before the title.
  final Widget? leading;

  /// The title of the list item.
  final Widget? title;

  /// The subtitle of the list item.
  final Widget? subtitle;

  /// The trailing widget of the list item. A widget to be displayed after the title.
  final Widget? trailing;

  /// The callback function to be called when the list item is tapped.
  final VoidCallback? onPressed;

  final bool isThreeLine;
  final _ListItemVariant _variant;

  /// Creates a standard list item.
  const ListItem({super.key, this.leading, this.title, this.subtitle, this.trailing, this.onPressed, this.isThreeLine = false})
    : _variant = _ListItemVariant.standard;

  /// Creates a card list item.
  const ListItem.card({super.key, this.leading, this.title, this.subtitle, this.trailing, this.onPressed, this.isThreeLine = false})
    : _variant = _ListItemVariant.card;

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return PrimeTheme.consumer(
      builder: (context, theme) {
        final isInteractive = widget.onPressed != null;
        final isCard = widget._variant == _ListItemVariant.card;

        Color? backgroundColor;
        Color? borderColor;

        if (isCard) {
          backgroundColor = theme.colorScheme.surfaceOffset;
          borderColor = theme.colorScheme.borderSubtle;

          if (isInteractive) {
            if (_isPressed) {
              backgroundColor = theme.colorScheme.surfaceHighlight; // darker state
            } else if (_isHovered) {
              backgroundColor = theme.colorScheme.surfaceHighlight;
            }
          }
        } else if (isInteractive) {
          if (_isPressed) {
            backgroundColor = theme.colorScheme.surfaceHighlight;
          } else if (_isHovered) {
            backgroundColor = theme.colorScheme.surfaceOffset;
          }
        }

        Widget content = Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.leading != null) ...[
              IconTheme(
                data: IconThemeData(color: isCard ? theme.colorScheme.iconSecondary : theme.colorScheme.iconPrimary, size: 20),
                child: widget.leading!,
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.title != null)
                    DefaultTextStyle(
                      style: theme.textTheme.bodyDefault.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.textPrimary,
                        height: 1,
                      ),
                      child: widget.title!,
                    ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 4),
                    DefaultTextStyle(
                      style: theme.textTheme.bodySmall.copyWith(color: theme.colorScheme.textSecondary),
                      child: widget.subtitle!,
                    ),
                  ],
                ],
              ),
            ),
            if (widget.trailing != null) ...[const SizedBox(width: 16), widget.trailing!],
          ],
        );

        // Add padding
        content = Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15), child: content);

        // Decoration
        if (isCard || isInteractive) {
          content = AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: backgroundColor ?? const Color(0x00000000),
              borderRadius: isCard ? BorderRadius.circular(theme.cornerRadius) : null,
              border: borderColor != null ? Border.all(color: borderColor) : null,
            ),
            child: content,
          );
        }

        if (isInteractive) {
          return MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              onTap: widget.onPressed,
              behavior: HitTestBehavior.opaque,
              child: content,
            ),
          );
        }

        return content;
      },
    );
  }
}
