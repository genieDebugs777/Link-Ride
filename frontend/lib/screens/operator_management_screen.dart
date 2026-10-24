import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/auth_storage.dart';
import '../theme/link_ride_theme.dart';

class OperatorManagementScreen extends StatefulWidget {
  const OperatorManagementScreen({super.key});

  @override
  State<OperatorManagementScreen> createState() =>
      _OperatorManagementScreenState();
}

class _OperatorManagementScreenState extends State<OperatorManagementScreen> {
  final AuthService _authService = AuthService();
  final AuthStorage _authStorage = AuthStorage();

  bool _isLoading = true;
  String? _errorMessage;
  int? _updatingUserId;

  List<Map<String, dynamic>> _operators = [];
  List<Map<String, dynamic>> _commuters = [];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String? token = await _authStorage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Your Link Ride session is no longer valid.');
      }

      final List<Map<String, dynamic>> users = await _authService.getAllUsers(
        token: token,
      );

      final List<Map<String, dynamic>> operators =
          users.where((user) {
            return _text(user['role']).toUpperCase() == 'OPERATOR';
          }).toList()..sort(
            (a, b) => _asInt(a['userId']).compareTo(_asInt(b['userId'])),
          );

      final List<Map<String, dynamic>> commuters =
          users.where((user) {
            return _text(user['role']).toUpperCase() == 'COMMUTER';
          }).toList()..sort(
            (a, b) => _asInt(a['userId']).compareTo(_asInt(b['userId'])),
          );

      if (!mounted) {
        return;
      }

      setState(() {
        _operators = operators;
        _commuters = commuters;
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

  Future<void> _changeRole({
    required Map<String, dynamic> user,
    required String newRole,
  }) async {
    final int userId = _asInt(user['userId']);
    final String fullName = _fullName(user);
    final bool promoting = newRole == 'OPERATOR';

    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: Text(
                promoting ? 'Promote to operator?' : 'Demote to commuter?',
              ),
              content: Text(
                promoting
                    ? '$fullName will receive operator access and '
                          'will be able to perform transport operations.'
                    : '$fullName will lose operator access and '
                          'return to normal commuter permissions.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(promoting ? 'Promote' : 'Demote'),
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
      _updatingUserId = userId;
      _errorMessage = null;
    });

    try {
      final String? token = await _authStorage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Your Link Ride session is no longer valid.');
      }

      await _authService.updateUserRole(
        token: token,
        userId: userId,
        role: newRole,
      );

      await _loadAccounts();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              promoting
                  ? '$fullName is now an operator.'
                  : '$fullName is now a commuter.',
            ),
          ),
        );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _updatingUserId = null;
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
          'Operator Management',
          style: TextStyle(
            color: LinkRideColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading || _updatingUserId != null
                ? null
                : _loadAccounts,
            tooltip: 'Refresh accounts',
            icon: const Icon(
              Icons.refresh_rounded,
              color: LinkRideColors.primaryBlue,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAccounts,
        color: LinkRideColors.primaryBlue,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _operators.isEmpty && _commuters.isEmpty) {
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
              'Loading operator access...',
              style: TextStyle(
                color: LinkRideColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    if (_errorMessage != null && _operators.isEmpty && _commuters.isEmpty) {
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
                  color: LinkRideColors.danger,
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
                  onPressed: _loadAccounts,
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
        _sectionHeader(
          title: 'Current operators',
          description: 'Accounts that currently have OPERATOR access.',
        ),
        const SizedBox(height: 12),
        if (_operators.isEmpty)
          _emptyCard(
            icon: Icons.badge_outlined,
            message: 'No operator accounts were returned.',
          )
        else
          ..._operators.map(
            (operator) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _accountCard(
                user: operator,
                roleLabel: 'OPERATOR',
                actionLabel: 'Demote',
                actionIcon: Icons.person_remove_alt_1_outlined,
                onAction: () =>
                    _changeRole(user: operator, newRole: 'COMMUTER'),
              ),
            ),
          ),
        const SizedBox(height: 10),
        _sectionHeader(
          title: 'Eligible commuters',
          description:
              'Promote a commuter when they need transport operator access.',
        ),
        const SizedBox(height: 12),
        if (_commuters.isEmpty)
          _emptyCard(
            icon: Icons.people_outline_rounded,
            message: 'No commuter accounts are available.',
          )
        else
          ..._commuters.map(
            (commuter) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _accountCard(
                user: commuter,
                roleLabel: 'COMMUTER',
                actionLabel: 'Promote',
                actionIcon: Icons.person_add_alt_1_rounded,
                onAction: () =>
                    _changeRole(user: commuter, newRole: 'OPERATOR'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _summaryCard() {
    final int activeOperators = _operators.where((operator) {
      return _text(operator['accountStatus']).toUpperCase() == 'ACTIVE';
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
          const Icon(Icons.badge_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_operators.length} '
                  'operator${_operators.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$activeOperators active operator '
                  'account${activeOperators == 1 ? '' : 's'}',
                  style: const TextStyle(color: Colors.white, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader({required String title, required String description}) {
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

  Widget _accountCard({
    required Map<String, dynamic> user,
    required String roleLabel,
    required String actionLabel,
    required IconData actionIcon,
    required VoidCallback onAction,
  }) {
    final int userId = _asInt(user['userId']);
    final String email = _text(user['email']);
    final String phone = _text(user['phoneNumber']);
    final String status = _text(user['accountStatus']).toUpperCase();
    final String fullName = _fullName(user);

    final bool active = status == 'ACTIVE';
    final bool updating = _updatingUserId == userId;

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
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: LinkRideColors.softGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  roleLabel == 'OPERATOR'
                      ? Icons.badge_outlined
                      : Icons.person_outline_rounded,
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
                            fullName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: LinkRideColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: active
                                ? LinkRideColors.softGreen
                                : LinkRideColors.surfaceSoft,
                            borderRadius: BorderRadius.circular(
                              LinkRideRadius.pill,
                            ),
                          ),
                          child: Text(
                            status.isEmpty ? 'UNKNOWN' : status,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: active
                                  ? LinkRideColors.linkGreen
                                  : LinkRideColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      email.isEmpty ? 'No email address' : email,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: LinkRideColors.textSecondary,
                      ),
                    ),
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        phone,
                        style: const TextStyle(
                          fontSize: 12,
                          color: LinkRideColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _pill(
                roleLabel,
                LinkRideColors.primaryBlue,
                LinkRideColors.softBlue,
              ),
              _pill(
                'User #$userId',
                LinkRideColors.textSecondary,
                LinkRideColors.surfaceSoft,
              ),
            ],
          ),
          const SizedBox(height: 13),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: updating || _updatingUserId != null ? null : onAction,
              icon: updating
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(actionIcon),
              label: Text(updating ? 'Updating...' : actionLabel),
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

  static String _fullName(Map<String, dynamic> user) {
    final String firstName = _text(user['firstName']);
    final String lastName = _text(user['lastName']);
    final String fullName = '$firstName $lastName'.trim();

    return fullName.isEmpty ? 'Unnamed user' : fullName;
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
