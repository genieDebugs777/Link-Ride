import 'package:flutter/material.dart';

import '../theme/link_ride_theme.dart';

class SecurityScreen extends StatelessWidget {
  final Map<String, dynamic> userProfile;

  const SecurityScreen({
    super.key,
    required this.userProfile,
  });

  @override
  Widget build(BuildContext context) {
    final String email =
        userProfile['email']
                ?.toString() ??
            'Not available';

    final String accountStatus =
        userProfile['accountStatus']
                ?.toString() ??
            'Unknown';

    final bool isActive =
        accountStatus.toUpperCase() ==
            'ACTIVE';

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
          'Security',
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
              _securityHero(),

              const SizedBox(height: 24),

              _sectionTitle(
                'ACCOUNT',
              ),

              _securityCard(
                children: [
                  _informationTile(
                    icon: Icons
                        .alternate_email_rounded,
                    accent:
                        LinkRideColors
                            .primaryBlue,
                    title:
                        'Signed-in email',
                    value: email,
                  ),

                  _divider(),

                  _informationTile(
                    icon: Icons
                        .check_circle_outline_rounded,
                    accent: isActive
                        ? LinkRideColors
                            .linkGreen
                        : LinkRideColors
                            .textSecondary,
                    title:
                        'Account status',
                    value:
                        _formatStatus(
                      accountStatus,
                    ),
                    valueColor:
                        isActive
                            ? LinkRideColors
                                .linkGreen
                            : LinkRideColors
                                .textSecondary,
                  ),
                ],
              ),

              const SizedBox(height: 22),

              _sectionTitle(
                'AUTHENTICATION',
              ),

              _securityCard(
                children: [
                  _informationTile(
                    icon: Icons
                        .password_rounded,
                    accent:
                        const Color(
                      0xFF6C63B8,
                    ),
                    title:
                        'Authentication method',
                    value: 'Password',
                  ),

                  _divider(),

                  _informationTile(
                    icon:
                        Icons.key_rounded,
                    accent:
                        LinkRideColors
                            .primaryBlue,
                    title:
                        'Current session',
                    value:
                        'Secure JWT authentication',
                  ),
                ],
              ),

              const SizedBox(height: 22),

              _sectionTitle(
                'SECURITY INFORMATION',
              ),

              _securityInformation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _securityHero() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color:
            LinkRideColors.softGreen,
        borderRadius:
            BorderRadius.circular(
          LinkRideRadius.extraLarge,
        ),
        border: Border.all(
          color:
              LinkRideColors.linkGreen
                  .withValues(
            alpha: 0.16,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration:
                const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons
                  .verified_user_outlined,
              color:
                  LinkRideColors
                      .linkGreen,
              size: 26,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Account protected',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        LinkRideColors
                            .textPrimary,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'You are signed in through an authenticated Link Ride session.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
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

  Widget _securityCard({
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

  Widget _informationTile({
    required IconData icon,
    required Color accent,
    required String title,
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
                  title,
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
                    fontSize: 13.5,
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

  Widget _securityInformation() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
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
            Icons
                .lock_person_outlined,
            size: 21,
            color:
                LinkRideColors
                    .primaryBlue,
          ),

          SizedBox(width: 11),

          Expanded(
            child: Text(
              'Link Ride protects account passwords using secure password hashing. Authenticated requests use your signed-in session, and your password is never displayed by the app.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
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

  String _formatStatus(
    String status,
  ) {
    if (status.isEmpty) {
      return 'Unknown';
    }

    final String lower =
        status.toLowerCase();

    return '${lower[0].toUpperCase()}${lower.substring(1)}';
  }
}