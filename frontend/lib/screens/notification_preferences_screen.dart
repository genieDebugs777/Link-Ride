import 'package:flutter/material.dart';

import '../services/notification_preferences_service.dart';
import '../theme/link_ride_theme.dart';

class NotificationPreferencesScreen
    extends StatefulWidget {
  const NotificationPreferencesScreen({
    super.key,
  });

  @override
  State<NotificationPreferencesScreen>
      createState() =>
          _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  final NotificationPreferencesService
      _preferencesService =
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
          await _preferencesService
              .getPreferences();

      if (!mounted) {
        return;
      }

      setState(() {
        disruptionAlerts =
            preferences[
                    'disruptionAlerts'] ??
                true;

        journeyUpdates =
            preferences[
                    'journeyUpdates'] ??
                true;

        ticketPaymentUpdates =
            preferences[
                    'ticketPaymentUpdates'] ??
                true;

        generalNotifications =
            preferences[
                    'generalNotifications'] ??
                false;

        isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to load notification preferences.',
          ),
        ),
      );
    }
  }

  Future<void> _savePreferences() async {
    if (isSaving) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await _preferencesService
          .savePreferences(
        disruptionAlerts:
            disruptionAlerts,
        journeyUpdates:
            journeyUpdates,
        ticketPaymentUpdates:
            ticketPaymentUpdates,
        generalNotifications:
            generalNotifications,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
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

      ScaffoldMessenger.of(context)
          .showSnackBar(
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
          'Notification Preferences',
        ),
      ),
      body: SafeArea(
        top: false,
        child: isLoading
            ? _loadingView()
            : SingleChildScrollView(
                padding:
                    const EdgeInsets
                        .fromLTRB(
                  20,
                  14,
                  20,
                  30,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    _headerCard(),

                    const SizedBox(
                      height: 24,
                    ),

                    _sectionTitle(
                      'TRAVEL ALERTS',
                    ),

                    _preferenceGroup(
                      children: [
                        _notificationOption(
                          icon: Icons
                              .warning_amber_rounded,
                          accent:
                              LinkRideColors
                                  .warning,
                          title:
                              'Service disruption alerts',
                          subtitle:
                              'Delays, cancellations and route disruptions affecting transport services.',
                          value:
                              disruptionAlerts,
                          onChanged:
                              (value) {
                            setState(() {
                              disruptionAlerts =
                                  value;
                            });
                          },
                        ),
                        _divider(),
                        _notificationOption(
                          icon:
                              Icons.route_rounded,
                          accent:
                              LinkRideColors
                                  .primaryBlue,
                          title:
                              'Journey updates',
                          subtitle:
                              'Important changes and information about your planned journeys.',
                          value:
                              journeyUpdates,
                          onChanged:
                              (value) {
                            setState(() {
                              journeyUpdates =
                                  value;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    _sectionTitle(
                      'ACCOUNT & SERVICE',
                    ),

                    _preferenceGroup(
                      children: [
                        _notificationOption(
                          icon: Icons
                              .confirmation_number_outlined,
                          accent:
                              LinkRideColors
                                  .linkGreen,
                          title:
                              'Ticket & payment updates',
                          subtitle:
                              'Payment confirmations, failures and digital ticket information.',
                          value:
                              ticketPaymentUpdates,
                          onChanged:
                              (value) {
                            setState(() {
                              ticketPaymentUpdates =
                                  value;
                            });
                          },
                        ),
                        _divider(),
                        _notificationOption(
                          icon: Icons
                              .notifications_outlined,
                          accent:
                              const Color(
                            0xFF6C63B8,
                          ),
                          title:
                              'General notifications',
                          subtitle:
                              'Non-critical Link Ride service information and app announcements.',
                          value:
                              generalNotifications,
                          onChanged:
                              (value) {
                            setState(() {
                              generalNotifications =
                                  value;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    _informationCard(),

                    const SizedBox(
                      height: 24,
                    ),

                    SizedBox(
                      width:
                          double.infinity,
                      child:
                          FilledButton.icon(
                        onPressed:
                            isSaving
                                ? null
                                : _savePreferences,
                        icon: isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2,
                                  color:
                                      Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons
                                    .save_outlined,
                                size: 18,
                              ),
                        label: Text(
                          isSaving
                              ? 'Saving...'
                              : 'Save Preferences',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _headerCard() {
    final int enabledCount = [
      disruptionAlerts,
      journeyUpdates,
      ticketPaymentUpdates,
      generalNotifications,
    ].where((value) => value).length;

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
            width: 52,
            height: 52,
            decoration:
                const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.tune_rounded,
              size: 24,
              color:
                  LinkRideColors
                      .primaryBlue,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stay informed',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        LinkRideColors
                            .textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '$enabledCount of 4 notification categories enabled',
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

  Widget _preferenceGroup({
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

  Widget _notificationOption({
    required IconData icon,
    required Color accent,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Padding(
        padding:
            const EdgeInsets.fromLTRB(
          15,
          14,
          12,
          14,
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.center,
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

            const SizedBox(width: 12),

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

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style:
                        const TextStyle(
                      fontSize: 11.5,
                      height: 1.4,
                      color:
                          LinkRideColors
                              .textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            Switch(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
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
            size: 20,
            color:
                LinkRideColors
                    .primaryBlue,
          ),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              'Critical account or security information may still be shown when necessary, regardless of these preferences.',
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
              LinkRideColors
                  .textMuted,
        ),
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding:
          EdgeInsets.only(
        left: 71,
      ),
      child: Divider(
        height: 1,
        thickness: 1,
        color:
            LinkRideColors.border,
      ),
    );
  }

  Widget _loadingView() {
    return const Center(
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

          SizedBox(height: 13),

          Text(
            'Loading preferences...',
            style: TextStyle(
              fontSize: 12.5,
              color:
                  LinkRideColors
                      .textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}