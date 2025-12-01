import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

class BadgeScreen extends StatelessWidget {
  const BadgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      appBar: // Header with back button
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(PrimeIcons.chevronLeft, size: 20),
                      SizedBox(width: 4),
                      Text('Back', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const Text('Badge', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Badges', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    'Badges are used to highlight important information or status.',
                    style: TextStyle(fontSize: 16, color: Color(0xFF757575)),
                  ),
                  const SizedBox(height: 32),

                  // Status Examples
                  _buildSection(
                    title: 'Examples',
                    description: 'Common use cases for badges.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusRow('USER ROLES:', const [
                          Badge(text: 'OWNER', variant: BadgeVariant.info),
                          Badge(text: 'OPERATOR', variant: BadgeVariant.neutral),
                        ]),
                        const SizedBox(height: 16),
                        _buildStatusRow('CONNECTION STATUS:', const [
                          Badge(text: 'ONLINE', variant: BadgeVariant.success, icon: Icon(PrimeIcons.broadcast), showBackground: false),
                          Badge(text: 'OFFLINE', variant: BadgeVariant.danger, icon: Icon(PrimeIcons.broadcastOff), showBackground: false),
                          Badge(
                            text: 'AWAITING SETUP',
                            variant: BadgeVariant.info,
                            icon: Icon(PrimeIcons.selectionEllipse),
                            showBackground: false,
                          ),
                        ]),
                        const SizedBox(height: 16),
                        _buildStatusRow('COMPONENT TYPE:', const [
                          Badge(text: 'BOARD', variant: BadgeVariant.neutral),
                          Badge(text: 'SENSOR', variant: BadgeVariant.neutral),
                          Badge(text: 'ARM', variant: BadgeVariant.neutral),
                          Badge(text: 'SERVO', variant: BadgeVariant.neutral),
                          Badge(text: 'MOTOR', variant: BadgeVariant.neutral),
                          Badge(text: 'GANTRY', variant: BadgeVariant.neutral),
                          Badge(text: 'MOVEMENT SENSOR', variant: BadgeVariant.neutral),
                          Badge(text: 'POWER SENSOR', variant: BadgeVariant.neutral),
                          Badge(text: 'AUDIO INPUT', variant: BadgeVariant.neutral),
                        ]),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Basic Variants
                  _buildSection(
                    title: 'Variants',
                    description: 'Badges come in different variants to convey different meanings.',
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: const [
                        Badge(text: 'SUCCESS', variant: BadgeVariant.success),
                        Badge(text: 'DANGER', variant: BadgeVariant.danger),
                        Badge(text: 'WARNING', variant: BadgeVariant.warning),
                        Badge(text: 'INFO', variant: BadgeVariant.info),
                        Badge(text: 'NEUTRAL', variant: BadgeVariant.neutral),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // With Icons
                  _buildSection(
                    title: 'With Icons',
                    description: 'Badges can include icons for additional context.',
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: const [
                        Badge(text: 'ACTIVE', variant: BadgeVariant.success, icon: Icon(PrimeIcons.checkCircle)),
                        Badge(text: 'ERROR', variant: BadgeVariant.danger, icon: Icon(PrimeIcons.alertCircle)),
                        Badge(text: 'WARNING', variant: BadgeVariant.warning, icon: Icon(PrimeIcons.alertOutline)),
                        Badge(text: 'INFO', variant: BadgeVariant.info, icon: Icon(PrimeIcons.information)),
                        Badge(text: 'PENDING', variant: BadgeVariant.neutral, icon: Icon(PrimeIcons.clockOutline)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Show Background
                  _buildSection(
                    title: 'Show Background',
                    description: 'Badges can be configured to show or hide the background.',
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: const [
                        Badge(text: 'ONLINE', variant: BadgeVariant.success, icon: Icon(PrimeIcons.broadcast), showBackground: false),
                        Badge(text: 'OFFLINE', variant: BadgeVariant.danger, icon: Icon(PrimeIcons.broadcastOff), showBackground: false),
                        Badge(text: 'WARNING', variant: BadgeVariant.warning, showBackground: false),
                        Badge(
                          text: 'AWAITING SETUP',
                          variant: BadgeVariant.info,
                          icon: Icon(PrimeIcons.selectionEllipse),
                          showBackground: false,
                        ),
                        Badge(text: 'NEUTRAL', variant: BadgeVariant.neutral, showBackground: false),
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

  Widget _buildSection({required String title, required String description, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(description, style: const TextStyle(fontSize: 14, color: Color(0xFF757575))),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
          child: child,
        ),
      ],
    );
  }

  Widget _buildStatusRow(String label, List<Badge> badges) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: badges),
      ],
    );
  }
}
