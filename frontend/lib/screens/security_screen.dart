import 'package:flutter/material.dart';

class SecurityScreen extends StatelessWidget {
  final Map<String, dynamic> userProfile;

  const SecurityScreen({
    super.key,
    required this.userProfile,
  });

  static const Color primaryBlue = Color(0xFF003F73);
  static const Color linkGreen = Color(0xFF4A9B45);
  static const Color background = Color(0xFFF7F9FB);
  static const Color textPrimary = Color(0xFF17212B);
  static const Color textSecondary = Color(0xFF667085);
  static const Color cardBorder = Color(0xFFE4E9EE);

  @override
  Widget build(BuildContext context) {
    final String email =
        userProfile['email']?.toString() ?? 'Not available';

    final String accountStatus =
        userProfile['accountStatus']?.toString() ?? 'Unknown';

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: background,
        elevation: 0,
        title: const Text(
          'Security',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: primaryBlue,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Account security',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Review your Link Ride account and current authentication information.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: textSecondary,
                ),
              ),

              const SizedBox(height: 26),

              // ───────────────── SECURITY STATUS ─────────────────

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: linkGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: linkGreen.withValues(alpha: 0.20),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_user_outlined,
                        color: linkGreen,
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 14),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account protected',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),

                          SizedBox(height: 5),

                          Text(
                            'You are signed in through an authenticated Link Ride session.',
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.4,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              // ───────────────── ACCOUNT ─────────────────

              _sectionTitle('ACCOUNT'),

              _securityCard(
                children: [
                  _informationTile(
                    icon: Icons.alternate_email_rounded,
                    title: 'Signed-in email',
                    value: email,
                  ),

                  _divider(),

                  _informationTile(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'Account status',
                    value: _formatStatus(accountStatus),
                    valueColor:
                        accountStatus.toUpperCase() == 'ACTIVE'
                            ? linkGreen
                            : textSecondary,
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ───────────────── AUTHENTICATION ─────────────────

              _sectionTitle('AUTHENTICATION'),

              _securityCard(
                children: [
                  _informationTile(
                    icon: Icons.password_rounded,
                    title: 'Authentication method',
                    value: 'Password',
                  ),

                  _divider(),

                  _informationTile(
                    icon: Icons.key_rounded,
                    title: 'Current session',
                    value: 'Secure JWT authentication',
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ───────────────── SECURITY INFORMATION ─────────────────

              _sectionTitle('SECURITY INFORMATION'),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3F8),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lock_person_outlined,
                      size: 22,
                      color: primaryBlue,
                    ),

                    SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        'Link Ride protects account passwords using secure '
                        'password hashing. Authenticated requests use your '
                        'signed-in session, and your password is never '
                        'displayed by the app.',
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.5,
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatStatus(String status) {
    if (status.isEmpty) {
      return 'Unknown';
    }

    final String lower = status.toLowerCase();

    return '${lower[0].toUpperCase()}${lower.substring(1)}';
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 4,
        bottom: 9,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: textSecondary,
        ),
      ),
    );
  }

  Widget _securityCard({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.018),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _informationTile({
    required IconData icon,
    required String title,
    required String value,
    Color valueColor = textPrimary,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3F8),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              size: 21,
              color: primaryBlue,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: textSecondary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.only(left: 72),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Color(0xFFEEF1F4),
      ),
    );
  }
}