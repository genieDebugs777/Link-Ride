import 'package:flutter/material.dart';

import '../services/auth_storage.dart';
import '../services/disruption_service.dart';
import '../services/my_journeys_service.dart';
import '../theme/link_ride_theme.dart';
import 'active_journey_screen.dart';
import 'my_journeys_screen.dart';
import 'payment_screen.dart';
import 'ticket_screen.dart';

class JourneysScreen extends StatefulWidget {
  final int refreshToken;

  const JourneysScreen({
    super.key,
    this.refreshToken = 0,
  });

  @override
  State<JourneysScreen> createState() =>
      _JourneysScreenState();
}

class _JourneysScreenState
    extends State<JourneysScreen> {
  final AuthStorage _authStorage =
      AuthStorage();

  final MyJourneysService _myJourneysService =
      MyJourneysService();

  final DisruptionService _disruptionService =
      DisruptionService();

  bool _isLoading = true;

  String? _errorMessage;

  List<Map<String, dynamic>> _journeys = [];

  List<Map<String, dynamic>>
      _currentJourneyDisruptions = [];

  @override
  void initState() {
    super.initState();
    _loadJourneys();
  }

  @override
  void didUpdateWidget(
    covariant JourneysScreen oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.refreshToken !=
        widget.refreshToken) {
      _loadJourneys();
    }
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

      final List<Map<String, dynamic>> journeys =
          await _myJourneysService
              .getMyJourneys(
        token: token,
      );

      List<Map<String, dynamic>> disruptions = [];

      Map<String, dynamic>? currentJourney;

      for (final Map<String, dynamic> journey
          in journeys) {
        final String status =
            journey['journeyStatus']
                    ?.toString()
                    .toUpperCase() ??
                '';

        if (status == 'SELECTED' ||
            status == 'PAID' ||
            status == 'READY' ||
            status == 'IN_PROGRESS') {
          currentJourney = journey;
          break;
        }
      }

      if (currentJourney != null) {
        final int journeyId =
            _asInt(
          currentJourney['journeyId'],
        );

        if (journeyId > 0) {
          try {
            disruptions =
                await _disruptionService
                    .getActiveDisruptionsForJourney(
              token: token,
              journeyId: journeyId,
            );
          } catch (error) {
            debugPrint(
              'Journey disruption check error: $error',
            );
          }
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _journeys = journeys;

        _currentJourneyDisruptions =
            disruptions;

        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      debugPrint(
        'Journeys hub error: $error',
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

  Map<String, dynamic>? get _currentJourney {
    for (final Map<String, dynamic> journey
        in _journeys) {
      final String status =
          journey['journeyStatus']
                  ?.toString()
                  .toUpperCase() ??
              '';

      if (status == 'SELECTED' ||
          status == 'PAID' ||
          status == 'READY' ||
          status == 'IN_PROGRESS') {
        return journey;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          LinkRideColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadJourneys,
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

              const SizedBox(height: 22),

              if (_isLoading)
                const _LoadingCard()
              else if (_errorMessage != null)
                _errorCard()
              else
                _currentJourneySection(),

              const SizedBox(height: 28),

              const Text(
                'Journey Management',
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
                'Review your saved journeys and completed travel history.',
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
                icon: Icons.history_rounded,
                title: 'My Journeys',
                subtitle:
                    'View saved, current and recent journeys',
                accent:
                    LinkRideColors.primaryBlue,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const MyJourneysScreen(),
                    ),
                  );

                  if (mounted) {
                    await _loadJourneys();
                  }
                },
              ),

              const SizedBox(height: 10),

              _managementCard(
                icon:
                    Icons.check_circle_outline_rounded,
                title: 'Journey History',
                subtitle:
                    'View journeys you have completed',
                accent:
                    LinkRideColors.linkGreen,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const MyJourneysScreen(
                        completedOnly: true,
                      ),
                    ),
                  );

                  if (mounted) {
                    await _loadJourneys();
                  }
                },
              ),

              const SizedBox(height: 24),

              _journeyLifecycleInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Journeys',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.7,
            color:
                LinkRideColors.primaryBlue,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'Manage your selected, active and previous journeys.',
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

  Widget _currentJourneySection() {
    final Map<String, dynamic>?
        journey =
        _currentJourney;

    if (journey == null) {
      return _emptyCurrentJourney();
    }

    final String origin =
        journey['origin']
                ?.toString() ??
            'Unknown origin';

    final String destination =
        journey['destination']
                ?.toString() ??
            'Unknown destination';

    final String status =
        journey['journeyStatus']
                ?.toString() ??
            'UNKNOWN';

    final int duration =
        _asInt(
      journey['estimatedDuration'],
    );

    final double cost =
        _asDouble(
      journey['estimatedCost'],
    );

    final int journeyId =
        _asInt(
      journey['journeyId'],
    );

    final Color statusColor =
        _statusColor(status);

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Current Journey',
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
            ),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration:
                  BoxDecoration(
                color:
                    LinkRideColors
                        .softBlue,
                borderRadius:
                    BorderRadius.circular(
                  LinkRideRadius.pill,
                ),
              ),
              child: const Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Icon(
                    Icons
                        .directions_transit_rounded,
                    size: 14,
                    color:
                        LinkRideColors
                            .primaryBlue,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'ACTIVE FLOW',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight:
                          FontWeight.w800,
                      letterSpacing: 0.5,
                      color:
                          LinkRideColors
                              .primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (_currentJourneyDisruptions
            .isNotEmpty) ...[
          _journeyDisruptionWarning(
            _currentJourneyDisruptions,
          ),
          const SizedBox(height: 12),
        ],

        Container(
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
                      statusColor
                          .withValues(
                    alpha: 0.055,
                  ),
                  borderRadius:
                      const BorderRadius
                          .vertical(
                    top: Radius.circular(
                      LinkRideRadius
                          .extraLarge,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration:
                          BoxDecoration(
                        color:
                            statusColor
                                .withValues(
                          alpha: 0.11,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          14,
                        ),
                      ),
                      child: Icon(
                        _statusIcon(status),
                        color: statusColor,
                        size: 22,
                      ),
                    ),

                    const SizedBox(width: 12),

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
                              fontSize: 15.5,
                              fontWeight:
                                  FontWeight
                                      .w800,
                              color:
                                  LinkRideColors
                                      .textPrimary,
                            ),
                          ),

                          const SizedBox(
                            height: 3,
                          ),

                          Text(
                            _statusDescription(
                              status,
                            ),
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
                padding:
                    const EdgeInsets.fromLTRB(
                  18,
                  18,
                  18,
                  18,
                ),
                child: Column(
                  children: [
                    _journeyRoute(
                      origin: origin,
                      destination:
                          destination,
                    ),

                    const SizedBox(
                      height: 17,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _metricCard(
                            icon: Icons
                                .schedule_rounded,
                            label:
                                'Duration',
                            value:
                                '$duration min',
                            accent:
                                LinkRideColors
                                    .primaryBlue,
                          ),
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Expanded(
                          child: _metricCard(
                            icon: Icons
                                .payments_outlined,
                            label:
                                'Est. cost',
                            value:
                                'R${cost.toStringAsFixed(2)}',
                            accent:
                                LinkRideColors
                                    .linkGreen,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 17,
                    ),

                    SizedBox(
                      width:
                          double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          await _handleJourneyAction(
                            journey,
                            status,
                          );
                        },
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            Icon(
                              _actionIcon(
                                status,
                              ),
                              size: 18,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              _actionLabel(
                                status,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            const Icon(
                              Icons
                                  .arrow_forward_rounded,
                              size: 17,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _emptyCurrentJourney() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(24),
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
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.route_outlined,
              size: 31,
              color:
                  LinkRideColors
                      .primaryBlue,
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            'No current journey',
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
            'Choose a journey from Home and it will appear here as you move through payment, ticketing and travel.',
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
        ],
      ),
    );
  }

  Widget _journeyRoute({
    required String origin,
    required String destination,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(15),
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
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration:
                    const BoxDecoration(
                  color:
                      LinkRideColors
                          .softGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons
                      .trip_origin_rounded,
                  size: 17,
                  color:
                      LinkRideColors
                          .linkGreen,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    const Text(
                      'FROM',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight:
                            FontWeight
                                .w800,
                        letterSpacing:
                            0.7,
                        color:
                            LinkRideColors
                                .textMuted,
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      origin,
                      style:
                          const TextStyle(
                        fontSize: 13,
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

          Padding(
            padding:
                const EdgeInsets.only(
              left: 16,
            ),
            child: Align(
              alignment:
                  Alignment.centerLeft,
              child: Container(
                width: 2,
                height: 19,
                color:
                    LinkRideColors
                        .borderStrong,
              ),
            ),
          ),

          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration:
                    const BoxDecoration(
                  color:
                      LinkRideColors
                          .softBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons
                      .location_on_rounded,
                  size: 18,
                  color:
                      LinkRideColors
                          .primaryBlue,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    const Text(
                      'TO',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight:
                            FontWeight
                                .w800,
                        letterSpacing:
                            0.7,
                        color:
                            LinkRideColors
                                .textMuted,
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      destination,
                      style:
                          const TextStyle(
                        fontSize: 13,
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
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(
          alpha: 0.055,
        ),
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: accent.withValues(
            alpha: 0.12,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
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

  Future<void> _handleJourneyAction(
    Map<String, dynamic> journey,
    String status,
  ) async {
    final String normalizedStatus =
        status.toUpperCase();

    if (normalizedStatus == 'SELECTED') {
      final bool? paymentCompleted =
          await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PaymentScreen(
            journey: journey,
          ),
        ),
      );

      if (paymentCompleted == true &&
          mounted) {
        await _loadJourneys();
      }

      return;
    }

    if (normalizedStatus == 'PAID' ||
        normalizedStatus == 'READY') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              TicketScreen(
            journey: journey,
          ),
        ),
      );

      if (mounted) {
        await _loadJourneys();
      }

      return;
    }

    if (normalizedStatus ==
        'IN_PROGRESS') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const ActiveJourneyScreen(),
        ),
      );

      if (mounted) {
        await _loadJourneys();
      }
    }
  }

  String _actionLabel(
    String status,
  ) {
    switch (status.toUpperCase()) {
      case 'SELECTED':
        return 'Continue to Payment';

      case 'PAID':
        return 'Continue to Ticket';

      case 'READY':
        return 'View Ticket';

      case 'IN_PROGRESS':
        return 'Continue Journey';

      default:
        return 'View Journey';
    }
  }

  IconData _actionIcon(
    String status,
  ) {
    switch (status.toUpperCase()) {
      case 'SELECTED':
        return Icons
            .credit_card_rounded;

      case 'PAID':
      case 'READY':
        return Icons
            .confirmation_number_outlined;

      case 'IN_PROGRESS':
        return Icons
            .navigation_rounded;

      default:
        return Icons.route_rounded;
    }
  }

  String _statusDescription(
    String status,
  ) {
    switch (status.toUpperCase()) {
      case 'SELECTED':
        return 'Journey selected and awaiting payment';

      case 'PAID':
        return 'Payment complete and ticket preparation available';

      case 'READY':
        return 'Ticket ready for your journey';

      case 'IN_PROGRESS':
        return 'Journey currently in progress';

      default:
        return 'Journey status available';
    }
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

      default:
        return LinkRideColors.textSecondary;
    }
  }

  IconData _statusIcon(
    String status,
  ) {
    switch (status.toUpperCase()) {
      case 'SELECTED':
        return Icons
            .route_rounded;

      case 'PAID':
        return Icons
            .payments_rounded;

      case 'READY':
        return Icons
            .confirmation_number_rounded;

      case 'IN_PROGRESS':
        return Icons
            .navigation_rounded;

      default:
        return Icons
            .info_outline_rounded;
    }
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
        color: warningColor.withValues(
          alpha: 0.07,
        ),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: warningColor.withValues(
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
                  BorderRadius.circular(13),
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
                          const EdgeInsets
                              .symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration:
                          BoxDecoration(
                        color: warningColor
                            .withValues(
                          alpha: 0.11,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          LinkRideRadius
                              .pill,
                        ),
                      ),
                      child: Text(
                        severity,
                        style:
                            TextStyle(
                          fontSize: 9.5,
                          fontWeight:
                              FontWeight
                                  .w800,
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

  Widget _managementCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
    required VoidCallback onTap,
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

  Widget _journeyLifecycleInfo() {
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
                  .timeline_rounded,
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
                  'Journey lifecycle',
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
                  'Your selected journey moves through payment, ticketing, active travel and completion from this hub.',
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
          color: color,
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
            'Unable to load journeys',
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
                'Unable to load journeys.',
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

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
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
              'Loading your journeys...',
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
}