import 'dart:async';

import 'package:flutter/material.dart';

import '../services/active_journey_service.dart';
import '../services/auth_storage.dart';
import '../services/ticket_service.dart';
import '../services/disruption_service.dart';

class ActiveJourneyScreen extends StatefulWidget {
  const ActiveJourneyScreen({
    super.key,
  });

  @override
  State<ActiveJourneyScreen> createState() =>
      _ActiveJourneyScreenState();
}

class _ActiveJourneyScreenState
    extends State<ActiveJourneyScreen> {
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

  static const Duration simulationTick =
      Duration(seconds: 2);

  final AuthStorage _authStorage =
      AuthStorage();

  final ActiveJourneyService
      _activeJourneyService =
      ActiveJourneyService();

  final TicketService _ticketService =
      TicketService();

  final DisruptionService _disruptionService =
      DisruptionService();

  bool _isLoading = true;
  bool _simulationCompleted = false;
  bool _isCompletingJourney = false;

  String? _errorMessage;

  Map<String, dynamic>? _journey;

  List<Map<String, dynamic>> _legs = [];

  List<Map<String, dynamic>>
      _journeyDisruptions = [];

  Timer? _simulationTimer;

  int _currentLegIndex = 0;
  int _elapsedCurrentLegMinutes = 0;

  @override
  void initState() {
    super.initState();

    _loadActiveJourney(
      resetSimulation: true,
    );
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();

    super.dispose();
  }

  Future<void> _loadActiveJourney({
    required bool resetSimulation,
  }) async {
    _simulationTimer?.cancel();

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

      final Map<String, dynamic> response =
          await _activeJourneyService
              .getActiveJourney(
        token: token,
      );

      if (!mounted) {
        return;
      }

      final List<Map<String, dynamic>>
          loadedLegs =
          (response['legs'] as List)
              .map(
                (dynamic leg) =>
                    Map<String, dynamic>.from(
                  leg as Map,
                ),
              )
              .toList();

      loadedLegs.sort(
        (
          Map<String, dynamic> a,
          Map<String, dynamic> b,
        ) =>
            _asInt(
              a['legOrder'],
            ).compareTo(
              _asInt(
                b['legOrder'],
              ),
            ),
      );

      final Map<String, dynamic> loadedJourney =
          Map<String, dynamic>.from(
        response['journey'] as Map,
      );

      List<Map<String, dynamic>> disruptions = [];

      final int journeyId =
          _asInt(
        loadedJourney['journeyId'],
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
            'Active journey disruption check error: $error',
          );
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _journey = loadedJourney;

        _legs = loadedLegs;
        _journeyDisruptions =
            disruptions;

        if (resetSimulation) {
          _currentLegIndex = 0;
          _elapsedCurrentLegMinutes = 0;
          _simulationCompleted = false;
        } else if (_legs.isNotEmpty) {
          _currentLegIndex =
              _currentLegIndex.clamp(
            0,
            _legs.length - 1,
          );

          final int duration =
              _currentLegDuration;

          _elapsedCurrentLegMinutes =
              _elapsedCurrentLegMinutes.clamp(
            0,
            duration,
          );
        }

        _isLoading = false;
      });

      _startSimulationTimer();
    } catch (error) {
      if (!mounted) {
        return;
      }

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

  void _startSimulationTimer() {
    _simulationTimer?.cancel();

    if (_legs.isEmpty ||
        _simulationCompleted) {
      return;
    }

    _simulationTimer =
        Timer.periodic(
      simulationTick,
      (_) {
        _tickSimulation();
      },
    );
  }

  void _tickSimulation() {
    if (!mounted ||
        _legs.isEmpty ||
        _simulationCompleted) {
      return;
    }

    final int duration =
        _currentLegDuration;

    if (duration <= 0) {
      _advanceSimulation(
        manual: false,
      );
      return;
    }

    setState(() {
      _elapsedCurrentLegMinutes += 1;
    });

    if (_elapsedCurrentLegMinutes >=
        duration) {
      _advanceSimulation(
        manual: false,
      );
    }
  }

  Future<void> _advanceSimulation({
    required bool manual,
  }) async {
    if (_legs.isEmpty ||
        _simulationCompleted ||
        _isCompletingJourney) {
      return;
    }

    final bool isFinalLeg =
        _currentLegIndex >=
            _legs.length - 1;

    if (isFinalLeg) {
      _simulationTimer?.cancel();

      setState(() {
        _elapsedCurrentLegMinutes =
            _currentLegDuration;
      });

      await _completeJourney(
        manual: manual,
      );

      return;
    }

    setState(() {
      _currentLegIndex += 1;
      _elapsedCurrentLegMinutes = 0;
    });

    if (mounted) {
      final Map<String, dynamic> nextLeg =
          _legs[_currentLegIndex];

      final String nextMode =
          nextLeg['transportMode']
                  ?.toString()
                  .toUpperCase() ??
              'NEXT';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          duration:
              const Duration(
            milliseconds: 900,
          ),
          content: Text(
            manual
                ? 'Simulation advanced to Leg ${_currentLegIndex + 1} · $nextMode.'
                : 'Leg completed. Now on Leg ${_currentLegIndex + 1} · $nextMode.',
          ),
        ),
      );
    }
  }

  Future<void> _completeJourney({
    required bool manual,
  }) async {
    if (_journey == null ||
        _simulationCompleted ||
        _isCompletingJourney) {
      return;
    }

    setState(() {
      _isCompletingJourney = true;
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

      final int journeyId =
          _asInt(
        _journey!['journeyId'],
      );

      final Map<String, dynamic> completedTicket =
          await _ticketService.completeJourney(
        token: token,
        journeyId: journeyId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isCompletingJourney = false;
        _simulationCompleted = true;
        _journey = {
          ..._journey!,
          'journeyStatus': 'COMPLETED',
        };
      });

      final String ticketStatus =
          completedTicket['ticketStatus']
                  ?.toString()
                  .toUpperCase() ??
              'USED';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            manual
                ? 'Final leg complete. Journey saved as COMPLETED and ticket is $ticketStatus.'
                : 'Journey completed successfully. Ticket is now $ticketStatus.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isCompletingJourney = false;
      });

      final String message =
          error
              .toString()
              .replaceFirst(
                'Exception: ',
                '',
              );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'The simulated journey reached the destination, but Link Ride could not save completion. $message',
          ),
        ),
      );
    }
  }

  Map<String, dynamic> get _currentLeg =>
      _legs[_currentLegIndex];

  int get _currentLegDuration =>
      _asInt(
        _currentLeg[
            'estimatedDuration'],
      );

  int get _remainingCurrentLegMinutes {
    final int remaining =
        _currentLegDuration -
            _elapsedCurrentLegMinutes;

    return remaining < 0
        ? 0
        : remaining;
  }

  int get _totalLegMinutes {
    return _legs.fold<int>(
      0,
      (
        int total,
        Map<String, dynamic> leg,
      ) =>
          total +
          _asInt(
            leg['estimatedDuration'],
          ),
    );
  }

  int get _completedSimulationMinutes {
    int completed = 0;

    for (int index = 0;
        index < _currentLegIndex;
        index++) {
      completed += _asInt(
        _legs[index][
            'estimatedDuration'],
      );
    }

    completed +=
        _elapsedCurrentLegMinutes;

    return completed.clamp(
      0,
      _totalLegMinutes,
    );
  }

  double get _currentLegProgress {
    final int duration =
        _currentLegDuration;

    if (duration <= 0) {
      return 1.0;
    }

    return (_elapsedCurrentLegMinutes /
            duration)
        .clamp(
      0.0,
      1.0,
    );
  }

  double get _overallProgress {
    final int total =
        _totalLegMinutes;

    if (total <= 0) {
      return 0.0;
    }

    return (_completedSimulationMinutes /
            total)
        .clamp(
      0.0,
      1.0,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor:
            Colors.white,

        surfaceTintColor:
            Colors.white,

        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(
              context,
            );
          },

          icon: const Icon(
            Icons.arrow_back_rounded,
            color: primaryBlue,
          ),
        ),

        title: const Text(
          'Active Journey',

          style: TextStyle(
            color: primaryBlue,
            fontSize: 20,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ),

      body: SafeArea(
        child:
            _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(
                      color:
                          primaryBlue,
                    ),
                  )
                : _errorMessage != null
                    ? _errorView()
                    : _journeyView(),
      ),
    );
  }

  Widget _journeyView() {
    final Map<String, dynamic> journey =
        _journey!;

    final int journeyId =
        _asInt(
      journey['journeyId'],
    );

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

    final int totalDuration =
        _asInt(
      journey['estimatedDuration'],
    );

    final double totalCost =
        _asDouble(
      journey['estimatedCost'],
    );

    return RefreshIndicator(
      onRefresh: _simulationCompleted
          ? () async {}
          : () =>
              _loadActiveJourney(
                resetSimulation: false,
              ),

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
          Text(
            _simulationCompleted
                ? 'Journey Completed'
                : 'Journey In Progress',

            style: const TextStyle(
              fontSize: 26,
              fontWeight:
                  FontWeight.w800,
              letterSpacing: -0.5,
              color:
                  primaryBlue,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            _simulationCompleted
                ? 'The journey is persisted as COMPLETED and its ticket has been marked USED.'
                : _isCompletingJourney
                    ? 'Destination reached. Saving journey completion...'
                    : 'Simulated live tracking is running at 2 real seconds per journey minute.',

            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color:
                  textSecondary,
            ),
          ),

          const SizedBox(
            height: 22,
          ),

          if (_journeyDisruptions
              .isNotEmpty) ...[
            _journeyDisruptionWarning(
              _journeyDisruptions,
            ),
            const SizedBox(
              height: 16,
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
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Row(
                  children: [
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

                _locationRow(
                  icon:
                      Icons
                          .trip_origin_rounded,
                  color:
                      linkGreen,
                  text:
                      origin,
                ),

                Padding(
                  padding:
                      const EdgeInsets
                          .only(
                    left: 7,
                  ),

                  child: Container(
                    width: 2,
                    height: 20,
                    color:
                        cardBorder,
                  ),
                ),

                _locationRow(
                  icon:
                      Icons
                          .location_on_rounded,
                  color:
                      primaryBlue,
                  text:
                      destination,
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
                            '$totalDuration min',
                      ),
                    ),

                    Expanded(
                      child: _metric(
                        icon:
                            Icons
                                .payments_outlined,
                        value:
                            'R${totalCost.toStringAsFixed(2)}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          _simulationProgressCard(),

          const SizedBox(
            height: 20,
          ),

          _currentLegCard(),

          const SizedBox(
            height: 20,
          ),

          const Text(
            'Journey Timeline',

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

          ...List.generate(
            _legs.length,
            (int index) =>
                Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 12,
              ),

              child: _timelineLegCard(
                _legs[index],
                index,
              ),
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          _simulationControls(),

          const SizedBox(
            height: 18,
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
                      .science_outlined,
                  size: 20,
                  color:
                      primaryBlue,
                ),

                SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: Text(
                    'Prototype simulation: two real seconds represent one simulated journey minute. Leg progression is driven by persisted estimated durations, not a real GPS feed. Advance Simulation is a demonstration control.',

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

  Widget _simulationProgressCard() {
    final int totalMinutes =
        _totalLegMinutes;

    final int elapsed =
        _completedSimulationMinutes;

    final int remaining =
        (totalMinutes - elapsed)
            .clamp(
      0,
      totalMinutes,
    );

    final int percent =
        (_overallProgress * 100)
            .round();

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

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Overall Journey Progress',

                  style:
                      TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight
                            .w800,
                    color:
                        textPrimary,
                  ),
                ),
              ),

              Text(
                '$percent%',

                style:
                    const TextStyle(
                  fontSize: 14,
                  fontWeight:
                      FontWeight
                          .w800,
                  color:
                      primaryBlue,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(
              20,
            ),

            child:
                LinearProgressIndicator(
              value:
                  _overallProgress,
              minHeight: 9,
              backgroundColor:
                  cardBorder,
              color:
                  primaryBlue,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            '$elapsed of $totalMinutes simulated minutes · $remaining min remaining',

            style:
                const TextStyle(
              fontSize: 11.5,
              color:
                  textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _currentLegCard() {
    final Map<String, dynamic> leg =
        _currentLeg;

    final String mode =
        leg['transportMode']
                ?.toString() ??
            'UNKNOWN';

    final String origin =
        leg['originName']
                ?.toString() ??
            'Unknown origin';

    final String destination =
        leg['destinationName']
                ?.toString() ??
            'Unknown destination';

    final int legOrder =
        _asInt(
      leg['legOrder'],
    );

    final int duration =
        _currentLegDuration;

    final int percent =
        (_currentLegProgress * 100)
            .round();

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
              primaryBlue.withValues(
            alpha: 0.25,
          ),
        ),
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

                child: Icon(
                  _modeIcon(
                    mode,
                  ),
                  color:
                      primaryBlue,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    Text(
                      _simulationCompleted
                          ? 'Final Leg Complete'
                          : 'Current Leg · $mode',

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

                    const SizedBox(
                      height: 2,
                    ),

                    Text(
                      'Leg $legOrder of ${_legs.length}',

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

              _smallStateChip(
                _simulationCompleted
                    ? 'COMPLETE'
                    : 'CURRENT',
              ),
            ],
          ),

          const SizedBox(
            height: 16,
          ),

          Text(
            origin,

            style:
                const TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.w700,
              color:
                  textPrimary,
            ),
          ),

          const Padding(
            padding:
                EdgeInsets.symmetric(
              vertical: 6,
            ),

            child: Icon(
              Icons
                  .arrow_downward_rounded,
              size: 17,
              color:
                  textSecondary,
            ),
          ),

          Text(
            destination,

            style:
                const TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.w700,
              color:
                  textPrimary,
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          Row(
            children: [
              Expanded(
                child: Text(
                  '${_elapsedCurrentLegMinutes.clamp(0, duration)} / $duration min',

                  style:
                      const TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight
                            .w700,
                    color:
                        textPrimary,
                  ),
                ),
              ),

              Text(
                '$percent%',

                style:
                    const TextStyle(
                  fontSize: 12,
                  fontWeight:
                      FontWeight
                          .w800,
                  color:
                      primaryBlue,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 8,
          ),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(
              20,
            ),

            child:
                LinearProgressIndicator(
              value:
                  _currentLegProgress,
              minHeight: 8,
              backgroundColor:
                  cardBorder,
              color:
                  primaryBlue,
            ),
          ),

          const SizedBox(
            height: 9,
          ),

          Text(
            _simulationCompleted
                ? 'Destination reached in the prototype simulation.'
                : '$_remainingCurrentLegMinutes simulated min remaining',

            style:
                const TextStyle(
              fontSize: 11.5,
              color:
                  textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineLegCard(
    Map<String, dynamic> leg,
    int index,
  ) {
    final int legOrder =
        _asInt(
      leg['legOrder'],
    );

    final String mode =
        leg['transportMode']
                ?.toString() ??
            'UNKNOWN';

    final String origin =
        leg['originName']
                ?.toString() ??
            'Unknown origin';

    final String destination =
        leg['destinationName']
                ?.toString() ??
            'Unknown destination';

    final int duration =
        _asInt(
      leg['estimatedDuration'],
    );

    final double cost =
        _asDouble(
      leg['estimatedCost'],
    );

    final bool completed =
        index < _currentLegIndex ||
            (_simulationCompleted &&
                index <=
                    _currentLegIndex);

    final bool current =
        index == _currentLegIndex &&
            !_simulationCompleted;

    final String state =
        completed
            ? 'COMPLETED'
            : current
                ? 'CURRENT'
                : 'UPCOMING';

    return Container(
      width:
          double.infinity,

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
              current
                  ? primaryBlue
                      .withValues(
                    alpha: 0.28,
                  )
                  : cardBorder,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,

                decoration:
                    BoxDecoration(
                  color:
                      completed
                          ? linkGreen
                              .withValues(
                            alpha: 0.10,
                          )
                          : primaryBlue
                              .withValues(
                            alpha: 0.08,
                          ),

                  borderRadius:
                      BorderRadius
                          .circular(
                    12,
                  ),
                ),

                child: Icon(
                  completed
                      ? Icons
                          .check_rounded
                      : _modeIcon(
                          mode,
                        ),
                  color:
                      completed
                          ? linkGreen
                          : primaryBlue,
                ),
              ),

              const SizedBox(
                width: 11,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    Text(
                      'Leg $legOrder · ${mode.toUpperCase()}',

                      style:
                          const TextStyle(
                        fontSize: 13.5,
                        fontWeight:
                            FontWeight
                                .w800,
                        color:
                            textPrimary,
                      ),
                    ),

                    const SizedBox(
                      height: 2,
                    ),

                    Text(
                      '$duration min · R${cost.toStringAsFixed(2)}',

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

              _smallStateChip(
                state,
              ),
            ],
          ),

          const SizedBox(
            height: 14,
          ),

          Text(
            origin,

            style:
                const TextStyle(
              fontSize: 12.5,
              fontWeight:
                  FontWeight.w700,
              color:
                  textPrimary,
            ),
          ),

          const Padding(
            padding:
                EdgeInsets.symmetric(
              vertical: 5,
            ),

            child: Icon(
              Icons
                  .arrow_downward_rounded,
              size: 16,
              color:
                  textSecondary,
            ),
          ),

          Text(
            destination,

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
      ),
    );
  }

  Widget _simulationControls() {
    return Container(
      width:
          double.infinity,

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

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            'Prototype Simulation Controls',

            style:
                TextStyle(
              fontSize: 14,
              fontWeight:
                  FontWeight.w800,
              color:
                  textPrimary,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          const Text(
            'Automatic progression continues in the background. Use this control to move immediately to the next leg during a demonstration.',

            style:
                TextStyle(
              fontSize: 11.5,
              height: 1.4,
              color:
                  textSecondary,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          SizedBox(
            width:
                double.infinity,

            height: 46,

            child:
                ElevatedButton.icon(
              onPressed:
                  _simulationCompleted ||
                          _isCompletingJourney
                      ? null
                      : () {
                          _advanceSimulation(
                            manual:
                                true,
                          );
                        },

              icon: _isCompletingJourney
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      _simulationCompleted
                          ? Icons
                              .check_circle_rounded
                          : Icons
                              .skip_next_rounded,
                    ),

              label: Text(
                _isCompletingJourney
                    ? 'Saving Completion...'
                    : _simulationCompleted
                        ? 'Journey Completed'
                        : (_currentLegIndex >=
                                    _legs.length - 1 &&
                                _elapsedCurrentLegMinutes >=
                                    _currentLegDuration)
                            ? 'Complete Journey'
                            : 'Advance Simulation',

                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight
                          .w800,
                ),
              ),

              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    primaryBlue,

                disabledBackgroundColor:
                    primaryBlue
                        .withValues(
                  alpha: 0.45,
                ),

                foregroundColor:
                    Colors.white,

                disabledForegroundColor:
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
            ),
          ),
        ],
      ),
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

  Widget _smallStateChip(
    String state,
  ) {
    final bool completed =
        state == 'COMPLETED' ||
            state == 'COMPLETE';

    return Container(
      padding:
          const EdgeInsets
              .symmetric(
        horizontal: 8,
        vertical: 5,
      ),

      decoration:
          BoxDecoration(
        color:
            completed
                ? linkGreen
                    .withValues(
                  alpha: 0.10,
                )
                : primaryBlue
                    .withValues(
                  alpha: 0.08,
                ),

        borderRadius:
            BorderRadius
                .circular(
          20,
        ),
      ),

      child: Text(
        state,

        style:
            TextStyle(
          fontSize: 9,
          fontWeight:
              FontWeight.w800,
          color:
              completed
                  ? linkGreen
                  : primaryBlue,
        ),
      ),
    );
  }

  Widget _locationRow({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color:
              color,
        ),

        const SizedBox(
          width: 8,
        ),

        Expanded(
          child: Text(
            text,

            style:
                const TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.w700,
              color:
                  textPrimary,
            ),
          ),
        ),
      ],
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

  Widget _errorView() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          24,
        ),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            const Icon(
              Icons
                  .error_outline_rounded,
              size: 50,
              color:
                  primaryBlue,
            ),

            const SizedBox(
              height: 14,
            ),

            Text(
              _errorMessage ??
                  'Unable to load active journey.',

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                fontSize: 13,
                height: 1.4,
                color:
                    textSecondary,
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            ElevatedButton.icon(
              onPressed: () {
                _loadActiveJourney(
                  resetSimulation:
                      true,
                );
              },

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
      ),
    );
  }

  IconData _modeIcon(
    String mode,
  ) {
    switch (mode.toUpperCase()) {
      case 'TRAIN':
        return Icons.train_rounded;

      case 'BUS':
        return Icons.directions_bus_rounded;

      case 'TAXI':
        return Icons.local_taxi_rounded;

      case 'WALK':
        return Icons.directions_walk_rounded;

      default:
        return Icons.route_rounded;
    }
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
