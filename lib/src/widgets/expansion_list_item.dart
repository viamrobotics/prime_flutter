import 'package:flutter/widgets.dart';
import '../theme/prime_theme.dart';
import 'prime_icons.dart';

/// A widget users can tap to show or hide a list of children.
class ExpansionListItem extends StatefulWidget {
  /// The title of the expansion list item.
  final Widget title;

  /// The widget to show before the title, on the left.
  final Widget? leading;

  /// The widget to show after the title, on the right of the widget.
  final Widget? trailing;

  /// The list of children to be displayed when the expansion list item is expanded.
  final List<Widget> children;

  /// Whether the expansion list item should be expanded by default.
  final bool initiallyExpanded;

  /// A callback function to be called when the expansion list item is expanded or collapsed.
  final ValueChanged<bool>? onExpansionChanged;

  /// Whether the expansion list item should be displayed as a card.
  final bool _isCard;

  /// Creates an expansion list item.
  const ExpansionListItem({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.children = const <Widget>[],
    this.initiallyExpanded = false,
    this.onExpansionChanged,
  }) : _isCard = false;

  /// Creates an expansion list item that is displayed as a card.
  const ExpansionListItem.card({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.children = const <Widget>[],
    this.initiallyExpanded = false,
    this.onExpansionChanged,
  }) : _isCard = true;

  @override
  State<ExpansionListItem> createState() => _ExpansionListItemState();
}

class _ExpansionListItemState extends State<ExpansionListItem> {
  late ExpansibleController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ExpansibleController();
    if (widget.initiallyExpanded) {
      _controller.expand();
    }
    _controller.addListener(_handleExpansionChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleExpansionChange);
    _controller.dispose();
    super.dispose();
  }

  void _handleExpansionChange() {
    widget.onExpansionChanged?.call(_controller.isExpanded);
  }

  void _handleTap() {
    if (_controller.isExpanded) {
      _controller.collapse();
    } else {
      _controller.expand();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PrimeTheme.consumer(
      builder: (context, theme) {
        final Color backgroundColor = widget._isCard ? theme.colorScheme.surfaceOffset : const Color(0x00000000);
        final BoxBorder? border = widget._isCard ? Border.all(color: theme.colorScheme.borderSubtle) : null;
        final BorderRadius? borderRadius = widget._isCard ? BorderRadius.circular(theme.cornerRadius) : null;

        return Container(
          decoration: BoxDecoration(color: backgroundColor, border: border, borderRadius: borderRadius),
          child: Expansible(
            controller: _controller,
            headerBuilder: (context, animation) {
              return GestureDetector(
                onTap: _handleTap,
                behavior: HitTestBehavior.opaque,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        RotationTransition(
                          turns: Tween<double>(begin: 0.0, end: 0.25).animate(animation),
                          child: Icon(PrimeIcons.chevronRight, color: theme.colorScheme.iconSecondary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        if (widget.leading != null) ...[
                          IconTheme(
                            data: IconThemeData(
                              color: widget._isCard ? theme.colorScheme.iconSecondary : theme.colorScheme.iconPrimary,
                              size: 20,
                            ),
                            child: widget.leading!,
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: DefaultTextStyle(
                            style: theme.textTheme.bodyDefault.copyWith(fontWeight: FontWeight.w500, color: theme.colorScheme.textPrimary),
                            child: widget.title,
                          ),
                        ),
                        if (widget.trailing != null) ...[const SizedBox(width: 12), widget.trailing!],
                      ],
                    ),
                  ),
                ),
              );
            },
            bodyBuilder: (context, animation) {
              return Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: widget.children),
              );
            },
          ),
        );
      },
    );
  }
}
