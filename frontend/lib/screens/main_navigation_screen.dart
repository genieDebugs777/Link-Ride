import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'journeys_screen.dart';
import 'profile_screen.dart';
import 'tickets_screen.dart';


const Color _background = Color(0xFFF7F9FB);

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
      backgroundColor: _background,

      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,

        backgroundColor: Colors.white,

        indicatorColor:
            const Color(0xFFE7F1F7),

        elevation: 3,

        onDestinationSelected:
            _selectTab,

        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home_rounded,
            ),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.route_outlined,
            ),
            selectedIcon: Icon(
              Icons.route_rounded,
            ),
            label: 'Journeys',
          ),

          NavigationDestination(
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
    );
  }
}
