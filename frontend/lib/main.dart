import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const LinkRideApp());
}

class LinkRideApp extends StatelessWidget {
  const LinkRideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Link Ride',

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF003366),
        ),
      ),

      home: const SplashScreen(),
    );
  }
}