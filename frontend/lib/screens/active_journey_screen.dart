import 'dart:async';

import 'package:flutter/material.dart';

import '../services/active_journey_service.dart';
import '../services/auth_storage.dart';
import '../services/disruption_service.dart';
import '../services/ticket_service.dart';
import '../theme/link_ride_theme.dart';

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

      final Map<String, dynamic>
          loadedJourney =
          Map<String, dynamic>.from(
        response['journey'] as Map,
      );

      List<Map<String, dynamic>>
          disruptions = [];

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

          _elapsedCurrentLegMinutes =
              0;

          _simulationCompleted =
              false;
        } else if (_legs.isNotEmpty) {
          _currentLegIndex =
              _currentLegIndex.clamp(
            0,
            _legs.length - 1,
          );

          final int duration =
              _currentLegDuration;

          _elapsedCurrentLegMinutes =
              _elapsedCurrentLegMinutes
                  .clamp(
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

      _elapsedCurrentLegMinutes =
          0;
    });

    if (mounted) {
      final Map<String, dynamic>
          nextLeg =
          _legs[_currentLegIndex];

      final String nextMode =
          nextLeg['transportMode']
                  ?.toString()
                  .toUpperCase() ??
              'NEXT';

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          duration: const Duration(
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

      final Map<String, dynamic>
          completedTicket =
          await _ticketService
              .completeJourney(
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

      ScaffoldMessenger.of(context)
          .showSnackBar(
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

      ScaffoldMessenger.of(context)
          .showSnackBar(
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          LinkRideColors.background,
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
          'Active Journey',
        ),
      ),
      body: SafeArea(
        top: false,
        child: _isLoading
            ? _loadingView()
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
          : () {
              return _loadActiveJourney(
                resetSimulation: false,
              );
            },
      color:
          LinkRideColors.primaryBlue,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.fromLTRB(
          20,
          14,
          20,
          30,
        ),
        children: [
          _journeyHeader(),

          const SizedBox(height: 18),

          if (_journeyDisruptions
              .isNotEmpty) ...[
            _journeyDisruptionWarning(
              _journeyDisruptions,
            ),

            const SizedBox(height: 14),
          ],

          _journeySummaryCard(
            journeyId: journeyId,
            status: status,
            origin: origin,
            destination: destination,
            totalDuration:
                totalDuration,
            totalCost:
                totalCost,
          ),

          const SizedBox(height: 18),

          _simulationProgressCard(),

          const SizedBox(height: 18),

          if (_legs.isNotEmpty)
            _currentLegCard(),

          const SizedBox(height: 24),

          const Text(
            'Journey Timeline',
            style: TextStyle(
              fontSize: 19,
              fontWeight:
                  FontWeight.w800,
              letterSpacing: -0.2,
              color:
                  LinkRideColors
                      .textPrimary,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Track each leg of your multimodal journey.',
            style: TextStyle(
              fontSize: 12.5,
              color:
                  LinkRideColors
                      .textSecondary,
            ),
          ),

          const SizedBox(height: 14),

          ...List.generate(
            _legs.length,
            (int index) =>
                Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 11,
              ),
              child:
                  _timelineLegCard(
                _legs[index],
                index,
              ),
            ),
          ),

          const SizedBox(height: 5),

          _simulationControls(),

          const SizedBox(height: 18),

          _prototypeNotice(),
        ],
      ),
    );
  }

  Widget _journeyHeader() {
    final bool completed =
        _simulationCompleted;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration:
          LinkRideDecorations.blueCard(),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -45,
            child: Container(
              width: 130,
              height: 130,
              decoration:
                  BoxDecoration(
                color: Colors.white
                    .withValues(
                  alpha: 0.06,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration:
                    BoxDecoration(
                  color: Colors.white
                      .withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    LinkRideRadius.pill,
                  ),
                ),
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Icon(
                      completed
                          ? Icons
                              .check_circle_rounded
                          : Icons
                              .navigation_rounded,
                      size: 15,
                      color: Colors.white,
                    ),

                    const SizedBox(width: 6),

                    Text(
                      completed
                          ? 'JOURNEY COMPLETE'
                          : 'LIVE JOURNEY',
                      style:
                          const TextStyle(
                        fontSize: 9.8,
                        fontWeight:
                            FontWeight.w800,
                        letterSpacing:
                            0.7,
                        color:
                            Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              Text(
                completed
                    ? 'Journey Completed'
                    : 'Journey In Progress',
                style:
                    const TextStyle(
                  fontSize: 26,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing: -0.6,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                completed
                    ? 'Your journey is persisted as COMPLETED and the linked ticket is marked USED.'
                    : _isCompletingJourney
                        ? 'Destination reached. Saving journey completion...'
                        : 'Live prototype tracking is currently running.',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.45,
                  color: Colors.white
                      .withValues(
                    alpha: 0.76,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _journeySummaryCard({
    required int journeyId,
    required String status,
    required String origin,
    required String destination,
    required int totalDuration,
    required double totalCost,
  }) {
    final Color statusColor =
        _statusColor(status);

    return Container(
      width: double.infinity,
      decoration:
          LinkRideDecorations.card(),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.fromLTRB(
              16,
              15,
              16,
              14,
            ),
            decoration:
                BoxDecoration(
              color:
                  statusColor.withValues(
                alpha: 0.055,
              ),
              borderRadius:
                  const BorderRadius.vertical(
                top: Radius.circular(
                  LinkRideRadius.large,
                ),
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
                        statusColor.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      13,
                    ),
                  ),
                  child: Icon(
                    _simulationCompleted
                        ? Icons
                            .check_circle_rounded
                        : Icons
                            .route_rounded,
                    size: 21,
                    color: statusColor,
                  ),
                ),

                const SizedBox(width: 11),

                Expanded(
                  child: Text(
                    'Journey #$journeyId',
                    style:
                        const TextStyle(
                      fontSize: 14.5,
                      fontWeight:
                          FontWeight.w800,
                      color:
                          LinkRideColors
                              .textPrimary,
                    ),
                  ),
                ),

                _statusChip(status),
              ],
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.all(16),
            child: Column(
              children: [
                _routePoint(
                  icon: Icons
                      .trip_origin_rounded,
                  color:
                      LinkRideColors.linkGreen,
                  label: 'FROM',
                  value: origin,
                ),

                Padding(
                  padding:
                      const EdgeInsets.only(
                    left: 16,
                  ),
                  child: Align(
                    alignment:
                        Alignment.centerLeft,
                    child: Container(
                      width: 2,
                      height: 20,
                      color:
                          LinkRideColors
                              .borderStrong,
                    ),
                  ),
                ),

                _routePoint(
                  icon: Icons
                      .location_on_rounded,
                  color:
                      LinkRideColors.primaryBlue,
                  label: 'TO',
                  value: destination,
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _metricCard(
                        icon: Icons
                            .schedule_rounded,
                        label: 'Duration',
                        value:
                            '$totalDuration min',
                        accent:
                            LinkRideColors.primaryBlue,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _metricCard(
                        icon: Icons
                            .payments_outlined,
                        label: 'Fare',
                        value:
                            'R${totalCost.toStringAsFixed(2)}',
                        accent:
                            LinkRideColors.linkGreen,
                      ),
                    ),
                  ],
                ),
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
        totalMinutes <= 0
            ? 0
            : (totalMinutes - elapsed)
                .clamp(
              0,
              totalMinutes,
            );

    final int percent =
        (_overallProgress * 100)
            .round();

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(17),
      decoration:
          LinkRideDecorations.card(),
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
                    const BoxDecoration(
                  color:
                      LinkRideColors.softBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons
                      .timeline_rounded,
                  size: 21,
                  color:
                      LinkRideColors
                          .primaryBlue,
                ),
              ),

              const SizedBox(width: 11),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall progress',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight:
                            FontWeight.w800,
                        color:
                            LinkRideColors
                                .textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Live prototype journey simulation',
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            LinkRideColors
                                .textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '$percent%',
                style:
                    const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      LinkRideColors
                          .primaryBlue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(
              LinkRideRadius.pill,
            ),
            child:
                LinearProgressIndicator(
              value:
                  _overallProgress,
              minHeight: 9,
              backgroundColor:
                  LinkRideColors.border,
              color:
                  _simulationCompleted
                      ? LinkRideColors
                          .linkGreen
                      : LinkRideColors
                          .primaryBlue,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            '$elapsed of $totalMinutes simulated minutes · $remaining min remaining',
            style:
                const TextStyle(
              fontSize: 11.5,
              color:
                  LinkRideColors
                      .textSecondary,
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

    final Color modeColor =
        _modeColor(mode);

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color:
            LinkRideColors.surface,
        borderRadius:
            BorderRadius.circular(
          LinkRideRadius.large,
        ),
        border: Border.all(
          color:
              modeColor.withValues(
            alpha: 0.28,
          ),
        ),
        boxShadow:
            LinkRideShadows.soft,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration:
                    BoxDecoration(
                  color:
                      modeColor.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
                child: Icon(
                  _modeIcon(mode),
                  color: modeColor,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      _simulationCompleted
                          ? 'Final Leg Complete'
                          : 'Current Leg · ${_formatMode(mode)}',
                      style:
                          const TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w800,
                        color:
                            LinkRideColors
                                .textPrimary,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      'Leg $legOrder of ${_legs.length}',
                      style:
                          const TextStyle(
                        fontSize: 11.5,
                        color:
                            LinkRideColors
                                .textSecondary,
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

          const SizedBox(height: 16),

          _simpleRoute(
            origin: origin,
            destination:
                destination,
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Text(
                  '${_elapsedCurrentLegMinutes.clamp(0, duration)} / $duration min',
                  style:
                      const TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        LinkRideColors
                            .textPrimary,
                  ),
                ),
              ),

              Text(
                '$percent%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w800,
                  color: modeColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(
              LinkRideRadius.pill,
            ),
            child:
                LinearProgressIndicator(
              value:
                  _currentLegProgress,
              minHeight: 8,
              backgroundColor:
                  LinkRideColors.border,
              color: modeColor,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            _simulationCompleted
                ? 'Destination reached in the prototype simulation.'
                : '$_remainingCurrentLegMinutes simulated min remaining',
            style:
                const TextStyle(
              fontSize: 11.5,
              color:
                  LinkRideColors
                      .textSecondary,
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

    final Color modeColor =
        completed
            ? LinkRideColors.linkGreen
            : _modeColor(mode);

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color:
            LinkRideColors.surface,
        borderRadius:
            BorderRadius.circular(
          LinkRideRadius.large,
        ),
        border: Border.all(
          color: current
              ? modeColor.withValues(
                  alpha: 0.30,
                )
              : LinkRideColors.border,
        ),
        boxShadow:
            current
                ? LinkRideShadows.soft
                : const [],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration:
                    BoxDecoration(
                  color:
                      modeColor.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    13,
                  ),
                ),
                child: Icon(
                  completed
                      ? Icons.check_rounded
                      : _modeIcon(mode),
                  color: modeColor,
                  size: 20,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Leg $legOrder · ${_formatMode(mode)}',
                      style:
                          const TextStyle(
                        fontSize: 13.5,
                        fontWeight:
                            FontWeight.w800,
                        color:
                            LinkRideColors
                                .textPrimary,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      cost <= 0
                          ? '$duration min'
                          : '$duration min · R${cost.toStringAsFixed(2)}',
                      style:
                          const TextStyle(
                        fontSize: 11.5,
                        color:
                            LinkRideColors
                                .textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              _smallStateChip(state),
            ],
          ),

          const SizedBox(height: 14),

          _simpleRoute(
            origin: origin,
            destination:
                destination,
          ),
        ],
      ),
    );
  }

  Widget _simulationControls() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration:
          LinkRideDecorations.card(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons
                    .science_outlined,
                size: 20,
                color:
                    LinkRideColors
                        .primaryBlue,
              ),
              SizedBox(width: 8),
              Text(
                'Prototype Simulation Controls',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      LinkRideColors
                          .textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          const Text(
            'Automatic progression continues in the background. Use this control to move immediately to the next leg during a demonstration.',
            style: TextStyle(
              fontSize: 11.5,
              height: 1.4,
              color:
                  LinkRideColors
                      .textSecondary,
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed:
                  _simulationCompleted ||
                          _isCompletingJourney
                      ? null
                      : () {
                          _advanceSimulation(
                            manual: true,
                          );
                        },
              icon: _isCompletingJourney
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color:
                            Colors.white,
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
                                _legs.isNotEmpty &&
                                _elapsedCurrentLegMinutes >=
                                    _currentLegDuration)
                            ? 'Complete Journey'
                            : 'Advance Simulation',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _prototypeNotice() {
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
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: const [
          Icon(
            Icons.science_outlined,
            size: 20,
            color:
                LinkRideColors.primaryBlue,
          ),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              'Prototype simulation: two real seconds represent one simulated journey minute. Leg progression uses persisted estimated durations rather than a real GPS feed. Advance Simulation is provided for demonstration.',
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

  Widget _journeyDisruptionWarning(
    List<Map<String, dynamic>> disruptions,
  ) {
    if (disruptions.isEmpty) {
      return const SizedBox.shrink();
    }

    final Map<String, dynamic> disruption =
        disruptions.first;

    final String title =
        disruption['title']
                ?.toString() ??
            'Transport disruption';

    final String description =
        disruption['description']
                ?.toString() ??
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
            ? LinkRideColors.danger
            : severity == 'HIGH'
                ? const Color(
                    0xFFD96A1D,
                  )
                : LinkRideColors.warning;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color:
            warningColor.withValues(
          alpha: 0.07,
        ),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              warningColor.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration:
                BoxDecoration(
              color:
                  warningColor.withValues(
                alpha: 0.11,
              ),
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
            ),
            child: Icon(
              Icons
                  .warning_amber_rounded,
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
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Text(
                        'Your journey is affected',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight:
                              FontWeight.w800,
                          color:
                              LinkRideColors
                                  .textPrimary,
                        ),
                      ),
                    ),

                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            warningColor
                                .withValues(
                          alpha: 0.11,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          LinkRideRadius
                              .pill,
                        ),
                      ),
                      child: Text(
                        severity,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight:
                              FontWeight.w800,
                          color:
                              warningColor,
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
                  style:
                      const TextStyle(
                    fontSize: 12.5,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        LinkRideColors
                            .textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  description,
                  style:
                      const TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    color:
                        LinkRideColors
                            .textSecondary,
                  ),
                ),

                if (disruptions.length >
                    1) ...[
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

  Widget _routePoint({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration:
              BoxDecoration(
            color:
                color.withValues(
              alpha: 0.09,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 17,
            color: color,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style:
                    const TextStyle(
                  fontSize: 9.5,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing: 0.7,
                  color:
                      LinkRideColors
                          .textMuted,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                style:
                    const TextStyle(
                  fontSize: 12.8,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      LinkRideColors
                          .textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _simpleRoute({
    required String origin,
    required String destination,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color:
            LinkRideColors.surfaceSoft,
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons
                    .trip_origin_rounded,
                size: 15,
                color:
                    LinkRideColors
                        .linkGreen,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  origin,
                  style:
                      const TextStyle(
                    fontSize: 12.5,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        LinkRideColors
                            .textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const Padding(
            padding:
                EdgeInsets.symmetric(
              vertical: 5,
            ),
            child: Icon(
              Icons
                  .arrow_downward_rounded,
              size: 15,
              color:
                  LinkRideColors
                      .textMuted,
            ),
          ),

          Row(
            children: [
              const Icon(
                Icons
                    .location_on_rounded,
                size: 16,
                color:
                    LinkRideColors
                        .primaryBlue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  destination,
                  style:
                      const TextStyle(
                    fontSize: 12.5,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        LinkRideColors
                            .textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color accent,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color:
            accent.withValues(
          alpha: 0.055,
        ),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 17,
            color: accent,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:
                      const TextStyle(
                    fontSize: 10.5,
                    color:
                        LinkRideColors
                            .textSecondary,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 12.5,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        LinkRideColors
                            .textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(
    String status,
  ) {
    final Color color =
        _statusColor(status);

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color:
            color.withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(
          LinkRideRadius.pill,
        ),
      ),
      child: Text(
        status
            .replaceAll(
              '_',
              ' ',
            )
            .toUpperCase(),
        style: TextStyle(
          fontSize: 9.5,
          fontWeight:
              FontWeight.w800,
          color: color,
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

    final bool current =
        state == 'CURRENT';

    final Color color =
        completed
            ? LinkRideColors.linkGreen
            : current
                ? LinkRideColors.primaryBlue
                : LinkRideColors.textSecondary;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color:
            color.withValues(
          alpha: 0.09,
        ),
        borderRadius:
            BorderRadius.circular(
          LinkRideRadius.pill,
        ),
      ),
      child: Text(
        state,
        style: TextStyle(
          fontSize: 9,
          fontWeight:
              FontWeight.w800,
          color: color,
        ),
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
                LinkRideColors.primaryBlue,
          ),
          SizedBox(height: 13),
          Text(
            'Loading active journey...',
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

  Widget _errorView() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.all(24),
          decoration:
              LinkRideDecorations.card(),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration:
                    const BoxDecoration(
                  color:
                      LinkRideColors
                          .dangerSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons
                      .error_outline_rounded,
                  size: 29,
                  color:
                      LinkRideColors
                          .danger,
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                'Unable to load active journey',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      LinkRideColors
                          .textPrimary,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                _errorMessage ??
                    'Unable to load active journey.',
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

              const SizedBox(height: 15),

              OutlinedButton.icon(
                onPressed: () {
                  _loadActiveJourney(
                    resetSimulation:
                        true,
                  );
                },
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 18,
                ),
                label: const Text(
                  'Try Again',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(
    String status,
  ) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return LinkRideColors.linkGreen;

      case 'IN_PROGRESS':
        return const Color(
          0xFF6C63B8,
        );

      default:
        return LinkRideColors.primaryBlue;
    }
  }

  Color _modeColor(
    String mode,
  ) {
    switch (mode.toUpperCase()) {
      case 'TRAIN':
        return LinkRideColors.primaryBlue;

      case 'BUS':
        return LinkRideColors.linkGreen;

      case 'TAXI':
        return LinkRideColors.warning;

      case 'WALK':
        return const Color(
          0xFF6C63B8,
        );

      default:
        return LinkRideColors.textSecondary;
    }
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

  String _formatMode(
    String mode,
  ) {
    switch (mode.toUpperCase()) {
      case 'TRAIN':
        return 'Train';

      case 'BUS':
        return 'Bus';

      case 'TAXI':
        return 'Taxi';

      case 'WALK':
        return 'Walk';

      default:
        return mode;
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
          value?.toString() ?? '',
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
          value?.toString() ?? '',
        ) ??
        0.0;
  }
}