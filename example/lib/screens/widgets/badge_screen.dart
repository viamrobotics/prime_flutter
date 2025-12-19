import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

class BadgeScreen extends StatelessWidget {
  const BadgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    return PrimeScaffold(
      appBar: const PrimeAppBar(title: Text('Badge')),
      body: Column(
        children: [
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Badges', style: theme.textTheme.heading.copyWith(fontSize: 32)),
                  const SizedBox(height: 8),
                  Text(
                    'Badges are used to highlight important information or status.',
                    style: theme.textTheme.bodyDefault.copyWith(color: theme.colorScheme.textSecondary),
                  ),
                  const SizedBox(height: 32),

                  // Status Examples
                  _buildSection(
                    context,
                    title: 'Examples',
                    description: 'Common use cases for badges.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusRow(context, 'USER ROLES:', const [
                          Badge(variant: BadgeVariant.info, child: Text('OWNER')),
                          Badge(variant: BadgeVariant.neutral, child: Text('OPERATOR')),
                        ]),
                        const SizedBox(height: 16),
                        _buildStatusRow(context, 'CONNECTION STATUS:', const [
                          Badge(
                            variant: BadgeVariant.success,
                            icon: Icon(PrimeIcons.broadcast),
                            showBackground: false,
                            child: Text('ONLINE'),
                          ),
                          Badge(
                            variant: BadgeVariant.danger,
                            icon: Icon(PrimeIcons.broadcastOff),
                            showBackground: false,
                            child: Text('OFFLINE'),
                          ),
                          Badge(
                            variant: BadgeVariant.info,
                            icon: Icon(PrimeIcons.selectionEllipse),
                            showBackground: false,
                            child: Text('AWAITING SETUP'),
                          ),
                        ]),
                        const SizedBox(height: 16),
                        _buildStatusRow(context, 'COMPONENT TYPE:', const [
                          Badge(variant: BadgeVariant.neutral, child: Text('BOARD')),
                          Badge(variant: BadgeVariant.neutral, child: Text('SENSOR')),
                          Badge(variant: BadgeVariant.neutral, child: Text('ARM')),
                          Badge(variant: BadgeVariant.neutral, child: Text('SERVO')),
                          Badge(variant: BadgeVariant.neutral, child: Text('MOTOR')),
                          Badge(variant: BadgeVariant.neutral, child: Text('GANTRY')),
                          Badge(variant: BadgeVariant.neutral, child: Text('MOVEMENT SENSOR')),
                          Badge(variant: BadgeVariant.neutral, child: Text('POWER SENSOR')),
                          Badge(variant: BadgeVariant.neutral, child: Text('AUDIO INPUT')),
                        ]),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Basic Variants
                  _buildSection(
                    context,
                    title: 'Variants',
                    description: 'Badges come in different variants to convey different meanings.',
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: const [
                        Badge(variant: BadgeVariant.success, child: Text('SUCCESS')),
                        Badge(variant: BadgeVariant.danger, child: Text('DANGER')),
                        Badge(variant: BadgeVariant.warning, child: Text('WARNING')),
                        Badge(variant: BadgeVariant.info, child: Text('INFO')),
                        Badge(variant: BadgeVariant.neutral, child: Text('NEUTRAL')),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // With Icons
                  _buildSection(
                    context,
                    title: 'With Icons',
                    description: 'Badges can include icons for additional context.',
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: const [
                        Badge(variant: BadgeVariant.success, icon: Icon(PrimeIcons.checkCircle), child: Text('ACTIVE')),
                        Badge(variant: BadgeVariant.danger, icon: Icon(PrimeIcons.alertCircle), child: Text('ERROR')),
                        Badge(variant: BadgeVariant.warning, icon: Icon(PrimeIcons.alertOutline), child: Text('WARNING')),
                        Badge(variant: BadgeVariant.info, icon: Icon(PrimeIcons.information), child: Text('INFO')),
                        Badge(variant: BadgeVariant.neutral, icon: Icon(PrimeIcons.clockOutline), child: Text('PENDING')),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Show Background
                  _buildSection(
                    context,
                    title: 'Show Background',
                    description: 'Badges can be configured to show or hide the background.',
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: const [
                        Badge(
                          variant: BadgeVariant.success,
                          icon: Icon(PrimeIcons.broadcast),
                          showBackground: false,
                          child: Text('ONLINE'),
                        ),
                        Badge(
                          variant: BadgeVariant.danger,
                          icon: Icon(PrimeIcons.broadcastOff),
                          showBackground: false,
                          child: Text('OFFLINE'),
                        ),
                        Badge(variant: BadgeVariant.warning, showBackground: false, child: Text('WARNING')),
                        Badge(
                          variant: BadgeVariant.info,
                          icon: Icon(PrimeIcons.selectionEllipse),
                          showBackground: false,
                          child: Text('AWAITING SETUP'),
                        ),
                        Badge(variant: BadgeVariant.neutral, showBackground: false, child: Text('NEUTRAL')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required String description, required Widget child}) {
    final theme = PrimeTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.heading),
        const SizedBox(height: 8),
        Text(description, style: theme.textTheme.bodySmall.copyWith(color: theme.colorScheme.textSecondary)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: theme.colorScheme.surfaceOffset, borderRadius: BorderRadius.circular(theme.cornerRadius)),
          child: child,
        ),
      ],
    );
  }

  Widget _buildStatusRow(BuildContext context, String label, List<Badge> badges) {
    final theme = PrimeTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: badges),
      ],
    );
  }
}
