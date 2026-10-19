import 'package:flutter/material.dart';

import '../services/auth_storage.dart';
import '../services/ticket_service.dart';
import '../services/disruption_service.dart';
import 'active_journey_screen.dart';

class TicketScreen extends StatefulWidget {
  final Map<String, dynamic> journey;
  final Map<String, dynamic>? ticket;

  const TicketScreen({
    super.key,
    required this.journey,
    this.ticket,
  });

  @override
  State<TicketScreen> createState() =>
      _TicketScreenState();
}

class _TicketScreenState
    extends State<TicketScreen> {
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

  final TicketService _ticketService =
      TicketService();

  final DisruptionService _disruptionService =
      DisruptionService();

  bool _isLoading = true;
  bool _isActivating = false;

  String? _errorMessage;

  Map<String, dynamic>? _ticket;

  List<Map<String, dynamic>>
      _journeyDisruptions = [];

  @override
  void initState() {
    super.initState();

    if (widget.ticket != null) {
      _ticket = Map<String, dynamic>.from(
        widget.ticket!,
      );
      _isLoading = false;
    } else {
      _loadTicket();
    }

    _loadJourneyDisruptions();
  }

  Future<void> _loadJourneyDisruptions() async {
    try {
      final String? token =
          await _authStorage.getToken();

      if (token == null ||
          token.isEmpty) {
        return;
      }

      final int journeyId =
          _asInt(
        widget.journey['journeyId'],
      );

      if (journeyId <= 0) {
        return;
      }

      final List<Map<String, dynamic>>
          disruptions =
          await _disruptionService
              .getActiveDisruptionsForJourney(
        token: token,
        journeyId: journeyId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _journeyDisruptions =
            disruptions;
      });
    } catch (error) {
      debugPrint(
        'Ticket disruption check error: $error',
      );
    }
  }

  Future<void> _loadTicket() async {
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

      final int journeyId =
          _asInt(
        widget.journey['journeyId'],
      );

      final Map<String, dynamic> ticket =
          await _ticketService.issueTicket(
        token: token,
        journeyId: journeyId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _ticket = ticket;
        _isLoading = false;
      });
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

  Future<void> _startJourney() async {
    if (_ticket == null ||
        _isActivating) {
      return;
    }

    final String currentStatus =
        _ticket!['ticketStatus']
                ?.toString()
                .toUpperCase() ??
            '';

    if (currentStatus == 'ACTIVE') {
      return;
    }

    setState(() {
      _isActivating = true;
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
        widget.journey['journeyId'],
      );

      final Map<String, dynamic>
          activatedTicket =
          await _ticketService.activateTicket(
        token: token,
        journeyId: journeyId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _ticket = activatedTicket;
        _isActivating = false;
      });

      await _loadJourneyDisruptions();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Journey started successfully.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isActivating = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            error
                .toString()
                .replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
        ),
      );
    }
  }

  Future<void> _openActiveJourney() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const ActiveJourneyScreen(),
      ),
    );

    if (mounted) {
      Navigator.pop(
        context,
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final String origin =
        widget.journey['origin']
                ?.toString() ??
            'Unknown origin';

    final String destination =
        widget.journey['destination']
                ?.toString() ??
            'Unknown destination';

    final int duration =
        _asInt(
      widget.journey[
          'estimatedDuration'],
    );

    final double cost =
        _asDouble(
      widget.journey[
          'estimatedCost'],
    );

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
          'Digital Ticket',

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
                    : _ticketView(
                        origin:
                            origin,
                        destination:
                            destination,
                        duration:
                            duration,
                        cost:
                            cost,
                      ),
      ),
    );
  }

  Widget _ticketView({
    required String origin,
    required String destination,
    required int duration,
    required double cost,
  }) {
    final Map<String, dynamic>
        ticket =
        _ticket!;

    final int ticketId =
        _asInt(
      ticket['ticketId'],
    );

    final String ticketCode =
        ticket['ticketCode']
                ?.toString() ??
            'Unavailable';

    final String status =
        ticket['ticketStatus']
                ?.toString() ??
            'UNKNOWN';

    final String normalizedStatus =
        status.toUpperCase();

    final bool isActive =
        normalizedStatus == 'ACTIVE';

    final bool isUsed =
        normalizedStatus == 'USED';

    final String issuedAt =
        _formatDateTime(
      ticket['issuedAt']
          ?.toString(),
    );

    final String activatedAt =
        _formatDateTime(
      ticket['activatedAt']
          ?.toString(),
    );

    return SingleChildScrollView(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        30,
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            'Your Ticket',

            style: TextStyle(
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
            isUsed
                ? 'This ticket was used for a completed Link Ride journey.'
                : isActive
                    ? 'Your Link Ride journey is now in progress.'
                    : 'Present this digital ticket as your journey credential.',

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
              20,
            ),

            decoration:
                BoxDecoration(
              color:
                  Colors.white,

              borderRadius:
                  BorderRadius
                      .circular(
                24,
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
                      width: 46,
                      height: 46,

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
                          14,
                        ),
                      ),

                      child:
                          const Icon(
                        Icons
                            .confirmation_number_rounded,
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
                            'Ticket #$ticketId',

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
                            height: 3,
                          ),

                          Text(
                            isActive
                                ? 'Activated $activatedAt'
                                : isUsed
                                    ? 'Used ticket • Issued $issuedAt'
                                    : issuedAt,

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
                  height: 20,
                ),

                Container(
                  width:
                      double.infinity,

                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 18,
                    horizontal: 14,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        background,

                    borderRadius:
                        BorderRadius
                            .circular(
                      16,
                    ),
                  ),

                  child: Column(
                    children: [
                      const Text(
                        'TICKET CODE',

                        style:
                            TextStyle(
                          fontSize: 10,
                          fontWeight:
                              FontWeight
                                  .w800,
                          letterSpacing:
                              1.3,
                          color:
                              textSecondary,
                        ),
                      ),

                      const SizedBox(
                        height: 7,
                      ),

                      SelectableText(
                        ticketCode,

                        style:
                            const TextStyle(
                          fontSize: 19,
                          fontWeight:
                              FontWeight
                                  .w900,
                          letterSpacing:
                              1.2,
                          color:
                              primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 20,
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
                  height: 18,
                ),

                const Divider(
                  height: 1,
                  color:
                      cardBorder,
                ),

                const SizedBox(
                  height: 15,
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
              ],
            ),
          ),

          const SizedBox(
            height: 20,
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

            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                const Icon(
                  Icons
                      .info_outline_rounded,
                  size: 20,
                  color:
                      primaryBlue,
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: Text(
                    isUsed
                        ? 'This ticket has already been used and is kept here as part of your Link Ride ticket history.'
                        : isActive
                            ? 'This ticket is active and linked to the journey currently in progress.'
                            : 'This ticket is ready to use. Starting the journey will activate it and move the journey into progress.',

                    style:
                        const TextStyle(
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

          const SizedBox(
            height: 22,
          ),

          SizedBox(
            width:
                double.infinity,

            height: 50,

            child:
                ElevatedButton.icon(
              onPressed:
                  isUsed ||
                          _isActivating
                      ? null
                      : isActive
                          ? _openActiveJourney
                          : _startJourney,

              icon:
                  _isActivating
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
                          isUsed
                              ? Icons
                                  .check_circle_outline_rounded
                              : isActive
                                  ? Icons
                                      .directions_transit_filled_rounded
                                  : Icons
                                      .play_arrow_rounded,
                        ),

              label: Text(
                _isActivating
                    ? 'Starting Journey...'
                    : isUsed
                        ? 'Ticket Used'
                        : isActive
                            ? 'Continue Journey'
                            : 'Start Journey',

                style:
                    const TextStyle(
                  fontSize: 15,
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
                  alpha: 0.65,
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
                  'Unable to load ticket.',

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
              onPressed:
                  _loadTicket,

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

  String _formatDateTime(
    String? rawDate,
  ) {
    if (rawDate == null ||
        rawDate.isEmpty) {
      return 'Unavailable';
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