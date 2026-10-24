import 'package:flutter/material.dart';

import '../theme/link_ride_theme.dart';
import 'user_management_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  final String firstName;

  const AdminDashboardScreen({super.key, required this.firstName});

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
            _adminBanner(),
            const SizedBox(height: 18),
            const Text(
              'Administration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: LinkRideColors.textPrimary,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Role-specific management areas connected to the secured Link Ride backend.',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: LinkRideColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            _managementCard(
              icon: Icons.people_alt_outlined,
              title: 'User management',
              description: 'Review users and administer account access.',
              badge: 'Open',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const UserManagementScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _managementCard(
              icon: Icons.badge_outlined,
              title: 'Operator management',
              description:
                  'Administer operator access for transport operations.',
              badge: 'Next',
            ),
            const SizedBox(height: 12),
            _managementCard(
              icon: Icons.directions_transit_rounded,
              title: 'Providers & routes',
              description: 'Review the transport providers and route data used by Link Ride.',
              badge: 'Planned',
            ),
            const SizedBox(height: 12),
            _managementCard(
              icon: Icons.warning_amber_rounded,
              title: 'Disruption administration',
              description:
                  'Create, review and resolve operational disruptions.',
              badge: 'Next',
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Admin Dashboard',
                style: TextStyle(
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
            color: LinkRideColors.softGreen,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.admin_panel_settings_rounded,
            color: LinkRideColors.linkGreen,
          ),
        ),
      ],
    );
  }

  Widget _adminBanner() {
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
          Icon(Icons.security_rounded, color: Colors.white),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ADMIN access active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Administrative actions are protected by backend RBAC.',
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

  Widget _managementCard({
    required IconData icon,
    required String title,
    required String description,
    required String badge,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(LinkRideRadius.extraLarge),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: LinkRideDecorations.card(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: LinkRideColors.softGreen,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: LinkRideColors.linkGreen),
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
                          color: LinkRideColors.softBlue,
                          borderRadius: BorderRadius.circular(
                            LinkRideRadius.pill,
                          ),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: LinkRideColors.primaryBlue,
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
      ),
    );
  }
}
