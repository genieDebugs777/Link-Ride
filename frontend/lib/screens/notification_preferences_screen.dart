import 'package:flutter/material.dart';
import '../services/notification_preferences_service.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({
    super.key,
  });

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  static const Color primaryBlue = Color(0xFF003F73);
  static const Color linkGreen = Color(0xFF4A9B45);
  static const Color background = Color(0xFFF7F9FB);
  static const Color textPrimary = Color(0xFF17212B);
  static const Color textSecondary = Color(0xFF667085);
  static const Color cardBorder = Color(0xFFE4E9EE);

  final NotificationPreferencesService _preferencesService =
      NotificationPreferencesService();

  bool disruptionAlerts = true;
  bool journeyUpdates = true;
  bool ticketPaymentUpdates = true;
  bool generalNotifications = false;

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final Map<String, bool> preferences =
          await _preferencesService.getPreferences();

      if (!mounted) {
        return;
      }

      setState(() {
        disruptionAlerts =
            preferences['disruptionAlerts'] ?? true;

        journeyUpdates =
            preferences['journeyUpdates'] ?? true;

        ticketPaymentUpdates =
            preferences['ticketPaymentUpdates'] ?? true;

        generalNotifications =
            preferences['generalNotifications'] ?? false;

        isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to load notification preferences.',
          ),
        ),
      );
    }
  }

  Future<void> _savePreferences() async {
    setState(() {
      isSaving = true;
    });

    try {
      await _preferencesService.savePreferences(
        disruptionAlerts: disruptionAlerts,
        journeyUpdates: journeyUpdates,
        ticketPaymentUpdates: ticketPaymentUpdates,
        generalNotifications: generalNotifications,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Notification preferences saved successfully.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to save notification preferences.',
          ),
        ),
      );
    }
  }

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
          'Notification Preferences',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: primaryBlue,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: primaryBlue,
                ),
              )
            : SingleChildScrollView(
                padding:
                    const EdgeInsets.fromLTRB(22, 16, 22, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Stay informed',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Choose which Link Ride updates you would '
                      'like to receive.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: textSecondary,
                      ),
                    ),

                    const SizedBox(height: 26),

                    _sectionTitle('TRAVEL ALERTS'),

                    _card(
                      child: Column(
                        children: [
                          _notificationOption(
                            icon: Icons.warning_amber_rounded,
                            title: 'Service disruption alerts',
                            subtitle:
                                'Delays, cancellations and route disruptions affecting transport services.',
                            value: disruptionAlerts,
                            onChanged: (value) {
                              setState(() {
                                disruptionAlerts = value;
                              });
                            },
                          ),

                          _divider(),

                          _notificationOption(
                            icon: Icons.route_rounded,
                            title: 'Journey updates',
                            subtitle:
                                'Important changes and information about your planned journeys.',
                            value: journeyUpdates,
                            onChanged: (value) {
                              setState(() {
                                journeyUpdates = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    _sectionTitle('ACCOUNT & SERVICE'),

                    _card(
                      child: Column(
                        children: [
                          _notificationOption(
                            icon: Icons.confirmation_number_outlined,
                            title: 'Ticket & payment updates',
                            subtitle:
                                'Payment confirmations, failures and digital ticket information.',
                            value: ticketPaymentUpdates,
                            onChanged: (value) {
                              setState(() {
                                ticketPaymentUpdates = value;
                              });
                            },
                          ),

                          _divider(),

                          _notificationOption(
                            icon: Icons.notifications_outlined,
                            title: 'General notifications',
                            subtitle:
                                'Non-critical Link Ride service information and app announcements.',
                            value: generalNotifications,
                            onChanged: (value) {
                              setState(() {
                                generalNotifications = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    _informationCard(),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed:
                            isSaving ? null : _savePreferences,
                        icon: isSaving
                            ? const SizedBox(
                                width: 19,
                                height: 19,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.save_outlined,
                                size: 20,
                              ),
                        label: Text(
                          isSaving
                              ? 'Saving...'
                              : 'Save Preferences',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          disabledBackgroundColor:
                              primaryBlue.withValues(
                            alpha: 0.65,
                          ),
                          foregroundColor: Colors.white,
                          disabledForegroundColor:
                              Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _notificationOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      activeThumbColor: linkGreen,
      secondary: _iconBox(icon),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 11.5,
            height: 1.35,
            color: textSecondary,
          ),
        ),
      ),
      onChanged: onChanged,
    );
  }

  Widget _informationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: primaryBlue,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Critical account or security information may still '
              'be shown when necessary, regardless of these preferences.',
              style: TextStyle(
                fontSize: 12,
                height: 1.45,
                color: textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
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
    );
  }

  Widget _card({
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: 0.018),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: child,
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