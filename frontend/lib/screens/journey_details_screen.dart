import 'package:flutter/material.dart';

import '../services/auth_storage.dart';
import '../services/journey_selection_service.dart';

class JourneyDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> journeyOption;

  const JourneyDetailsScreen({
    super.key,
    required this.journeyOption,
  });

  @override
  State<JourneyDetailsScreen> createState() =>
      _JourneyDetailsScreenState();
}

class _JourneyDetailsScreenState
    extends State<JourneyDetailsScreen> {
  static const Color primaryBlue = Color(0xFF003F73);
  static const Color linkGreen = Color(0xFF4A9B45);
  static const Color background = Color(0xFFF7F9FB);
  static const Color textPrimary = Color(0xFF17212B);
  static const Color textSecondary = Color(0xFF667085);
  static const Color cardBorder = Color(0xFFE4E9EE);

  final AuthStorage _authStorage = AuthStorage();

  final JourneySelectionService _journeySelectionService =
      JourneySelectionService();

  bool _isSelectingJourney = false;

  Map<String, dynamic>? _savedJourney;

  Future<void> _selectJourney() async {
    if (_isSelectingJourney ||
        _savedJourney != null) {
      return;
    }

    setState(() {
      _isSelectingJourney = true;
    });

    try {
      final String? token =
          await _authStorage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Your Link Ride session is no longer valid.',
        );
      }

      final Map<String, dynamic> savedJourney =
          await _journeySelectionService.selectJourney(
        journeyOption: widget.journeyOption,
        token: token,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isSelectingJourney = false;
        _savedJourney = savedJourney;
      });

      final dynamic journeyId =
          savedJourney['journeyId'];

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                22,
              ),
            ),
            icon: const Icon(
              Icons.check_circle_rounded,
              color: linkGreen,
              size: 48,
            ),
            title: const Text(
              'Journey selected',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryBlue,
                fontWeight: FontWeight.w800,
              ),
            ),
            content: Text(
              journeyId == null
                  ? 'Your journey has been saved successfully.'
                  : 'Your journey has been saved successfully '
                      'as Journey #$journeyId.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textSecondary,
                height: 1.4,
              ),
            ),
            actionsAlignment:
                MainAxisAlignment.center,
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Done',
                ),
              ),
            ],
          );
        },
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSelectingJourney = false;
      });

      debugPrint(
        'Journey selection error: $error',
      );

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
            message,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> journeyOption =
        widget.journeyOption;

    final List<String> tags =
        ((journeyOption['tags'] as List?) ?? [])
            .map(
              (dynamic tag) =>
                  tag.toString(),
            )
            .toList();

    final int totalDuration =
        _asInt(
      journeyOption['totalDurationMinutes'],
    );

    final double totalCost =
        _asDouble(
      journeyOption['totalCost'],
    );

    final int transferCount =
        _asInt(
      journeyOption['transferCount'],
    );

    final List<Map<String, dynamic>> legs =
        ((journeyOption['legs'] as List?) ?? [])
            .map<Map<String, dynamic>>(
              (dynamic leg) =>
                  Map<String, dynamic>.from(
                leg as Map,
              ),
            )
            .toList();

    final String journeyStart =
        legs.isNotEmpty
            ? legs.first['startLocationName']
                    ?.toString() ??
                'Journey start'
            : 'Journey start';

    final String journeyEnd =
        legs.isNotEmpty
            ? legs.last['endLocationName']
                    ?.toString() ??
                'Journey destination'
            : 'Journey destination';

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: primaryBlue,
          ),
        ),
        title: const Text(
          'Journey Details',
          style: TextStyle(
            color: primaryBlue,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          30,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ───────────────── SUMMARY ─────────────────

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(22),
                border: Border.all(
                  color: cardBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withValues(
                      alpha: 0.025,
                    ),
                    blurRadius: 16,
                    offset:
                        const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your journey',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(
                        Icons
                            .trip_origin_rounded,
                        size: 18,
                        color: linkGreen,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          journeyStart,
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
                      ),
                    ],
                  ),

                  Padding(
                    padding:
                        const EdgeInsets.only(
                      left: 8,
                    ),
                    child: Container(
                      width: 2,
                      height: 22,
                      color: cardBorder,
                    ),
                  ),

                  Row(
                    children: [
                      const Icon(
                        Icons
                            .location_on_rounded,
                        size: 18,
                        color: primaryBlue,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          journeyEnd,
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
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  const Divider(
                    height: 1,
                    color: cardBorder,
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _summaryMetric(
                          icon: Icons
                              .schedule_rounded,
                          value:
                              '$totalDuration min',
                          label:
                              'Duration',
                        ),
                      ),
                      Expanded(
                        child: _summaryMetric(
                          icon: Icons
                              .payments_outlined,
                          value:
                              'R${totalCost.toStringAsFixed(2)}',
                          label:
                              'Estimated cost',
                        ),
                      ),
                      Expanded(
                        child: _summaryMetric(
                          icon: Icons
                              .swap_horiz_rounded,
                          value:
                              '$transferCount',
                          label:
                              transferCount ==
                                      1
                                  ? 'Transfer'
                                  : 'Transfers',
                        ),
                      ),
                    ],
                  ),

                  if (tags.isNotEmpty) ...[
                    const SizedBox(
                      height: 18,
                    ),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: tags.map(
                        (String tag) {
                          return Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration:
                                BoxDecoration(
                              color: linkGreen
                                  .withValues(
                                alpha: 0.10,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                20,
                              ),
                            ),
                            child: Text(
                              _formatTag(
                                tag,
                              ),
                              style:
                                  const TextStyle(
                                fontSize: 10.5,
                                fontWeight:
                                    FontWeight
                                        .w800,
                                color:
                                    linkGreen,
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Route breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w800,
                color: textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            // ───────────────── LEGS ─────────────────

            Container(
              padding:
                  const EdgeInsets.fromLTRB(
                16,
                18,
                16,
                8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(22),
                border: Border.all(
                  color: cardBorder,
                ),
              ),
              child: Column(
                children: List.generate(
                  legs.length,
                  (int index) {
                    return _journeyLeg(
                      legs[index],
                      isLast:
                          index ==
                              legs.length - 1,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ───────────────── PROTOTYPE NOTE ─────────────────

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryBlue.withValues(
                  alpha: 0.05,
                ),
                borderRadius:
                    BorderRadius.circular(18),
              ),
              child: const Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons
                        .info_outline_rounded,
                    size: 20,
                    color: primaryBlue,
                  ),
                  SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      'Journey times and fares are prototype estimates '
                      'based on the transport routes currently available '
                      'within the Link Ride controlled network.',
                      style: TextStyle(
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

            const SizedBox(height: 22),

            // ───────────────── CHOOSE JOURNEY ─────────────────

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed:
                    _isSelectingJourney ||
                            _savedJourney !=
                                null
                        ? null
                        : _selectJourney,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      primaryBlue,
                  foregroundColor:
                      Colors.white,
                  disabledBackgroundColor:
                      _savedJourney != null
                          ? linkGreen
                          : primaryBlue
                              .withValues(
                              alpha: 0.65,
                            ),
                  disabledForegroundColor:
                      Colors.white,
                  elevation: 0,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(16),
                  ),
                ),
                child: _isSelectingJourney
                    ? const Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color:
                                  Colors.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Saving journey...',
                            style:
                                TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),
                        ],
                      )
                    : _savedJourney != null
                        ? const Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            children: [
                              Icon(
                                Icons
                                    .check_circle_rounded,
                                size: 20,
                              ),
                              SizedBox(
                                width: 9,
                              ),
                              Text(
                                'Journey Selected',
                                style:
                                    TextStyle(
                                  fontSize:
                                      15,
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                ),
                              ),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            children: [
                              Icon(
                                Icons
                                    .check_circle_outline_rounded,
                                size: 20,
                              ),
                              SizedBox(
                                width: 9,
                              ),
                              Text(
                                'Choose This Journey',
                                style:
                                    TextStyle(
                                  fontSize:
                                      15,
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Icon(
                                Icons
                                    .arrow_forward_rounded,
                                size: 18,
                              ),
                            ],
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryMetric({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: primaryBlue,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10.5,
            color: textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _journeyLeg(
    Map<String, dynamic> leg, {
    required bool isLast,
  }) {
    final String mode =
        leg['transportMode']
                ?.toString() ??
            'UNKNOWN';

    final String start =
        leg['startLocationName']
                ?.toString() ??
            'Unknown start';

    final String end =
        leg['endLocationName']
                ?.toString() ??
            'Unknown destination';

    final int duration =
        _asInt(
      leg['durationMinutes'],
    );

    final double cost =
        _asDouble(
      leg['cost'],
    );

    final dynamic rawRouteId =
        leg['routeId'];

    final String? routeLabel =
        rawRouteId == null
            ? null
            : 'Route $rawRouteId';

    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 10 : 18,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      primaryBlue.withValues(
                    alpha: 0.09,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _iconForMode(mode),
                  size: 20,
                  color: primaryBlue,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 52,
                  color: cardBorder,
                ),
            ],
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _formatMode(mode),
                      style:
                          const TextStyle(
                        fontSize: 13,
                        fontWeight:
                            FontWeight
                                .w800,
                        color:
                            primaryBlue,
                      ),
                    ),
                    if (routeLabel !=
                        null) ...[
                      const SizedBox(
                        width: 7,
                      ),
                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration:
                            BoxDecoration(
                          color: background,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),
                        ),
                        child: Text(
                          routeLabel,
                          style:
                              const TextStyle(
                            fontSize: 9.5,
                            fontWeight:
                                FontWeight
                                    .w700,
                            color:
                                textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  start,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons
                          .south_rounded,
                      size: 15,
                      color:
                          textSecondary,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Expanded(
                      child: Text(
                        end,
                        style:
                            const TextStyle(
                          fontSize: 13,
                          fontWeight:
                              FontWeight
                                  .w600,
                          color:
                              textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  cost <= 0
                      ? '$duration min'
                      : '$duration min • '
                          'R${cost.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color:
                        textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForMode(
    String mode,
  ) {
    switch (mode.toUpperCase()) {
      case 'TRAIN':
        return Icons.train_rounded;

      case 'BUS':
        return Icons
            .directions_bus_rounded;

      case 'TAXI':
        return Icons.local_taxi_rounded;

      case 'WALK':
        return Icons
            .directions_walk_rounded;

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

  String _formatTag(
    String tag,
  ) {
    switch (tag.toUpperCase()) {
      case 'FASTEST':
        return 'FASTEST';

      case 'CHEAPEST':
        return 'CHEAPEST';

      case 'BALANCED':
        return 'BALANCED';

      case 'FEWEST_TRANSFERS':
        return 'FEWEST TRANSFERS';

      default:
        return tag.replaceAll(
          '_',
          ' ',
        );
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