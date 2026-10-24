import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'theme/link_ride_theme.dart';

void main() {
  runApp(const LinkRideApp());
}

class LinkRideApp extends StatelessWidget {
  const LinkRideApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Link Ride',
      theme: LinkRideTheme.light,
      home: const SplashScreen(),
    );
  }
}