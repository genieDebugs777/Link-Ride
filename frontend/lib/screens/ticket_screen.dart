import 'package:flutter/material.dart';

import '../services/auth_storage.dart';
import '../services/disruption_service.dart';
import '../services/ticket_service.dart';
import '../theme/link_ride_theme.dart';
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
      _ticket =
          Map<String, dynamic>.from(
        widget.ticket!,
      );

      _isLoading = false;
    } else {
      _loadTicket();
    }

    _loadJourneyDisruptions();
  }

  Future<void> _loadJourneyDisruptions()
      async {
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
          await _ticketService
              .activateTicket(
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

      ScaffoldMessenger.of(context)
          .showSnackBar(
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

      ScaffoldMessenger.of(context)
          .showSnackBar(
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
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Digital Ticket',
        ),
      ),
      body: SafeArea(
        top: false,
        child: _isLoading
            ? _loadingView()
            : _errorMessage != null
                ? _errorView()
                : _ticketView(
                    origin: origin,
                    destination:
                        destination,
                    duration: duration,
                    cost: cost,
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
    final Map<String, dynamic> ticket =
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

    final Color statusColor =
        _statusColor(status);

    return SingleChildScrollView(
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
          _ticketHeader(
            isActive: isActive,
            isUsed: isUsed,
          ),

          const SizedBox(height: 18),

          if (_journeyDisruptions
              .isNotEmpty) ...[
            _journeyDisruptionWarning(
              _journeyDisruptions,
            ),
            const SizedBox(height: 14),
          ],

          _digitalPass(
            ticketId: ticketId,
            ticketCode: ticketCode,
            status: status,
            statusColor:
                statusColor,
            issuedAt: issuedAt,
            activatedAt:
                activatedAt,
            isActive: isActive,
            isUsed: isUsed,
            origin: origin,
            destination:
                destination,
            duration: duration,
            cost: cost,
          ),

          const SizedBox(height: 20),

          _ticketInformation(
            isActive: isActive,
            isUsed: isUsed,
          ),

          const SizedBox(height: 22),

          _actionButton(
            isActive: isActive,
            isUsed: isUsed,
          ),
        ],
      ),
    );
  }

  Widget _ticketHeader({
    required bool isActive,
    required bool isUsed,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Ticket',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            color:
                LinkRideColors.primaryBlue,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          isUsed
              ? 'This ticket was used for a completed Link Ride journey.'
              : isActive
                  ? 'Your Link Ride journey is currently in progress.'
                  : 'Your digital travel credential is ready to use.',
          style: const TextStyle(
            fontSize: 13,
            height: 1.4,
            color:
                LinkRideColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _digitalPass({
    required int ticketId,
    required String ticketCode,
    required String status,
    required Color statusColor,
    required String issuedAt,
    required String activatedAt,
    required bool isActive,
    required bool isUsed,
    required String origin,
    required String destination,
    required int duration,
    required double cost,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color:
            LinkRideColors.surface,
        borderRadius:
            BorderRadius.circular(
          26,
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
              19,
              18,
              19,
              17,
            ),
            decoration: BoxDecoration(
              color:
                  LinkRideColors.primaryBlue,
              borderRadius:
                  const BorderRadius.vertical(
                top: Radius.circular(26),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration:
                      BoxDecoration(
                    color: Colors.white
                        .withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),
                  child: const Icon(
                    Icons
                        .confirmation_number_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Link Ride Ticket',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              FontWeight.w700,
                          color: Colors.white
                              .withValues(
                            alpha: 0.72,
                          ),
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        '#$ticketId',
                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.w800,
                          color:
                              Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        statusColor ==
                                LinkRideColors
                                    .primaryBlue
                            ? Colors.white
                                .withValues(
                                alpha: 0.12,
                              )
                            : statusColor
                                .withValues(
                                alpha: 0.18,
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
                      letterSpacing: 0.3,
                      color:
                          Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              19,
              18,
              19,
              19,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _ticketCodeBlock(
                  ticketCode,
                ),

                const SizedBox(height: 20),

                _routeBlock(
                  origin: origin,
                  destination:
                      destination,
                ),

                const SizedBox(height: 18),

                _ticketDivider(),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _metricCard(
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
                      child: _metricCard(
                        icon: Icons
                            .payments_outlined,
                        label: 'Fare',
                        value:
                            'R${cost.toStringAsFixed(2)}',
                        accent:
                            LinkRideColors
                                .linkGreen,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(
                    13,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        LinkRideColors
                            .surfaceSoft,
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isUsed
                            ? Icons
                                .history_rounded
                            : isActive
                                ? Icons
                                    .play_circle_fill_rounded
                                : Icons
                                    .schedule_rounded,
                        size: 18,
                        color:
                            statusColor,
                      ),

                      const SizedBox(width: 9),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              isActive
                                  ? 'Activated'
                                  : isUsed
                                      ? 'Issued'
                                      : 'Issued',
                              style:
                                  const TextStyle(
                                fontSize: 10.5,
                                color:
                                    LinkRideColors
                                        .textSecondary,
                              ),
                            ),

                            const SizedBox(
                              height: 2,
                            ),

                            Text(
                              isActive
                                  ? activatedAt
                                  : issuedAt,
                              style:
                                  const TextStyle(
                                fontSize: 12,
                                fontWeight:
                                    FontWeight
                                        .w700,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ticketCodeBlock(
    String ticketCode,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 14,
      ),
      decoration: BoxDecoration(
        gradient:
            LinkRideGradients.primarySoft,
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
      child: Column(
        children: [
          const Text(
            'TICKET CODE',
            style: TextStyle(
              fontSize: 10,
              fontWeight:
                  FontWeight.w800,
              letterSpacing: 1.4,
              color:
                  LinkRideColors.textMuted,
            ),
          ),

          const SizedBox(height: 8),

          SelectableText(
            ticketCode,
            textAlign:
                TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.w900,
              letterSpacing: 1.3,
              color:
                  LinkRideColors
                      .primaryBlue,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Keep this code available during your journey.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 10.8,
              color:
                  LinkRideColors
                      .textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _routeBlock({
    required String origin,
    required String destination,
  }) {
    return Column(
      children: [
        _routePoint(
          icon:
              Icons.trip_origin_rounded,
          color:
              LinkRideColors.linkGreen,
          label: 'FROM',
          value: origin,
        ),

        Padding(
          padding:
              const EdgeInsets.only(
            left: 17,
          ),
          child: Align(
            alignment:
                Alignment.centerLeft,
            child: Container(
              width: 2,
              height: 22,
              color:
                  LinkRideColors
                      .borderStrong,
            ),
          ),
        ),

        _routePoint(
          icon:
              Icons.location_on_rounded,
          color:
              LinkRideColors.primaryBlue,
          label: 'TO',
          value: destination,
        ),
      ],
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
          width: 36,
          height: 36,
          decoration:
              BoxDecoration(
            color:
                color.withValues(
              alpha: 0.09,
            ),
            shape:
                BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),

        const SizedBox(width: 11),

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
                  fontSize: 13,
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

  Widget _ticketDivider() {
    return Row(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (
              context,
              constraints,
            ) {
              const double dashWidth = 6;
              const double gap = 5;

              final int count =
                  (constraints.maxWidth /
                          (dashWidth + gap))
                      .floor();

              return Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children:
                    List.generate(
                  count,
                  (_) => Container(
                    width: dashWidth,
                    height: 1,
                    color:
                        LinkRideColors
                            .borderStrong,
                  ),
                ),
              );
            },
          ),
        ),
      ],
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
        horizontal: 12,
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

  Widget _ticketInformation({
    required bool isActive,
    required bool isUsed,
  }) {
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
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 20,
            color:
                LinkRideColors.primaryBlue,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              isUsed
                  ? 'This ticket has already been used and remains available as part of your Link Ride ticket history.'
                  : isActive
                      ? 'This ticket is active and linked to the journey currently in progress.'
                      : 'This ticket is ready to use. Starting the journey activates it and moves the journey into progress.',
              style: const TextStyle(
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

  Widget _actionButton({
    required bool isActive,
    required bool isUsed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed:
            isUsed || _isActivating
                ? null
                : isActive
                    ? _openActiveJourney
                    : _startJourney,
        icon: _isActivating
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
        ),
        style:
            FilledButton.styleFrom(
          backgroundColor:
              isActive
                  ? LinkRideColors.linkGreen
                  : LinkRideColors.primaryBlue,
          disabledBackgroundColor:
              isUsed
                  ? LinkRideColors.linkGreen
                      .withValues(
                      alpha: 0.55,
                    )
                  : LinkRideColors.primaryBlue
                      .withValues(
                      alpha: 0.45,
                    ),
          disabledForegroundColor:
              Colors.white,
        ),
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
                          const EdgeInsets.symmetric(
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
            'Preparing ticket...',
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
                  shape:
                      BoxShape.circle,
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
                'Unable to load ticket',
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
                    'Unable to load ticket.',
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
                onPressed: _loadTicket,
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
      case 'ACTIVE':
        return LinkRideColors.linkGreen;

      case 'USED':
        return const Color(
          0xFF3E7A49,
        );

      case 'ISSUED':
        return LinkRideColors.primaryBlue;

      default:
        return LinkRideColors.textSecondary;
    }
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