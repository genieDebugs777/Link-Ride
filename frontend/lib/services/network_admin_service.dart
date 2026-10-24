import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class NetworkAdminService {
  Future<List<Map<String, dynamic>>> getProviders({
    required String token,
  }) async {
    final Uri uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/admin/network/providers',
    );

    final http.Response response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return _parseListResponse(
      response,
      fallback: 'Unable to load transport providers.',
    );
  }

  Future<List<Map<String, dynamic>>> getRoutes({required String token}) async {
    final Uri uri = Uri.parse('${ApiConfig.baseUrl}/api/admin/network/routes');

    final http.Response response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return _parseListResponse(
      response,
      fallback: 'Unable to load transport routes.',
    );
  }

  List<Map<String, dynamic>> _parseListResponse(
    http.Response response, {
    required String fallback,
  }) {
    if (response.statusCode == 200) {
      if (response.body.trim().isEmpty) {
        return [];
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception('Link Ride returned an invalid network response.');
      }

      return decoded
          .map<Map<String, dynamic>>(
            (dynamic item) => Map<String, dynamic>.from(item as Map),
          )
          .toList();
    }

    if (response.statusCode == 401) {
      throw Exception('Your Link Ride session is no longer valid.');
    }

    if (response.statusCode == 403) {
      throw Exception(
        'This account is not allowed to access network administration.',
      );
    }

    String message = fallback;

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

    throw Exception('$message (Status ${response.statusCode})');
  }
}
