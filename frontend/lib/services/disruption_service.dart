import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class DisruptionService {
  Future<List<Map<String, dynamic>>> getActiveDisruptions({
    required String token,
  }) async {
    final Uri uri = Uri.parse('${ApiConfig.baseUrl}/api/disruptions/active');

    final http.Response response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      if (response.body.trim().isEmpty) {
        return [];
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception('Link Ride returned an invalid disruptions response.');
      }

      return decoded
          .map<Map<String, dynamic>>(
            (dynamic item) => Map<String, dynamic>.from(item as Map),
          )
          .toList();
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Your Link Ride session is no longer valid.');
    }

    throw Exception(
      'Unable to load transport updates. '
      'Status code: ${response.statusCode}',
    );
  }

  Future<List<Map<String, dynamic>>> getActiveDisruptionsForJourney({
    required String token,
    required int journeyId,
  }) async {
    final Uri uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/disruptions/journey/$journeyId',
    );

    final http.Response response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      if (response.body.trim().isEmpty) {
        return [];
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception(
          'Link Ride returned an invalid journey disruption response.',
        );
      }

      return decoded
          .map<Map<String, dynamic>>(
            (dynamic item) => Map<String, dynamic>.from(item as Map),
          )
          .toList();
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Your Link Ride session is no longer valid.');
    }

    if (response.statusCode == 400) {
      String message = 'Unable to check journey disruptions.';

      if (response.body.trim().isNotEmpty) {
        try {
          final dynamic decoded = jsonDecode(response.body);

          if (decoded is String) {
            message = decoded;
          } else if (decoded is Map && decoded['message'] != null) {
            message = decoded['message'].toString();
          }
        } catch (_) {
          message = response.body;
        }
      }

      throw Exception(message);
    }

    throw Exception(
      'Unable to check journey disruptions. '
      'Status code: ${response.statusCode}',
    );
  }
}
