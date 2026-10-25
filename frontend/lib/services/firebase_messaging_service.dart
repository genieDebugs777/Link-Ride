import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  StreamSubscription<RemoteMessage>? _foregroundSubscription;

  StreamSubscription<RemoteMessage>? _openedAppSubscription;

  StreamSubscription<String>? _registrationSubscription;

  Future<void> initialize() async {
    final NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint(
      'FCM permission status: '
      '${settings.authorizationStatus}',
    );

    await _registrationSubscription?.cancel();

    _registrationSubscription = _messaging.onRegistered.listen(
      (String installationId) {
        debugPrint(
          'Firebase Installation ID registered: '
          '$installationId',
        );
      },
      onError: (Object error) {
        debugPrint('FCM registration error: $error');
      },
    );

    await _foregroundSubscription?.cancel();

    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );

    await _openedAppSubscription?.cancel();

    _openedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleOpenedMessage,
    );

    final RemoteMessage? initialMessage = await _messaging.getInitialMessage();

    if (initialMessage != null) {
      _handleOpenedMessage(initialMessage);
    }

    await _messaging.register();
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint(
      'FCM foreground message received: '
      '${message.messageId}',
    );

    debugPrint(
      'FCM title: '
      '${message.notification?.title}',
    );

    debugPrint(
      'FCM body: '
      '${message.notification?.body}',
    );

    debugPrint(
      'FCM data: '
      '${message.data}',
    );
  }

  void _handleOpenedMessage(RemoteMessage message) {
    debugPrint(
      'FCM notification opened: '
      '${message.messageId}',
    );

    debugPrint(
      'FCM opened data: '
      '${message.data}',
    );
  }
}
