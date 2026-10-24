import 'package:flutter/material.dart';

import '../services/auth_storage.dart';
import '../services/profile_service.dart';
import '../theme/link_ride_theme.dart';
import 'about_link_ride_screen.dart';
import 'authentication_screen.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';
import 'help_support_screen.dart';
import 'journey_preferences_screen.dart';
import 'notification_preferences_screen.dart';
import 'personal_details_screen.dart';
import 'security_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String firstName;

  const ProfileScreen({
    super.key,
    required this.firstName,
  });

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {
  final AuthStorage _authStorage =
      AuthStorage();

  final ProfileService _profileService =
      ProfileService();

  Map<String, dynamic>? userProfile;

  bool isLoadingProfile = true;

  String? profileError;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final String? token =
          await _authStorage.getToken();

      final int? userId =
          await _authStorage.getUserId();

      if (token == null ||
          userId == null) {
        throw Exception(
          'No active user session found.',
        );
      }

      final Map<String, dynamic> profile =
          await _profileService.getUserProfile(
        userId: userId,
        token: token,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        userProfile = profile;
        isLoadingProfile = false;
        profileError = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoadingProfile = false;

        profileError = error
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  Future<void> _logout() async {
    final bool? shouldLogout =
        await showDialog<bool>(
      context: context,
      builder:
          (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            'Log out?',
          ),
          content: const Text(
            'Are you sure you want to log out of Link Ride on this device?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style:
                  FilledButton.styleFrom(
                backgroundColor:
                    LinkRideColors.danger,
              ),
              child: const Text(
                'Log Out',
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true ||
        !mounted) {
      return;
    }

    await _authStorage.clearSession();

    if (!mounted) {
      return;
    }

    Navigator.of(context)
        .pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) =>
            const AuthenticationScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          LinkRideColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadProfile,
          color:
              LinkRideColors.primaryBlue,
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding:
                const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              30,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _pageHeader(),

                const SizedBox(height: 20),

                if (isLoadingProfile)
                  _profileLoadingCard()
                else if (profileError != null)
                  _profileErrorCard()
                else
                  _profileHero(),

                const SizedBox(height: 26),

                _sectionTitle(
                  'ACCOUNT',
                ),

                _settingsCard(
                  children: [
                    _settingsTile(
                      icon: Icons
                          .person_outline_rounded,
                      accent:
                          LinkRideColors
                              .primaryBlue,
                      title:
                          'Personal Details',
                      subtitle:
                          'View your account information',
                      onTap: () {
                        if (userProfile ==
                            null) {
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    PersonalDetailsScreen(
                              userProfile:
                                  userProfile!,
                            ),
                          ),
                        );
                      },
                    ),

                    _divider(),

                    _settingsTile(
                      icon:
                          Icons.edit_outlined,
                      accent:
                          LinkRideColors
                              .linkGreen,
                      title: 'Edit Profile',
                      subtitle:
                          'Update your personal details',
                      onTap: () async {
                        if (userProfile ==
                            null) {
                          return;
                        }

                        final Map<String, dynamic>?
                            updatedProfile =
                            await Navigator
                                .push<
                                    Map<String,
                                        dynamic>>(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    EditProfileScreen(
                              userProfile:
                                  userProfile!,
                            ),
                          ),
                        );

                        if (updatedProfile ==
                                null ||
                            !mounted) {
                          return;
                        }

                        setState(() {
                          userProfile =
                              updatedProfile;
                        });

                        final String
                            updatedFirstName =
                            updatedProfile[
                                        'firstName']
                                    ?.toString() ??
                                '';

                        if (updatedFirstName
                            .isNotEmpty) {
                          await _authStorage
                              .saveFirstName(
                            updatedFirstName,
                          );
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                _sectionTitle(
                  'TRAVEL',
                ),

                _settingsCard(
                  children: [
                    _settingsTile(
                      icon:
                          Icons.route_rounded,
                      accent:
                          LinkRideColors
                              .primaryBlue,
                      title:
                          'Journey Preferences',
                      subtitle:
                          'Manage your preferred travel options',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    const JourneyPreferencesScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                _sectionTitle(
                  'PREFERENCES',
                ),

                _settingsCard(
                  children: [
                    _settingsTile(
                      icon: Icons
                          .notifications_outlined,
                      accent:
                          const Color(
                        0xFF6C63B8,
                      ),
                      title:
                          'Notification Preferences',
                      subtitle:
                          'Manage alerts and notifications',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    const NotificationPreferencesScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                _sectionTitle(
                  'SECURITY',
                ),

                _settingsCard(
                  children: [
                    _settingsTile(
                      icon: Icons
                          .lock_outline_rounded,
                      accent:
                          LinkRideColors
                              .primaryBlue,
                      title:
                          'Change Password',
                      subtitle:
                          'Update your account password',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    const ChangePasswordScreen(),
                          ),
                        );
                      },
                    ),

                    _divider(),

                    _settingsTile(
                      icon: Icons
                          .shield_outlined,
                      accent:
                          LinkRideColors
                              .linkGreen,
                      title: 'Security',
                      subtitle:
                          'View your account security',
                      onTap: () {
                        if (userProfile ==
                            null) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Your profile information is still loading. Please try again.',
                              ),
                            ),
                          );

                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    SecurityScreen(
                              userProfile:
                                  userProfile!,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                _sectionTitle(
                  'SUPPORT',
                ),

                _settingsCard(
                  children: [
                    _settingsTile(
                      icon: Icons
                          .help_outline_rounded,
                      accent:
                          LinkRideColors
                              .primaryBlue,
                      title:
                          'Help & Support',
                      subtitle:
                          'Get help using Link Ride',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    const HelpSupportScreen(),
                          ),
                        );
                      },
                    ),

                    _divider(),

                    _settingsTile(
                      icon: Icons
                          .info_outline_rounded,
                      accent:
                          LinkRideColors
                              .linkGreen,
                      title:
                          'About Link Ride',
                      subtitle:
                          'App information and version',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    const AboutLinkRideScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                _logoutButton(),

                const SizedBox(height: 22),

                _versionFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pageHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Profile',
            style: TextStyle(
              fontSize: 29,
              fontWeight:
                  FontWeight.w800,
              letterSpacing: -0.7,
              color:
                  LinkRideColors
                      .primaryBlue,
            ),
          ),
        ),

        Image.asset(
          'assets/link_ride_header_logo.png',
          width: 112,
          fit: BoxFit.contain,
        ),
      ],
    );
  }

  Widget _profileHero() {
    final String firstName =
        userProfile?['firstName']
                ?.toString() ??
            widget.firstName;

    final String lastName =
        userProfile?['lastName']
                ?.toString() ??
            '';

    final String email =
        userProfile?['email']
                ?.toString() ??
            '';

    final String fullName =
        '$firstName $lastName'.trim();

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(20),
      decoration:
          LinkRideDecorations.blueCard(),
      child: Stack(
        children: [
          Positioned(
            right: -34,
            top: -44,
            child: Container(
              width: 130,
              height: 130,
              decoration:
                  BoxDecoration(
                color: Colors.white
                    .withValues(
                  alpha: 0.06,
                ),
                shape:
                    BoxShape.circle,
              ),
            ),
          ),

          Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    alignment:
                        Alignment.center,
                    decoration:
                        BoxDecoration(
                      color: Colors.white
                          .withValues(
                        alpha: 0.11,
                      ),
                      shape:
                          BoxShape.circle,
                      border: Border.all(
                        color:
                            Colors.white
                                .withValues(
                          alpha: 0.18,
                        ),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      _initials(
                        firstName,
                        lastName,
                      ),
                      style:
                          const TextStyle(
                        fontSize: 25,
                        fontWeight:
                            FontWeight
                                .w800,
                        color:
                            Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          fullName.isEmpty
                              ? 'Link Ride User'
                              : fullName,
                          style:
                              const TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight
                                    .w800,
                            letterSpacing:
                                -0.3,
                            color:
                                Colors.white,
                          ),
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        Text(
                          email.isEmpty
                              ? 'Account details unavailable'
                              : email,
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Colors.white
                                    .withValues(
                              alpha: 0.74,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 9,
                        ),

                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                LinkRideColors
                                    .linkGreen
                                    .withValues(
                              alpha: 0.18,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              LinkRideRadius
                                  .pill,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              Icon(
                                Icons
                                    .check_circle_rounded,
                                size: 14,
                                color:
                                    Colors.white,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'ACTIVE ACCOUNT',
                                style:
                                    TextStyle(
                                  fontSize:
                                      9.5,
                                  fontWeight:
                                      FontWeight
                                          .w800,
                                  letterSpacing:
                                      0.4,
                                  color:
                                      Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(
                  13,
                ),
                decoration:
                    BoxDecoration(
                  color: Colors.white
                      .withValues(
                    alpha: 0.07,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons
                          .account_circle_outlined,
                      size: 18,
                      color: Colors.white,
                    ),

                    const SizedBox(width: 9),

                    Expanded(
                      child: Text(
                        'Manage your account, travel settings, security and support from one place.',
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.4,
                          color: Colors.white
                              .withValues(
                            alpha: 0.77,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _profileLoadingCard() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration:
          LinkRideDecorations.card(),
      child: const Center(
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2.3,
              color:
                  LinkRideColors
                      .primaryBlue,
            ),
            SizedBox(height: 12),
            Text(
              'Loading profile...',
              style: TextStyle(
                fontSize: 12.5,
                color:
                    LinkRideColors
                        .textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileErrorCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(22),
      decoration:
          LinkRideDecorations.card(),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration:
                const BoxDecoration(
              color:
                  LinkRideColors
                      .dangerSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons
                  .person_off_outlined,
              size: 28,
              color:
                  LinkRideColors
                      .danger,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Unable to load profile',
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w800,
              color:
                  LinkRideColors
                      .textPrimary,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            profileError ??
                'Unable to load your account details.',
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color:
                  LinkRideColors
                      .textSecondary,
            ),
          ),

          const SizedBox(height: 14),

          OutlinedButton.icon(
            onPressed: _loadProfile,
            icon: const Icon(
              Icons.refresh_rounded,
              size: 18,
            ),
            label:
                const Text(
              'Try Again',
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

  Widget _settingsCard({
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

  Widget _settingsTile({
    required IconData icon,
    required Color accent,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 14,
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
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w800,
                      color:
                          LinkRideColors
                              .textPrimary,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    style:
                        const TextStyle(
                      fontSize: 11.5,
                      height: 1.3,
                      color:
                          LinkRideColors
                              .textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            const Icon(
              Icons
                  .chevron_right_rounded,
              size: 21,
              color:
                  LinkRideColors
                      .textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _logout,
        icon: const Icon(
          Icons.logout_rounded,
          size: 19,
        ),
        label: const Text(
          'Log Out',
        ),
        style:
            OutlinedButton.styleFrom(
          foregroundColor:
              LinkRideColors.danger,
          backgroundColor:
              LinkRideColors.dangerSoft,
          side: BorderSide(
            color:
                LinkRideColors.danger
                    .withValues(
              alpha: 0.18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _versionFooter() {
    return const Center(
      child: Column(
        children: [
          Text(
            'Link Ride',
            style: TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.w700,
              color:
                  LinkRideColors
                      .textSecondary,
            ),
          ),

          SizedBox(height: 3),

          Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: 11,
              color:
                  LinkRideColors
                      .textMuted,
            ),
          ),
        ],
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

  String _initials(
    String firstName,
    String lastName,
  ) {
    final String first =
        firstName.trim();

    final String last =
        lastName.trim();

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