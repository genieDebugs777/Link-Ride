import 'dart:async';

import 'package:flutter/material.dart';
import '../services/auth_storage.dart';
import 'authentication_screen.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthStorage _authStorage = AuthStorage();
  
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () async {
      final String? token = await _authStorage.getToken();
      final String? firstName = await _authStorage.getFirstName();

      if (!mounted) return;

      if (token != null && firstName != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavigationScreen(
              firstName: firstName,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AuthenticationScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/link_ride_logo.png',
          width: 220,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}