import 'package:flutter/material.dart';

import '../services/auth_storage.dart';
import '../services/my_journeys_service.dart';
import '../services/disruption_service.dart';
import 'active_journey_screen.dart';
import 'my_journeys_screen.dart';
import 'payment_screen.dart';
import 'ticket_screen.dart';

class JourneysScreen extends StatefulWidget {
  final int refreshToken;

  const JourneysScreen({
    super.key,
    this.refreshToken = 0,
  });

  @override
  State<JourneysScreen> createState() =>
      _JourneysScreenState();
}

class _JourneysScreenState
    extends State<JourneysScreen> {
  static const Color primaryBlue =
      Color(0xFF003F73);

  static const Color linkGreen =
      Color(0xFF4A9B45);

  static const Color background =
      Color(0xFFF7F9FB);

  static const Color textPrimary =
      Color(0xFF17212B);

  static const Color textSecondary =
      Color(0xFF667085);

  static const Color cardBorder =
      Color(0xFFE4E9EE);

  final AuthStorage _authStorage =
      AuthStorage();

  final MyJourneysService _myJourneysService =
      MyJourneysService();

  final DisruptionService _disruptionService =
      DisruptionService();

  bool _isLoading = true;

  String? _errorMessage;

  List<Map<String, dynamic>> _journeys = [];

  List<Map<String, dynamic>>
      _currentJourneyDisruptions = [];

  @override
  void initState() {
    super.initState();

    _loadJourneys();
  }

  @override
  void didUpdateWidget(
    covariant JourneysScreen oldWidget,
  ) {
    super.didUpdateWidget(
      oldWidget,
    );

    if (oldWidget.refreshToken !=
        widget.refreshToken) {
      _loadJourneys();
    }
  }

  Future<void> _loadJourneys() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String? token =
          await _authStorage.getToken();

      if (token == null ||
          token.isEmpty) {
        throw Exception(
          'Your Link Ride session is no longer valid.',
        );
      }

      final List<Map<String, dynamic>>
          journeys =
          await _myJourneysService
              .getMyJourneys(
        token: token,
      );

      List<Map<String, dynamic>> disruptions = [];

      Map<String, dynamic>? currentJourney;

      for (final Map<String, dynamic> journey
          in journeys) {
        final String status =
            journey['journeyStatus']
                    ?.toString()
                    .toUpperCase() ??
                '';

        if (status == 'SELECTED' ||
            status == 'PAID' ||
            status == 'READY' ||
            status == 'IN_PROGRESS') {
          currentJourney = journey;
          break;
        }
      }

      if (currentJourney != null) {
        final int journeyId =
            _asInt(
          currentJourney['journeyId'],
        );

        if (journeyId > 0) {
          try {
            disruptions =
                await _disruptionService
                    .getActiveDisruptionsForJourney(
              token: token,
              journeyId: journeyId,
            );
          } catch (error) {
            debugPrint(
              'Journey disruption check error: $error',
            );
          }
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _journeys = journeys;
        _currentJourneyDisruptions =
            disruptions;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      debugPrint(
        'Journeys hub error: $error',
      );

      setState(() {
        _isLoading = false;
        _errorMessage = error
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  Map<String, dynamic>? get _currentJourney {
    for (final Map<String, dynamic> journey
        in _journeys) {
      final String status =
          journey['journeyStatus']
                  ?.toString()
                  .toUpperCase() ??
              '';

      if (status == 'SELECTED' ||
          status == 'PAID' ||
          status == 'READY' ||
          status == 'IN_PROGRESS') {
        return journey;
      }
    }

    return null;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: background,

      body: SafeArea(
        bottom: false,

        child: RefreshIndicator(
          onRefresh: _loadJourneys,

          child: ListView(
            physics:
                const AlwaysScrollableScrollPhysics(),

            padding:
                const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              30,
            ),

            children: [
              const Text(
                'Journeys',

                style: TextStyle(
                  fontSize: 28,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing: -0.6,
                  color: primaryBlue,
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              const Text(
                'Manage your selected, active and previous journeys.',

                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.4,
                  color:
                      textSecondary,
                ),
              ),

              const SizedBox(
                height: 22,
              ),

              if (_isLoading)
                const _LoadingCard()
              else if (_errorMessage != null)
                _errorCard()
              else
                _currentJourneySection(),

              const SizedBox(
                height: 24,
              ),

              const Text(
                'Journey Management',

                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      textPrimary,
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              _managementCard(
                icon:
                    Icons.history_rounded,

                title:
                    'My Journeys',

                subtitle:
                    'View your saved and recent journeys',

                onTap: () async {
                  await Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder:
                          (context) =>
                              const MyJourneysScreen(),
                    ),
                  );

                  if (mounted) {
                    await _loadJourneys();
                  }
                },
              ),

              const SizedBox(
                height: 10,
              ),

              _managementCard(
                icon:
                    Icons
                        .check_circle_outline_rounded,

                title:
                    'Journey History',

                subtitle:
                    'View your completed journeys',

                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const MyJourneysScreen(
                        completedOnly: true,
                      ),
                    ),
                  );

                  if (mounted) {
                    await _loadJourneys();
                  }
                },
              ),

              const SizedBox(
                height: 24,
              ),

              Container(
                width:
                    double.infinity,

                padding:
                    const EdgeInsets.all(
                  16,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      primaryBlue
                          .withValues(
                    alpha: 0.05,
                  ),

                  borderRadius:
                      BorderRadius
                          .circular(
                    18,
                  ),
                ),

                child: const Row(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    Icon(
                      Icons
                          .info_outline_rounded,
                      size: 20,
                      color:
                          primaryBlue,
                    ),

                    SizedBox(
                      width: 11,
                    ),

                    Expanded(
                      child: Text(
                        'As Link Ride evolves, this area will support payment, tickets, live journey tracking, disruption alerts and journey completion.',

                        style:
                            TextStyle(
                          fontSize: 12,
                          height: 1.45,
                          color:
                              textSecondary,
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

  Widget _currentJourneySection() {
    final Map<String, dynamic>?
        journey =
        _currentJourney;

    if (journey == null) {
      return Container(
        width:
            double.infinity,

        padding:
            const EdgeInsets.all(
          18,
        ),

        decoration:
            BoxDecoration(
          color:
              Colors.white,

          borderRadius:
              BorderRadius
                  .circular(
            20,
          ),

          border:
              Border.all(
            color:
                cardBorder,
          ),
        ),

        child: const Column(
          children: [
            Icon(
              Icons
                  .route_outlined,
              size: 42,
              color:
                  primaryBlue,
            ),

            SizedBox(
              height: 12,
            ),

            Text(
              'No current journey',

              style:
                  TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight
                        .w800,
                color:
                    textPrimary,
              ),
            ),

            SizedBox(
              height: 5,
            ),

            Text(
              'Choose a journey from Home and it will appear here.',

              textAlign:
                  TextAlign.center,

              style:
                  TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color:
                    textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final String origin =
        journey['origin']
                ?.toString() ??
            'Unknown origin';

    final String destination =
        journey['destination']
                ?.toString() ??
            'Unknown destination';

    final String status =
        journey['journeyStatus']
                ?.toString() ??
            'UNKNOWN';

    final int duration =
        _asInt(
      journey[
          'estimatedDuration'],
    );

    final double cost =
        _asDouble(
      journey[
          'estimatedCost'],
    );

    final int journeyId =
        _asInt(
      journey[
          'journeyId'],
    );

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        const Text(
          'Current Journey',

          style: TextStyle(
            fontSize: 18,
            fontWeight:
                FontWeight.w800,
            color:
                textPrimary,
          ),
        ),

        const SizedBox(
          height: 12,
        ),

        if (_currentJourneyDisruptions
            .isNotEmpty) ...[
          _journeyDisruptionWarning(
            _currentJourneyDisruptions,
          ),
          const SizedBox(
            height: 12,
          ),
        ],

        Container(
          width:
              double.infinity,

          padding:
              const EdgeInsets.all(
            18,
          ),

          decoration:
              BoxDecoration(
            color:
                Colors.white,

            borderRadius:
                BorderRadius
                    .circular(
              22,
            ),

            border:
                Border.all(
              color:
                  cardBorder,
            ),

            boxShadow: [
              BoxShadow(
                color:
                    Colors.black
                        .withValues(
                  alpha: 0.025,
                ),

                blurRadius:
                    16,

                offset:
                    const Offset(
                  0,
                  6,
                ),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,

                    decoration:
                        BoxDecoration(
                      color:
                          primaryBlue
                              .withValues(
                        alpha: 0.08,
                      ),

                      borderRadius:
                          BorderRadius
                              .circular(
                        13,
                      ),
                    ),

                    child:
                        const Icon(
                      Icons
                          .route_rounded,
                      color:
                          primaryBlue,
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: Text(
                      'Journey #$journeyId',

                      style:
                          const TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight
                                .w800,
                        color:
                            textPrimary,
                      ),
                    ),
                  ),

                  _statusChip(
                    status,
                  ),
                ],
              ),

              const SizedBox(
                height: 16,
              ),

              Row(
                children: [
                  const Icon(
                    Icons
                        .trip_origin_rounded,
                    size: 17,
                    color:
                        linkGreen,
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  Expanded(
                    child: Text(
                      origin,

                      style:
                          const TextStyle(
                        fontSize: 13,
                        fontWeight:
                            FontWeight
                                .w700,
                        color:
                            textPrimary,
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding:
                    const EdgeInsets
                        .only(
                  left: 7,
                ),

                child:
                    Container(
                  width: 2,
                  height: 20,
                  color:
                      cardBorder,
                ),
              ),

              Row(
                children: [
                  const Icon(
                    Icons
                        .location_on_rounded,
                    size: 17,
                    color:
                        primaryBlue,
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  Expanded(
                    child: Text(
                      destination,

                      style:
                          const TextStyle(
                        fontSize: 13,
                        fontWeight:
                            FontWeight
                                .w700,
                        color:
                            textPrimary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 16,
              ),

              const Divider(
                height: 1,
                color:
                    cardBorder,
              ),

              const SizedBox(
                height: 14,
              ),

              Row(
                children: [
                  Expanded(
                    child: _metric(
                      icon:
                          Icons
                              .schedule_rounded,
                      value:
                          '$duration min',
                    ),
                  ),

                  Expanded(
                    child: _metric(
                      icon:
                          Icons
                              .payments_outlined,
                      value:
                          'R${cost.toStringAsFixed(2)}',
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 16,
              ),

              SizedBox(
                width:
                    double.infinity,

                height: 46,

                child:
                    ElevatedButton(
                  onPressed: () async {
                    final String normalizedStatus =
                        status.toUpperCase();

                    if (normalizedStatus == 'SELECTED') {
                      final bool? paymentCompleted =
                          await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PaymentScreen(
                            journey: journey,
                          ),
                        ),
                      );

                      if (paymentCompleted == true &&
                          mounted) {
                        await _loadJourneys();
                      }

                      return;
                    }

                   if (normalizedStatus == 'PAID') {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TicketScreen(
                            journey: journey,
                          ),
                        ),
                      );

                      if (mounted) {
                        await _loadJourneys();
                      }

                      return;
                    }

                   if (normalizedStatus == 'READY') {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TicketScreen(
                            journey: journey,
                          ),
                        ),
                      );

                      if (mounted) {
                        await _loadJourneys();
                      }

                      return;
                    }

                    if (normalizedStatus ==
                        'IN_PROGRESS') {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ActiveJourneyScreen(),
                        ),
                      );

                      if (mounted) {
                        await _loadJourneys();
                      }

                      return;
                    }
                  },

                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        primaryBlue,

                    foregroundColor:
                        Colors.white,

                    elevation: 0,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                    ),
                  ),

                  child: Text(
                    status.toUpperCase() == 'SELECTED'
                      ? 'Continue to Payment'
                      : status.toUpperCase() == 'PAID'
                          ? 'Continue to Ticket'
                          : status.toUpperCase() == 'READY'
                              ? 'View Ticket'
                              : 'Continue Journey',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _journeyDisruptionWarning(
    List<Map<String, dynamic>> disruptions,
  ) {
    if (disruptions.isEmpty) {
      return const SizedBox.shrink();
    }

    final Map<String, dynamic> disruption =
        disruptions.first;

    final String title =
        disruption['title']?.toString() ??
            'Transport disruption';

    final String description =
        disruption['description']?.toString() ??
            'A service disruption is affecting this journey.';

    final String severity =
        disruption['severity']
                ?.toString()
                .toUpperCase() ??
            'MEDIUM';

    final int routeId =
        _asInt(
      disruption['routeId'],
    );

    final Color warningColor =
        severity == 'CRITICAL'
            ? const Color(0xFFD64545)
            : severity == 'HIGH'
                ? const Color(0xFFD96A1D)
                : const Color(0xFFE28A19);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: warningColor.withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: warningColor.withValues(
            alpha: 0.30,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: warningColor.withValues(
                alpha: 0.12,
              ),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: warningColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Your journey is affected',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: warningColor
                            .withValues(
                          alpha: 0.12,
                        ),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Text(
                        severity,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight:
                              FontWeight.w800,
                          color: warningColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  routeId > 0
                      ? 'Route #$routeId • $title'
                      : title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight:
                        FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    color: textSecondary,
                  ),
                ),
                if (disruptions.length > 1) ...[
                  const SizedBox(height: 5),
                  Text(
                    '+${disruptions.length - 1} more active disruption'
                    '${disruptions.length - 1 == 1 ? '' : 's'} affecting this journey',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight:
                          FontWeight.w700,
                      color: warningColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _managementCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color:
          Colors.transparent,

      child: InkWell(
        onTap:
            onTap,

        borderRadius:
            BorderRadius
                .circular(
          18,
        ),

        child: Ink(
          padding:
              const EdgeInsets.all(
            16,
          ),

          decoration:
              BoxDecoration(
            color:
                Colors.white,

            borderRadius:
                BorderRadius
                    .circular(
              18,
            ),

            border:
                Border.all(
              color:
                  cardBorder,
            ),
          ),

          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,

                decoration:
                    BoxDecoration(
                  color:
                      primaryBlue
                          .withValues(
                    alpha: 0.08,
                  ),

                  borderRadius:
                      BorderRadius
                          .circular(
                    13,
                  ),
                ),

                child: Icon(
                  icon,
                  size: 22,
                  color:
                      primaryBlue,
                ),
              ),

              const SizedBox(
                width: 13,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    Text(
                      title,

                      style:
                          const TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight
                                .w700,
                        color:
                            textPrimary,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      subtitle,

                      style:
                          const TextStyle(
                        fontSize: 11.5,
                        color:
                            textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons
                    .chevron_right_rounded,
                color:
                    Color(
                  0xFF98A2B3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metric({
    required IconData icon,
    required String value,
  }) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,

      children: [
        Icon(
          icon,
          size: 16,
          color:
              primaryBlue,
        ),

        const SizedBox(
          width: 6,
        ),

        Text(
          value,

          style:
              const TextStyle(
            fontSize: 12.5,
            fontWeight:
                FontWeight.w700,
            color:
                textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _statusChip(
    String status,
  ) {
    return Container(
      padding:
          const EdgeInsets
              .symmetric(
        horizontal: 9,
        vertical: 5,
      ),

      decoration:
          BoxDecoration(
        color:
            linkGreen.withValues(
          alpha: 0.10,
        ),

        borderRadius:
            BorderRadius
                .circular(
          20,
        ),
      ),

      child: Text(
        status
            .replaceAll(
              '_',
              ' ',
            )
            .toUpperCase(),

        style:
            const TextStyle(
          fontSize: 10,
          fontWeight:
              FontWeight.w800,
          color:
              linkGreen,
        ),
      ),
    );
  }

  Widget _errorCard() {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.all(
        18,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius
                .circular(
          18,
        ),

        border:
            Border.all(
          color:
              cardBorder,
        ),
      ),

      child: Column(
        children: [
          const Icon(
            Icons
                .error_outline_rounded,
            size: 38,
            color:
                primaryBlue,
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            _errorMessage ??
                'Unable to load journeys.',

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              fontSize: 12.5,
              color:
                  textSecondary,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          TextButton.icon(
            onPressed:
                _loadJourneys,

            icon:
                const Icon(
              Icons
                  .refresh_rounded,
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

  int _asInt(
    dynamic value,
  ) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ??
              '',
        ) ??
        0;
  }

  double _asDouble(
    dynamic value,
  ) {
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ??
              '',
        ) ??
        0.0;
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          20,
        ),
        border: Border.all(
          color: const Color(
            0xFFE4E9EE,
          ),
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(
            0xFF003F73,
          ),
        ),
      ),
    );
  }
}