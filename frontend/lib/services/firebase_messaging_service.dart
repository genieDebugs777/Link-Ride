import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'auth_storage.dart';
import 'push_registration_service.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final AuthStorage _authStorage = AuthStorage();
  final PushRegistrationService _pushRegistrationService =
      PushRegistrationService();

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

    debugPrint('FCM permission status: ${settings.authorizationStatus}');

    await _registrationSubscription?.cancel();
    _registrationSubscription = _messaging.onRegistered.listen(
      _handleRegistration,
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

  Future<void> _handleRegistration(String firebaseInstallationId) async {
    final String fid = firebaseInstallationId.trim();

    if (fid.isEmpty) {
      return;
    }

    debugPrint('Firebase Installation ID registered: $fid');

    await _authStorage.saveFirebaseInstallationId(fid);

    await _pushRegistrationService.syncForCurrentSession(
      firebaseInstallationId: fid,
    );
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('FCM foreground message received: ${message.messageId}');
    debugPrint('FCM title: ${message.notification?.title}');
    debugPrint('FCM body: ${message.notification?.body}');
    debugPrint('FCM data: ${message.data}');
  }

  void _handleOpenedMessage(RemoteMessage message) {
    debugPrint('FCM notification opened: ${message.messageId}');
    debugPrint('FCM opened data: ${message.data}');
  }
}
