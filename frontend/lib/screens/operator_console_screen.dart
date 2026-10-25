import 'package:flutter/material.dart';

import '../services/auth_storage.dart';
import '../services/disruption_service.dart';
import '../theme/link_ride_theme.dart';

class OperatorConsoleScreen extends StatefulWidget {
  final String firstName;

  const OperatorConsoleScreen({super.key, required this.firstName});

  @override
  State<OperatorConsoleScreen> createState() => _OperatorConsoleScreenState();
}

class _OperatorConsoleScreenState extends State<OperatorConsoleScreen> {
  final AuthStorage _authStorage = AuthStorage();

  final DisruptionService _disruptionService = DisruptionService();

  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _activeDisruptions = [];

  static const List<String> _disruptionTypes = [
    'DELAY',
    'CANCELLATION',
    'SERVICE_SUSPENSION',
    'ROUTE_CHANGE',
    'STATION_CLOSURE',
    'OTHER',
  ];

  static const List<String> _severities = ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'];

  @override
  void initState() {
    super.initState();
    _loadDisruptions();
  }

  Future<void> _loadDisruptions() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final String? token = await _authStorage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Your Link Ride session is no longer valid.');
      }

      final List<Map<String, dynamic>> disruptions = await _disruptionService
          .getActiveDisruptions(token: token);

      if (!mounted) {
        return;
      }

      setState(() {
        _activeDisruptions = disruptions;
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

  Future<void> _openCreateDisruption() async {
    final bool? created = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => _CreateDisruptionDialog(
        authStorage: _authStorage,
        disruptionService: _disruptionService,
      ),
    );

    if (!mounted) return;
    if (created == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disruption created successfully.')),
      );
      await _loadDisruptions();
    }
  }

  Future<void> _resolveDisruption(Map<String, dynamic> disruption) async {
    final int disruptionId = _asInt(disruption['disruptionId']);

    if (disruptionId <= 0) {
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Resolve disruption?'),
          content: Text(
            'Mark "${disruption['title'] ?? 'this disruption'}" as resolved?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Resolve'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      final String? token = await _authStorage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Your Link Ride session is no longer valid.');
      }

      await _disruptionService.resolveDisruption(
        token: token,
        disruptionId: disruptionId,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Disruption resolved.')));

      await _loadDisruptions();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LinkRideColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadDisruptions,
          color: LinkRideColors.primaryBlue,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
            children: [
              _header(),
              const SizedBox(height: 20),
              _roleBanner(),
              const SizedBox(height: 18),
              _sectionTitle(
                'Operations workspace',
                'Manage live service information using your secured operator access.',
              ),
              const SizedBox(height: 12),
              _actionCard(
                icon: Icons.add_alert_outlined,
                title: 'Create disruption',
                description: 'Publish a new operational disruption for an affected route.',
                onTap: _openCreateDisruption,
              ),
              const SizedBox(height: 12),
              _networkCard(),
              const SizedBox(height: 24),
              _activeHeader(),
              const SizedBox(height: 12),
              _activeBody(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activeHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Active disruptions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: LinkRideColors.textPrimary,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Refresh',
          onPressed: _loadDisruptions,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    );
  }

  Widget _activeBody() {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: LinkRideDecorations.card(),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: LinkRideDecorations.card(),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: LinkRideColors.danger,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: LinkRideColors.textSecondary),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: _loadDisruptions,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    if (_activeDisruptions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(22),
        decoration: LinkRideDecorations.card(),
        child: const Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 34,
              color: LinkRideColors.success,
            ),
            SizedBox(height: 10),
            Text(
              'No active disruptions',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: LinkRideColors.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'The controlled demo network currently has no unresolved service incidents.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: LinkRideColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (int index = 0; index < _activeDisruptions.length; index++) ...[
          _disruptionCard(_activeDisruptions[index]),
          if (index < _activeDisruptions.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _disruptionCard(Map<String, dynamic> disruption) {
    final String severity =
        disruption['severity']?.toString().toUpperCase() ?? 'UNKNOWN';

    final String type =
        disruption['disruptionType']?.toString().toUpperCase() ?? 'DISRUPTION';

    final int routeId = _asInt(disruption['routeId']);

    final int providerId = _asInt(disruption['providerId']);

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: LinkRideDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _severitySoftColor(severity),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: _severityColor(severity),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      disruption['title']?.toString() ?? 'Service disruption',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: LinkRideColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_displayEnum(type)} • Route #$routeId',
                      style: const TextStyle(
                        fontSize: 12,
                        color: LinkRideColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _statusChip(severity),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            disruption['description']?.toString() ?? '',
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: LinkRideColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _metaChip(Icons.route_outlined, 'Route $routeId'),
              if (providerId > 0)
                _metaChip(
                  Icons.directions_transit_outlined,
                  'Provider $providerId',
                ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: () => _resolveDisruption(disruption),
              icon: const Icon(Icons.task_alt_rounded),
              label: const Text('Resolve disruption'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _networkCard() {
    return Container(
      padding: const EdgeInsets.all(17),
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
              Icons.hub_outlined,
              color: LinkRideColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Network overview',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: LinkRideColors.textPrimary,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Provider and route overview will be enabled once a dedicated backend network endpoint is added.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: LinkRideColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: LinkRideColors.softGreen,
              borderRadius: BorderRadius.circular(LinkRideRadius.pill),
            ),
            child: const Text(
              'Planned',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: LinkRideColors.linkGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(LinkRideRadius.extraLarge),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(17),
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
              child: Icon(icon, color: LinkRideColors.primaryBlue),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: LinkRideColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: LinkRideColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: LinkRideColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Operator Console',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.7,
                  color: LinkRideColors.textPrimary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Welcome, ${widget.firstName}',
                style: const TextStyle(
                  fontSize: 14,
                  color: LinkRideColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: LinkRideColors.softBlue,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.monitor_heart_rounded,
            color: LinkRideColors.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _roleBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinkRideGradients.primary,
        borderRadius: BorderRadius.circular(LinkRideRadius.extraLarge),
        boxShadow: LinkRideShadows.elevated,
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_rounded, color: Colors.white),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OPERATOR access active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Your authenticated role can create and resolve disruptions. Backend RBAC remains the security boundary.',
                  style: TextStyle(
                    color: Colors.white,
                    height: 1.4,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: LinkRideColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            height: 1.4,
            color: LinkRideColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _statusChip(String severity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _severitySoftColor(severity),
        borderRadius: BorderRadius.circular(LinkRideRadius.pill),
      ),
      child: Text(
        severity,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: _severityColor(severity),
        ),
      ),
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: LinkRideColors.surfaceSoft,
        borderRadius: BorderRadius.circular(LinkRideRadius.pill),
        border: Border.all(color: LinkRideColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: LinkRideColors.textSecondary),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: LinkRideColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  static String _displayEnum(String value) {
    final String cleaned = value.toLowerCase().replaceAll('_', ' ');

    return cleaned
        .split(' ')
        .map(
          (String word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'CRITICAL':
        return LinkRideColors.danger;
      case 'HIGH':
        return LinkRideColors.warning;
      case 'MEDIUM':
        return LinkRideColors.primaryBlue;
      default:
        return LinkRideColors.success;
    }
  }

  Color _severitySoftColor(String severity) {
    switch (severity) {
      case 'CRITICAL':
        return LinkRideColors.dangerSoft;
      case 'HIGH':
        return LinkRideColors.warningSoft;
      case 'MEDIUM':
        return LinkRideColors.softBlue;
      default:
        return LinkRideColors.successSoft;
    }
  }
}

/// Owns its text controllers for the entire lifetime of the dialog route.
/// This prevents controllers from being disposed while the closing animation
/// still has TextFormFields mounted.
class _CreateDisruptionDialog extends StatefulWidget {
  final AuthStorage authStorage;
  final DisruptionService disruptionService;

  const _CreateDisruptionDialog({
    required this.authStorage,
    required this.disruptionService,
  });

  @override
  State<_CreateDisruptionDialog> createState() =>
      _CreateDisruptionDialogState();
}

class _CreateDisruptionDialogState extends State<_CreateDisruptionDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _routeIdController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedType = 'DELAY';
  String _selectedSeverity = 'MEDIUM';
  bool _submitting = false;

  @override
  void dispose() {
    _routeIdController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);

    try {
      final String? token = await widget.authStorage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Your Link Ride session is no longer valid.');
      }

      await widget.disruptionService.createDisruption(
        token: token,
        routeId: int.parse(_routeIdController.text.trim()),
        disruptionType: _selectedType,
        severity: _selectedSeverity,
        title: _titleController.text,
        description: _descriptionController.text,
      );

      if (!mounted) return;
      setState(() => _submitting = false);
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_submitting,
      child: AlertDialog(
        title: const Text('Create disruption'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _routeIdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Route ID',
                    helperText:
                        'Use the route ID from the current controlled dataset.',
                  ),
                  validator: (String? value) {
                    final int? routeId = int.tryParse(value?.trim() ?? '');
                    return routeId == null || routeId <= 0
                        ? 'Enter a valid route ID.'
                        : null;
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Disruption type',
                  ),
                  items: _OperatorConsoleScreenState._disruptionTypes
                      .map(
                        (String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            _OperatorConsoleScreenState._displayEnum(value),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: _submitting
                      ? null
                      : (String? value) {
                          if (value != null) {
                            setState(() => _selectedType = value);
                          }
                        },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _selectedSeverity,
                  decoration: const InputDecoration(labelText: 'Severity'),
                  items: _OperatorConsoleScreenState._severities
                      .map(
                        (String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            _OperatorConsoleScreenState._displayEnum(value),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: _submitting
                      ? null
                      : (String? value) {
                          if (value != null) {
                            setState(() => _selectedSeverity = value);
                          }
                        },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (String? value) => (value ?? '').trim().isEmpty
                      ? 'Enter a disruption title.'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                  ),
                  validator: (String? value) => (value ?? '').trim().isEmpty
                      ? 'Enter a disruption description.'
                      : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _submitting
                ? null
                : () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create'),
          ),
        ],
      ),
    );
  }
}
