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

  Future<Map<String, dynamic>> createDisruption({
    required String token,
    required int routeId,
    required String disruptionType,
    required String severity,
    required String title,
    required String description,
  }) async {
    final Uri uri = Uri.parse('${ApiConfig.baseUrl}/api/disruptions');

    final http.Response response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'routeId': routeId,
        'disruptionType': disruptionType,
        'severity': severity,
        'title': title.trim(),
        'description': description.trim(),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
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

    throw Exception(
      _errorMessage(response, fallback: 'Unable to create disruption.'),
    );
  }

  Future<Map<String, dynamic>> resolveDisruption({
    required String token,
    required int disruptionId,
  }) async {
    final Uri uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/disruptions/$disruptionId/resolve',
    );

    final http.Response response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
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

      throw Exception(
        'Link Ride returned an invalid resolved disruption response.',
      );
    }

    throw Exception(
      _errorMessage(response, fallback: 'Unable to resolve disruption.'),
    );
  }

  String _errorMessage(http.Response response, {required String fallback}) {
    if (response.statusCode == 401) {
      return 'Your Link Ride session is no longer valid.';
    }

    if (response.statusCode == 403) {
      return 'Your account is not allowed to perform this action.';
    }

    if (response.body.trim().isNotEmpty) {
      try {
        final dynamic decoded = jsonDecode(response.body);

        if (decoded is String && decoded.trim().isNotEmpty) {
          return decoded;
        }

        if (decoded is Map && decoded['message'] != null) {
          return decoded['message'].toString();
        }
      } catch (_) {
        return response.body.trim();
      }
    }

    return '$fallback Status code: ${response.statusCode}';
  }
}
