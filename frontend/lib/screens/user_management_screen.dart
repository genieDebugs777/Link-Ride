import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/auth_storage.dart';
import '../theme/link_ride_theme.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final AuthService _authService = AuthService();
  final AuthStorage _authStorage = AuthStorage();

  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String? token = await _authStorage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Your Link Ride session is no longer valid.');
      }

      final users = await _authService.getAllUsers(token: token);
      users.sort((a, b) => _asInt(a['userId']).compareTo(_asInt(b['userId'])));

      if (!mounted) return;
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
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
          'User Management',
          style: TextStyle(
            color: LinkRideColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadUsers,
            tooltip: 'Refresh users',
            icon: const Icon(
              Icons.refresh_rounded,
              color: LinkRideColors.primaryBlue,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUsers,
        color: LinkRideColors.primaryBlue,
        child: _body(),
      ),
    );
  }

  Widget _body() {
    if (_isLoading && _users.isEmpty) {
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
              'Loading Link Ride users...',
              style: TextStyle(
                color: LinkRideColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    if (_errorMessage != null && _users.isEmpty) {
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
                  onPressed: _loadUsers,
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
          'All users',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: LinkRideColors.textPrimary,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Accounts returned by the secured ADMIN user endpoint.',
          style: TextStyle(
            fontSize: 12.5,
            height: 1.4,
            color: LinkRideColors.textSecondary,
          ),
        ),
        const SizedBox(height: 14),
        if (_users.isEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: LinkRideDecorations.card(),
            child: const Text(
              'No users were returned by the backend.',
              textAlign: TextAlign.center,
              style: TextStyle(color: LinkRideColors.textSecondary),
            ),
          )
        else
          ..._users.map(
            (user) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _userCard(user),
            ),
          ),
      ],
    );
  }

  Widget _summaryCard() {
    final int activeCount = _users.where((user) {
      return _text(user['accountStatus']).toUpperCase() == 'ACTIVE';
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
          const Icon(Icons.people_alt_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_users.length} user${_users.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$activeCount active account${activeCount == 1 ? '' : 's'}',
                  style: const TextStyle(color: Colors.white, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _userCard(Map<String, dynamic> user) {
    final int userId = _asInt(user['userId']);
    final String firstName = _text(user['firstName']);
    final String lastName = _text(user['lastName']);
    final String email = _text(user['email']);
    final String phone = _text(user['phoneNumber']);
    final String status = _text(user['accountStatus']).toUpperCase();

    final String fullName = '$firstName $lastName'.trim().isEmpty
        ? 'Unnamed user'
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
              Icons.person_outline_rounded,
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: LinkRideColors.softBlue,
                    borderRadius: BorderRadius.circular(LinkRideRadius.pill),
                  ),
                  child: Text(
                    'User #$userId',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: LinkRideColors.primaryBlue,
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

  static int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _text(dynamic value) {
    return value?.toString().trim() ?? '';
  }
}
