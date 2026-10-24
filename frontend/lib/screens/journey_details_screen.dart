import 'package:flutter/material.dart';

import '../services/auth_storage.dart';
import '../services/journey_selection_service.dart';
import '../theme/link_ride_theme.dart';

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
  final AuthStorage _authStorage =
      AuthStorage();

  final JourneySelectionService
      _journeySelectionService =
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

      if (token == null ||
          token.isEmpty) {
        throw Exception(
          'Your Link Ride session is no longer valid.',
        );
      }

      final Map<String, dynamic>
          savedJourney =
          await _journeySelectionService
              .selectJourney(
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
        builder:
            (BuildContext dialogContext) {
          return AlertDialog(
            icon: Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color:
                    LinkRideColors.softGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 32,
                color:
                    LinkRideColors.linkGreen,
              ),
            ),
            title: const Text(
              'Journey selected',
              textAlign: TextAlign.center,
            ),
            content: Text(
              journeyId == null
                  ? 'Your journey has been saved successfully.'
                  : 'Your journey has been saved successfully as Journey #$journeyId.',
              textAlign: TextAlign.center,
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
                child:
                    const Text('Done'),
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
          content: Text(message),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>
        journeyOption =
        widget.journeyOption;

    final List<String> tags =
        ((journeyOption['tags'] as List?) ??
                [])
            .map(
              (dynamic tag) =>
                  tag.toString(),
            )
            .toList();

    final int totalDuration =
        _asInt(
      journeyOption[
          'totalDurationMinutes'],
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
        ((journeyOption['legs'] as List?) ??
                [])
            .map<Map<String, dynamic>>(
              (dynamic leg) =>
                  Map<String, dynamic>.from(
                leg as Map,
              ),
            )
            .toList();

    final String journeyStart =
        legs.isNotEmpty
            ? legs.first[
                        'startLocationName']
                    ?.toString() ??
                'Journey start'
            : 'Journey start';

    final String journeyEnd =
        legs.isNotEmpty
            ? legs.last[
                        'endLocationName']
                    ?.toString() ??
                'Journey destination'
            : 'Journey destination';

    final String? primaryTag =
        tags.isNotEmpty
            ? tags.first
            : null;

    final Color accent =
        _accentForTag(primaryTag);

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
          'Journey Details',
        ),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.fromLTRB(
          20,
          14,
          20,
          30,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _summaryCard(
              journeyStart:
                  journeyStart,
              journeyEnd:
                  journeyEnd,
              totalDuration:
                  totalDuration,
              totalCost:
                  totalCost,
              transferCount:
                  transferCount,
              tags: tags,
              accent: accent,
            ),

            const SizedBox(height: 26),

            const Text(
              'Route breakdown',
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
              'Follow each leg of your connected journey.',
              style: TextStyle(
                fontSize: 12.5,
                color:
                    LinkRideColors
                        .textSecondary,
              ),
            ),

            const SizedBox(height: 14),

            _routeBreakdown(
              legs,
            ),

            const SizedBox(height: 22),

            _prototypeInformation(),

            const SizedBox(height: 22),

            _selectionButton(),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard({
    required String journeyStart,
    required String journeyEnd,
    required int totalDuration,
    required double totalCost,
    required int transferCount,
    required List<String> tags,
    required Color accent,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color:
            LinkRideColors.surface,
        borderRadius:
            BorderRadius.circular(
          LinkRideRadius.extraLarge,
        ),
        border: Border.all(
          color:
              LinkRideColors.border,
        ),
        boxShadow:
            LinkRideShadows.elevated,
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.fromLTRB(
              18,
              18,
              18,
              17,
            ),
            decoration:
                BoxDecoration(
              color: accent.withValues(
                alpha: 0.06,
              ),
              borderRadius:
                  const BorderRadius.vertical(
                top: Radius.circular(
                  LinkRideRadius.extraLarge,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child:
                          const Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            'Your journey',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight
                                      .w800,
                              color:
                                  LinkRideColors
                                      .textPrimary,
                            ),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Text(
                            'Review the route before selecting it.',
                            style:
                                TextStyle(
                              fontSize: 11.5,
                              color:
                                  LinkRideColors
                                      .textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (tags.isNotEmpty)
                      _tagBadge(
                        tags.first,
                        accent,
                      ),
                  ],
                ),

                const SizedBox(height: 18),

                _routePoint(
                  icon: Icons
                      .trip_origin_rounded,
                  iconColor:
                      LinkRideColors
                          .linkGreen,
                  label: 'FROM',
                  value: journeyStart,
                ),

                Padding(
                  padding:
                      const EdgeInsets.only(
                    left: 18,
                  ),
                  child: Container(
                    width: 2,
                    height: 25,
                    color:
                        LinkRideColors
                            .borderStrong,
                  ),
                ),

                _routePoint(
                  icon: Icons
                      .location_on_rounded,
                  iconColor:
                      LinkRideColors
                          .primaryBlue,
                  label: 'TO',
                  value: journeyEnd,
                ),
              ],
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              18,
            ),
            child: Column(
              children: [
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
                        accent: accent,
                      ),
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    Expanded(
                      child: _summaryMetric(
                        icon: Icons
                            .payments_outlined,
                        value:
                            'R${totalCost.toStringAsFixed(2)}',
                        label: 'Est. cost',
                        accent: accent,
                      ),
                    ),

                    const SizedBox(
                      width: 8,
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
                        accent: accent,
                      ),
                    ),
                  ],
                ),

                if (tags.length > 1) ...[
                  const SizedBox(
                    height: 15,
                  ),

                  Align(
                    alignment:
                        Alignment.centerLeft,
                    child: Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: tags
                          .skip(1)
                          .map(
                            (String tag) =>
                                _tagBadge(
                              tag,
                              _accentForTag(
                                tag,
                              ),
                            ),
                          )
                          .toList(),
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
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration:
              BoxDecoration(
            color:
                iconColor.withValues(
              alpha: 0.09,
            ),
            shape:
                BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 19,
            color: iconColor,
          ),
        ),

        const SizedBox(width: 12),

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
                  letterSpacing: 0.8,
                  color:
                      LinkRideColors
                          .textMuted,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style:
                    const TextStyle(
                  fontSize: 13.5,
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

  Widget _summaryMetric({
    required IconData icon,
    required String value,
    required String label,
    required Color accent,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color:
            LinkRideColors.surfaceSoft,
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        border: Border.all(
          color:
              LinkRideColors.border,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 18,
            color: accent,
          ),

          const SizedBox(height: 6),

          Text(
            value,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.w800,
              color:
                  LinkRideColors
                      .textPrimary,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            label,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              fontSize: 10,
              color:
                  LinkRideColors
                      .textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _routeBreakdown(
    List<Map<String, dynamic>> legs,
  ) {
    if (legs.isEmpty) {
      return Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(20),
        decoration:
            LinkRideDecorations.card(),
        child: const Column(
          children: [
            Icon(
              Icons.route_outlined,
              size: 34,
              color:
                  LinkRideColors
                      .textMuted,
            ),
            SizedBox(height: 10),
            Text(
              'No route-leg information available',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    FontWeight.w700,
                color:
                    LinkRideColors
                        .textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        8,
      ),
      decoration:
          LinkRideDecorations.card(),
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

    final Color modeColor =
        _modeColor(mode);

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
                width: 42,
                height: 42,
                decoration:
                    BoxDecoration(
                  color:
                      modeColor.withValues(
                    alpha: 0.10,
                  ),
                  shape:
                      BoxShape.circle,
                ),
                child: Icon(
                  _iconForMode(mode),
                  size: 20,
                  color: modeColor,
                ),
              ),

              if (!isLast)
                Container(
                  width: 2,
                  height: 64,
                  margin:
                      const EdgeInsets.symmetric(
                    vertical: 2,
                  ),
                  color:
                      LinkRideColors
                          .borderStrong,
                ),
            ],
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.only(
                top: 1,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
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
                              modeColor
                                  .withValues(
                            alpha: 0.09,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            LinkRideRadius
                                .pill,
                          ),
                        ),
                        child: Text(
                          _formatMode(
                            mode,
                          ),
                          style:
                              TextStyle(
                            fontSize: 10.5,
                            fontWeight:
                                FontWeight
                                    .w800,
                            color:
                                modeColor,
                          ),
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
                            vertical: 4,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                LinkRideColors
                                    .surfaceSoft,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              LinkRideRadius
                                  .pill,
                            ),
                            border:
                                Border.all(
                              color:
                                  LinkRideColors
                                      .border,
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
                                  LinkRideColors
                                      .textSecondary,
                            ),
                          ),
                        ),
                      ],

                      const Spacer(),

                      Text(
                        cost <= 0
                            ? '$duration min'
                            : '$duration min • R${cost.toStringAsFixed(2)}',
                        style:
                            const TextStyle(
                          fontSize: 10.8,
                          fontWeight:
                              FontWeight
                                  .w600,
                          color:
                              LinkRideColors
                                  .textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 9),

                  Text(
                    start,
                    style:
                        const TextStyle(
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w700,
                      color:
                          LinkRideColors
                              .textPrimary,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding:
                            EdgeInsets.only(
                          top: 1,
                        ),
                        child: Icon(
                          Icons
                              .south_rounded,
                          size: 14,
                          color:
                              LinkRideColors
                                  .textMuted,
                        ),
                      ),

                      const SizedBox(width: 5),

                      Expanded(
                        child: Text(
                          end,
                          style:
                              const TextStyle(
                            fontSize: 12.5,
                            color:
                                LinkRideColors
                                    .textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _prototypeInformation() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color:
            LinkRideColors.softBlue,
        borderRadius:
            BorderRadius.circular(
          LinkRideRadius.medium,
        ),
        border: Border.all(
          color:
              LinkRideColors
                  .primaryBlue
                  .withValues(
            alpha: 0.09,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration:
                BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons
                  .info_outline_rounded,
              size: 20,
              color:
                  LinkRideColors
                      .primaryBlue,
            ),
          ),

          SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Prototype estimates',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        LinkRideColors
                            .textPrimary,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Journey times and fares are prototype estimates based on transport routes currently available within the Link Ride controlled network.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.45,
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

  Widget _selectionButton() {
    final bool selected =
        _savedJourney != null;

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed:
            _isSelectingJourney ||
                    selected
                ? null
                : _selectJourney,
        style: FilledButton.styleFrom(
          backgroundColor:
              selected
                  ? LinkRideColors
                      .linkGreen
                  : LinkRideColors
                      .primaryBlue,
          disabledBackgroundColor:
              selected
                  ? LinkRideColors
                      .linkGreen
                  : LinkRideColors
                      .primaryBlue
                      .withValues(
                    alpha: 0.38,
                  ),
          disabledForegroundColor:
              Colors.white,
        ),
        child: AnimatedSwitcher(
          duration:
              const Duration(
            milliseconds: 180,
          ),
          child: _isSelectingJourney
              ? const Row(
                  key: ValueKey(
                    'saving',
                  ),
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
                    ),
                  ],
                )
              : selected
                  ? const Row(
                      key: ValueKey(
                        'selected',
                      ),
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        Icon(
                          Icons
                              .check_circle_rounded,
                          size: 19,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          'Journey Selected',
                        ),
                      ],
                    )
                  : const Row(
                      key: ValueKey(
                        'choose',
                      ),
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        Icon(
                          Icons
                              .check_circle_outline_rounded,
                          size: 19,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          'Choose This Journey',
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
    );
  }

  Widget _tagBadge(
    String tag,
    Color accent,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color:
            accent.withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(
          LinkRideRadius.pill,
        ),
        border: Border.all(
          color:
              accent.withValues(
            alpha: 0.14,
          ),
        ),
      ),
      child: Text(
        _formatTag(tag),
        style: TextStyle(
          fontSize: 9.8,
          fontWeight:
              FontWeight.w800,
          letterSpacing: 0.25,
          color: accent,
        ),
      ),
    );
  }

  Color _accentForTag(
    String? tag,
  ) {
    switch (tag?.toUpperCase()) {
      case 'FASTEST':
        return LinkRideColors
            .primaryBlue;

      case 'CHEAPEST':
        return LinkRideColors
            .linkGreen;

      case 'BALANCED':
        return const Color(
          0xFF6C63B8,
        );

      case 'FEWEST_TRANSFERS':
        return const Color(
          0xFFAA6F20,
        );

      default:
        return LinkRideColors
            .primaryBlue;
    }
  }

  Color _modeColor(
    String mode,
  ) {
    switch (mode.toUpperCase()) {
      case 'TRAIN':
        return LinkRideColors
            .primaryBlue;

      case 'BUS':
        return LinkRideColors
            .linkGreen;

      case 'TAXI':
        return const Color(
          0xFFE28A19,
        );

      case 'WALK':
        return const Color(
          0xFF6C63B8,
        );

      default:
        return LinkRideColors
            .textSecondary;
    }
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
        return Icons
            .local_taxi_rounded;

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