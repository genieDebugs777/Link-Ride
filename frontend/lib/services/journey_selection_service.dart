import 'dart:convert';

import 'package:http/http.dart' as http;

class JourneySelectionService {
  static const String _baseUrl = 'http://10.0.2.2:8080';

  Future<Map<String, dynamic>> selectJourney({
    required Map<String, dynamic> journeyOption,
    required String token,
  }) async {
    final Uri uri = Uri.parse(
      '$_baseUrl/api/journeys/select',
    );

    final Map<String, dynamic> requestBody = {
      'totalDurationMinutes':
          journeyOption['totalDurationMinutes'],
      'totalCost':
          journeyOption['totalCost'],
      'transferCount':
          journeyOption['transferCount'],
      'legs':
          journeyOption['legs'] ?? [],
    };

    final http.Response response =
        await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final dynamic decoded =
          jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(
          decoded,
        );
      }

      throw Exception(
        'Link Ride returned an invalid journey response.',
      );
    }

    if (response.statusCode == 401 ||
        response.statusCode == 403) {
      throw Exception(
        'Your Link Ride session is no longer valid.',
      );
    }

    if (response.statusCode == 400) {
      throw Exception(
        'The selected journey could not be saved.',
      );
    }

    throw Exception(
      'Unable to save journey. '
      'Status code: ${response.statusCode}',
    );
  }
}