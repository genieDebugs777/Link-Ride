import 'dart:async';

import 'package:flutter/material.dart';

import '../services/auth_storage.dart';
import '../services/disruption_service.dart';
import '../services/journey_plan_service.dart';
import '../services/journey_preferences_service.dart';
import '../services/location_service.dart';
import '../services/my_journeys_service.dart';
import '../services/notification_service.dart';
import '../services/stop_search_service.dart';
import '../services/ticket_service.dart';
import '../theme/link_ride_theme.dart';

import 'journey_options_screen.dart';
import 'my_journeys_screen.dart';
import 'notifications_screen.dart';
import 'ticket_screen.dart';

class HomeScreen extends StatefulWidget {
  final String firstName;

  const HomeScreen({
    super.key,
    required this.firstName,
  });

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthStorage _authStorage =
      AuthStorage();

  final StopSearchService _stopSearchService =
      StopSearchService();

  final LocationService _locationService =
      LocationService();

  final JourneyPlanService _journeyPlanService =
      JourneyPlanService();

  final JourneyPreferencesService
      _journeyPreferencesService =
      JourneyPreferencesService();

  final TicketService _ticketService =
      TicketService();

  final MyJourneysService _myJourneysService =
      MyJourneysService();

  final DisruptionService _disruptionService =
      DisruptionService();

  final NotificationService _notificationService =
      NotificationService();

  bool _isPlanningJourney = false;

  bool _isLoadingCurrentTicket = true;
  Map<String, dynamic>? _currentTicket;

  bool _isLoadingDisruptions = true;
  String? _disruptionError;

  List<Map<String, dynamic>>
      _activeDisruptions = [];

  int _unreadNotificationCount = 0;

  final TextEditingController _originController =
      TextEditingController();

  final TextEditingController
      _destinationController =
      TextEditingController();

  Timer? _originSearchDebounce;
  Timer? _destinationSearchDebounce;

  List<Map<String, dynamic>>
      _originSuggestions = [];

  Map<String, dynamic>? _selectedOrigin;

  bool _isSearchingOrigin = false;
  String? _originSearchError;

  List<Map<String, dynamic>>
      _destinationSuggestions = [];

  Map<String, dynamic>? _selectedDestination;

  bool _isSearchingDestination = false;
  String? _destinationSearchError;

  bool _isLoadingCurrentLocation = false;

  double? _currentLatitude;
  double? _currentLongitude;

  String? _currentLocationError;

  @override
  void initState() {
    super.initState();

    _loadCurrentTicketSummary();
    _loadActiveDisruptions();
    _loadUnreadNotificationCount();
  }

  @override
  void dispose() {
    _originSearchDebounce?.cancel();
    _destinationSearchDebounce?.cancel();

    _originController.dispose();
    _destinationController.dispose();

    super.dispose();
  }

  // ───────────────── HOME DATA ─────────────────

  Future<void> _refreshHomeData() async {
    await Future.wait<void>([
      _loadCurrentTicketSummary(),
      _loadActiveDisruptions(),
      _loadUnreadNotificationCount(),
    ]);
  }

