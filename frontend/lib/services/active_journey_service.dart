import 'dart:convert';

import 'package:http/http.dart' as http;

class ActiveJourneyService {
  static const String _baseUrl =
      'http://10.0.2.2:8080';

  Future<Map<String, dynamic>> getActiveJourney({
    required String token,
  }) async {
    final Uri uri = Uri.parse(
      '$_baseUrl/api/journeys/active',
    );

    final http.Response response =
        await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final dynamic decoded =
          jsonDecode(response.body);

      if (decoded is! Map) {
        throw Exception(
          'Link Ride returned an invalid active journey response.',
        );
      }

      final Map<String, dynamic> result =
          Map<String, dynamic>.from(
        decoded,
      );

      if (result['journey'] is! Map ||
          result['legs'] is! List) {
        throw Exception(
          'Active journey data is incomplete.',
        );
      }

      result['journey'] =
          Map<String, dynamic>.from(
        result['journey'] as Map,
      );

      result['legs'] =
          (result['legs'] as List)
              .map(
                (dynamic leg) =>
                    Map<String, dynamic>.from(
                  leg as Map,
                ),
              )
              .toList();

      return result;
    }

    if (response.statusCode == 401 ||
        response.statusCode == 403) {
      throw Exception(
        'Your Link Ride session is no longer valid.',
      );
    }

    if (response.statusCode == 400) {
      String message =
          'No active journey is available.';

      if (response.body.isNotEmpty) {
        try {
          final dynamic decoded =
              jsonDecode(response.body);

          if (decoded is String) {
            message = decoded;
          } else if (decoded is Map &&
              decoded['message'] != null) {
            message =
                decoded['message'].toString();
          }
        } catch (_) {
          message =
              response.body;
        }
      }

      throw Exception(
        message,
      );
    }

    throw Exception(
      'Unable to load active journey. '
      'Status code: ${response.statusCode}',
    );
  }
}