import 'package:flutter/widgets.dart';
import '../theme/prime_theme.dart';

class PrimeTabBar extends StatefulWidget {
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const PrimeTabBar({super.key, required this.items, required this.selectedIndex, required this.onDestinationSelected});

  @override
  State<PrimeTabBar> createState() => _PrimeTabBarState();
}

class _PrimeTabBarState extends State<PrimeTabBar> {
  final ScrollController _scrollController = ScrollController();
  bool _showLeftFade = false;
  bool _showRightFade = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateFadeState);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFadeState());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateFadeState);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateFadeState() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final showLeft = position.pixels > 0;
    final showRight = position.pixels < position.maxScrollExtent;

    if (showLeft != _showLeftFade || showRight != _showRightFade) {
      setState(() {
        _showLeftFade = showLeft;
        _showRightFade = showRight;
      });
    }
  }

  @override
  void didUpdateWidget(PrimeTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items.length != oldWidget.items.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateFadeState());
    }
  }

  @override
  Widget build(BuildContext context) {
    return PrimeTheme.consumer(
      builder: (context, theme) {
        return SizedBox(
          height: 44,
          child: Stack(
            children: [
              ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  final isSelected = index == widget.selectedIndex;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => widget.onDestinationSelected(index),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        margin: EdgeInsets.only(right: index == widget.items.length - 1 ? 0 : 24),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: isSelected ? theme.colorScheme.gray9 : const Color(0x00000000), width: 2),
                          ),
                        ),
                        child: Text(
                          item.toUpperCase(),
                          style: theme.textTheme.label.copyWith(
                            fontWeight: FontWeight.w400,
                            color: isSelected ? theme.colorScheme.gray9 : theme.colorScheme.gray5,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (_showLeftFade)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 24,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [theme.colorScheme.bgExtraLight, theme.colorScheme.bgExtraLight.withOpacity(0)],
                        ),
                      ),
                    ),
                  ),
                ),
              if (_showRightFade)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: 24,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [theme.colorScheme.bgExtraLight, theme.colorScheme.bgExtraLight.withOpacity(0)],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
