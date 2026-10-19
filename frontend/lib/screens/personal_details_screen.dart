import 'package:flutter/material.dart';

class PersonalDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> userProfile;

  const PersonalDetailsScreen({
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
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: primaryBlue,
          ),
        ),
        title: const Text(
          'Personal Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: primaryBlue,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your account information',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'These details are linked to your Link Ride account.',
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: textSecondary,
              ),
            ),

            const SizedBox(height: 24),

            _detailsCard(
              children: [
                _detailRow(
                  icon: Icons.person_outline_rounded,
                  label: 'First name',
                  value: userProfile['firstName'] ?? 'Not provided',
                ),
                _divider(),
                _detailRow(
                  icon: Icons.badge_outlined,
                  label: 'Last name',
                  value: userProfile['lastName'] ?? 'Not provided',
                ),
                _divider(),
                _detailRow(
                  icon: Icons.email_outlined,
                  label: 'Email address',
                  value: userProfile['email'] ?? 'Not provided',
                ),
                _divider(),
                _detailRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone number',
                  value: userProfile['phoneNumber'] ?? 'Not provided',
                ),
              ],
            ),

            const SizedBox(height: 22),

            const Text(
              'ACCOUNT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: textSecondary,
              ),
            ),

            const SizedBox(height: 9),

            _detailsCard(
              children: [
                _detailRow(
                  icon: Icons.verified_user_outlined,
                  label: 'Account status',
                  value: _formatAccountStatus(
                    userProfile['accountStatus'],
                  ),
                  valueColor: linkGreen,
                ),
                _divider(),
                _detailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Member since',
                  value: _formatMemberSince(
                    userProfile['createdAt'],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3F8),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: primaryBlue,
                    size: 21,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'To change your personal information, use Edit Profile from your Profile screen.',
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.45,
                        color: primaryBlue,
                      ),
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

  Widget _detailsCard({
    required List<Widget> children,
  }) {
    return Container(
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

  Widget _detailRow({
    required IconData icon,
    required String label,
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
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
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

  String _formatAccountStatus(dynamic status) {
    if (status == null) {
      return 'Unknown';
    }

    final String value = status.toString().toLowerCase();

    if (value.isEmpty) {
      return 'Unknown';
    }

    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  String _formatMemberSince(dynamic createdAt) {
    if (createdAt == null) {
      return 'Not available';
    }

    final DateTime? date =
        DateTime.tryParse(createdAt.toString());

    if (date == null) {
      return 'Not available';
    }

    const List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}