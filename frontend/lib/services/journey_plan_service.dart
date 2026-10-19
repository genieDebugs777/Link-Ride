import 'dart:convert';

import 'package:http/http.dart' as http;

class JourneyPlanService {
  static const String _baseUrl =
      'http://10.0.2.2:8080';

  Future<List<Map<String, dynamic>>> planJourney({
    required double originLatitude,
    required double originLongitude,
    required int destinationStopId,
    required String token,
    required String priority,
    required bool gautrainSelected,
    required bool metrorailSelected,
    required bool busSelected,
    required bool taxiSelected,
    required bool preferFewerTransfers,
  }) async {
    final Uri uri = Uri.parse(
      '$_baseUrl/api/journeys/plan',
    );

    final http.Response response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'originLatitude': originLatitude,
        'originLongitude': originLongitude,
        'destinationStopId': destinationStopId,
        'priority': priority,
        'gautrainSelected': gautrainSelected,
        'metrorailSelected': metrorailSelected,
        'busSelected': busSelected,
        'taxiSelected': taxiSelected,
        'preferFewerTransfers': preferFewerTransfers,
      }),
    );

    if (response.statusCode == 200) {
      final dynamic decoded =
          jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception(
          'Unexpected journey-planning response.',
        );
      }

      return decoded
          .map<Map<String, dynamic>>(
            (dynamic option) =>
                Map<String, dynamic>.from(
              option as Map,
            ),
          )
          .toList();
    }

    if (response.statusCode == 404) {
      return [];
    }

    if (response.statusCode == 401 ||
        response.statusCode == 403) {
      throw Exception(
        'Your Link Ride session has expired.',
      );
    }

    throw Exception(
      'Unable to plan journey. '
      'Server returned ${response.statusCode}.',
    );
  }
}