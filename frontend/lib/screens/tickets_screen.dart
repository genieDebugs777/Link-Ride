import 'package:flutter/material.dart';

import '../services/auth_storage.dart';
import '../services/my_journeys_service.dart';
import '../services/ticket_service.dart';
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
  static const Color primaryBlue = Color(0xFF003F73);
  static const Color linkGreen = Color(0xFF4A9B45);
  static const Color background = Color(0xFFF7F9FB);
  static const Color textPrimary = Color(0xFF17212B);
  static const Color textSecondary = Color(0xFF667085);
  static const Color cardBorder = Color(0xFFE4E9EE);

  final AuthStorage _authStorage = AuthStorage();
  final TicketService _ticketService = TicketService();
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
    super.didUpdateWidget(
      oldWidget,
    );

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
      final String? token = await _authStorage.getToken();

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
      backgroundColor: background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadTickets,
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
              const Text(
                'Tickets',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Manage your current and previous Link Ride tickets.',
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.4,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Current Ticket',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              if (_isLoading)
                _loadingCard()
              else if (_errorMessage != null)
                _errorCard()
              else
                _currentTicketSection(),
              const SizedBox(height: 24),
              const Text(
                'Ticket Management',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _managementCard(
                icon: Icons.confirmation_number_outlined,
                title: 'All Tickets',
                subtitle:
                    'View issued, active and used tickets',
                onTap:
                    _isLoading || _errorMessage != null
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
                    'View tickets from completed journeys',
                onTap:
                    _isLoading || _errorMessage != null
                        ? null
                        : () {
                            _openTicketList(
                              usedOnly: true,
                            );
                          },
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      primaryBlue.withValues(
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
                      Icons.info_outline_rounded,
                      size: 20,
                      color: primaryBlue,
                    ),
                    SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        'Your current ticket is the ticket ready for use or already active. Used tickets remain available in your ticket history.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.45,
                          color: textSecondary,
                        ),
                      ),
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

  Widget _currentTicketSection() {
    final Map<String, dynamic>? ticket =
        _currentTicket;

    if (ticket == null) {
      return Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(20),
          border: Border.all(
            color: cardBorder,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.confirmation_number_outlined,
              size: 42,
              color: primaryBlue,
            ),
            const SizedBox(height: 12),
            const Text(
              'No current ticket',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Choose a journey and complete payment to receive a Link Ride digital ticket.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 14),
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
              ),
              label: const Text(
                'View My Journeys',
              ),
            ),
          ],
        ),
      );
    }

    final Map<String, dynamic>? journey =
        _journeyForTicket(ticket);

    final int ticketId =
        _asInt(ticket['ticketId']);

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

    return Container(
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
            color:
                Colors.black.withValues(
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
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color:
                      primaryBlue.withValues(
                    alpha: 0.08,
                  ),
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.confirmation_number_rounded,
                  color: primaryBlue,
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
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ticketCode,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 11.5,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _statusChip(status),
            ],
          ),
          const SizedBox(height: 16),
          _locationRow(
            icon: Icons.trip_origin_rounded,
            color: linkGreen,
            text: origin,
          ),
          Padding(
            padding:
                const EdgeInsets.only(
              left: 7,
            ),
            child: Container(
              width: 2,
              height: 18,
              color: cardBorder,
            ),
          ),
          _locationRow(
            icon: Icons.location_on_rounded,
            color: primaryBlue,
            text: destination,
          ),
          const SizedBox(height: 16),
          const Divider(
            height: 1,
            color: cardBorder,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _metric(
                  icon: Icons.route_rounded,
                  value:
                      'Journey #${_asInt(ticket['journeyId'])}',
                ),
              ),
              Expanded(
                child: _metric(
                  icon: Icons.payments_outlined,
                  value:
                      'R${cost.toStringAsFixed(2)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () {
                _openTicket(ticket);
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    primaryBlue,
                foregroundColor:
                    Colors.white,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'View Ticket',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _managementCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(18),
        child: Ink(
          padding:
              const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(18),
            border: Border.all(
              color: cardBorder,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color:
                      primaryBlue.withValues(
                    alpha: 0.08,
                  ),
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: primaryBlue,
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
                            FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style:
                          const TextStyle(
                        fontSize: 11.5,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color:
                    Color(0xFF98A2B3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loadingCard() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: cardBorder,
        ),
      ),
      child: const Center(
        child:
            CircularProgressIndicator(
          color: primaryBlue,
        ),
      ),
    );
  }

  Widget _errorCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: cardBorder,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 38,
            color: primaryBlue,
          ),
          const SizedBox(height: 10),
          Text(
            _errorMessage ??
                'Unable to load tickets.',
            textAlign: TextAlign.center,
            style:
                const TextStyle(
              fontSize: 12.5,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _loadTickets,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            label: const Text(
              'Try Again',
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final String normalized =
        status.toUpperCase();

    final Color colour =
        normalized == 'ACTIVE'
            ? linkGreen
            : primaryBlue;

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
            BorderRadius.circular(20),
      ),
      child: Text(
        normalized.replaceAll('_', ' '),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: colour,
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
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style:
                const TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.w700,
              color: textPrimary,
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
          color: primaryBlue,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            value,
            overflow:
                TextOverflow.ellipsis,
            style:
                const TextStyle(
              fontSize: 12.5,
              fontWeight:
                  FontWeight.w700,
              color: textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  int _asInt(dynamic value) {
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

  double _asDouble(dynamic value) {
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

  List<Map<String, dynamic>>
      get _visibleTickets {
    if (!usedOnly) {
      return tickets;
    }

    return tickets.where(
      (ticket) =>
          ticket['ticketStatus']
                  ?.toString()
                  .toUpperCase() ==
              'USED',
    ).toList();
  }

  Map<String, dynamic>? _journeyForTicket(
    Map<String, dynamic> ticket,
  ) {
    final int journeyId =
        _asInt(ticket['journeyId']);

    for (final journey in journeys) {
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
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: Text(
          usedOnly
              ? 'Used Tickets'
              : 'All Tickets',
          style:
              const TextStyle(
            color: primaryBlue,
            fontSize: 20,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ),
      body:
          visibleTickets.isEmpty
              ? ListView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.all(24),
                  children: [
                    const SizedBox(height: 130),
                    const Icon(
                      Icons.confirmation_number_outlined,
                      size: 56,
                      color: primaryBlue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      usedOnly
                          ? 'No used tickets yet'
                          : 'No tickets yet',
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      usedOnly
                          ? 'Tickets from completed journeys will appear here.'
                          : 'Tickets you receive after payment will appear here.',
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: textSecondary,
                      ),
                    ),
                  ],
                )
              : ListView(
                  padding:
                      const EdgeInsets.fromLTRB(
                    20,
                    18,
                    20,
                    30,
                  ),
                  children: [
                    Text(
                      '${visibleTickets.length} '
                      '${visibleTickets.length == 1 ? 'ticket' : 'tickets'}',
                      style:
                          const TextStyle(
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w700,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...visibleTickets.map(
                      (ticket) {
                        final journey =
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

  Widget _ticketCard(
    BuildContext context,
    Map<String, dynamic> ticket,
    Map<String, dynamic>? journey,
  ) {
    final int ticketId =
        _asInt(ticket['ticketId']);

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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap:
            journey == null
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                TicketScreen(
                          journey: journey,
                          ticket: ticket,
                        ),
                      ),
                    );
                  },
        borderRadius:
            BorderRadius.circular(18),
        child: Ink(
          padding:
              const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(18),
            border: Border.all(
              color: cardBorder,
            ),
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
                    decoration: BoxDecoration(
                      color:
                          primaryBlue.withValues(
                        alpha: 0.08,
                      ),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.confirmation_number_rounded,
                      color: primaryBlue,
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
                          'Ticket #$ticketId',
                          style:
                              const TextStyle(
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          code,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            fontSize: 11.5,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusChip(status),
                ],
              ),
              const SizedBox(height: 15),
              _locationRow(
                icon: Icons.trip_origin_rounded,
                color: linkGreen,
                text: origin,
              ),
              Padding(
                padding:
                    const EdgeInsets.only(
                  left: 7,
                ),
                child: Container(
                  width: 2,
                  height: 18,
                  color: cardBorder,
                ),
              ),
              _locationRow(
                icon: Icons.location_on_rounded,
                color: primaryBlue,
                text: destination,
              ),
              const SizedBox(height: 12),
              Align(
                alignment:
                    Alignment.centerRight,
                child: Text(
                  'Journey #${_asInt(ticket['journeyId'])}',
                  style:
                      const TextStyle(
                    fontSize: 11.5,
                    fontWeight:
                        FontWeight.w700,
                    color: textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final String normalized =
        status.toUpperCase();

    final Color colour =
        normalized == 'ACTIVE'
            ? linkGreen
            : primaryBlue;

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
            BorderRadius.circular(20),
      ),
      child: Text(
        normalized,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: colour,
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
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style:
                const TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.w700,
              color: textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  int _asInt(dynamic value) {
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
