import 'package:flutter/material.dart';

import '../services/auth_storage.dart';
import '../services/my_journeys_service.dart';
import '../services/ticket_service.dart';
import '../theme/link_ride_theme.dart';
import 'my_journeys_screen.dart';
import 'ticket_screen.dart';

class TicketsScreen extends StatefulWidget {
  final int refreshToken;

  const TicketsScreen({
    super.key,
    this.refreshToken = 0,
  });

  @override
  State<TicketsScreen> createState() =>
      _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  final AuthStorage _authStorage =
      AuthStorage();

  final TicketService _ticketService =
      TicketService();

  final MyJourneysService _myJourneysService =
      MyJourneysService();

  bool _isLoading = true;
  String? _errorMessage;

  Map<String, dynamic>? _currentTicket;
  List<Map<String, dynamic>> _tickets = [];
  List<Map<String, dynamic>> _journeys = [];

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  @override
  void didUpdateWidget(
    covariant TicketsScreen oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.refreshToken !=
        widget.refreshToken) {
      _loadTickets();
    }
  }

  Future<void> _loadTickets() async {
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

      final List<dynamic> results =
          await Future.wait<dynamic>([
        _ticketService.getMyTickets(
          token: token,
        ),
        _ticketService.getCurrentTicket(
          token: token,
        ),
        _myJourneysService.getMyJourneys(
          token: token,
        ),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        _tickets =
            List<Map<String, dynamic>>.from(
          results[0] as List,
        );

        _currentTicket =
            results[1] == null
                ? null
                : Map<String, dynamic>.from(
                    results[1] as Map,
                  );

        _journeys =
            List<Map<String, dynamic>>.from(
          results[2] as List,
        );

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

  Map<String, dynamic>? _journeyForTicket(
    Map<String, dynamic> ticket,
  ) {
    final int journeyId =
        _asInt(
      ticket['journeyId'],
    );

    for (final Map<String, dynamic> journey
        in _journeys) {
      if (_asInt(journey['journeyId']) ==
          journeyId) {
        return journey;
      }
    }

    return null;
  }

  Future<void> _openTicket(
    Map<String, dynamic> ticket,
  ) async {
    final Map<String, dynamic>? journey =
        _journeyForTicket(ticket);

    if (journey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to find the journey linked to this ticket.',
          ),
        ),
      );

      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TicketScreen(
          journey: journey,
          ticket: ticket,
        ),
      ),
    );

    if (mounted) {
      await _loadTickets();
    }
  }

  Future<void> _openTicketList({
    required bool usedOnly,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TicketsListScreen(
          tickets: _tickets,
          journeys: _journeys,
          usedOnly: usedOnly,
        ),
      ),
    );

    if (mounted) {
      await _loadTickets();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          LinkRideColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadTickets,
          color:
              LinkRideColors.primaryBlue,
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
              _header(),

              const SizedBox(height: 24),

              const Text(
                'Current Ticket',
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

              const SizedBox(height: 12),

              if (_isLoading)
                _loadingCard()
              else if (_errorMessage != null)
                _errorCard()
              else
                _currentTicketSection(),

              const SizedBox(height: 28),

              const Text(
                'Ticket Management',
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
                'Review your full ticket history and completed travel passes.',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.4,
                  color:
                      LinkRideColors
                          .textSecondary,
                ),
              ),

              const SizedBox(height: 13),

              _managementCard(
                icon:
                    Icons.confirmation_number_outlined,
                title: 'All Tickets',
                subtitle:
                    'Issued, active and used tickets',
                accent:
                    LinkRideColors.primaryBlue,
                onTap:
                    _isLoading ||
                            _errorMessage != null
                        ? null
                        : () {
                            _openTicketList(
                              usedOnly: false,
                            );
                          },
              ),

              const SizedBox(height: 10),

              _managementCard(
                icon: Icons.history_rounded,
                title: 'Used Tickets',
                subtitle:
                    'Tickets from completed journeys',
                accent:
                    LinkRideColors.linkGreen,
                onTap:
                    _isLoading ||
                            _errorMessage != null
                        ? null
                        : () {
                            _openTicketList(
                              usedOnly: true,
                            );
                          },
              ),

              const SizedBox(height: 24),

              _ticketInformation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return const Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Tickets',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.7,
            color:
                LinkRideColors.primaryBlue,
          ),
        ),

        SizedBox(height: 5),

        Text(
          'Manage your current and previous Link Ride tickets.',
          style: TextStyle(
            fontSize: 13.5,
            height: 1.4,
            color:
                LinkRideColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _currentTicketSection() {
    final Map<String, dynamic>? ticket =
        _currentTicket;

    if (ticket == null) {
      return _emptyCurrentTicket();
    }

    final Map<String, dynamic>? journey =
        _journeyForTicket(ticket);

    final int ticketId =
        _asInt(
      ticket['ticketId'],
    );

    final String status =
        ticket['ticketStatus']
                ?.toString() ??
            'UNKNOWN';

    final String ticketCode =
        ticket['ticketCode']
                ?.toString() ??
            'Unavailable';

    final String origin =
        journey?['origin']
                ?.toString() ??
            'Journey origin';

    final String destination =
        journey?['destination']
                ?.toString() ??
            'Journey destination';

    final double cost =
        _asDouble(
      journey?['estimatedCost'],
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
              17,
              18,
              16,
            ),
            decoration:
                BoxDecoration(
              color:
                  statusColor.withValues(
                alpha: 0.06,
              ),
              borderRadius:
                  const BorderRadius.vertical(
                top: Radius.circular(
                  LinkRideRadius.extraLarge,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration:
                      BoxDecoration(
                    color:
                        statusColor.withValues(
                      alpha: 0.11,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                  child: Icon(
                    Icons
                        .confirmation_number_rounded,
                    size: 23,
                    color: statusColor,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ticket #$ticketId',
                        style:
                            const TextStyle(
                          fontSize: 15.5,
                          fontWeight:
                              FontWeight.w800,
                          color:
                              LinkRideColors
                                  .textPrimary,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        ticketCode,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
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

                _statusChip(status),
              ],
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              18,
              18,
              18,
              18,
            ),
            child: Column(
              children: [
                _ticketRoute(
                  origin: origin,
                  destination:
                      destination,
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _metricCard(
                        icon:
                            Icons.route_rounded,
                        label: 'Journey',
                        value:
                            '#${_asInt(ticket['journeyId'])}',
                        accent:
                            LinkRideColors.primaryBlue,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _metricCard(
                        icon:
                            Icons.payments_outlined,
                        label: 'Fare',
                        value:
                            'R${cost.toStringAsFixed(2)}',
                        accent:
                            LinkRideColors.linkGreen,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 17),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      _openTicket(ticket);
                    },
                    icon: const Icon(
                      Icons
                          .confirmation_number_outlined,
                      size: 18,
                    ),
                    label: const Text(
                      'View Ticket',
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

  Widget _emptyCurrentTicket() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(24),
      decoration:
          LinkRideDecorations.card(),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration:
                const BoxDecoration(
              color:
                  LinkRideColors.softBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons
                  .confirmation_number_outlined,
              size: 32,
              color:
                  LinkRideColors
                      .primaryBlue,
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            'No current ticket',
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

          const Text(
            'Choose a journey and complete payment to receive your Link Ride digital ticket.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color:
                  LinkRideColors
                      .textSecondary,
            ),
          ),

          const SizedBox(height: 15),

          OutlinedButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const MyJourneysScreen(),
                ),
              );

              if (mounted) {
                await _loadTickets();
              }
            },
            icon: const Icon(
              Icons.route_rounded,
              size: 18,
            ),
            label: const Text(
              'View My Journeys',
            ),
          ),
        ],
      ),
    );
  }

  Widget _ticketRoute({
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
            BorderRadius.circular(16),
        border: Border.all(
          color:
              LinkRideColors.border,
        ),
      ),
      child: Column(
        children: [
          _locationRow(
            icon:
                Icons.trip_origin_rounded,
            color:
                LinkRideColors.linkGreen,
            label: 'FROM',
            text: origin,
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
                height: 18,
                color:
                    LinkRideColors
                        .borderStrong,
              ),
            ),
          ),

          _locationRow(
            icon:
                Icons.location_on_rounded,
            color:
                LinkRideColors.primaryBlue,
            label: 'TO',
            text: destination,
          ),
        ],
      ),
    );
  }

  Widget _managementCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(
          LinkRideRadius.large,
        ),
        child: Ink(
          padding:
              const EdgeInsets.all(16),
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
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration:
                    BoxDecoration(
                  color:
                      accent.withValues(
                    alpha: 0.09,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 21,
                  color: accent,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
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
                      subtitle,
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

              const Icon(
                Icons
                    .chevron_right_rounded,
                color:
                    LinkRideColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ticketInformation() {
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
            Icons.info_outline_rounded,
            size: 20,
            color:
                LinkRideColors.primaryBlue,
          ),

          SizedBox(width: 11),

          Expanded(
            child: Text(
              'Your current ticket is ready for use or already active. Used tickets remain available in your ticket history after a journey is completed.',
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

  Widget _loadingCard() {
    return Container(
      width: double.infinity,
      height: 190,
      decoration:
          LinkRideDecorations.card(),
      child: const Center(
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2.3,
              color:
                  LinkRideColors
                      .primaryBlue,
            ),

            SizedBox(height: 12),

            Text(
              'Loading tickets...',
              style: TextStyle(
                fontSize: 12.5,
                color:
                    LinkRideColors
                        .textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(22),
      decoration:
          LinkRideDecorations.card(),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration:
                const BoxDecoration(
              color:
                  LinkRideColors.dangerSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 29,
              color:
                  LinkRideColors.danger,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Unable to load tickets',
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w800,
              color:
                  LinkRideColors
                      .textPrimary,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            _errorMessage ??
                'Unable to load tickets.',
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

          const SizedBox(height: 14),

          OutlinedButton.icon(
            onPressed: _loadTickets,
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
    final String normalized =
        status.toUpperCase();

    final Color colour =
        _statusColor(status);

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color:
            colour.withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(
          LinkRideRadius.pill,
        ),
      ),
      child: Text(
        normalized.replaceAll(
          '_',
          ' ',
        ),
        style: TextStyle(
          fontSize: 9.5,
          fontWeight:
              FontWeight.w800,
          color: colour,
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

  Widget _locationRow({
    required IconData icon,
    required Color color,
    required String label,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
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
            size: 16,
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
                text,
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

class TicketsListScreen
    extends StatelessWidget {
  final List<Map<String, dynamic>> tickets;
  final List<Map<String, dynamic>> journeys;
  final bool usedOnly;

  const TicketsListScreen({
    super.key,
    required this.tickets,
    required this.journeys,
    required this.usedOnly,
  });

  List<Map<String, dynamic>>
      get _visibleTickets {
    if (!usedOnly) {
      return tickets;
    }

    return tickets.where(
      (Map<String, dynamic> ticket) {
        return ticket['ticketStatus']
                ?.toString()
                .toUpperCase() ==
            'USED';
      },
    ).toList();
  }

  Map<String, dynamic>? _journeyForTicket(
    Map<String, dynamic> ticket,
  ) {
    final int journeyId =
        _asInt(
      ticket['journeyId'],
    );

    for (final Map<String, dynamic> journey
        in journeys) {
      if (_asInt(journey['journeyId']) ==
          journeyId) {
        return journey;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>>
        visibleTickets =
        _visibleTickets;

    return Scaffold(
      backgroundColor:
          LinkRideColors.background,
      appBar: AppBar(
        title: Text(
          usedOnly
              ? 'Used Tickets'
              : 'All Tickets',
        ),
      ),
      body: visibleTickets.isEmpty
          ? ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 90),
                _emptyState(),
              ],
            )
          : ListView(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                16,
                20,
                30,
              ),
              children: [
                _listSummary(
                  visibleTickets.length,
                ),

                const SizedBox(height: 14),

                ...visibleTickets.map(
                  (
                    Map<String, dynamic> ticket,
                  ) {
                    final Map<String, dynamic>?
                        journey =
                        _journeyForTicket(
                      ticket,
                    );

                    return Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: _ticketCard(
                        context,
                        ticket,
                        journey,
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }

  Widget _listSummary(
    int count,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
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
            width: 44,
            height: 44,
            decoration:
                const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              usedOnly
                  ? Icons.history_rounded
                  : Icons
                      .confirmation_number_rounded,
              size: 21,
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
                  usedOnly
                      ? 'Ticket history'
                      : 'Your tickets',
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
                  '$count ${count == 1 ? 'ticket' : 'tickets'}',
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
            child: const Icon(
              Icons
                  .confirmation_number_outlined,
              size: 31,
              color:
                  LinkRideColors
                      .primaryBlue,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            usedOnly
                ? 'No used tickets yet'
                : 'No tickets yet',
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
            usedOnly
                ? 'Tickets from completed journeys will appear here.'
                : 'Tickets you receive after payment will appear here.',
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

  Widget _ticketCard(
    BuildContext context,
    Map<String, dynamic> ticket,
    Map<String, dynamic>? journey,
  ) {
    final int ticketId =
        _asInt(
      ticket['ticketId'],
    );

    final String status =
        ticket['ticketStatus']
                ?.toString() ??
            'UNKNOWN';

    final String code =
        ticket['ticketCode']
                ?.toString() ??
            'Unavailable';

    final String origin =
        journey?['origin']
                ?.toString() ??
            'Journey origin';

    final String destination =
        journey?['destination']
                ?.toString() ??
            'Journey destination';

    final Color statusColor =
        _statusColor(status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: journey == null
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TicketScreen(
                      journey: journey,
                      ticket: ticket,
                    ),
                  ),
                );
              },
        borderRadius:
            BorderRadius.circular(
          LinkRideRadius.large,
        ),
        child: Ink(
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
                padding:
                    const EdgeInsets.fromLTRB(
                  15,
                  14,
                  15,
                  13,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      statusColor
                          .withValues(
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
                      width: 40,
                      height: 40,
                      decoration:
                          BoxDecoration(
                        color:
                            statusColor
                                .withValues(
                          alpha: 0.10,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),
                      child: Icon(
                        Icons
                            .confirmation_number_rounded,
                        color:
                            statusColor,
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 11),

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
                              fontSize: 14,
                              fontWeight:
                                  FontWeight
                                      .w800,
                              color:
                                  LinkRideColors
                                      .textPrimary,
                            ),
                          ),

                          const SizedBox(
                            height: 2,
                          ),

                          Text(
                            code,
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
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

                    _statusChip(status),
                  ],
                ),
              ),

              Padding(
                padding:
                    const EdgeInsets.all(
                  15,
                ),
                child: Column(
                  children: [
                    _routeRow(
                      icon: Icons
                          .trip_origin_rounded,
                      color:
                          LinkRideColors
                              .linkGreen,
                      text: origin,
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

                    _routeRow(
                      icon: Icons
                          .location_on_rounded,
                      color:
                          LinkRideColors
                              .primaryBlue,
                      text: destination,
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    Row(
                      children: [
                        const Icon(
                          Icons
                              .route_rounded,
                          size: 15,
                          color:
                              LinkRideColors
                                  .textMuted,
                        ),

                        const SizedBox(
                          width: 6,
                        ),

                        Text(
                          'Journey #${_asInt(ticket['journeyId'])}',
                          style:
                              const TextStyle(
                            fontSize: 11.5,
                            fontWeight:
                                FontWeight
                                    .w700,
                            color:
                                LinkRideColors
                                    .textSecondary,
                          ),
                        ),

                        const Spacer(),

                        if (journey != null)
                          const Icon(
                            Icons
                                .chevron_right_rounded,
                            color:
                                LinkRideColors
                                    .textMuted,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _routeRow({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          width: 31,
          height: 31,
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
            size: 15,
            color: color,
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Text(
            text,
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
    );
  }

  Widget _statusChip(
    String status,
  ) {
    final Color colour =
        _statusColor(status);

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color:
            colour.withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(
          LinkRideRadius.pill,
        ),
      ),
      child: Text(
        status
            .toUpperCase()
            .replaceAll(
              '_',
              ' ',
            ),
        style: TextStyle(
          fontSize: 9.5,
          fontWeight:
              FontWeight.w800,
          color: colour,
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
}