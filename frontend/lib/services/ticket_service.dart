import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class TicketService {
  Future<Map<String, dynamic>> issueTicket({
    required String token,
    required int journeyId,
  }) async {
    return _postTicketAction(
      token: token,
      journeyId: journeyId,
      endpoint: '/api/tickets/issue',
      fallbackMessage: 'Unable to issue ticket.',
    );
  }

  Future<Map<String, dynamic>> activateTicket({
    required String token,
    required int journeyId,
  }) async {
    return _postTicketAction(
      token: token,
      journeyId: journeyId,
      endpoint: '/api/tickets/activate',
      fallbackMessage: 'Unable to start journey.',
    );
  }

  Future<Map<String, dynamic>> completeJourney({
    required String token,
    required int journeyId,
  }) async {
    return _postTicketAction(
      token: token,
      journeyId: journeyId,
      endpoint: '/api/tickets/complete',
      fallbackMessage: 'Unable to complete journey.',
    );
  }

  Future<List<Map<String, dynamic>>> getMyTickets({
    required String token,
  }) async {
    final Uri uri = Uri.parse('${ApiConfig.baseUrl}/api/tickets/mine');

    final http.Response response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception('Link Ride returned an invalid ticket list.');
      }

      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Your Link Ride session is no longer valid.');
    }

    throw Exception(
      'Unable to load tickets. '
      'Status code: ${response.statusCode}',
    );
  }

  Future<Map<String, dynamic>?> getCurrentTicket({
    required String token,
  }) async {
    final Uri uri = Uri.parse('${ApiConfig.baseUrl}/api/tickets/current');

    final http.Response response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map) {
        throw Exception(
          'Link Ride returned an invalid current ticket response.',
        );
      }

      return Map<String, dynamic>.from(decoded);
    }

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Your Link Ride session is no longer valid.');
    }

    throw Exception(
      'Unable to load current ticket. '
      'Status code: ${response.statusCode}',
    );
  }

  Future<Map<String, dynamic>> _postTicketAction({
    required String token,
    required int journeyId,
    required String endpoint,
    required String fallbackMessage,
  }) async {
    final Uri uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    final http.Response response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'journeyId': journeyId}),
    );

    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map) {
        throw Exception('Link Ride returned an invalid ticket response.');
      }

      return Map<String, dynamic>.from(decoded);
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Your Link Ride session is no longer valid.');
    }

    if (response.statusCode == 400) {
      String message = fallbackMessage;

      if (response.body.isNotEmpty) {
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
      '$fallbackMessage '
      'Status code: ${response.statusCode}',
    );
  }
}
