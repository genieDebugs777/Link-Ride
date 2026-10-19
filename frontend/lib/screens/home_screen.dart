import 'dart:async';

import 'package:flutter/material.dart';

import '../services/auth_storage.dart';
import '../services/stop_search_service.dart';
import '../services/location_service.dart';
import '../services/journey_plan_service.dart';
import '../services/journey_preferences_service.dart';
import '../services/my_journeys_service.dart';
import '../services/ticket_service.dart';
import '../services/disruption_service.dart';
import '../services/notification_service.dart';
import 'journey_options_screen.dart';
import 'my_journeys_screen.dart';
import 'ticket_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  final String firstName;

  const HomeScreen({
    super.key,
    required this.firstName,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color primaryBlue = Color(0xFF003F73);
  static const Color linkGreen = Color(0xFF4A9B45);
  static const Color background = Color(0xFFF7F9FB);
  static const Color textPrimary = Color(0xFF17212B);
  static const Color textSecondary = Color(0xFF667085);
  static const Color cardBorder = Color(0xFFE4E9EE);

  final AuthStorage _authStorage = AuthStorage();
  final StopSearchService _stopSearchService = StopSearchService();
  final LocationService _locationService = LocationService();
  final JourneyPlanService _journeyPlanService =
    JourneyPlanService();

  final JourneyPreferencesService _journeyPreferencesService =
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
  List<Map<String, dynamic>> _activeDisruptions = [];

  int _unreadNotificationCount = 0;

  final TextEditingController _originController =
      TextEditingController();

  final TextEditingController _destinationController =
      TextEditingController();

  Timer? _originSearchDebounce;
  Timer? _destinationSearchDebounce;

  List<Map<String, dynamic>> _originSuggestions = [];

  Map<String, dynamic>? _selectedOrigin;

  bool _isSearchingOrigin = false;
  String? _originSearchError;

  List<Map<String, dynamic>> _destinationSuggestions = [];

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

  Future<void> _loadActiveDisruptions() async {
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

      final List<Map<String, dynamic>> disruptions =
          await _disruptionService.getActiveDisruptions(
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

  Future<void> _loadUnreadNotificationCount() async {
    try {
      final String? token =
          await _authStorage.getToken();

      if (token == null ||
          token.isEmpty) {
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
        _unreadNotificationCount =
            count;
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

  Future<void> _refreshHomeData() async {
    await Future.wait<void>([
      _loadCurrentTicketSummary(),
      _loadActiveDisruptions(),
      _loadUnreadNotificationCount(),
    ]);
  }

  Future<void> _loadCurrentTicketSummary() async {
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
          await _ticketService.getCurrentTicket(
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
      return 'View active ticket';
    }

    if (status == 'ISSUED') {
      return 'View ready ticket';
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

      ScaffoldMessenger.of(context).showSnackBar(
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You do not have a current ticket.',
          ),
        ),
      );
      return;
    }

    final List<Map<String, dynamic>> journeys =
        await _myJourneysService.getMyJourneys(
      token: token,
    );

    if (!mounted) {
      return;
    }

    final int journeyId =
        _asInt(ticket['journeyId']);

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
          journey: journey!,
          ticket: ticket,
        ),
      ),
    );

    if (mounted) {
      await _loadCurrentTicketSummary();
    }
  }

  @override
  void dispose() {
    _originSearchDebounce?.cancel();
    _destinationSearchDebounce?.cancel();

    _originController.dispose();
    _destinationController.dispose();

    super.dispose();
  }

  // ───────────────── ORIGIN SEARCH ─────────────────

  void _onOriginChanged(String value) {
    _originSearchDebounce?.cancel();

    final String query = value.trim();

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
      const Duration(milliseconds: 350),
      () {
        _searchOrigin(query);
      },
    );
  }

  Future<void> _searchOrigin(String query) async {
    try {
      final String? token =
          await _authStorage.getToken();

      if (token == null ||
          token.isEmpty) {
        throw Exception(
          'No active Link Ride session found.',
        );
      }

      final List<Map<String, dynamic>> results =
          await _stopSearchService.searchStops(
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
        stop['stopName']?.toString() ?? '';

    setState(() {
      _selectedOrigin = stop;

      _originController.text = stopName;

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

  void _onDestinationChanged(String value) {
    _destinationSearchDebounce?.cancel();

    final String query = value.trim();

    setState(() {
      _selectedDestination = null;
      _destinationSearchError = null;
    });

    if (query.length < 2) {
      setState(() {
        _destinationSuggestions = [];
        _isSearchingDestination = false;
      });

      return;
    }

    setState(() {
      _isSearchingDestination = true;
    });

    _destinationSearchDebounce = Timer(
      const Duration(milliseconds: 350),
      () {
        _searchDestination(query);
      },
    );
  }

  Future<void> _searchDestination(String query) async {
    try {
      final String? token = await _authStorage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'No active Link Ride session found.',
        );
      }

      final List<Map<String, dynamic>> results =
          await _stopSearchService.searchStops(
        query: query,
        token: token,
      );

      if (!mounted) {
        return;
      }

      // Ignore an old response if the commuter has already typed
      // something different.
      if (_destinationController.text.trim() != query) {
        return;
      }

      setState(() {
        _destinationSuggestions = results;
        _isSearchingDestination = false;
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
        _isSearchingDestination = false;
        _destinationSearchError =
            'Unable to search destinations right now.';
      });
    }
  }

  void _selectDestination(
    Map<String, dynamic> stop,
  ) {
    final String stopName =
        stop['stopName']?.toString() ?? '';

    setState(() {
      _selectedDestination = stop;

      _destinationController.text = stopName;

      _destinationController.selection =
          TextSelection.collapsed(
        offset: stopName.length,
      );

      _destinationSuggestions = [];
      _destinationSearchError = null;
      _isSearchingDestination = false;
    });

    FocusScope.of(context).unfocus();
  }

  void _clearDestination() {
    _destinationSearchDebounce?.cancel();

    setState(() {
      _destinationController.clear();
      _selectedDestination = null;
      _destinationSuggestions = [];
      _destinationSearchError = null;
      _isSearchingDestination = false;
    });
  }

  // ───────────────── CURRENT LOCATION ─────────────────

  Future<void> _loadCurrentLocation() async {
    if (_isLoadingCurrentLocation) {
      return;
    }

    setState(() {
      _isLoadingCurrentLocation = true;
      _currentLocationError = null;
    });

    try {
      final position =
          await _locationService.getCurrentPosition();

      if (!mounted) {
        return;
      }

      setState(() {
        _currentLatitude = position.latitude;
        _currentLongitude = position.longitude;

        _selectedOrigin = null;
        _originController.clear();
        _originSuggestions = [];
        _originSearchError = null;
        _isSearchingOrigin = false;

        _isLoadingCurrentLocation = false;
        _currentLocationError = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingCurrentLocation = false;
        _currentLocationError =
            'Location unavailable - tap to retry';
      });
    }
  }

  Future<void> _planJourney() async {
    if (_isPlanningJourney) {
      return;
    }

    /*
    * Destination must come from autocomplete.
    *
    * Typed text alone is not enough because Link Ride
    * needs the controlled seed stopId.
    */
    if (_selectedDestination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The selected origin stop does not have valid coordinates.',
            ),
          ),
        );

        return;
      }
    } else {
      /*
       * No manual origin was selected, so keep the
       * existing device-location behaviour.
       */
      if (_currentLatitude == null ||
          _currentLongitude == null) {
        await _loadCurrentLocation();

        if (!mounted) {
          return;
        }
      }

      if (_currentLatitude == null ||
          _currentLongitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
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
                rawStopId?.toString() ?? '',
              );

    if (destinationStopId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
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

      final Map<String, dynamic> preferences =
          await _journeyPreferencesService.getPreferences();

      final List<Map<String, dynamic>> options =
          await _journeyPlanService.planJourney(
        originLatitude: originLatitude!,
        originLongitude: originLongitude!,
        destinationStopId: destinationStopId,
        token: token,
        priority:
            preferences['priority'] as String,
        gautrainSelected:
            preferences['gautrainSelected'] as bool,
        metrorailSelected:
            preferences['metrorailSelected'] as bool,
        busSelected:
            preferences['busSelected'] as bool,
        taxiSelected:
            preferences['taxiSelected'] as bool,
        preferFewerTransfers:
            preferences['preferFewerTransfers'] as bool,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isPlanningJourney = false;
      });

      if (options.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No sensible journey is available within '
              'the current Link Ride prototype network.',
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
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isPlanningJourney = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to plan your journey right now.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      body: SafeArea(
        bottom: false,

        child: RefreshIndicator(
          onRefresh: _refreshHomeData,

          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),

            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,

            padding: const EdgeInsets.fromLTRB(
            22,
            10,
            22,
            24,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // ───────────────── HEADER ─────────────────

              SizedBox(
                height: 70,

                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.center,

                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: [
                    Image.asset(
                      'assets/link_ride_header_logo.png',
                      width: 165,
                      fit: BoxFit.contain,
                    ),

                    Stack(
                      clipBehavior: Clip.none,

                      children: [
                        Container(
                          width: 48,
                          height: 48,

                          decoration: BoxDecoration(
                            color: Colors.white,

                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),

                            border: Border.all(
                              color: cardBorder,
                            ),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(
                                  alpha: 0.035,
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

                          child: IconButton(
                            onPressed: _openNotifications,

                            icon: const Icon(
                              Icons
                                  .notifications_none_rounded,

                              color: primaryBlue,

                              size: 25,
                            ),
                          ),
                        ),

                        if (_unreadNotificationCount >
                            0)
                          Positioned(
                            right: -2,
                            top: -2,

                            child: Container(
                              constraints:
                                  const BoxConstraints(
                                minWidth: 19,
                                minHeight: 19,
                              ),

                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),

                              alignment:
                                  Alignment.center,

                              decoration:
                                  const BoxDecoration(
                                color: linkGreen,

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

                                  fontSize: 10,

                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 13),

              // ───────────────── GREETING ─────────────────

              Text(
                'Welcome, ${widget.firstName} 👋',

                style: const TextStyle(
                  fontSize: 26,

                  fontWeight:
                      FontWeight.w700,

                  color: linkGreen,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Where are you going?',

                style: TextStyle(
                  fontSize: 22,

                  fontWeight:
                      FontWeight.w800,

                  letterSpacing: -0.5,

                  color: primaryBlue,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Plan your journey across connected transport services.',

                style: TextStyle(
                  fontSize: 14,

                  height: 1.4,

                  color: textSecondary,
                ),
              ),

              const SizedBox(height: 20),

              // ───────────────── JOURNEY PLANNER ─────────────────

              Container(
                padding:
                    const EdgeInsets.all(
                  18,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(
                    22,
                  ),

                  border: Border.all(
                    color: cardBorder,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color:
                          const Color(
                        0xFF003F73,
                      ).withValues(
                        alpha: 0.045,
                      ),

                      blurRadius: 22,

                      offset:
                          const Offset(
                        0,
                        8,
                      ),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    // ───────── FROM / CURRENT LOCATION OR MANUAL STOP ─────────

                    _originAutocompleteField(),

                    Padding(
                      padding:
                          const EdgeInsets.only(
                        left: 20,
                      ),

                      child: Row(
                        children: [
                          Container(
                            width: 2,

                            height: 22,

                            color:
                                const Color(
                              0xFFD9E1E8,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ───────── TO / AUTOCOMPLETE ─────────

                    _destinationAutocompleteField(),

                    const SizedBox(
                      height: 17,
                    ),

                    SizedBox(
                      width:
                          double.infinity,

                      height: 52,

                      child:
                          ElevatedButton(
                        onPressed:
                            _isPlanningJourney ? null : _planJourney,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              primaryBlue.withValues(
                            alpha: 0.65,
                          ),
                          disabledForegroundColor:
                              Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),
                          ),
                        ),

                        child: _isPlanningJourney
                            ? const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Finding journeys...',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                                ],
                              )
                            : const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.route_rounded,
                                    size: 20,
                                  ),
                                  SizedBox(width: 9),
                                  Text(
                                    'Find Journey',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                  ),
                                ],
                              ),
                      )
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              // ───────────────── LIVE UPDATES ─────────────────

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Live Transport Updates',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed:
                        _isLoadingDisruptions
                            ? null
                            : _loadActiveDisruptions,
                    style: TextButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Refresh',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 12,
              ),

              _liveTransportUpdatesSection(),

              const SizedBox(
                height: 24,
              ),

              // ───────────────── QUICK ACCESS ─────────────────

              const Text(
                'Quick Access',

                style: TextStyle(
                  fontSize: 18,

                  fontWeight:
                      FontWeight.w800,

                  color:
                      textPrimary,
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              Row(
                children: [
                  Expanded(
                    child:
                        _quickAccessCard(
                      icon: Icons
                          .confirmation_number_outlined,

                      title:
                          'My Ticket',

                      subtitle:
                          _myTicketSubtitle,
                      onTap:
                          _openCurrentTicket,
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: _quickAccessCard(
                      icon: Icons.history_rounded,
                      title: 'My Journeys',
                      subtitle: 'Recent trips',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const MyJourneysScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 14,
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  // ───────────────── ORIGIN AUTOCOMPLETE ─────────────────

  Widget _originAutocompleteField() {
    final bool usingManualOrigin =
        _selectedOrigin != null ||
            _originController.text.isNotEmpty;

    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius:
                BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration:
                    BoxDecoration(
                  color: linkGreen
                      .withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(12),
                ),
                child: Icon(
                  usingManualOrigin
                      ? Icons
                          .place_outlined
                      : Icons
                          .my_location_rounded,
                  size: 20,
                  color: linkGreen,
                ),
              ),

              const SizedBox(width: 13),

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
                            FontWeight.w700,
                        letterSpacing: 0.8,
                        color:
                            textSecondary,
                      ),
                    ),

                    TextField(
                      controller:
                          _originController,
                      onChanged:
                          _onOriginChanged,
                      textInputAction:
                          TextInputAction.search,
                      style:
                          const TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w600,
                        color: textPrimary,
                      ),
                      decoration:
                          InputDecoration(
                        hintText:
                            _isLoadingCurrentLocation
                                ? 'Getting current location...'
                                : _currentLatitude != null &&
                                        _currentLongitude != null
                                    ? 'Current location selected'
                                    : 'Current location or search a stop',
                        hintStyle:
                            const TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w600,
                          color:
                              textSecondary,
                        ),
                        border:
                            InputBorder.none,
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.only(
                          top: 3,
                          bottom: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_isSearchingOrigin)
                const Padding(
                  padding:
                      EdgeInsets.only(
                    left: 8,
                  ),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                      color: linkGreen,
                    ),
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
                  visualDensity:
                      VisualDensity.compact,
                  icon: const Icon(
                    Icons
                        .my_location_rounded,
                    size: 20,
                    color: linkGreen,
                  ),
                ),
            ],
          ),
        ),

        if (_originSearchError !=
            null) ...[
          const SizedBox(height: 7),
          Align(
            alignment:
                Alignment.centerLeft,
            child: Text(
              _originSearchError!,
              style:
                  const TextStyle(
                fontSize: 12,
                height: 1.35,
                color:
                    Color(0xFFD64545),
              ),
            ),
          ),
        ],

        if (_originSuggestions
            .isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width:
                double.infinity,
            clipBehavior:
                Clip.antiAlias,
            decoration:
                BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius
                      .circular(16),
              border:
                  Border.all(
                color: cardBorder,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black
                          .withValues(
                    alpha: 0.05,
                  ),
                  blurRadius: 14,
                  offset:
                      const Offset(
                    0,
                    6,
                  ),
                ),
              ],
            ),
            child: Column(
              children:
                  List.generate(
                _originSuggestions
                    .length,
                (index) {
                  final Map<String,
                          dynamic>
                      stop =
                      _originSuggestions[
                          index];

                  return Column(
                    children: [
                      _originSuggestionTile(
                        stop,
                      ),
                      if (index <
                          _originSuggestions
                                  .length -
                              1)
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color:
                              cardBorder,
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _originSuggestionTile(
    Map<String, dynamic> stop,
  ) {
    final String stopName =
        stop['stopName']
                ?.toString() ??
            'Unknown stop';

    final String stopType =
        stop['stopType']
                ?.toString() ??
            'Transport stop';

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          _selectOrigin(stop);
        },
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFEAF5EA,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(11),
                ),
                child:
                    const Icon(
                  Icons
                      .place_outlined,
                  size: 19,
                  color: linkGreen,
                ),
              ),
              const SizedBox(
                width: 11,
              ),
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
                            FontWeight
                                .w700,
                        color:
                            textPrimary,
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      stopType,
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
              const Icon(
                Icons
                    .north_west_rounded,
                size: 17,
                color:
                    Color(
                  0xFF98A2B3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────── DESTINATION AUTOCOMPLETE ─────────────────

  Widget _destinationAutocompleteField() {
    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets
                  .symmetric(
            horizontal: 14,
            vertical: 10,
          ),

          decoration:
              BoxDecoration(
            color: background,

            borderRadius:
                BorderRadius
                    .circular(
              16,
            ),
          ),

          child: Row(
            children: [
              Container(
                width: 38,

                height: 38,

                decoration:
                    BoxDecoration(
                  color:
                      primaryBlue
                          .withValues(
                    alpha: 0.10,
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
                      .location_on_outlined,

                  size: 20,

                  color:
                      primaryBlue,
                ),
              ),

              const SizedBox(
                width: 13,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    const Text(
                      'TO',

                      style:
                          TextStyle(
                        fontSize: 10,

                        fontWeight:
                            FontWeight
                                .w700,

                        letterSpacing:
                            0.8,

                        color:
                            textSecondary,
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
                            FontWeight
                                .w600,

                        color:
                            textPrimary,
                      ),

                      decoration:
                          InputDecoration(
                        hintText:
                            'Where do you want to go?',

                        hintStyle:
                            const TextStyle(
                          fontSize:
                              14,

                          fontWeight:
                              FontWeight
                                  .w600,

                          color:
                              textSecondary,
                        ),

                        border:
                            InputBorder.none,

                        isDense: true,

                        contentPadding:
                            const EdgeInsets
                                .only(
                          top: 3,
                          bottom: 2,
                        ),

                        suffixIconConstraints:
                            const BoxConstraints(
                          minWidth:
                              28,

                          minHeight:
                              28,
                        ),

                        suffixIcon:
                            _destinationController
                                    .text
                                    .isNotEmpty
                                ? IconButton(
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

                                      size:
                                          18,

                                      color:
                                          Color(
                                        0xFF98A2B3,
                                      ),
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
                    left: 8,
                  ),

                  child:
                      SizedBox(
                    width: 18,

                    height: 18,

                    child:
                        CircularProgressIndicator(
                      strokeWidth:
                          2,

                      color:
                          primaryBlue,
                    ),
                  ),
                ),
            ],
          ),
        ),

        if (_destinationSearchError !=
            null) ...[
          const SizedBox(
            height: 7,
          ),

          Align(
            alignment:
                Alignment.centerLeft,

            child: Text(
              _destinationSearchError!,

              style:
                  const TextStyle(
                fontSize: 12,

                height: 1.35,

                color:
                    Color(
                  0xFFD64545,
                ),
              ),
            ),
          ),
        ],

        if (_destinationSuggestions
            .isNotEmpty) ...[
          const SizedBox(
            height: 8,
          ),

          Container(
            width:
                double.infinity,

            clipBehavior:
                Clip.antiAlias,

            decoration:
                BoxDecoration(
              color:
                  Colors.white,

              borderRadius:
                  BorderRadius
                      .circular(
                16,
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
                    alpha:
                        0.05,
                  ),

                  blurRadius:
                      14,

                  offset:
                      const Offset(
                    0,
                    6,
                  ),
                ),
              ],
            ),

            child: Column(
              children:
                  List.generate(
                _destinationSuggestions
                    .length,

                (index) {
                  final Map<String,
                          dynamic>
                      stop =
                      _destinationSuggestions[
                          index];

                  return Column(
                    children: [
                      _destinationSuggestionTile(
                        stop,
                      ),

                      if (index <
                          _destinationSuggestions
                                  .length -
                              1)
                        const Divider(
                          height: 1,

                          thickness:
                              1,

                          color:
                              cardBorder,
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _destinationSuggestionTile(
    Map<String, dynamic> stop,
  ) {
    final String stopName =
        stop['stopName']?.toString() ??
            'Unknown stop';

    final String stopType =
        stop['stopType']?.toString() ??
            'Transport stop';

    return Material(
      color: Colors.white,

      child: InkWell(
        onTap: () {
          _selectDestination(
            stop,
          );
        },

        child: Padding(
          padding:
              const EdgeInsets
                  .symmetric(
            horizontal: 14,
            vertical: 12,
          ),

          child: Row(
            children: [
              Container(
                width: 36,

                height: 36,

                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFEAF3F8,
                  ),

                  borderRadius:
                      BorderRadius
                          .circular(
                    11,
                  ),
                ),

                child:
                    const Icon(
                  Icons
                      .place_outlined,

                  size: 19,

                  color:
                      primaryBlue,
                ),
              ),

              const SizedBox(
                width: 11,
              ),

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
                        fontSize:
                            13.5,

                        fontWeight:
                            FontWeight
                                .w700,

                        color:
                            textPrimary,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      stopType,

                      style:
                          const TextStyle(
                        fontSize:
                            11.5,

                        color:
                            textSecondary,
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
                    Color(
                  0xFF98A2B3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _liveTransportUpdatesSection() {
    if (_isLoadingDisruptions) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: cardBorder,
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: primaryBlue,
          ),
        ),
      );
    }

    if (_disruptionError != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: cardBorder,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: primaryBlue,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _disruptionError!,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: textSecondary,
                ),
              ),
            ),
            IconButton(
              onPressed: _loadActiveDisruptions,
              icon: const Icon(
                Icons.refresh_rounded,
                color: primaryBlue,
              ),
            ),
          ],
        ),
      );
    }

    if (_activeDisruptions.isEmpty) {
      return _serviceUpdateCard(
        icon: Icons.check_circle_outline_rounded,
        service: 'Network status',
        message:
            'No active transport disruptions reported.',
        status: 'Normal',
        statusColor: linkGreen,
      );
    }

    final List<Map<String, dynamic>> visible =
        _activeDisruptions.take(3).toList();

    return Column(
      children: [
        for (int index = 0;
            index < visible.length;
            index++) ...[
          _disruptionCard(
            visible[index],
          ),
          if (index < visible.length - 1)
            const SizedBox(height: 10),
        ],
        if (_activeDisruptions.length > 3) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '+${_activeDisruptions.length - 3} more active update'
              '${_activeDisruptions.length - 3 == 1 ? '' : 's'}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: textSecondary,
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
        disruption['title']?.toString() ??
            'Transport disruption';

    final String description =
        disruption['description']?.toString() ??
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

    return _serviceUpdateCard(
      icon: _disruptionIcon(
        disruption['disruptionType']
                ?.toString() ??
            '',
      ),
      service:
          '${_providerName(providerId)} • Route #$routeId',
      message:
          '$title — $description',
      status: severity,
      statusColor: severityColor,
    );
  }

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
        return linkGreen;
      case 'MEDIUM':
        return const Color(
          0xFFE28A19,
        );
      case 'HIGH':
        return const Color(
          0xFFD96A1D,
        );
      case 'CRITICAL':
        return const Color(
          0xFFD64545,
        );
      default:
        return primaryBlue;
    }
  }

  IconData _disruptionIcon(
    String disruptionType,
  ) {
    switch (disruptionType.toUpperCase()) {
      case 'DELAY':
        return Icons.schedule_rounded;
      case 'CANCELLATION':
        return Icons.cancel_outlined;
      case 'SERVICE_SUSPENSION':
        return Icons.pause_circle_outline_rounded;
      case 'ROUTE_CHANGE':
        return Icons.alt_route_rounded;
      case 'STATION_CLOSURE':
        return Icons.location_off_outlined;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  // ───────────────── LIVE UPDATE CARD ─────────────────

  Widget _serviceUpdateCard({
    required IconData icon,
    required String service,
    required String message,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(
        15,
      ),

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          18,
        ),

        border: Border.all(
          color: cardBorder,
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black
                    .withValues(
              alpha: 0.018,
            ),

            blurRadius: 10,

            offset:
                const Offset(
              0,
              3,
            ),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 45,

            height: 45,

            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFFEAF3F8,
              ),

              borderRadius:
                  BorderRadius
                      .circular(
                14,
              ),
            ),

            child: Icon(
              icon,

              color:
                  primaryBlue,

              size: 23,
            ),
          ),

          const SizedBox(
            width: 13,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                Text(
                  service,

                  style:
                      const TextStyle(
                    fontSize: 14,

                    fontWeight:
                        FontWeight
                            .w700,

                    color:
                        textPrimary,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  message,

                  style:
                      const TextStyle(
                    fontSize: 12,

                    color:
                        textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 9,
              vertical: 6,
            ),

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
                20,
              ),
            ),

            child: Text(
              status,

              style: TextStyle(
                fontSize: 11,

                fontWeight:
                    FontWeight
                        .w700,

                color:
                    statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── QUICK ACCESS CARD ─────────────────

  Widget _quickAccessCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        borderRadius:
            BorderRadius.circular(
          18,
        ),

        child: Ink(
          padding:
              const EdgeInsets
                  .all(
            16,
          ),

          decoration:
              BoxDecoration(
            color: Colors.white,

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
                  alpha:
                      0.018,
                ),

                blurRadius:
                    10,

                offset:
                    const Offset(
                  0,
                  3,
                ),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,

            children: [
              Container(
                width: 42,

                height: 42,

                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFEAF3F8,
                  ),

                  borderRadius:
                      BorderRadius
                          .circular(
                    13,
                  ),
                ),

                child: Icon(
                  icon,

                  size: 22,

                  color:
                      primaryBlue,
                ),
              ),

              const SizedBox(
                height: 13,
              ),

              Text(
                title,

                style:
                    const TextStyle(
                  fontSize: 14,

                  fontWeight:
                      FontWeight
                          .w700,

                  color:
                      textPrimary,
                ),
              ),

              const SizedBox(
                height: 3,
              ),

              Text(
                subtitle,

                style:
                    const TextStyle(
                  fontSize: 11,

                  color:
                      textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

    return double.tryParse(
      value?.toString() ?? '',
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