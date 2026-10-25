import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'auth_storage.dart';

class PushRegistrationService {
  final AuthStorage _authStorage = AuthStorage();

  Future<bool> syncForCurrentSession({String? firebaseInstallationId}) async {
    final String? token = await _authStorage.getToken();

    if (token == null || token.trim().isEmpty) {
      debugPrint('FCM backend sync skipped: no authenticated session.');
      return false;
    }

    return syncWithToken(
      token: token,
      firebaseInstallationId: firebaseInstallationId,
    );
  }

  Future<bool> syncWithToken({
    required String token,
    String? firebaseInstallationId,
  }) async {
    String? fid = firebaseInstallationId?.trim();

    if (fid == null || fid.isEmpty) {
      fid = await _authStorage.getFirebaseInstallationId();
    }

    if (fid == null || fid.isEmpty) {
      debugPrint('FCM backend sync skipped: no Firebase Installation ID.');
      return false;
    }

    final Uri url = Uri.parse('${ApiConfig.baseUrl}/api/notifications/devices');

    try {
      final http.Response response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token.trim()}',
        },
        body: jsonEncode({'firebaseInstallationId': fid}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('Firebase Installation ID synced with Link Ride backend.');
        return true;
      }

      debugPrint(
        'FCM backend sync failed: ${response.statusCode} ${response.body}',
      );
      return false;
    } catch (error) {
      debugPrint('FCM backend sync error: $error');
      return false;
    }
  }
}
