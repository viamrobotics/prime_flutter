import 'package:flutter/widgets.dart';
import '../theme/prime_theme.dart';

class Card extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? status;
  final VoidCallback? onTap;
  final VoidCallback? onMenuTap;

  const Card({
    super.key,
    required this.title,
    this.subtitle,
    this.status,
    this.onTap,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return PrimeTheme.consumer(
      builder: (context, theme) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.white,
              border: Border.all(color: theme.colorScheme.borderLight),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x0D000000), // Black with opacity
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (subtitle != null) ...[
                              Text(
                                subtitle!,
                                style: theme.textTheme.bodySmall.copyWith(
                                  color: theme.colorScheme.textSubtle2,
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                            Text(title, style: theme.textTheme.title),
                          ],
                        ),
                      ),
                      if (onMenuTap != null)
                        GestureDetector(
                          onTap: onMenuTap,
                          child: Icon(
                            const IconData(
                              0xe3c9,
                              fontFamily: 'MaterialIcons',
                            ), // more_horiz
                            color: theme.colorScheme.textSubtle2,
                          ),
                        ),
                      const SizedBox(width: 8),
                      Icon(
                        const IconData(
                          0xe5cc,
                          fontFamily: 'MaterialIcons',
                        ), // chevron_right
                        color: theme.colorScheme.textSubtle2,
                      ),
                    ],
                  ),
                  if (status != null) ...[const SizedBox(height: 12), status!],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
