import 'package:flutter/material.dart';

import '../theme/link_ride_theme.dart';
import 'admin_dashboard_screen.dart';
import 'home_screen.dart';
import 'journeys_screen.dart';
import 'operator_console_screen.dart';
import 'profile_screen.dart';
import 'tickets_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final String firstName;
  final String role;

  const MainNavigationScreen({
    super.key,
    required this.firstName,
    this.role = 'COMMUTER',
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  int _journeysRefreshToken = 0;
  int _ticketsRefreshToken = 0;

  String get _role => widget.role.trim().toUpperCase();

  bool get _isOperator => _role == 'OPERATOR';

  bool get _isAdmin => _role == 'ADMIN';

  void _selectTab(int index) {
    setState(() {
      _selectedIndex = index;

      if (index == 1) {
        _journeysRefreshToken++;
      }

      if (index == 2) {
        _ticketsRefreshToken++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(firstName: widget.firstName),
      JourneysScreen(refreshToken: _journeysRefreshToken),
      TicketsScreen(refreshToken: _ticketsRefreshToken),
      if (_isOperator) OperatorConsoleScreen(firstName: widget.firstName),
      if (_isAdmin) AdminDashboardScreen(firstName: widget.firstName),
      ProfileScreen(firstName: widget.firstName),
    ];

    return Scaffold(
      backgroundColor: LinkRideColors.background,
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: _buildNavigationBar(),
    );
  }

  Widget _buildNavigationBar() {
    final List<NavigationDestination> destinations = [
      const NavigationDestination(
        tooltip: 'Home',
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: 'Home',
      ),
      const NavigationDestination(
        tooltip: 'Journeys',
        icon: Icon(Icons.route_outlined),
        selectedIcon: Icon(Icons.route_rounded),
        label: 'Journeys',
      ),
      const NavigationDestination(
        tooltip: 'Tickets',
        icon: Icon(Icons.confirmation_number_outlined),
        selectedIcon: Icon(Icons.confirmation_number_rounded),
        label: 'Tickets',
      ),
      if (_isOperator)
        const NavigationDestination(
          tooltip: 'Operator Console',
          icon: Icon(Icons.monitor_heart_outlined),
          selectedIcon: Icon(Icons.monitor_heart_rounded),
          label: 'Operator',
        ),
      if (_isAdmin)
        const NavigationDestination(
          tooltip: 'Admin Dashboard',
          icon: Icon(Icons.admin_panel_settings_outlined),
          selectedIcon: Icon(Icons.admin_panel_settings_rounded),
          label: 'Admin',
        ),
      const NavigationDestination(
        tooltip: 'Profile',
        icon: Icon(Icons.person_outline_rounded),
        selectedIcon: Icon(Icons.person_rounded),
        label: 'Profile',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: LinkRideColors.surface,
        border: Border(
          top: BorderSide(color: LinkRideColors.border.withValues(alpha: 0.85)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 22,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _selectTab,
            backgroundColor: Colors.transparent,
            elevation: 0,
            height: 68,
            indicatorColor: LinkRideColors.softBlue,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: destinations,
          ),
        ),
      ),
    );
  }
}
