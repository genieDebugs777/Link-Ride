import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'services/firebase_messaging_service.dart';
import 'theme/link_ride_theme.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint(
    'FCM background message received: '
    '${message.messageId}',
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const LinkRideApp());
}

class LinkRideApp extends StatefulWidget {
  const LinkRideApp({super.key});

  @override
  State<LinkRideApp> createState() => _LinkRideAppState();
}

class _LinkRideAppState extends State<LinkRideApp> {
  final FirebaseMessagingService _firebaseMessagingService =
      FirebaseMessagingService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMessaging();
    });
  }

  Future<void> _initializeMessaging() async {
    try {
      await _firebaseMessagingService.initialize();
    } catch (error) {
      debugPrint('FCM initialization error: $error');
    }
  }

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
