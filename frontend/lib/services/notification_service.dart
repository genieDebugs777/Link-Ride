import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class NotificationService {
  Future<List<Map<String, dynamic>>> getMyNotifications({
    required String token,
  }) async {
    final http.Response response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/notifications/mine',
      ),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final dynamic decoded =
          jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception(
          'Link Ride returned an invalid notifications response.',
        );
      }

      return decoded
          .map<Map<String, dynamic>>(
            (dynamic item) =>
                Map<String, dynamic>.from(
              item as Map,
            ),
          )
          .toList();
    }

    throw _apiException(
      response,
      'Unable to load notifications.',
    );
  }

  Future<int> getUnreadCount({
    required String token,
  }) async {
    final http.Response response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/notifications/unread-count',
      ),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final dynamic decoded =
          jsonDecode(response.body);

      if (decoded is Map &&
          decoded['unreadCount'] != null) {
        final dynamic value =
            decoded['unreadCount'];

        if (value is int) {
          return value;
        }

        return int.tryParse(
              value.toString(),
            ) ??
            0;
      }

      return 0;
    }

    throw _apiException(
      response,
      'Unable to load unread notification count.',
    );
  }

  Future<void> markAsRead({
    required String token,
    required int notificationId,
  }) async {
    final http.Response response =
        await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/notifications/$notificationId/read',
      ),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      throw _apiException(
        response,
        'Unable to mark notification as read.',
      );
    }
  }

  Future<void> markAllAsRead({
    required String token,
  }) async {
    final http.Response response =
        await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/notifications/read-all',
      ),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      throw _apiException(
        response,
        'Unable to mark notifications as read.',
      );
    }
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
