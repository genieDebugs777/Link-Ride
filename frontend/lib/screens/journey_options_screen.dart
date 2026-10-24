import 'package:flutter/material.dart';

import '../theme/link_ride_theme.dart';
import 'journey_details_screen.dart';

class JourneyOptionsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> journeyOptions;

  const JourneyOptionsScreen({
    super.key,
    required this.journeyOptions,
  });

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
          'Journey Options',
        ),
      ),
      body: journeyOptions.isEmpty
          ? _emptyState()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                20,
                14,
                20,
                30,
              ),
              itemCount: journeyOptions.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final Map<String, dynamic> option =
                    journeyOptions[index];

                return _journeyOptionCard(
                  context,
                  option,
                  index,
                );
              },
            ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(26),
          decoration: LinkRideDecorations.card(),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 68,
                height: 68,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: LinkRideColors.softBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.route_outlined,
                    size: 32,
                    color: LinkRideColors.primaryBlue,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'No journey options found',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: LinkRideColors.textPrimary,
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Link Ride could not find a sensible journey within the current prototype transport network.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: LinkRideColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _journeyOptionCard(
    BuildContext context,
    Map<String, dynamic> option,
    int index,
  ) {
    final List<String> tags =
        ((option['tags'] as List?) ?? [])
            .map(
              (dynamic tag) => tag.toString(),
            )
            .toList();

    final int duration =
        _asInt(
      option['totalDurationMinutes'],
    );

    final double cost =
        _asDouble(
      option['totalCost'],
    );

    final int transfers =
        _asInt(
      option['transferCount'],
    );

    final List<Map<String, dynamic>> legs =
        ((option['legs'] as List?) ?? [])
            .map<Map<String, dynamic>>(
              (dynamic leg) =>
                  Map<String, dynamic>.from(
                leg as Map,
              ),
            )
            .toList();

    final String? primaryTag =
        tags.isNotEmpty ? tags.first : null;

    final Color accent =
        _accentForTag(
      primaryTag,
      index,
    );

    return Container(
      decoration: BoxDecoration(
        color: LinkRideColors.surface,
        borderRadius: BorderRadius.circular(
          LinkRideRadius.extraLarge,
        ),
        border: Border.all(
          color: LinkRideColors.border,
        ),
        boxShadow: LinkRideShadows.soft,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              18,
              17,
              18,
              16,
            ),
            decoration: BoxDecoration(
              color: accent.withValues(
                alpha: 0.055,
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
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: accent.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          13,
                        ),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: accent,
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Journey option',
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight:
                                  FontWeight.w800,
                              color:
                                  LinkRideColors
                                      .textPrimary,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Compare this route with the alternatives below.',
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

                    if (primaryTag != null)
                      _tagBadge(
                        primaryTag,
                        accent,
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _metricTile(
                        icon:
                            Icons.schedule_rounded,
                        value:
                            '$duration min',
                        label: 'Duration',
                        accent: accent,
                      ),
                    ),

                    const SizedBox(width: 9),

                    Expanded(
                      child: _metricTile(
                        icon:
                            Icons.payments_outlined,
                        value:
                            'R${cost.toStringAsFixed(2)}',
                        label: 'Cost',
                        accent: accent,
                      ),
                    ),

                    const SizedBox(width: 9),

                    Expanded(
                      child: _metricTile(
                        icon:
                            Icons.swap_horiz_rounded,
                        value: '$transfers',
                        label: transfers == 1
                            ? 'Transfer'
                            : 'Transfers',
                        accent: accent,
                      ),
                    ),
                  ],
                ),

                if (tags.length > 1) ...[
                  const SizedBox(height: 13),

                  Wrap(
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
                              index,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              18,
              17,
              18,
              18,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Route overview',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        LinkRideColors
                            .textPrimary,
                  ),
                ),

                const SizedBox(height: 13),

                if (legs.isEmpty)
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(
                      14,
                    ),
                    decoration: BoxDecoration(
                      color:
                          LinkRideColors
                              .surfaceSoft,
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                    child: const Text(
                      'No route-leg information is available for this option.',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            LinkRideColors
                                .textSecondary,
                      ),
                    ),
                  )
                else
                  ...List.generate(
                    legs.length,
                    (int legIndex) {
                      final Map<String, dynamic>
                          leg =
                          legs[legIndex];

                      return _journeyLeg(
                        leg,
                        isLast:
                            legIndex ==
                                legs.length - 1,
                      );
                    },
                  ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              JourneyDetailsScreen(
                            journeyOption:
                                option,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons
                          .arrow_forward_rounded,
                      size: 18,
                    ),
                    label: const Text(
                      'View Journey Details',
                    ),
                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor:
                          LinkRideColors
                              .primaryBlue,
                      side: const BorderSide(
                        color:
                            LinkRideColors
                                .primaryBlue,
                      ),
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

  Widget _metricTile({
    required IconData icon,
    required String value,
    required String label,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: LinkRideColors.surface,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: LinkRideColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 17,
            color: accent,
          ),

          const SizedBox(height: 7),

          Text(
            value,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
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
            style: const TextStyle(
              fontSize: 10.5,
              color:
                  LinkRideColors
                      .textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tagBadge(
    String tag,
    Color accent,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(
          alpha: 0.10,
        ),
        borderRadius: BorderRadius.circular(
          LinkRideRadius.pill,
        ),
        border: Border.all(
          color: accent.withValues(
            alpha: 0.14,
          ),
        ),
      ),
      child: Text(
        _formatTag(tag),
        style: TextStyle(
          fontSize: 9.8,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.25,
          color: accent,
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

    final Color modeColor =
        _modeColor(mode);

    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 0 : 14,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: modeColor.withValues(
                    alpha: 0.10,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _iconForMode(mode),
                  size: 19,
                  color: modeColor,
                ),
              ),

              if (!isLast)
                Container(
                  width: 2,
                  height: 31,
                  margin:
                      const EdgeInsets.symmetric(
                    vertical: 2,
                  ),
                  color:
                      LinkRideColors.borderStrong,
                ),
            ],
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Container(
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
                            const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration:
                            BoxDecoration(
                          color: modeColor
                              .withValues(
                            alpha: 0.09,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            LinkRideRadius.pill,
                          ),
                        ),
                        child: Text(
                          _formatMode(mode),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight:
                                FontWeight.w800,
                            color:
                                modeColor,
                          ),
                        ),
                      ),

                      const Spacer(),

                      Text(
                        cost <= 0
                            ? '$duration min'
                            : '$duration min • R${cost.toStringAsFixed(2)}',
                        style:
                            const TextStyle(
                          fontSize: 10.8,
                          fontWeight:
                              FontWeight.w600,
                          color:
                              LinkRideColors
                                  .textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    start,
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

                  const SizedBox(height: 2),

                  Row(
                    children: [
                      const Icon(
                        Icons
                            .south_rounded,
                        size: 13,
                        color:
                            LinkRideColors
                                .textMuted,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          end,
                          style:
                              const TextStyle(
                            fontSize: 12,
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

  Color _accentForTag(
    String? tag,
    int index,
  ) {
    switch (tag?.toUpperCase()) {
      case 'FASTEST':
        return LinkRideColors.primaryBlue;

      case 'CHEAPEST':
        return LinkRideColors.linkGreen;

      case 'BALANCED':
        return const Color(
          0xFF6C63B8,
        );

      case 'FEWEST_TRANSFERS':
        return const Color(
          0xFFAA6F20,
        );

      default:
        return index.isEven
            ? LinkRideColors.primaryBlue
            : LinkRideColors.linkGreen;
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
        return const Color(
          0xFFE28A19,
        );

      case 'WALK':
        return const Color(
          0xFF6C63B8,
        );

      default:
        return LinkRideColors.textSecondary;
    }
  }

  IconData _iconForMode(
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