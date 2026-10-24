import 'package:flutter/material.dart';

import '../services/auth_storage.dart';
import '../services/network_admin_service.dart';
import '../theme/link_ride_theme.dart';

class NetworkAdminScreen extends StatefulWidget {
  const NetworkAdminScreen({super.key});

  @override
  State<NetworkAdminScreen> createState() => _NetworkAdminScreenState();
}

class _NetworkAdminScreenState extends State<NetworkAdminScreen> {
  final AuthStorage _authStorage = AuthStorage();
  final NetworkAdminService _networkAdminService = NetworkAdminService();

  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _providers = [];
  List<Map<String, dynamic>> _routes = [];

  @override
  void initState() {
    super.initState();
    _loadNetwork();
  }

  Future<void> _loadNetwork() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String? token = await _authStorage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Your Link Ride session is no longer valid.');
      }

      final List<dynamic> results = await Future.wait([
        _networkAdminService.getProviders(token: token),
        _networkAdminService.getRoutes(token: token),
      ]);

      final List<Map<String, dynamic>> providers =
          List<Map<String, dynamic>>.from(results[0] as List);

      final List<Map<String, dynamic>> routes = List<Map<String, dynamic>>.from(
        results[1] as List,
      );

      providers.sort(
        (a, b) => _asInt(a['providerId']).compareTo(_asInt(b['providerId'])),
      );

      routes.sort(
        (a, b) => _asInt(a['routeId']).compareTo(_asInt(b['routeId'])),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _providers = providers;
        _routes = routes;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LinkRideColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: LinkRideColors.primaryBlue,
          ),
        ),
        title: const Text(
          'Providers & Routes',
          style: TextStyle(
            color: LinkRideColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadNetwork,
            tooltip: 'Refresh network data',
            icon: const Icon(
              Icons.refresh_rounded,
              color: LinkRideColors.primaryBlue,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNetwork,
        color: LinkRideColors.primaryBlue,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _providers.isEmpty && _routes.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: const [
          SizedBox(height: 90),
          Center(
            child: CircularProgressIndicator(color: LinkRideColors.primaryBlue),
          ),
          SizedBox(height: 16),
          Center(
            child: Text(
              'Loading providers and routes...',
              style: TextStyle(
                color: LinkRideColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    if (_errorMessage != null && _providers.isEmpty && _routes.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          _summaryCard(),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: LinkRideDecorations.card(),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.redAccent,
                  size: 36,
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: LinkRideColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: _loadNetwork,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try again'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      children: [
        _summaryCard(),
        const SizedBox(height: 20),
        const Text(
          'Transport providers',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: LinkRideColors.textPrimary,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Controlled provider records used by the Link Ride academic prototype.',
          style: TextStyle(
            fontSize: 12.5,
            height: 1.4,
            color: LinkRideColors.textSecondary,
          ),
        ),
        const SizedBox(height: 14),
        if (_providers.isEmpty)
          _emptyCard(
            icon: Icons.business_outlined,
            message: 'No transport providers were returned.',
          )
        else
          ..._providers.map(
            (provider) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _providerCard(provider),
            ),
          ),
        const SizedBox(height: 10),
        const Text(
          'Routes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: LinkRideColors.textPrimary,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Routes currently represented in the controlled interoperability dataset.',
          style: TextStyle(
            fontSize: 12.5,
            height: 1.4,
            color: LinkRideColors.textSecondary,
          ),
        ),
        const SizedBox(height: 14),
        if (_routes.isEmpty)
          _emptyCard(
            icon: Icons.route_outlined,
            message: 'No routes were returned.',
          )
        else
          ..._routes.map(
            (route) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _routeCard(route),
            ),
          ),
      ],
    );
  }

  Widget _summaryCard() {
    final int activeProviders = _providers.where((provider) {
      return _text(provider['providerStatus']).toUpperCase() == 'ACTIVE';
    }).length;

    final int activeRoutes = _routes.where((route) {
      return _text(route['routeStatus']).toUpperCase() == 'ACTIVE';
    }).length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinkRideGradients.primary,
        borderRadius: BorderRadius.circular(LinkRideRadius.extraLarge),
        boxShadow: LinkRideShadows.elevated,
      ),
      child: Row(
        children: [
          const Icon(Icons.hub_outlined, color: Colors.white, size: 29),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_providers.length} providers • ${_routes.length} routes',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$activeProviders active providers • $activeRoutes active routes',
                  style: const TextStyle(color: Colors.white, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _providerCard(Map<String, dynamic> provider) {
    final int providerId = _asInt(provider['providerId']);
    final String name = _text(provider['providerName']);
    final String type = _text(provider['providerType']).toUpperCase();
    final String status = _text(provider['providerStatus']).toUpperCase();

    final int routeCount = _routes.where((route) {
      return _asInt(route['providerId']) == providerId;
    }).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: LinkRideDecorations.card(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: LinkRideColors.softGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.directions_transit_rounded,
              color: LinkRideColors.linkGreen,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name.isEmpty ? 'Unnamed provider' : name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: LinkRideColors.textPrimary,
                        ),
                      ),
                    ),
                    _statusPill(status),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _pill(
                      type.isEmpty ? 'UNKNOWN' : type,
                      LinkRideColors.primaryBlue,
                      LinkRideColors.softBlue,
                    ),
                    _pill(
                      'Provider #$providerId',
                      LinkRideColors.textSecondary,
                      LinkRideColors.surfaceSoft,
                    ),
                    _pill(
                      '$routeCount route${routeCount == 1 ? '' : 's'}',
                      LinkRideColors.textSecondary,
                      LinkRideColors.surfaceSoft,
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

  Widget _routeCard(Map<String, dynamic> route) {
    final int routeId = _asInt(route['routeId']);
    final int providerId = _asInt(route['providerId']);
    final String name = _text(route['routeName']);
    final String mode = _text(route['transportMode']).toUpperCase();
    final String status = _text(route['routeStatus']).toUpperCase();

    final String providerName = _providerName(providerId);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: LinkRideDecorations.card(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: LinkRideColors.softBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.route_rounded,
              color: LinkRideColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name.isEmpty ? 'Unnamed route' : name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: LinkRideColors.textPrimary,
                        ),
                      ),
                    ),
                    _statusPill(status),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  providerName,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: LinkRideColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _pill(
                      mode.isEmpty ? 'UNKNOWN' : mode,
                      LinkRideColors.primaryBlue,
                      LinkRideColors.softBlue,
                    ),
                    _pill(
                      'Route #$routeId',
                      LinkRideColors.textSecondary,
                      LinkRideColors.surfaceSoft,
                    ),
                    _pill(
                      'Provider #$providerId',
                      LinkRideColors.textSecondary,
                      LinkRideColors.surfaceSoft,
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

  Widget _statusPill(String status) {
    final bool active = status == 'ACTIVE';

    return _pill(
      status.isEmpty ? 'UNKNOWN' : status,
      active ? LinkRideColors.linkGreen : LinkRideColors.textSecondary,
      active ? LinkRideColors.softGreen : LinkRideColors.surfaceSoft,
    );
  }

  Widget _emptyCard({required IconData icon, required String message}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: LinkRideDecorations.card(),
      child: Column(
        children: [
          Icon(icon, size: 34, color: LinkRideColors.textSecondary),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: LinkRideColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, Color foreground, Color background) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(LinkRideRadius.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: foreground,
        ),
      ),
    );
  }

  String _providerName(int providerId) {
    for (final provider in _providers) {
      if (_asInt(provider['providerId']) == providerId) {
        final String name = _text(provider['providerName']);
        if (name.isNotEmpty) {
          return name;
        }
      }
    }

    return 'Provider #$providerId';
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _text(dynamic value) {
    return value?.toString().trim() ?? '';
  }
}
