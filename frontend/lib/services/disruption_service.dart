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
      headers: _headers(token),
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

    _throwForResponse(response, fallback: 'Unable to load transport updates.');
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
      headers: _headers(token),
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

    _throwForResponse(
      response,
      fallback: 'Unable to check journey disruptions.',
    );
  }

  Future<Map<String, dynamic>> createDisruption({
    required String token,
    required int routeId,
    required String disruptionType,
    required String severity,
    required String title,
    required String description,
    DateTime? expectedEndDateTime,
  }) async {
    final Uri uri = Uri.parse('${ApiConfig.baseUrl}/api/disruptions');

    final Map<String, dynamic> payload = {
      'routeId': routeId,
      'disruptionType': disruptionType,
      'severity': severity,
      'title': title,
      'description': description,
      'startDateTime': DateTime.now().toIso8601String(),
    };

    if (expectedEndDateTime != null) {
      payload['expectedEndDateTime'] = expectedEndDateTime.toIso8601String();
    }

    final http.Response response = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      if (response.body.trim().isEmpty) {
        return {};
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      throw Exception('Link Ride returned an invalid disruption response.');
    }

    _throwForResponse(response, fallback: 'Unable to create disruption.');
  }

  Future<Map<String, dynamic>> resolveDisruption({
    required String token,
    required int disruptionId,
  }) async {
    final Uri uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/disruptions/'
      '$disruptionId/resolve',
    );

    final http.Response response = await http.put(
      uri,
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      if (response.body.trim().isEmpty) {
        return {};
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      throw Exception('Link Ride returned an invalid disruption response.');
    }

    _throwForResponse(response, fallback: 'Unable to resolve disruption.');
  }

  Map<String, String> _headers(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Never _throwForResponse(http.Response response, {required String fallback}) {
    if (response.statusCode == 401) {
      throw Exception('Your Link Ride session is no longer valid.');
    }

    if (response.statusCode == 403) {
      throw Exception('Your account is not allowed to perform this action.');
    }

    String message = fallback;

    if (response.body.trim().isNotEmpty) {
      try {
        final dynamic decoded = jsonDecode(response.body);

        if (decoded is String) {
          message = decoded;
        } else if (decoded is Map && decoded['message'] != null) {
          message = decoded['message'].toString();
        } else {
          message = response.body;
        }
      } catch (_) {
        message = response.body;
      }
    }

    throw Exception('$message (Status ${response.statusCode})');
  }
}
