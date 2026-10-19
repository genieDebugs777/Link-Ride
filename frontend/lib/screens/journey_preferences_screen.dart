import 'package:flutter/material.dart';
import '../services/journey_preferences_service.dart';

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
  static const Color primaryBlue = Color(0xFF003F73);
  static const Color linkGreen = Color(0xFF4A9B45);
  static const Color background = Color(0xFFF7F9FB);
  static const Color textPrimary = Color(0xFF17212B);
  static const Color textSecondary = Color(0xFF667085);
  static const Color cardBorder = Color(0xFFE4E9EE);

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
          'Journey Preferences',
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
                      'Personalise your journeys',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Choose how Link Ride should prioritise and '
                      'suggest transport options.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: textSecondary,
                      ),
                    ),

                    const SizedBox(height: 26),

                    _sectionTitle('JOURNEY PRIORITY'),

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
                      child: _card(
                        child: Column(
                          children: [
                            _priorityOption(
                              title: 'Balanced',
                              subtitle:
                                  'Balance travel time, cost and convenience',
                              icon: Icons.balance_rounded,
                            ),
                            _divider(),
                            _priorityOption(
                              title: 'Fastest',
                              subtitle:
                                  'Prioritise the shortest overall travel time',
                              icon: Icons.bolt_rounded,
                            ),
                            _divider(),
                            _priorityOption(
                              title: 'Cheapest',
                              subtitle:
                                  'Prioritise journeys with lower estimated costs',
                              icon: Icons.savings_outlined,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    _sectionTitle('PREFERRED TRANSPORT'),

                    _card(
                      child: Column(
                        children: [
                          _transportOption(
                            title: 'Gautrain',
                            icon: Icons.train_rounded,
                            value: gautrainSelected,
                            onChanged: (value) {
                              setState(() {
                                gautrainSelected = value;
                              });
                            },
                          ),
                          _divider(),
                          _transportOption(
                            title: 'Metrorail',
                            icon:
                                Icons.directions_railway_rounded,
                            value: metrorailSelected,
                            onChanged: (value) {
                              setState(() {
                                metrorailSelected = value;
                              });
                            },
                          ),
                          _divider(),
                          _transportOption(
                            title: 'Bus',
                            icon: Icons.directions_bus_rounded,
                            value: busSelected,
                            onChanged: (value) {
                              setState(() {
                                busSelected = value;
                              });
                            },
                          ),
                          _divider(),
                          _transportOption(
                            title: 'Minibus Taxi',
                            icon:
                                Icons.airport_shuttle_rounded,
                            value: taxiSelected,
                            onChanged: (value) {
                              setState(() {
                                taxiSelected = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    _sectionTitle('ROUTE PREFERENCE'),

                    _card(
                      child: SwitchListTile(
                        value: preferFewerTransfers,
                        activeThumbColor: linkGreen,
                        title: const Text(
                          'Prefer fewer transfers',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        subtitle: const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            'Prioritise journeys with fewer interchanges '
                            'between transport services.',
                            style: TextStyle(
                              fontSize: 11.5,
                              height: 1.35,
                              color: textSecondary,
                            ),
                          ),
                        ),
                        secondary: const Icon(
                          Icons.compare_arrows_rounded,
                          color: primaryBlue,
                        ),
                        onChanged: (value) {
                          setState(() {
                            preferFewerTransfers = value;
                          });
                        },
                      ),
                    ),

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

  Widget _priorityOption({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedPriority = title;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 14,
        ),
        child: Row(
          children: [
            _iconBox(icon),
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
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      height: 1.35,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: title,
            ),
          ],
        ),
      ),
    );
  }

  Widget _transportOption({
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return CheckboxListTile(
      value: value,
      activeColor: linkGreen,
      controlAffinity:
          ListTileControlAffinity.trailing,
      secondary: _iconBox(icon),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      onChanged: (newValue) {
        if (newValue == null) {
          return;
        }

        onChanged(newValue);
      },
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