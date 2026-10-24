import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class StopSearchService {
  Future<List<Map<String, dynamic>>> searchStops({
    required String query,
    required String token,
  }) async {
    final String cleanedQuery = query.trim();

    if (cleanedQuery.length < 2) {
      return [];
    }

    final Uri uri = Uri.parse('${ApiConfig.baseUrl}/api/journeys/stops/search')
        .replace(queryParameters: {'query': cleanedQuery});

    final http.Response response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final dynamic decodedBody = jsonDecode(response.body);

      return (decodedBody as List<dynamic>)
          .map((dynamic item) => Map<String, dynamic>.from(item as Map))
          .toList();
    }

    if (response.statusCode == 401) {
      throw Exception('Your Link Ride session is no longer valid.');
    }

    throw Exception('Stop search failed with status ${response.statusCode}.');
  }
}
