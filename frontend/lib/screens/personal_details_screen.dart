import 'package:flutter/material.dart';

import '../theme/link_ride_theme.dart';

class PersonalDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> userProfile;

  const PersonalDetailsScreen({
    super.key,
    required this.userProfile,
  });

  @override
  Widget build(BuildContext context) {
    final String firstName =
        userProfile['firstName']
                ?.toString() ??
            'Not provided';

    final String lastName =
        userProfile['lastName']
                ?.toString() ??
            'Not provided';

    final String email =
        userProfile['email']
                ?.toString() ??
            'Not provided';

    final String phoneNumber =
        userProfile['phoneNumber']
                ?.toString() ??
            'Not provided';

    final String accountStatus =
        _formatAccountStatus(
      userProfile['accountStatus'],
    );

    final String memberSince =
        _formatMemberSince(
      userProfile['createdAt'],
    );

    return Scaffold(
      backgroundColor:
          LinkRideColors.background,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () =>
              Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
        ),
        title: const Text(
          'Personal Details',
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            20,
            14,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _headerCard(
                firstName: firstName,
                lastName: lastName,
                email: email,
              ),

              const SizedBox(height: 24),

              _sectionTitle(
                'PERSONAL INFORMATION',
              ),

              _detailsCard(
                children: [
                  _detailRow(
                    icon: Icons
                        .person_outline_rounded,
                    accent:
                        LinkRideColors
                            .primaryBlue,
                    label: 'First name',
                    value: firstName,
                  ),

                  _divider(),

                  _detailRow(
                    icon:
                        Icons.badge_outlined,
                    accent:
                        LinkRideColors
                            .linkGreen,
                    label: 'Last name',
                    value: lastName,
                  ),

                  _divider(),

                  _detailRow(
                    icon:
                        Icons.email_outlined,
                    accent:
                        const Color(
                      0xFF6C63B8,
                    ),
                    label: 'Email address',
                    value: email,
                  ),

                  _divider(),

                  _detailRow(
                    icon:
                        Icons.phone_outlined,
                    accent:
                        LinkRideColors
                            .primaryBlue,
                    label: 'Phone number',
                    value: phoneNumber,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _sectionTitle(
                'ACCOUNT',
              ),

              _detailsCard(
                children: [
                  _detailRow(
                    icon: Icons
                        .verified_user_outlined,
                    accent:
                        LinkRideColors
                            .linkGreen,
                    label: 'Account status',
                    value: accountStatus,
                    valueColor:
                        LinkRideColors
                            .linkGreen,
                  ),

                  _divider(),

                  _detailRow(
                    icon: Icons
                        .calendar_today_outlined,
                    accent:
                        LinkRideColors
                            .primaryBlue,
                    label: 'Member since',
                    value: memberSince,
                  ),
                ],
              ),

              const SizedBox(height: 22),

              _informationCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerCard({
    required String firstName,
    required String lastName,
    required String email,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient:
            LinkRideGradients.primarySoft,
        borderRadius:
            BorderRadius.circular(
          LinkRideRadius.extraLarge,
        ),
        border: Border.all(
          color:
              LinkRideColors.primaryBlue
                  .withValues(
            alpha: 0.08,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            alignment:
                Alignment.center,
            decoration:
                const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Text(
              _initials(
                firstName,
                lastName,
              ),
              style:
                  const TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.w800,
                color:
                    LinkRideColors
                        .primaryBlue,
              ),
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your account information',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        LinkRideColors
                            .textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  email == 'Not provided'
                      ? 'These details are linked to your Link Ride account.'
                      : email,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 12,
                    color:
                        LinkRideColors
                            .textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailsCard({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration:
          LinkRideDecorations.card(),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(
          LinkRideRadius.large,
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required Color accent,
    required String label,
    required String value,
    Color valueColor =
        LinkRideColors.textPrimary,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 15,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration:
                BoxDecoration(
              color:
                  accent.withValues(
                alpha: 0.09,
              ),
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),
            child: Icon(
              icon,
              size: 21,
              color: accent,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:
                      const TextStyle(
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        LinkRideColors
                            .textSecondary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w800,
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

  Widget _informationCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color:
            LinkRideColors.softBlue,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              LinkRideColors.primaryBlue
                  .withValues(
            alpha: 0.08,
          ),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color:
                LinkRideColors
                    .primaryBlue,
            size: 20,
          ),

          SizedBox(width: 11),

          Expanded(
            child: Text(
              'To change your personal information, use Edit Profile from your Profile screen.',
              style: TextStyle(
                fontSize: 12,
                height: 1.45,
                color:
                    LinkRideColors
                        .textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    String title,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        left: 3,
        bottom: 9,
      ),
      child: Text(
        title,
        style:
            const TextStyle(
          fontSize: 10.5,
          fontWeight:
              FontWeight.w800,
          letterSpacing: 1.1,
          color:
              LinkRideColors.textMuted,
        ),
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding:
          EdgeInsets.only(
        left: 72,
      ),
      child: Divider(
        height: 1,
        thickness: 1,
        color:
            LinkRideColors.border,
      ),
    );
  }

  String _formatAccountStatus(
    dynamic status,
  ) {
    if (status == null) {
      return 'Unknown';
    }

    final String value =
        status
            .toString()
            .trim()
            .toLowerCase();

    if (value.isEmpty) {
      return 'Unknown';
    }

    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  String _formatMemberSince(
    dynamic createdAt,
  ) {
    if (createdAt == null) {
      return 'Not available';
    }

    final DateTime? date =
        DateTime.tryParse(
      createdAt.toString(),
    );

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

  String _initials(
    String firstName,
    String lastName,
  ) {
    final String first =
        firstName == 'Not provided'
            ? ''
            : firstName.trim();

    final String last =
        lastName == 'Not provided'
            ? ''
            : lastName.trim();

    if (first.isEmpty &&
        last.isEmpty) {
      return 'U';
    }

    if (first.isNotEmpty &&
        last.isNotEmpty) {
      return '${first[0]}${last[0]}'
          .toUpperCase();
    }

    final String source =
        first.isNotEmpty
            ? first
            : last;

    return source[0].toUpperCase();
  }
}