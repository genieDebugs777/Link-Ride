import 'package:flutter/material.dart';

import '../services/auth_storage.dart';
import '../services/my_journeys_service.dart';

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

  final MyJourneysService
      _myJourneysService =
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

        title: Text(
          widget.completedOnly
              ? 'Journey History'
              : 'My Journeys',
          style: const TextStyle(
            color: primaryBlue,
            fontSize: 20,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _loadJourneys,

        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),

        children: const [
          SizedBox(
            height: 260,
          ),

          Center(
            child:
                CircularProgressIndicator(
              color: primaryBlue,
            ),
          ),
        ],
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),

        padding:
            const EdgeInsets.all(24),

        children: [
          const SizedBox(
            height: 120,
          ),

          const Icon(
            Icons
                .error_outline_rounded,
            size: 52,
            color: primaryBlue,
          ),

          const SizedBox(
            height: 16,
          ),

          const Text(
            'Unable to load journeys',
            textAlign:
                TextAlign.center,

            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w800,
              color: textPrimary,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            _errorMessage!,
            textAlign:
                TextAlign.center,

            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color:
                  textSecondary,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          Center(
            child:
                ElevatedButton.icon(
              onPressed:
                  _loadJourneys,

              icon: const Icon(
                Icons
                    .refresh_rounded,
              ),

              label:
                  const Text(
                'Try Again',
              ),

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
            ),
          ),
        ],
      );
    }

    final List<Map<String, dynamic>> journeys =
        _visibleJourneys;

    if (journeys.isEmpty) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),

        padding:
            const EdgeInsets.all(24),

        children: [
          const SizedBox(
            height: 130,
          ),

          const Icon(
            Icons.route_outlined,
            size: 56,
            color: primaryBlue,
          ),

          const SizedBox(
            height: 16,
          ),

          Text(
            widget.completedOnly
                ? 'No completed journeys yet'
                : 'No journeys yet',
            textAlign:
                TextAlign.center,

            style: const TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w800,
              color: textPrimary,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            widget.completedOnly
                ? 'Completed journeys will appear here once you finish a trip.'
                : 'Journeys you choose will appear here.',
            textAlign:
                TextAlign.center,

            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color:
                  textSecondary,
            ),
          ),
        ],
      );
    }

    return ListView(
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
          '${journeys.length} '
          '${journeys.length == 1 ? 'journey' : 'journeys'}',

          style: const TextStyle(
            fontSize: 13,
            fontWeight:
                FontWeight.w700,
            color:
                textSecondary,
          ),
        ),

        const SizedBox(
          height: 12,
        ),

        ...journeys.map(
          (
            Map<String, dynamic>
                journey,
          ) {
            return Padding(
              padding:
                  const EdgeInsets
                      .only(
                bottom: 12,
              ),

              child:
                  _journeyCard(
                journey,
              ),
            );
          },
        ),
      ],
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
      journey[
          'estimatedDuration'],
    );

    final double cost =
        _asDouble(
      journey[
          'estimatedCost'],
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

        boxShadow: [
          BoxShadow(
            color:
                Colors.black
                    .withValues(
              alpha: 0.02,
            ),

            blurRadius: 12,

            offset:
                const Offset(
              0,
              4,
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
                width: 40,
                height: 40,

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
                    12,
                  ),
                ),

                child:
                    const Icon(
                  Icons
                      .route_rounded,

                  color:
                      primaryBlue,

                  size: 21,
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
                      'Journey #$journeyId',

                      style:
                          const TextStyle(
                        fontSize: 14,
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
                      dateText,

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

                size: 16,
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

            child: Container(
              width: 2,
              height: 18,

              color:
                  cardBorder,
            ),
          ),

          Row(
            children: [
              const Icon(
                Icons
                    .location_on_rounded,

                size: 16,
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
                child:
                    _metric(
                  icon:
                      Icons
                          .schedule_rounded,

                  value:
                      '$duration min',
                ),
              ),

              Expanded(
                child:
                    _metric(
                  icon:
                      Icons
                          .payments_outlined,

                  value:
                      'R${cost.toStringAsFixed(2)}',
                ),
              ),
            ],
          ),
        ],
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
    final bool selected =
        status.toUpperCase() ==
            'SELECTED';

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
            (selected
                    ? linkGreen
                    : primaryBlue)
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
        _formatStatus(
          status,
        ),

        style:
            TextStyle(
          fontSize: 10,
          fontWeight:
              FontWeight.w800,

          color:
              selected
                  ? linkGreen
                  : primaryBlue,
        ),
      ),
    );
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
    if (value
        is double) {
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