  Future<void> _loadUnreadNotificationCount()
      async {
    try {
      final String? token =
          await _authStorage.getToken();

      if (token == null || token.isEmpty) {
        if (!mounted) {
          return;
        }

        setState(() {
          _unreadNotificationCount = 0;
        });

        return;
      }

      final int count =
          await _notificationService
              .getUnreadCount(
        token: token,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _unreadNotificationCount = count;
      });
    } catch (error) {
      debugPrint(
        'Notification count error: $error',
      );
    }
  }

  Future<void> _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const NotificationsScreen(),
      ),
    );

    if (mounted) {
      await _loadUnreadNotificationCount();
    }
  }

  Future<void> _loadCurrentTicketSummary()
      async {
    try {
      final String? token =
          await _authStorage.getToken();

      if (token == null || token.isEmpty) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isLoadingCurrentTicket = false;
          _currentTicket = null;
        });

        return;
      }

      final Map<String, dynamic>? ticket =
          await _ticketService
              .getCurrentTicket(
        token: token,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _currentTicket = ticket;
        _isLoadingCurrentTicket = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _currentTicket = null;
        _isLoadingCurrentTicket = false;
      });
    }
  }

  String get _myTicketSubtitle {
    if (_isLoadingCurrentTicket) {
      return 'Checking ticket...';
    }

    final String status =
        _currentTicket?['ticketStatus']
                ?.toString()
                .toUpperCase() ??
            '';

    if (status == 'ACTIVE') {
      return 'Active journey';
    }

    if (status == 'ISSUED') {
      return 'Ready to use';
    }

    return 'No current ticket';
  }

  Future<void> _openCurrentTicket() async {
    if (_isLoadingCurrentTicket) {
      return;
    }

    final String? token =
        await _authStorage.getToken();

    if (token == null || token.isEmpty) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Your Link Ride session is no longer valid.',
          ),
        ),
      );

      return;
    }

    Map<String, dynamic>? ticket =
        _currentTicket;

    ticket ??=
        await _ticketService.getCurrentTicket(
      token: token,
    );

    if (!mounted) {
      return;
    }

    if (ticket == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'You do not have a current ticket.',
          ),
        ),
      );

      return;
    }

    final List<Map<String, dynamic>> journeys =
        await _myJourneysService
            .getMyJourneys(
      token: token,
    );

    if (!mounted) {
      return;
    }

    final int journeyId =
        _asInt(
      ticket['journeyId'],
    );

    Map<String, dynamic>? journey;

    for (final Map<String, dynamic> item
        in journeys) {
      if (_asInt(item['journeyId']) ==
          journeyId) {
        journey = item;
        break;
      }
    }

    if (journey == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
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
          journey: journey!,
          ticket: ticket,
        ),
      ),
    );

    if (mounted) {
      await _loadCurrentTicketSummary();
    }
  }

  // ───────────────── DISRUPTIONS ─────────────────

  Future<void> _loadActiveDisruptions()
      async {
    if (mounted) {
      setState(() {
        _isLoadingDisruptions = true;
        _disruptionError = null;
      });
    }

    try {
      final String? token =
          await _authStorage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Your Link Ride session is no longer valid.',
        );
      }

      final List<Map<String, dynamic>>
          disruptions =
          await _disruptionService
              .getActiveDisruptions(
        token: token,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _activeDisruptions = disruptions;
        _isLoadingDisruptions = false;
        _disruptionError = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      debugPrint(
        'Disruption loading error: $error',
      );

      setState(() {
        _activeDisruptions = [];
        _isLoadingDisruptions = false;
        _disruptionError =
            'Unable to load live transport updates.';
      });
    }
  }

  // ───────────────── ORIGIN SEARCH ─────────────────

  void _onOriginChanged(String value) {
    _originSearchDebounce?.cancel();

    final String query =
        value.trim();

    setState(() {
      _selectedOrigin = null;
      _originSearchError = null;
    });

    if (query.length < 2) {
      setState(() {
        _originSuggestions = [];
        _isSearchingOrigin = false;
      });

      return;
    }

    setState(() {
      _isSearchingOrigin = true;
    });

    _originSearchDebounce = Timer(
      const Duration(
        milliseconds: 350,
      ),
      () {
        _searchOrigin(query);
      },
    );
  }

  Future<void> _searchOrigin(
    String query,
  ) async {
    try {
      final String? token =
          await _authStorage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'No active Link Ride session found.',
        );
      }

      final List<Map<String, dynamic>> results =
          await _stopSearchService
              .searchStops(
        query: query,
        token: token,
      );

      if (!mounted) {
        return;
      }

      if (_originController.text.trim() !=
          query) {
        return;
      }

      setState(() {
        _originSuggestions = results;
        _isSearchingOrigin = false;
        _originSearchError = null;
      });
    } catch (error) {
      debugPrint(
        'Origin search error: $error',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _originSuggestions = [];
        _isSearchingOrigin = false;

        _originSearchError =
            'Unable to search origin stops right now.';
      });
    }
  }

  void _selectOrigin(
    Map<String, dynamic> stop,
  ) {
    final String stopName =
        stop['stopName']
                ?.toString() ??
            '';

    setState(() {
      _selectedOrigin = stop;

      _originController.text =
          stopName;

      _originController.selection =
          TextSelection.collapsed(
        offset: stopName.length,
      );

      _originSuggestions = [];
      _originSearchError = null;
      _isSearchingOrigin = false;

      _currentLatitude = null;
      _currentLongitude = null;
      _currentLocationError = null;
    });

    FocusScope.of(context).unfocus();
  }

  void _useCurrentLocationOrigin() {
    _originSearchDebounce?.cancel();

    setState(() {
      _originController.clear();
      _selectedOrigin = null;
      _originSuggestions = [];
      _originSearchError = null;
      _isSearchingOrigin = false;
    });

    _loadCurrentLocation();
  }

  // ───────────────── DESTINATION SEARCH ─────────────────

  void _onDestinationChanged(
    String value,
  ) {
    _destinationSearchDebounce
        ?.cancel();

    final String query =
        value.trim();

    setState(() {
      _selectedDestination = null;
      _destinationSearchError = null;
    });

    if (query.length < 2) {
      setState(() {
        _destinationSuggestions = [];
        _isSearchingDestination =
            false;
      });

      return;
    }

    setState(() {
      _isSearchingDestination =
          true;
    });

    _destinationSearchDebounce =
        Timer(
      const Duration(
        milliseconds: 350,
      ),
      () {
        _searchDestination(query);
      },
    );
  }

  Future<void> _searchDestination(
    String query,
  ) async {
    try {
      final String? token =
          await _authStorage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'No active Link Ride session found.',
        );
      }

      final List<Map<String, dynamic>> results =
          await _stopSearchService
              .searchStops(
        query: query,
        token: token,
      );

      if (!mounted) {
        return;
      }

      if (_destinationController.text
              .trim() !=
          query) {
        return;
      }

      setState(() {
        _destinationSuggestions =
            results;

        _isSearchingDestination =
            false;

        _destinationSearchError = null;
      });
    } catch (error) {
      debugPrint(
        'Destination search error: $error',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _destinationSuggestions = [];

        _isSearchingDestination =
            false;

        _destinationSearchError =
            'Unable to search destinations right now.';
      });
    }
  }

  void _selectDestination(
    Map<String, dynamic> stop,
  ) {
    final String stopName =
        stop['stopName']
                ?.toString() ??
            '';

    setState(() {
      _selectedDestination = stop;

      _destinationController.text =
          stopName;

      _destinationController.selection =
          TextSelection.collapsed(
        offset: stopName.length,
      );

      _destinationSuggestions = [];
      _destinationSearchError = null;

      _isSearchingDestination =
          false;
    });

    FocusScope.of(context).unfocus();
  }

  void _clearDestination() {
    _destinationSearchDebounce
        ?.cancel();

    setState(() {
      _destinationController.clear();
      _selectedDestination = null;
      _destinationSuggestions = [];
      _destinationSearchError = null;

      _isSearchingDestination =
          false;
    });
  }

  // ───────────────── CURRENT LOCATION ─────────────────

  Future<void> _loadCurrentLocation()
      async {
    if (_isLoadingCurrentLocation) {
      return;
    }

    setState(() {
      _isLoadingCurrentLocation =
          true;

      _currentLocationError = null;
    });

    try {
      final position =
          await _locationService
              .getCurrentPosition();

      if (!mounted) {
        return;
      }

      setState(() {
        _currentLatitude =
            position.latitude;

        _currentLongitude =
            position.longitude;

        _selectedOrigin = null;

        _originController.clear();

        _originSuggestions = [];

        _originSearchError = null;

        _isSearchingOrigin = false;

        _isLoadingCurrentLocation =
            false;

        _currentLocationError = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingCurrentLocation =
            false;

        _currentLocationError =
            'Location unavailable - tap to retry';
      });
    }
  }

  // ───────────────── JOURNEY PLANNING ─────────────────

  Future<void> _planJourney() async {
    if (_isPlanningJourney) {
      return;
    }

    if (_selectedDestination == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a destination from the suggestions.',
          ),
        ),
      );

      return;
    }

    double? originLatitude;
    double? originLongitude;

    if (_selectedOrigin != null) {
      originLatitude =
          _asDouble(
        _selectedOrigin!['latitude'],
      );

      originLongitude =
          _asDouble(
        _selectedOrigin!['longitude'],
      );

      if (originLatitude == null ||
          originLongitude == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'The selected origin stop does not have valid coordinates.',
            ),
          ),
        );

        return;
      }
    } else {
      if (_currentLatitude == null ||
          _currentLongitude == null) {
        await _loadCurrentLocation();

        if (!mounted) {
          return;
        }
      }

      if (_currentLatitude == null ||
          _currentLongitude == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              _currentLocationError ??
                  'Choose an origin stop or enable current location.',
            ),
          ),
        );

        return;
      }

      originLatitude =
          _currentLatitude;

      originLongitude =
          _currentLongitude;
    }

    final dynamic rawStopId =
        _selectedDestination!['stopId'];

    final int? destinationStopId =
        rawStopId is int
            ? rawStopId
            : int.tryParse(
                rawStopId
                        ?.toString() ??
                    '',
              );

    if (destinationStopId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'The selected destination is invalid.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isPlanningJourney = true;
    });

    try {
      final String? token =
          await _authStorage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'No active Link Ride session found.',
        );
      }

      final Map<String, dynamic>
          preferences =
          await _journeyPreferencesService
              .getPreferences();

      final List<Map<String, dynamic>>
          options =
          await _journeyPlanService
              .planJourney(
        originLatitude:
            originLatitude!,
        originLongitude:
            originLongitude!,
        destinationStopId:
            destinationStopId,
        token: token,
        priority:
            preferences['priority']
                as String,
        gautrainSelected:
            preferences[
                    'gautrainSelected']
                as bool,
        metrorailSelected:
            preferences[
                    'metrorailSelected']
                as bool,
        busSelected:
            preferences['busSelected']
                as bool,
        taxiSelected:
            preferences['taxiSelected']
                as bool,
        preferFewerTransfers:
            preferences[
                    'preferFewerTransfers']
                as bool,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isPlanningJourney = false;
      });

      if (options.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'No sensible journey is available within the current Link Ride prototype network.',
            ),
          ),
        );

        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              JourneyOptionsScreen(
            journeyOptions: options,
          ),
        ),
      );
    } catch (error) {
      debugPrint(
        'Journey planning error: $error',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isPlanningJourney = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to plan your journey right now.',
          ),
        ),
      );
    }
  }

  // ───────────────── BUILD ─────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          LinkRideColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refreshHomeData,
          color:
              LinkRideColors.primaryBlue,
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior
                    .onDrag,
            padding:
                const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              30,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _header(),

                const SizedBox(height: 20),

                _heroCard(),

                const SizedBox(height: 18),

                _journeyPlanner(),

                const SizedBox(height: 28),

                _sectionHeader(
                  title:
                      'Live Transport Updates',
                  actionLabel: 'Refresh',
                  onAction:
                      _isLoadingDisruptions
                          ? null
                          : _loadActiveDisruptions,
                ),

                const SizedBox(height: 12),

                _liveTransportUpdatesSection(),

                const SizedBox(height: 28),

                const Text(
                  'Quick Access',
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

                Row(
                  children: [
                    Expanded(
                      child:
                          _quickAccessCard(
                        icon: Icons
                            .confirmation_number_outlined,
                        title: 'My Ticket',
                        subtitle:
                            _myTicketSubtitle,
                        accent:
                            LinkRideColors
                                .primaryBlue,
                        onTap:
                            _openCurrentTicket,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child:
                          _quickAccessCard(
                        icon: Icons
                            .history_rounded,
                        title:
                            'My Journeys',
                        subtitle:
                            'Recent trips',
                        accent:
                            LinkRideColors
                                .linkGreen,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      const MyJourneysScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────── HEADER ─────────────────

  Widget _header() {
    return Row(
      children: [
        Expanded(
          child: Image.asset(
            'assets/link_ride_header_logo.png',
            height: 50,
            alignment:
                Alignment.centerLeft,
            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(width: 16),

        Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color:
                  LinkRideColors.surface,
              borderRadius:
                  BorderRadius.circular(16),
              child: InkWell(
                onTap: _openNotifications,
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                    border: Border.all(
                      color:
                          LinkRideColors
                              .border,
                    ),
                    boxShadow:
                        LinkRideShadows.soft,
                  ),
                  child: const Icon(
                    Icons
                        .notifications_none_rounded,
                    size: 24,
                    color:
                        LinkRideColors
                            .primaryBlue,
                  ),
                ),
              ),
            ),

            if (_unreadNotificationCount >
                0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  constraints:
                      const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 5,
                  ),
                  alignment:
                      Alignment.center,
                  decoration:
                      const BoxDecoration(
                    color:
                        LinkRideColors
                            .linkGreen,
                    shape:
                        BoxShape.circle,
                  ),
                  child: Text(
                    _unreadNotificationCount >
                            99
                        ? '99+'
                        : '$_unreadNotificationCount',
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontSize: 9.5,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ───────────────── HERO ─────────────────

  Widget _heroCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        21,
      ),
      decoration:
          LinkRideDecorations.blueCard(),
      child: Stack(
        children: [
          Positioned(
            top: -38,
            right: -32,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white
                    .withValues(
                  alpha: 0.06,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -48,
            right: 42,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    LinkRideColors
                        .linkGreen
                        .withValues(
                  alpha: 0.16,
                ),
              ),
            ),
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration:
                    BoxDecoration(
                  color: Colors.white
                      .withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    LinkRideRadius.pill,
                  ),
                  border: Border.all(
                    color: Colors.white
                        .withValues(
                      alpha: 0.12,
                    ),
                  ),
                ),
                child: const Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Icon(
                      Icons
                          .directions_transit_rounded,
                      size: 15,
                      color:
                          Colors.white,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'CONNECTED MOBILITY',
                      style: TextStyle(
                        color:
                            Colors.white,
                        fontSize: 10,
                        fontWeight:
                            FontWeight.w800,
                        letterSpacing:
                            0.8,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 17),

              Text(
                'Hi, ${widget.firstName}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w600,
                  color: Colors.white
                      .withValues(
                    alpha: 0.78,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'Where are you going?',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing: -0.7,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                'Plan one connected journey across supported public transport services.',
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  color: Colors.white
                      .withValues(
                    alpha: 0.78,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────── JOURNEY PLANNER ─────────────────

  Widget _journeyPlanner() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: LinkRideColors.surface,
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
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      'Plan your journey',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w800,
                        color:
                            LinkRideColors
                                .textPrimary,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Choose where you are and where you want to go.',
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

              Container(
                width: 38,
                height: 38,
                decoration:
                    BoxDecoration(
                  color:
                      LinkRideColors
                          .softBlue,
                  shape:
                      BoxShape.circle,
                ),
                child: Icon(
                  Icons.route_rounded,
                  size: 20,
                  color:
                      LinkRideColors
                          .primaryBlue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _originAutocompleteField(),

          Padding(
            padding:
                const EdgeInsets.only(
              left: 21,
            ),
            child: Container(
              width: 2,
              height: 18,
              color:
                  LinkRideColors.borderStrong,
            ),
          ),

          _destinationAutocompleteField(),

          if (_currentLocationError !=
              null) ...[
            const SizedBox(height: 10),

            InkWell(
              onTap:
                  _loadCurrentLocation,
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      LinkRideColors
                          .dangerSoft,
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons
                          .location_off_outlined,
                      size: 17,
                      color:
                          LinkRideColors
                              .danger,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Text(
                        _currentLocationError!,
                        style:
                            const TextStyle(
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w600,
                          color:
                              LinkRideColors
                                  .danger,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed:
                  _isPlanningJourney
                      ? null
                      : _planJourney,
              child: AnimatedSwitcher(
                duration:
                    const Duration(
                  milliseconds: 180,
                ),
                child:
                    _isPlanningJourney
                        ? const Row(
                            key:
                                ValueKey(
                              'planning',
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
                                  strokeWidth:
                                      2,
                                  color:
                                      Colors.white,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Finding journeys...',
                              ),
                            ],
                          )
                        : const Row(
                            key:
                                ValueKey(
                              'find-journey',
                            ),
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            children: [
                              Icon(
                                Icons
                                    .route_rounded,
                                size: 19,
                              ),
                              SizedBox(
                                width: 9,
                              ),
                              Text(
                                'Find Journey',
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
          ),
        ],
      ),
    );
  }

  // ───────────────── ORIGIN FIELD ─────────────────

  Widget _originAutocompleteField() {
    final bool usingManualOrigin =
        _selectedOrigin != null ||
            _originController
                .text.isNotEmpty;

    final bool usingGps =
        !usingManualOrigin &&
            _currentLatitude != null &&
            _currentLongitude != null;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color:
                LinkRideColors.surfaceSoft,
            borderRadius:
                BorderRadius.circular(
              17,
            ),
            border: Border.all(
              color: usingGps ||
                      _selectedOrigin !=
                          null
                  ? LinkRideColors
                      .linkGreen
                      .withValues(
                      alpha: 0.28,
                    )
                  : LinkRideColors
                      .border,
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
                      LinkRideColors
                          .softGreen,
                  borderRadius:
                      BorderRadius.circular(
                    13,
                  ),
                ),
                child: Icon(
                  usingGps
                      ? Icons
                          .my_location_rounded
                      : Icons
                          .trip_origin_rounded,
                  size: 20,
                  color:
                      LinkRideColors
                          .linkGreen,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    const Text(
                      'FROM',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            FontWeight.w800,
                        letterSpacing:
                            0.9,
                        color:
                            LinkRideColors
                                .textMuted,
                      ),
                    ),

                    TextField(
                      controller:
                          _originController,
                      onChanged:
                          _onOriginChanged,
                      textInputAction:
                          TextInputAction
                              .search,
                      style:
                          const TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            LinkRideColors
                                .textPrimary,
                      ),
                      decoration:
                          InputDecoration(
                        filled: false,
                        hintText:
                            _isLoadingCurrentLocation
                                ? 'Getting current location...'
                                : usingGps
                                    ? 'Current location selected'
                                    : 'Current location or search a stop',
                        hintStyle:
                            const TextStyle(
                          fontSize: 13.5,
                          fontWeight:
                              FontWeight.w600,
                          color:
                              LinkRideColors
                                  .textSecondary,
                        ),
                        border:
                            InputBorder.none,
                        enabledBorder:
                            InputBorder.none,
                        focusedBorder:
                            InputBorder.none,
                        contentPadding:
                            const EdgeInsets
                                .only(
                          top: 3,
                          bottom: 1,
                        ),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 5),

              if (_isSearchingOrigin)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                    color:
                        LinkRideColors
                            .linkGreen,
                  ),
                )
              else
                IconButton(
                  tooltip:
                      'Use current location',
                  onPressed:
                      _isLoadingCurrentLocation
                          ? null
                          : _useCurrentLocationOrigin,
                  icon: const Icon(
                    Icons
                        .my_location_rounded,
                    size: 20,
                    color:
                        LinkRideColors
                            .linkGreen,
                  ),
                ),
            ],
          ),
        ),

        if (_originSearchError !=
            null) ...[
          const SizedBox(height: 7),
          _inlineError(
            _originSearchError!,
          ),
        ],

        if (_originSuggestions
            .isNotEmpty) ...[
          const SizedBox(height: 8),
          _suggestionPanel(
            suggestions:
                _originSuggestions,
            accent:
                LinkRideColors.linkGreen,
            onTap: _selectOrigin,
          ),
        ],
      ],
    );
  }

  // ───────────────── DESTINATION FIELD ─────────────────

  Widget _destinationAutocompleteField() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color:
                LinkRideColors.surfaceSoft,
            borderRadius:
                BorderRadius.circular(
              17,
            ),
            border: Border.all(
              color:
                  _selectedDestination !=
                          null
                      ? LinkRideColors
                          .primaryBlue
                          .withValues(
                          alpha: 0.28,
                        )
                      : LinkRideColors
                          .border,
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
                      LinkRideColors
                          .softBlue,
                  borderRadius:
                      BorderRadius.circular(
                    13,
                  ),
                ),
                child: const Icon(
                  Icons
                      .location_on_outlined,
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
                      CrossAxisAlignment
                          .start,
                  children: [
                    const Text(
                      'TO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            FontWeight.w800,
                        letterSpacing:
                            0.9,
                        color:
                            LinkRideColors
                                .textMuted,
                      ),
                    ),

                    TextField(
                      controller:
                          _destinationController,
                      onChanged:
                          _onDestinationChanged,
                      textInputAction:
                          TextInputAction
                              .search,
                      style:
                          const TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            LinkRideColors
                                .textPrimary,
                      ),
                      decoration:
                          InputDecoration(
                        filled: false,
                        hintText:
                            'Where do you want to go?',
                        hintStyle:
                            const TextStyle(
                          fontSize: 13.5,
                          fontWeight:
                              FontWeight.w600,
                          color:
                              LinkRideColors
                                  .textSecondary,
                        ),
                        border:
                            InputBorder.none,
                        enabledBorder:
                            InputBorder.none,
                        focusedBorder:
                            InputBorder.none,
                        contentPadding:
                            const EdgeInsets
                                .only(
                          top: 3,
                          bottom: 1,
                        ),
                        isDense: true,
                        suffixIconConstraints:
                            const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                        suffixIcon:
                            _destinationController
                                    .text
                                    .isNotEmpty
                                ? IconButton(
                                    tooltip:
                                        'Clear destination',
                                    onPressed:
                                        _clearDestination,
                                    padding:
                                        EdgeInsets.zero,
                                    visualDensity:
                                        VisualDensity
                                            .compact,
                                    icon:
                                        const Icon(
                                      Icons
                                          .close_rounded,
                                      size: 18,
                                      color:
                                          LinkRideColors
                                              .textMuted,
                                    ),
                                  )
                                : null,
                      ),
                    ),
                  ],
                ),
              ),

              if (_isSearchingDestination)
                const Padding(
                  padding:
                      EdgeInsets.only(
                    left: 7,
                  ),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                      color:
                          LinkRideColors
                              .primaryBlue,
                    ),
                  ),
                ),
            ],
          ),
        ),

        if (_destinationSearchError !=
            null) ...[
          const SizedBox(height: 7),
          _inlineError(
            _destinationSearchError!,
          ),
        ],

        if (_destinationSuggestions
            .isNotEmpty) ...[
          const SizedBox(height: 8),
          _suggestionPanel(
            suggestions:
                _destinationSuggestions,
            accent:
                LinkRideColors.primaryBlue,
            onTap:
                _selectDestination,
          ),
        ],
      ],
    );
  }

  Widget _suggestionPanel({
    required List<Map<String, dynamic>>
        suggestions,
    required Color accent,
    required void Function(
      Map<String, dynamic>,
    ) onTap,
  }) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: LinkRideColors.surface,
        borderRadius:
            BorderRadius.circular(
          LinkRideRadius.medium,
        ),
        border: Border.all(
          color:
              LinkRideColors.border,
        ),
        boxShadow:
            LinkRideShadows.floating,
      ),
      child: Column(
        children:
            List.generate(
          suggestions.length,
          (index) {
            final Map<String, dynamic> stop =
                suggestions[index];

            return Column(
              children: [
                _suggestionTile(
                  stop: stop,
                  accent: accent,
                  onTap: () {
                    onTap(stop);
                  },
                ),

                if (index <
                    suggestions.length - 1)
                  const Divider(
                    height: 1,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _suggestionTile({
    required Map<String, dynamic> stop,
    required Color accent,
    required VoidCallback onTap,
  }) {
    final String stopName =
        stop['stopName']
                ?.toString() ??
            'Unknown stop';

    final String stopType =
        stop['stopType']
                ?.toString() ??
            'Transport stop';

    return Material(
      color: LinkRideColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration:
                    BoxDecoration(
                  color: accent.withValues(
                    alpha: 0.09,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: Icon(
                  Icons.place_outlined,
                  size: 19,
                  color: accent,
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
                      stopName,
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

                    const SizedBox(height: 3),

                    Text(
                      stopType,
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
                    .north_west_rounded,
                size: 17,
                color:
                    LinkRideColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inlineError(
    String message,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        left: 4,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons
                .error_outline_rounded,
            size: 15,
            color:
                LinkRideColors.danger,
          ),

          const SizedBox(width: 6),

          Expanded(
            child: Text(
              message,
              style:
                  const TextStyle(
                fontSize: 11.5,
                height: 1.35,
                color:
                    LinkRideColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── LIVE TRANSPORT ─────────────────

  Widget _liveTransportUpdatesSection() {
    if (_isLoadingDisruptions) {
      return Container(
        width: double.infinity,
        height: 112,
        decoration:
            LinkRideDecorations.card(),
        child: const Center(
          child:
              CircularProgressIndicator(
            strokeWidth: 2.3,
            color:
                LinkRideColors.primaryBlue,
          ),
        ),
      );
    }

    if (_disruptionError != null) {
      return Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(16),
        decoration:
            LinkRideDecorations.card(),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration:
                  BoxDecoration(
                color:
                    LinkRideColors
                        .dangerSoft,
                borderRadius:
                    BorderRadius.circular(
                  13,
                ),
              ),
              child: const Icon(
                Icons
                    .error_outline_rounded,
                color:
                    LinkRideColors.danger,
                size: 21,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                _disruptionError!,
                style:
                    const TextStyle(
                  fontSize: 12.5,
                  height: 1.4,
                  color:
                      LinkRideColors
                          .textSecondary,
                ),
              ),
            ),

            IconButton(
              tooltip: 'Retry',
              onPressed:
                  _loadActiveDisruptions,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
            ),
          ],
        ),
      );
    }

    if (_activeDisruptions.isEmpty) {
      return _serviceUpdateCard(
        icon: Icons
            .check_circle_outline_rounded,
        service: 'Network status',
        message:
            'No active transport disruptions reported.',
        status: 'Normal',
        statusColor:
            LinkRideColors.linkGreen,
      );
    }

    final List<Map<String, dynamic>>
        visible =
        _activeDisruptions
            .take(3)
            .toList();

    return Column(
      children: [
        for (int index = 0;
            index < visible.length;
            index++) ...[
          _disruptionCard(
            visible[index],
          ),

          if (index <
              visible.length - 1)
            const SizedBox(height: 10),
        ],

        if (_activeDisruptions.length >
            3) ...[
          const SizedBox(height: 10),

          Align(
            alignment:
                Alignment.centerLeft,
            child: Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 11,
                vertical: 7,
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
              child: Text(
                '+${_activeDisruptions.length - 3} more active update'
                '${_activeDisruptions.length - 3 == 1 ? '' : 's'}',
                style:
                    const TextStyle(
                  fontSize: 11.5,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      LinkRideColors
                          .primaryBlue,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _disruptionCard(
    Map<String, dynamic> disruption,
  ) {
    final String title =
        disruption['title']
                ?.toString() ??
            'Transport disruption';

    final String description =
        disruption['description']
                ?.toString() ??
            'Service disruption reported.';

    final String severity =
        disruption['severity']
                ?.toString()
                .toUpperCase() ??
            'MEDIUM';

    final int providerId =
        _asInt(
      disruption['providerId'],
    );

    final int routeId =
        _asInt(
      disruption['routeId'],
    );

    final Color severityColor =
        _severityColor(
      severity,
    );

    final String routeLabel =
        routeId > 0
            ? '${_providerName(providerId)} • Route #$routeId'
            : _providerName(providerId);

    return _serviceUpdateCard(
      icon: _disruptionIcon(
        disruption['disruptionType']
                ?.toString() ??
            '',
      ),
      service: routeLabel,
      message:
          '$title — $description',
      status: severity,
      statusColor:
          severityColor,
    );
  }

  Widget _serviceUpdateCard({
    required IconData icon,
    required String service,
    required String message,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(15),
      decoration:
          LinkRideDecorations.card(),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration:
                BoxDecoration(
              color: statusColor
                  .withValues(
                alpha: 0.09,
              ),
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),
            child: Icon(
              icon,
              color: statusColor,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  service,
                  style:
                      const TextStyle(
                    fontSize: 13.5,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        LinkRideColors
                            .textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  message,
                  maxLines: 3,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color:
                        LinkRideColors
                            .textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration:
                BoxDecoration(
              color: statusColor
                  .withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(
                LinkRideRadius.pill,
              ),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight:
                    FontWeight.w800,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── QUICK ACCESS ─────────────────

  Widget _quickAccessCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
    VoidCallback? onTap,
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
          height: 150,
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
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration:
                        BoxDecoration(
                      color: accent
                          .withValues(
                        alpha: 0.09,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        13,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: 21,
                      color: accent,
                    ),
                  ),

                  const Spacer(),

                  const Icon(
                    Icons
                        .arrow_forward_rounded,
                    size: 18,
                    color:
                        LinkRideColors
                            .textMuted,
                  ),
                ],
              ),

              const Spacer(),

              Text(
                title,
                style:
                    const TextStyle(
                  fontSize: 14.5,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      LinkRideColors
                          .textPrimary,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
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
      ),
    );
  }

  // ───────────────── SECTION HEADER ─────────────────

  Widget _sectionHeader({
    required String title,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style:
                const TextStyle(
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

        if (actionLabel != null)
          TextButton.icon(
            onPressed: onAction,
            icon: const Icon(
              Icons.refresh_rounded,
              size: 17,
            ),
            label: Text(
              actionLabel,
              style:
                  const TextStyle(
                fontSize: 12.5,
              ),
            ),
          ),
      ],
    );
  }

  // ───────────────── HELPERS ─────────────────

  String _providerName(
    int providerId,
  ) {
    switch (providerId) {
      case 1:
        return 'Gautrain';

      case 2:
        return 'A Re Yeng';

      case 3:
        return 'Rea Vaya';

      case 4:
        return 'Metrorail Gauteng';

      case 5:
        return 'Minibus Taxi Network';

      default:
        return 'Transport Provider';
    }
  }

  Color _severityColor(
    String severity,
  ) {
    switch (severity.toUpperCase()) {
      case 'LOW':
        return LinkRideColors
            .linkGreen;

      case 'MEDIUM':
        return LinkRideColors.warning;

      case 'HIGH':
        return const Color(
          0xFFD96A1D,
        );

      case 'CRITICAL':
        return LinkRideColors.danger;

      default:
        return LinkRideColors
            .primaryBlue;
    }
  }

  IconData _disruptionIcon(
    String disruptionType,
  ) {
    switch (disruptionType
        .toUpperCase()) {
      case 'DELAY':
        return Icons.schedule_rounded;

      case 'CANCELLATION':
        return Icons.cancel_outlined;

      case 'SERVICE_SUSPENSION':
        return Icons
            .pause_circle_outline_rounded;

      case 'ROUTE_CHANGE':
        return Icons.alt_route_rounded;

      case 'STATION_CLOSURE':
        return Icons
            .location_off_outlined;

      default:
        return Icons
            .warning_amber_rounded;
    }
  }

  double? _asDouble(
    dynamic value,
  ) {
    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
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
}