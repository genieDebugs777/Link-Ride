import 'package:flutter/material.dart';
import '../services/auth_storage.dart';
import '../services/profile_service.dart';
import 'personal_details_screen.dart';
import 'edit_profile_screen.dart';
import 'journey_preferences_screen.dart';
import 'notification_preferences_screen.dart';
import 'change_password_screen.dart';
import 'security_screen.dart';
import 'help_support_screen.dart';
import 'about_link_ride_screen.dart';
import 'authentication_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String firstName;

  const ProfileScreen({
    super.key,
    required this.firstName,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthStorage _authStorage = AuthStorage();
  final ProfileService _profileService = ProfileService();

  Map<String, dynamic>? userProfile;
  bool isLoadingProfile = true;
  String? profileError;

  static const Color primaryBlue = Color(0xFF003F73);
  static const Color linkGreen = Color(0xFF4A9B45);
  static const Color background = Color(0xFFF7F9FB);
  static const Color textPrimary = Color(0xFF17212B);
  static const Color textSecondary = Color(0xFF667085);
  static const Color cardBorder = Color(0xFFE4E9EE);
  static const Color dangerRed = Color(0xFFD64545);

 @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final String? token = await _authStorage.getToken();
      final int? userId = await _authStorage.getUserId();

      if (token == null || userId == null) {
        throw Exception('No active user session found.');
      }

      final Map<String, dynamic> profile =
          await _profileService.getUserProfile(
        userId: userId,
        token: token,
      );

      if (!mounted) return;

      setState(() {
        userProfile = profile;
        isLoadingProfile = false;
        profileError = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoadingProfile = false;
        profileError = error.toString();
      });
    }
  }

  Future<void> _logout() async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Log out?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out of Link Ride on this device?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !mounted) {
      return;
    }

    await _authStorage.clearSession();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const AuthenticationScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ───────────────── HEADER ─────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                      color: primaryBlue,
                    ),
                  ),
                  Image.asset(
                    'assets/link_ride_header_logo.png',
                    width: 125,
                    fit: BoxFit.contain,
                  ),
                ],
              ),

              const SizedBox(height: 26),

              // ───────────────── PROFILE SUMMARY ─────────────────
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3F8),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryBlue.withValues(alpha: 0.10),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        userProfile != null
                          ? '${userProfile!['firstName'][0]}${userProfile!['lastName'][0]}'
                              .toUpperCase()
                          : widget.firstName.isNotEmpty
                              ? widget.firstName[0].toUpperCase()
                              : 'U',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: primaryBlue,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      userProfile != null
                        ? '${userProfile!['firstName']} ${userProfile!['lastName']}'
                        : widget.firstName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      userProfile?['email'] ?? 'Loading...',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: textSecondary,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: linkGreen.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 15,
                            color: linkGreen,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Active account',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: linkGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ───────────────── ACCOUNT ─────────────────
              _sectionTitle('ACCOUNT'),

              _settingsCard(
                children: [
                  _settingsTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Personal Details',
                    subtitle: 'View your account information',
                    onTap: () {
                      if (userProfile == null) {
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PersonalDetailsScreen(
                            userProfile: userProfile!,
                          ),
                        ),
                      );
                    },
                  ),
                  _divider(),
                  _settingsTile(
                    icon: Icons.edit_outlined,
                    title: 'Edit Profile',
                    subtitle: 'Update your personal details',
                    onTap: () async {
                      if (userProfile == null) {
                        return;
                      }

                      final Map<String, dynamic>? updatedProfile =
                          await Navigator.push<Map<String, dynamic>>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(
                            userProfile: userProfile!,
                          ),
                        ),
                      );

                      if (updatedProfile == null || !mounted) {
                        return;
                      }

                      setState(() {
                        userProfile = updatedProfile;
                      });

                      final String updatedFirstName =
                          updatedProfile['firstName']?.toString() ?? '';

                      if (updatedFirstName.isNotEmpty) {
                        await _authStorage.saveFirstName(updatedFirstName);
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ───────────────── TRAVEL ─────────────────
              _sectionTitle('TRAVEL'),

              _settingsCard(
                children: [
                  _settingsTile(
                    icon: Icons.route_rounded,
                    title: 'Journey Preferences',
                    subtitle: 'Manage your preferred travel options',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const JourneyPreferencesScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ───────────────── PREFERENCES ─────────────────
              _sectionTitle('PREFERENCES'),

              _settingsCard(
                children: [
                  _settingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notification Preferences',
                    subtitle: 'Manage alerts and notifications',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const NotificationPreferencesScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ───────────────── SECURITY ─────────────────
              _sectionTitle('SECURITY'),

              _settingsCard(
                children: [
                  _settingsTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Change Password',
                    subtitle: 'Update your account password',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),
                  _divider(),
                 _settingsTile(
                    icon: Icons.shield_outlined,
                    title: 'Security',
                    subtitle: 'View your account security',
                    onTap: () {
                      if (userProfile == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
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
                          builder: (context) => SecurityScreen(
                            userProfile: userProfile!,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ───────────────── SUPPORT ─────────────────
              _sectionTitle('SUPPORT'),

              _settingsCard(
                children: [
                  _settingsTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    subtitle: 'Get help using Link Ride',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpSupportScreen(),
                        ),
                      );
                    },
                  ),
                  _divider(),
                  _settingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'About Link Ride',
                    subtitle: 'App information and version',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutLinkRideScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 26),

              // ───────────────── LOG OUT ─────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(
                    Icons.logout_rounded,
                    size: 20,
                  ),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: dangerRed,
                    side: const BorderSide(
                      color: Color(0xFFF0CACA),
                    ),
                    backgroundColor: const Color(0xFFFFFAFA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ───────────────── VERSION ─────────────────
              const Center(
                child: Column(
                  children: [
                    Text(
                      'Link Ride',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textSecondary,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF98A2B3),
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

  Widget _settingsCard({
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

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 14,
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
                  size: 22,
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
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.3,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.chevron_right_rounded,
                size: 21,
                color: Color(0xFF98A2B3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.only(left: 71),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Color(0xFFEEF1F4),
      ),
    );
  }
}