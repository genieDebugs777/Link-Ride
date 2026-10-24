import 'package:flutter/material.dart';

import '../theme/link_ride_theme.dart';

class OperatorConsoleScreen extends StatelessWidget {
  final String firstName;

  const OperatorConsoleScreen({super.key, required this.firstName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LinkRideColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          children: [
            _header(),
            const SizedBox(height: 20),
            _roleBanner(),
            const SizedBox(height: 18),
            _sectionTitle(
              'Operations workspace',
              'Manage service information without leaving the Link Ride app.',
            ),
            const SizedBox(height: 12),
            _workspaceCard(
              icon: Icons.warning_amber_rounded,
              title: 'Active disruptions',
              description: 'Review current service disruptions across the controlled demo network.',
              badge: 'Next',
            ),
            const SizedBox(height: 12),
            _workspaceCard(
              icon: Icons.add_alert_outlined,
              title: 'Create disruption',
              description: 'Publish a new operational disruption for an affected route or provider.',
              badge: 'Next',
            ),
            const SizedBox(height: 12),
            _workspaceCard(
              icon: Icons.task_alt_rounded,
              title: 'Resolve disruption',
              description:
                  'Close active incidents when service has returned to normal.',
              badge: 'Next',
            ),
            const SizedBox(height: 12),
            _workspaceCard(
              icon: Icons.hub_outlined,
              title: 'Network overview',
              description: 'View the routes and providers represented in the deployed academic demo.',
              badge: 'Planned',
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Operator Console',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.7,
                  color: LinkRideColors.textPrimary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Welcome, $firstName',
                style: const TextStyle(
                  fontSize: 14,
                  color: LinkRideColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: LinkRideColors.softBlue,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.monitor_heart_rounded,
            color: LinkRideColors.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _roleBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinkRideGradients.primary,
        borderRadius: BorderRadius.circular(LinkRideRadius.extraLarge),
        boxShadow: LinkRideShadows.elevated,
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_rounded, color: Colors.white),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OPERATOR access active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Your authenticated role can create and resolve disruptions. Backend RBAC remains the security boundary.',
                  style: TextStyle(
                    color: Colors.white,
                    height: 1.4,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: LinkRideColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            height: 1.4,
            color: LinkRideColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _workspaceCard({
    required IconData icon,
    required String title,
    required String description,
    required String badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: LinkRideDecorations.card(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: LinkRideColors.softBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: LinkRideColors.primaryBlue),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: LinkRideColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: LinkRideColors.softGreen,
                        borderRadius: BorderRadius.circular(
                          LinkRideRadius.pill,
                        ),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: LinkRideColors.linkGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: LinkRideColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
