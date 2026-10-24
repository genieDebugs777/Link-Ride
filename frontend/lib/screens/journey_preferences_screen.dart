import 'package:flutter/material.dart';

import '../services/journey_preferences_service.dart';
import '../theme/link_ride_theme.dart';

class JourneyPreferencesScreen extends StatefulWidget {
  const JourneyPreferencesScreen({
    super.key,
  });

  @override
  State<JourneyPreferencesScreen> createState() =>
      _JourneyPreferencesScreenState();
}

class _JourneyPreferencesScreenState
    extends State<JourneyPreferencesScreen> {
  final JourneyPreferencesService _preferencesService =
      JourneyPreferencesService();

  String selectedPriority = 'Balanced';

  bool gautrainSelected = true;
  bool metrorailSelected = true;
  bool busSelected = true;
  bool taxiSelected = true;

  bool preferFewerTransfers = false;

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final Map<String, dynamic> preferences =
          await _preferencesService.getPreferences();

      if (!mounted) {
        return;
      }

      setState(() {
        selectedPriority =
            preferences['priority'] as String;

        gautrainSelected =
            preferences['gautrainSelected'] as bool;

        metrorailSelected =
            preferences['metrorailSelected'] as bool;

        busSelected =
            preferences['busSelected'] as bool;

        taxiSelected =
            preferences['taxiSelected'] as bool;

        preferFewerTransfers =
            preferences['preferFewerTransfers'] as bool;

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
            'Unable to load journey preferences.',
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
      await _preferencesService.savePreferences(
        priority: selectedPriority,
        gautrainSelected: gautrainSelected,
        metrorailSelected: metrorailSelected,
        busSelected: busSelected,
        taxiSelected: taxiSelected,
        preferFewerTransfers: preferFewerTransfers,
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
            'Journey preferences saved successfully.',
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
            'Unable to save journey preferences.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LinkRideColors.background,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
        ),
        title: const Text(
          'Journey Preferences',
        ),
      ),
      body: SafeArea(
        top: false,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: LinkRideColors.primaryBlue,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  30,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _introCard(),

                    const SizedBox(height: 26),

                    _sectionHeader(
                      icon: Icons.tune_rounded,
                      title: 'Journey Priority',
                      description:
                          'Choose what matters most when Link Ride ranks your journey options.',
                    ),

                    const SizedBox(height: 12),

                    RadioGroup<String>(
                      groupValue: selectedPriority,
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          selectedPriority = value;
                        });
                      },
                      child: Column(
                        children: [
                          _priorityOption(
                            title: 'Balanced',
                            subtitle:
                                'Balance travel time, cost and convenience',
                            icon: Icons.balance_rounded,
                            accent: const Color(
                              0xFF6C63B8,
                            ),
                          ),

                          const SizedBox(height: 10),

                          _priorityOption(
                            title: 'Fastest',
                            subtitle:
                                'Prioritise the shortest overall travel time',
                            icon: Icons.bolt_rounded,
                            accent:
                                LinkRideColors.primaryBlue,
                          ),

                          const SizedBox(height: 10),

                          _priorityOption(
                            title: 'Cheapest',
                            subtitle:
                                'Prioritise journeys with lower estimated costs',
                            icon: Icons.savings_outlined,
                            accent:
                                LinkRideColors.linkGreen,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    _sectionHeader(
                      icon:
                          Icons.directions_transit_rounded,
                      title: 'Preferred Transport',
                      description:
                          'Select the transport modes Link Ride may include in your journey.',
                    ),

                    const SizedBox(height: 12),

                    _transportGrid(),

                    const SizedBox(height: 28),

                    _sectionHeader(
                      icon:
                          Icons.compare_arrows_rounded,
                      title: 'Route Preference',
                      description:
                          'Fine-tune how Link Ride handles interchanges.',
                    ),

                    const SizedBox(height: 12),

                    _transferPreferenceCard(),

                    const SizedBox(height: 28),

                    _saveButton(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _introCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinkRideGradients.primarySoft,
        borderRadius: BorderRadius.circular(
          LinkRideRadius.extraLarge,
        ),
        border: Border.all(
          color: LinkRideColors.primaryBlue
              .withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: LinkRideColors.primaryBlue,
              size: 23,
            ),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Personalise your journeys',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.25,
                    color:
                        LinkRideColors.textPrimary,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Your preferences influence how journey options are prioritised when you plan a trip.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color:
                        LinkRideColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: LinkRideColors.softBlue,
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 19,
            color: LinkRideColors.primaryBlue,
          ),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color:
                      LinkRideColors.textPrimary,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                description,
                style: const TextStyle(
                  fontSize: 11.8,
                  height: 1.4,
                  color:
                      LinkRideColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _priorityOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
  }) {
    final bool selected =
        selectedPriority == title;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            selectedPriority = title;
          });
        },
        borderRadius: BorderRadius.circular(
          LinkRideRadius.large,
        ),
        child: Ink(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(
                    alpha: 0.06,
                  )
                : LinkRideColors.surface,
            borderRadius: BorderRadius.circular(
              LinkRideRadius.large,
            ),
            border: Border.all(
              color: selected
                  ? accent.withValues(
                      alpha: 0.34,
                    )
                  : LinkRideColors.border,
              width: selected ? 1.3 : 1,
            ),
            boxShadow: selected
                ? LinkRideShadows.soft
                : const [],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accent.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 22,
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
                      style: const TextStyle(
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
                      style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.35,
                        color:
                            LinkRideColors
                                .textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Radio<String>(
                value: title,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _transportGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _transportCard(
                title: 'Gautrain',
                subtitle: 'Rapid rail',
                icon: Icons.train_rounded,
                value: gautrainSelected,
                accent:
                    LinkRideColors.primaryBlue,
                onChanged: (value) {
                  setState(() {
                    gautrainSelected = value;
                  });
                },
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _transportCard(
                title: 'Metrorail',
                subtitle: 'Commuter rail',
                icon:
                    Icons.directions_railway_rounded,
                value: metrorailSelected,
                accent: const Color(
                  0xFF6C63B8,
                ),
                onChanged: (value) {
                  setState(() {
                    metrorailSelected = value;
                  });
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _transportCard(
                title: 'Bus',
                subtitle: 'City bus',
                icon:
                    Icons.directions_bus_rounded,
                value: busSelected,
                accent:
                    LinkRideColors.linkGreen,
                onChanged: (value) {
                  setState(() {
                    busSelected = value;
                  });
                },
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _transportCard(
                title: 'Minibus Taxi',
                subtitle: 'Taxi network',
                icon:
                    Icons.airport_shuttle_rounded,
                value: taxiSelected,
                accent: LinkRideColors.warning,
                onChanged: (value) {
                  setState(() {
                    taxiSelected = value;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _transportCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Color accent,
    required ValueChanged<bool> onChanged,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onChanged(!value);
        },
        borderRadius: BorderRadius.circular(
          LinkRideRadius.large,
        ),
        child: Ink(
          height: 132,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: value
                ? accent.withValues(
                    alpha: 0.055,
                  )
                : LinkRideColors.surface,
            borderRadius: BorderRadius.circular(
              LinkRideRadius.large,
            ),
            border: Border.all(
              color: value
                  ? accent.withValues(
                      alpha: 0.28,
                    )
                  : LinkRideColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 39,
                    height: 39,
                    decoration: BoxDecoration(
                      color: accent.withValues(
                        alpha: 0.10,
                      ),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: accent,
                    ),
                  ),

                  const Spacer(),

                  Checkbox(
                    value: value,
                    activeColor: accent,
                    onChanged: (newValue) {
                      if (newValue == null) {
                        return;
                      }

                      onChanged(newValue);
                    },
                  ),
                ],
              ),

              const Spacer(),

              Text(
                title,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color:
                      LinkRideColors.textPrimary,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10.8,
                  color:
                      LinkRideColors
                          .textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _transferPreferenceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        15,
        13,
        11,
        13,
      ),
      decoration:
          LinkRideDecorations.card(),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: LinkRideColors.softGreen,
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.compare_arrows_rounded,
              color: LinkRideColors.linkGreen,
              size: 22,
            ),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Prefer fewer transfers',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color:
                        LinkRideColors.textPrimary,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Prioritise journeys with fewer interchanges between transport services.',
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.35,
                    color:
                        LinkRideColors
                            .textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Switch(
            value: preferFewerTransfers,
            onChanged: (value) {
              setState(() {
                preferFewerTransfers = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed:
            isSaving ? null : _savePreferences,
        child: AnimatedSwitcher(
          duration:
              const Duration(milliseconds: 180),
          child: isSaving
              ? const Row(
                  key: ValueKey(
                    'saving-preferences',
                  ),
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 19,
                      height: 19,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 9),
                    Text(
                      'Saving...',
                    ),
                  ],
                )
              : const Row(
                  key: ValueKey(
                    'save-preferences',
                  ),
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.save_outlined,
                      size: 19,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Save Preferences',
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}