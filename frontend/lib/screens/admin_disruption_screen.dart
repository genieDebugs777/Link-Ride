import 'package:flutter/material.dart';

import '../services/auth_storage.dart';
import '../services/disruption_service.dart';
import '../theme/link_ride_theme.dart';

class AdminDisruptionScreen extends StatefulWidget {
  const AdminDisruptionScreen({super.key});

  @override
  State<AdminDisruptionScreen> createState() => _AdminDisruptionScreenState();
}

class _AdminDisruptionScreenState extends State<AdminDisruptionScreen> {
  final AuthStorage _authStorage = AuthStorage();
  final DisruptionService _disruptionService = DisruptionService();

  bool _isLoading = true;
  bool _isCreating = false;
  int? _resolvingDisruptionId;
  String? _errorMessage;
  List<Map<String, dynamic>> _disruptions = [];

  @override
  void initState() {
    super.initState();
    _loadDisruptions();
  }

  Future<void> _loadDisruptions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String? token = await _authStorage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Your Link Ride session is no longer valid.');
      }

      final List<Map<String, dynamic>> disruptions = await _disruptionService
          .getActiveDisruptions(token: token);

      disruptions.sort(
        (a, b) =>
            _asInt(b['disruptionId']).compareTo(_asInt(a['disruptionId'])),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _disruptions = disruptions;
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
    final TextEditingController routeController = TextEditingController();
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    String type = 'DELAY';
    String severity = 'MEDIUM';

    final Map<String, dynamic>?
    result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create disruption',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: LinkRideColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Publish an operational incident to the controlled Link Ride network.',
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: LinkRideColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: routeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Route ID',
                        hintText: 'e.g. 5',
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: type,
                      decoration: const InputDecoration(
                        labelText: 'Disruption type',
                      ),
                      items:
                          const [
                                'DELAY',
                                'CANCELLATION',
                                'SERVICE_SUSPENSION',
                                'ROUTE_CHANGE',
                                'STATION_CLOSURE',
                                'OTHER',
                              ]
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() {
                            type = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: severity,
                      decoration: const InputDecoration(labelText: 'Severity'),
                      items: const ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL']
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() {
                            severity = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'Short incident title',
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: descriptionController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Describe the operational impact',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              final int? routeId = int.tryParse(
                                routeController.text.trim(),
                              );

                              final String title = titleController.text.trim();
                              final String description = descriptionController
                                  .text
                                  .trim();

                              if (routeId == null ||
                                  routeId <= 0 ||
                                  title.isEmpty ||
                                  description.isEmpty) {
                                ScaffoldMessenger.of(sheetContext).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Route ID, title and description are required.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              Navigator.pop(sheetContext, {
                                'routeId': routeId,
                                'disruptionType': type,
                                'severity': severity,
                                'title': title,
                                'description': description,
                              });
                            },
                            icon: const Icon(Icons.add_alert_outlined),
                            label: const Text('Create'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    routeController.dispose();
    titleController.dispose();
    descriptionController.dispose();

    if (result == null || !mounted) {
      return;
    }

    await _createDisruption(result);
  }

  Future<void> _createDisruption(Map<String, dynamic> values) async {
    setState(() {
      _isCreating = true;
    });

    try {
      final String? token = await _authStorage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Your Link Ride session is no longer valid.');
      }

      await _disruptionService.createDisruption(
        token: token,
        routeId: values['routeId'] as int,
        disruptionType: values['disruptionType'] as String,
        severity: values['severity'] as String,
        title: values['title'] as String,
        description: values['description'] as String,
      );

      await _loadDisruptions();

      if (!mounted) {
        return;
      }

      setState(() {
        _isCreating = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Disruption created successfully.')),
        );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isCreating = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
    }
  }

  Future<void> _resolveDisruption(Map<String, dynamic> disruption) async {
    final int disruptionId = _asInt(disruption['disruptionId']);
    final String title = _text(disruption['title']);

    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Resolve disruption?'),
              content: Text(
                title.isEmpty
                    ? 'This incident will be marked as resolved and removed from the active list.'
                    : '"$title" will be marked as resolved and removed from the active list.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Resolve'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed || !mounted) {
      return;
    }

    setState(() {
      _resolvingDisruptionId = disruptionId;
    });

    try {
      final String? token = await _authStorage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Your Link Ride session is no longer valid.');
      }

      await _disruptionService.resolveDisruption(
        token: token,
        disruptionId: disruptionId,
      );

      await _loadDisruptions();

      if (!mounted) {
        return;
      }

      setState(() {
        _resolvingDisruptionId = null;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Disruption resolved.')));
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _resolvingDisruptionId = null;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
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
          'Disruption Administration',
          style: TextStyle(
            color: LinkRideColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading || _isCreating ? null : _loadDisruptions,
            tooltip: 'Refresh disruptions',
            icon: const Icon(
              Icons.refresh_rounded,
              color: LinkRideColors.primaryBlue,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isCreating ? null : _openCreateDisruption,
        icon: _isCreating
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.add_alert_outlined),
        label: Text(_isCreating ? 'Creating...' : 'Create disruption'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDisruptions,
        color: LinkRideColors.primaryBlue,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _disruptions.isEmpty) {
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
              'Loading active disruptions...',
              style: TextStyle(
                color: LinkRideColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    if (_errorMessage != null && _disruptions.isEmpty) {
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
                  onPressed: _loadDisruptions,
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
      children: [
        _summaryCard(),
        const SizedBox(height: 18),
        const Text(
          'Active disruptions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: LinkRideColors.textPrimary,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Create incidents or resolve active operational disruptions from the secured ADMIN workspace.',
          style: TextStyle(
            fontSize: 12.5,
            height: 1.4,
            color: LinkRideColors.textSecondary,
          ),
        ),
        const SizedBox(height: 14),
        if (_disruptions.isEmpty)
          _emptyCard()
        else
          ..._disruptions.map(
            (disruption) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _disruptionCard(disruption),
            ),
          ),
      ],
    );
  }

  Widget _summaryCard() {
    final int critical = _disruptions.where((item) {
      return _text(item['severity']).toUpperCase() == 'CRITICAL';
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
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.white,
            size: 29,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_disruptions.length} active '
                  'disruption${_disruptions.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$critical critical '
                  'incident${critical == 1 ? '' : 's'}',
                  style: const TextStyle(color: Colors.white, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: LinkRideDecorations.card(),
      child: const Column(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 36,
            color: LinkRideColors.linkGreen,
          ),
          SizedBox(height: 10),
          Text(
            'No active disruptions.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: LinkRideColors.textPrimary,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'The controlled demo network currently has no active operational incidents.',
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

  Widget _disruptionCard(Map<String, dynamic> disruption) {
    final int disruptionId = _asInt(disruption['disruptionId']);
    final int routeId = _asInt(disruption['routeId']);
    final int providerId = _asInt(disruption['providerId']);
    final String title = _text(disruption['title']);
    final String description = _text(disruption['description']);
    final String type = _text(disruption['disruptionType']).toUpperCase();
    final String severity = _text(disruption['severity']).toUpperCase();

    final bool resolving = _resolvingDisruptionId == disruptionId;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: LinkRideDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _severityBackground(severity),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: _severityForeground(severity),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.isEmpty ? 'Untitled disruption' : title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: LinkRideColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    if (description.isNotEmpty)
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
            ],
          ),
          const SizedBox(height: 13),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _pill(
                severity.isEmpty ? 'UNKNOWN' : severity,
                _severityForeground(severity),
                _severityBackground(severity),
              ),
              _pill(
                type.isEmpty ? 'OTHER' : type,
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
              _pill(
                'Disruption #$disruptionId',
                LinkRideColors.textSecondary,
                LinkRideColors.surfaceSoft,
              ),
            ],
          ),
          const SizedBox(height: 13),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: resolving || _resolvingDisruptionId != null
                  ? null
                  : () => _resolveDisruption(disruption),
              icon: resolving
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.task_alt_rounded),
              label: Text(resolving ? 'Resolving...' : 'Resolve disruption'),
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

  Color _severityForeground(String severity) {
    switch (severity) {
      case 'CRITICAL':
        return Colors.red.shade700;
      case 'HIGH':
        return Colors.deepOrange.shade700;
      case 'MEDIUM':
        return Colors.orange.shade800;
      case 'LOW':
        return Colors.green.shade700;
      default:
        return LinkRideColors.textSecondary;
    }
  }

  Color _severityBackground(String severity) {
    switch (severity) {
      case 'CRITICAL':
        return Colors.red.shade50;
      case 'HIGH':
        return Colors.deepOrange.shade50;
      case 'MEDIUM':
        return Colors.orange.shade50;
      case 'LOW':
        return Colors.green.shade50;
      default:
        return LinkRideColors.surfaceSoft;
    }
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
