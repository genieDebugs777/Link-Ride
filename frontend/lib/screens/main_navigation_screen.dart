import 'package:flutter/material.dart';

import '../theme/link_ride_theme.dart';
import 'home_screen.dart';
import 'journeys_screen.dart';
import 'profile_screen.dart';
import 'tickets_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final String firstName;

  const MainNavigationScreen({
    super.key,
    required this.firstName,
  });

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  int _journeysRefreshToken = 0;
  int _ticketsRefreshToken = 0;

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
      HomeScreen(
        firstName: widget.firstName,
      ),
      JourneysScreen(
        refreshToken:
            _journeysRefreshToken,
      ),
      TicketsScreen(
        refreshToken:
            _ticketsRefreshToken,
      ),
      ProfileScreen(
        firstName: widget.firstName,
      ),
    ];

    return Scaffold(
      backgroundColor:
          LinkRideColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: _buildNavigationBar(),
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: LinkRideColors.surface,
        border: Border(
          top: BorderSide(
            color: LinkRideColors.border
                .withValues(alpha: 0.85),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.045,
            ),
            blurRadius: 22,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            10,
            4,
            10,
            4,
          ),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected:
                _selectTab,
            backgroundColor:
                Colors.transparent,
            elevation: 0,
            height: 68,
            indicatorColor:
                LinkRideColors.softBlue,
            labelBehavior:
                NavigationDestinationLabelBehavior
                    .alwaysShow,
            destinations: const [
              NavigationDestination(
                tooltip: 'Home',
                icon: Icon(
                  Icons.home_outlined,
                ),
                selectedIcon: Icon(
                  Icons.home_rounded,
                ),
                label: 'Home',
              ),
              NavigationDestination(
                tooltip: 'Journeys',
                icon: Icon(
                  Icons.route_outlined,
                ),
                selectedIcon: Icon(
                  Icons.route_rounded,
                ),
                label: 'Journeys',
              ),
              NavigationDestination(
                tooltip: 'Tickets',
                icon: Icon(
                  Icons
                      .confirmation_number_outlined,
                ),
                selectedIcon: Icon(
                  Icons
                      .confirmation_number_rounded,
                ),
                label: 'Tickets',
              ),
              NavigationDestination(
                tooltip: 'Profile',
                icon: Icon(
                  Icons
                      .person_outline_rounded,
                ),
                selectedIcon: Icon(
                  Icons.person_rounded,
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}