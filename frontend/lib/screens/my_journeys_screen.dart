import 'package:flutter/material.dart';

import '../services/auth_storage.dart';
import '../services/my_journeys_service.dart';
import '../theme/link_ride_theme.dart';

class MyJourneysScreen extends StatefulWidget {
  final bool completedOnly;

  const MyJourneysScreen({
    super.key,
    this.completedOnly = false,
  });

  @override
  State<MyJourneysScreen> createState() =>
      _MyJourneysScreenState();
}

class _MyJourneysScreenState
    extends State<MyJourneysScreen> {
  final AuthStorage _authStorage =
      AuthStorage();

  final MyJourneysService _myJourneysService =
      MyJourneysService();

  bool _isLoading = true;

  String? _errorMessage;

  List<Map<String, dynamic>> _journeys = [];

  List<Map<String, dynamic>> get _visibleJourneys {
    if (!widget.completedOnly) {
      return _journeys;
    }

    return _journeys.where(
      (Map<String, dynamic> journey) {
        final String status =
            journey['journeyStatus']
                    ?.toString()
                    .toUpperCase() ??
                '';

        return status == 'COMPLETED';
      },
    ).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadJourneys();
  }

  Future<void> _loadJourneys() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String? token =
          await _authStorage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Your Link Ride session is no longer valid.',
        );
      }

      final List<Map<String, dynamic>> journeys =
          await _myJourneysService.getMyJourneys(
        token: token,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _journeys = journeys;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      debugPrint(
        'My Journeys error: $error',
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
        title: Text(
          widget.completedOnly
              ? 'Journey History'
              : 'My Journeys',
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadJourneys,
        color:
            LinkRideColors.primaryBlue,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 120),
          _loadingState(),
        ],
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 80),
          _errorState(),
        ],
      );
    }

    final List<Map<String, dynamic>> journeys =
        _visibleJourneys;

    if (journeys.isEmpty) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 90),
          _emptyState(),
        ],
      );
    }

    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        30,
      ),
      children: [
        _summaryHeader(
          journeys.length,
        ),

        const SizedBox(height: 14),

        ...journeys.map(
          (
            Map<String, dynamic> journey,
          ) {
            return Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 12,
              ),
              child: _journeyCard(
                journey,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _summaryHeader(
    int count,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient:
            LinkRideGradients.primarySoft,
        borderRadius:
            BorderRadius.circular(
          LinkRideRadius.large,
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
            width: 46,
            height: 46,
            decoration:
                const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.completedOnly
                  ? Icons
                      .history_rounded
                  : Icons
                      .route_rounded,
              size: 22,
              color:
                  LinkRideColors
                      .primaryBlue,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  widget.completedOnly
                      ? 'Completed journeys'
                      : 'Journey records',
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

                const SizedBox(height: 3),

                Text(
                  '$count ${count == 1 ? 'journey' : 'journeys'}',
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

  Widget _journeyCard(
    Map<String, dynamic> journey,
  ) {
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

    final int duration =
        _asInt(
      journey['estimatedDuration'],
    );

    final double cost =
        _asDouble(
      journey['estimatedCost'],
    );

    final String status =
        journey['journeyStatus']
                ?.toString() ??
            'UNKNOWN';

    final String dateText =
        _formatDate(
      journey['searchDateTime']
          ?.toString(),
    );

    final Color statusColor =
        _statusColor(status);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color:
            LinkRideColors.surface,
        borderRadius:
            BorderRadius.circular(
          LinkRideRadius.large,
        ),
        border: Border.all(
          color:
              LinkRideColors.border,
        ),
        boxShadow:
            LinkRideShadows.soft,
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              16,
              15,
              16,
              14,
            ),
            decoration:
                BoxDecoration(
              color:
                  statusColor.withValues(
                alpha: 0.05,
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
                    _statusIcon(status),
                    color: statusColor,
                    size: 21,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Journey #$journeyId',
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

                      const SizedBox(height: 3),

                      Text(
                        dateText,
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

                _statusChip(
                  status,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16,
            ),
            child: Column(
              children: [
                _routeSummary(
                  origin: origin,
                  destination:
                      destination,
                ),

                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: _metricTile(
                        icon: Icons
                            .schedule_rounded,
                        label: 'Duration',
                        value:
                            '$duration min',
                        accent:
                            LinkRideColors
                                .primaryBlue,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _metricTile(
                        icon: Icons
                            .payments_outlined,
                        label: 'Est. cost',
                        value:
                            'R${cost.toStringAsFixed(2)}',
                        accent:
                            LinkRideColors
                                .linkGreen,
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

  Widget _routeSummary({
    required String origin,
    required String destination,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            LinkRideColors.surfaceSoft,
        borderRadius:
            BorderRadius.circular(15),
        border: Border.all(
          color:
              LinkRideColors.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration:
                    const BoxDecoration(
                  color:
                      LinkRideColors
                          .softGreen,
                  shape:
                      BoxShape.circle,
                ),
                child: const Icon(
                  Icons
                      .trip_origin_rounded,
                  size: 16,
                  color:
                      LinkRideColors
                          .linkGreen,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  origin,
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
              ),
            ],
          ),

          Padding(
            padding:
                const EdgeInsets.only(
              left: 15,
            ),
            child: Align(
              alignment:
                  Alignment.centerLeft,
              child: Container(
                width: 2,
                height: 17,
                color:
                    LinkRideColors
                        .borderStrong,
              ),
            ),
          ),

          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration:
                    const BoxDecoration(
                  color:
                      LinkRideColors
                          .softBlue,
                  shape:
                      BoxShape.circle,
                ),
                child: const Icon(
                  Icons
                      .location_on_rounded,
                  size: 17,
                  color:
                      LinkRideColors
                          .primaryBlue,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  destination,
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricTile({
    required IconData icon,
    required String label,
    required String value,
    required Color accent,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(
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
        color: color.withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(
          LinkRideRadius.pill,
        ),
      ),
      child: Text(
        _formatStatus(status),
        style: TextStyle(
          fontSize: 9.5,
          fontWeight:
              FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Widget _loadingState() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(28),
      decoration:
          LinkRideDecorations.card(),
      child: const Column(
        children: [
          CircularProgressIndicator(
            strokeWidth: 2.3,
            color:
                LinkRideColors
                    .primaryBlue,
          ),

          SizedBox(height: 13),

          Text(
            'Loading journeys...',
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

  Widget _errorState() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(24),
      decoration:
          LinkRideDecorations.card(),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration:
                const BoxDecoration(
              color:
                  LinkRideColors.dangerSoft,
              shape:
                  BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 29,
              color:
                  LinkRideColors.danger,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'Unable to load journeys',
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
            _errorMessage!,
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
            onPressed: _loadJourneys,
            icon: const Icon(
              Icons.refresh_rounded,
              size: 18,
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

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(26),
      decoration:
          LinkRideDecorations.card(),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration:
                const BoxDecoration(
              color:
                  LinkRideColors.softBlue,
              shape:
                  BoxShape.circle,
            ),
            child: Icon(
              widget.completedOnly
                  ? Icons
                      .history_rounded
                  : Icons
                      .route_outlined,
              size: 31,
              color:
                  LinkRideColors
                      .primaryBlue,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            widget.completedOnly
                ? 'No completed journeys yet'
                : 'No journeys yet',
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
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
            widget.completedOnly
                ? 'Completed journeys will appear here once you finish a trip.'
                : 'Journeys you choose will appear here.',
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
        ],
      ),
    );
  }

  Color _statusColor(
    String status,
  ) {
    switch (status.toUpperCase()) {
      case 'SELECTED':
        return LinkRideColors.primaryBlue;

      case 'PAID':
      case 'READY':
        return LinkRideColors.linkGreen;

      case 'IN_PROGRESS':
        return const Color(
          0xFF6C63B8,
        );

      case 'COMPLETED':
        return const Color(
          0xFF3E7A49,
        );

      default:
        return LinkRideColors.textSecondary;
    }
  }

  IconData _statusIcon(
    String status,
  ) {
    switch (status.toUpperCase()) {
      case 'SELECTED':
        return Icons.route_rounded;

      case 'PAID':
        return Icons.payments_rounded;

      case 'READY':
        return Icons
            .confirmation_number_rounded;

      case 'IN_PROGRESS':
        return Icons.navigation_rounded;

      case 'COMPLETED':
        return Icons
            .check_circle_rounded;

      default:
        return Icons
            .info_outline_rounded;
    }
  }

  String _formatStatus(
    String status,
  ) {
    return status
        .replaceAll(
          '_',
          ' ',
        )
        .toUpperCase();
  }

  String _formatDate(
    String? rawDate,
  ) {
    if (rawDate == null ||
        rawDate.isEmpty) {
      return 'Date unavailable';
    }

    final DateTime? date =
        DateTime.tryParse(
      rawDate,
    );

    if (date == null) {
      return rawDate;
    }

    final String day =
        date.day
            .toString()
            .padLeft(
              2,
              '0',
            );

    final String month =
        date.month
            .toString()
            .padLeft(
              2,
              '0',
            );

    final String hour =
        date.hour
            .toString()
            .padLeft(
              2,
              '0',
            );

    final String minute =
        date.minute
            .toString()
            .padLeft(
              2,
              '0',
            );

    return '$day/$month/${date.year} • '
        '$hour:$minute';
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