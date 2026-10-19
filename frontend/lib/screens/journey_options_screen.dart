import 'package:flutter/material.dart';
import 'journey_details_screen.dart';

class JourneyOptionsScreen extends StatelessWidget {
  static const Color primaryBlue = Color(0xFF003F73);
  static const Color linkGreen = Color(0xFF4A9B45);
  static const Color background = Color(0xFFF7F9FB);
  static const Color textPrimary = Color(0xFF17212B);
  static const Color textSecondary = Color(0xFF667085);
  static const Color cardBorder = Color(0xFFE4E9EE);

  final List<Map<String, dynamic>> journeyOptions;

  const JourneyOptionsScreen({
    super.key,
    required this.journeyOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
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
          'Journey Options',
          style: TextStyle(
            color: primaryBlue,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: journeyOptions.isEmpty
          ? _emptyState()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                28,
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
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.route_outlined,
              size: 54,
              color: textSecondary,
            ),
            SizedBox(height: 14),
            Text(
              'No journey options found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Link Ride could not find a sensible journey '
              'within the current prototype transport network.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: textSecondary,
              ),
            ),
          ],
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
            .map((dynamic tag) => tag.toString())
            .toList();

    final int duration =
        _asInt(option['totalDurationMinutes']);

    final double cost =
        _asDouble(option['totalCost']);

    final int transfers =
        _asInt(option['transferCount']);

    final List<Map<String, dynamic>> legs =
        ((option['legs'] as List?) ?? [])
            .map<Map<String, dynamic>>(
              (dynamic leg) =>
                  Map<String, dynamic>.from(
                leg as Map,
              ),
            )
            .toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: cardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.025,
            ),
            blurRadius: 16,
            offset: const Offset(
              0,
              6,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  color: primaryBlue.withValues(
                    alpha: 0.09,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    13,
                  ),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: primaryBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Journey option',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$duration min • '
                      'R${cost.toStringAsFixed(2)} • '
                      '$transfers '
                      '${transfers == 1 ? 'transfer' : 'transfers'}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (tags.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: tags.map(
                (String tag) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: linkGreen.withValues(
                        alpha: 0.10,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: Text(
                      _formatTag(tag),
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight:
                            FontWeight.w800,
                        color: linkGreen,
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ],

          const SizedBox(height: 16),

          const Divider(
            height: 1,
            color: cardBorder,
          ),

          const SizedBox(height: 15),

          ...List.generate(
            legs.length,
            (int legIndex) {
              final Map<String, dynamic> leg =
                  legs[legIndex];

              return _journeyLeg(
                leg,
                isLast:
                    legIndex == legs.length - 1,
              );
            },
          ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton(
              onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                JourneyDetailsScreen(
                                    journeyOption: option,
                            ),
                        ),
                    );
                },
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryBlue,
                side: const BorderSide(
                  color: primaryBlue,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
              ),
              child: const Text(
                'View Journey Details',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _journeyLeg(
    Map<String, dynamic> leg, {
    required bool isLast,
  }) {
    final String mode =
        leg['transportMode']?.toString() ??
            'UNKNOWN';

    final String start =
        leg['startLocationName']?.toString() ??
            'Unknown start';

    final String end =
        leg['endLocationName']?.toString() ??
            'Unknown destination';

    final int duration =
        _asInt(leg['durationMinutes']);

    final double cost =
        _asDouble(leg['cost']);

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
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: primaryBlue.withValues(
                    alpha: 0.09,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _iconForMode(mode),
                  size: 18,
                  color: primaryBlue,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 28,
                  color: cardBorder,
                ),
            ],
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _formatMode(mode),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w800,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$start → $end',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  cost <= 0
                      ? '$duration min'
                      : '$duration min • '
                          'R${cost.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: textSecondary,
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