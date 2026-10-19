import 'dart:convert';

import 'package:http/http.dart' as http;

class MyJourneysService {
  static const String _baseUrl =
      'http://10.0.2.2:8080';

  Future<List<Map<String, dynamic>>> getMyJourneys({
    required String token,
  }) async {
    final Uri uri = Uri.parse(
      '$_baseUrl/api/journeys/mine',
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

      if (decoded is! List) {
        throw Exception(
          'Link Ride returned an invalid journeys response.',
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

    if (response.statusCode == 401 ||
        response.statusCode == 403) {
      throw Exception(
        'Your Link Ride session is no longer valid.',
      );
    }

    throw Exception(
      'Unable to load journeys. '
      'Status code: ${response.statusCode}',
    );
  }
}