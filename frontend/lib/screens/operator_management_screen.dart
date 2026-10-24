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
  List<Map<String, dynamic>> _operators = [];

  @override
  void initState() {
    super.initState();
    _loadOperators();
  }

  Future<void> _loadOperators() async {
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

      if (!mounted) {
        return;
      }

      setState(() {
        _operators = operators;
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
          'Operator Management',
          style: TextStyle(
            color: LinkRideColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadOperators,
            tooltip: 'Refresh operators',
            icon: const Icon(
              Icons.refresh_rounded,
              color: LinkRideColors.primaryBlue,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadOperators,
        color: LinkRideColors.primaryBlue,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _operators.isEmpty) {
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
              'Loading operator accounts...',
              style: TextStyle(
                color: LinkRideColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    if (_errorMessage != null && _operators.isEmpty) {
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
                  onPressed: _loadOperators,
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
        const SizedBox(height: 18),
        const Text(
          'Operator accounts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: LinkRideColors.textPrimary,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Users with the OPERATOR role returned by the secured ADMIN user endpoint.',
          style: TextStyle(
            fontSize: 12.5,
            height: 1.4,
            color: LinkRideColors.textSecondary,
          ),
        ),
        const SizedBox(height: 14),
        if (_operators.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: LinkRideDecorations.card(),
            child: const Column(
              children: [
                Icon(
                  Icons.badge_outlined,
                  size: 34,
                  color: LinkRideColors.textSecondary,
                ),
                SizedBox(height: 10),
                Text(
                  'No operator accounts were returned.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: LinkRideColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else
          ..._operators.map(
            (operator) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _operatorCard(operator),
            ),
          ),
      ],
    );
  }

  Widget _summaryCard() {
    final int activeCount = _operators.where((operator) {
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
                  '${_operators.length} operator${_operators.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$activeCount active operator account${activeCount == 1 ? '' : 's'}',
                  style: const TextStyle(color: Colors.white, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _operatorCard(Map<String, dynamic> operator) {
    final int userId = _asInt(operator['userId']);
    final String firstName = _text(operator['firstName']);
    final String lastName = _text(operator['lastName']);
    final String email = _text(operator['email']);
    final String phone = _text(operator['phoneNumber']);
    final String status = _text(operator['accountStatus']).toUpperCase();

    final String fullName = '$firstName $lastName'.trim().isEmpty
        ? 'Unnamed operator'
        : '$firstName $lastName'.trim();

    final bool active = status == 'ACTIVE';

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
              Icons.badge_outlined,
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
                const SizedBox(height: 10),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _pill(
                      'OPERATOR',
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
              ],
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
