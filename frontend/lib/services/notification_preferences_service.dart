import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'auth_storage.dart';

class NotificationPreferencesService {
  final AuthStorage _authStorage =
      AuthStorage();

  Future<Map<String, bool>> getPreferences() async {
    final String token =
        await _requireToken();

    final http.Response response =
        await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/notifications/preferences',
      ),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final dynamic decoded =
          jsonDecode(response.body);

      final Map<String, dynamic> data =
          Map<String, dynamic>.from(
        decoded as Map,
      );

      return {
        'disruptionAlerts':
            data['disruptionAlerts'] != false,
        'journeyUpdates':
            data['journeyUpdates'] != false,
        'ticketPaymentUpdates':
            data['ticketPaymentUpdates'] != false,
        'generalNotifications':
            data['generalNotifications'] == true,
      };
    }

    throw _apiException(
      response,
      'Unable to load notification preferences.',
    );
  }

  Future<void> savePreferences({
    required bool disruptionAlerts,
    required bool journeyUpdates,
    required bool ticketPaymentUpdates,
    required bool generalNotifications,
  }) async {
    final String token =
        await _requireToken();

    final http.Response response =
        await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/notifications/preferences',
      ),
      headers: _headers(token),
      body: jsonEncode({
        'disruptionAlerts': disruptionAlerts,
        'journeyUpdates': journeyUpdates,
        'ticketPaymentUpdates': ticketPaymentUpdates,
        'generalNotifications': generalNotifications,
      }),
    );

    if (response.statusCode != 200) {
      throw _apiException(
        response,
        'Unable to save notification preferences.',
      );
    }
  }

  Future<String> _requireToken() async {
    final String? token =
        await _authStorage.getToken();

    if (token == null ||
        token.isEmpty) {
      throw Exception(
        'Your Link Ride session is no longer valid.',
      );
    }

    return token;
  }

  Map<String, String> _headers(
    String token,
  ) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Exception _apiException(
    http.Response response,
    String fallback,
  ) {
    if (response.statusCode == 401 ||
        response.statusCode == 403) {
      return Exception(
        'Your Link Ride session is no longer valid.',
      );
    }

    return Exception(
      '$fallback Status code: ${response.statusCode}',
    );
  }
}
