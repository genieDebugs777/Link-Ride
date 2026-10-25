import 'dart:convert';

import 'package:http/http.dart' as http;

class PaymentService {
  static const String _baseUrl = 'http://10.0.2.2:8080';

  Future<Map<String, dynamic>> processPayment({
    required String token,
    required int journeyId,
    required String paymentMethod,
  }) async {
    final Uri uri = Uri.parse('$_baseUrl/api/payments/process');

    final http.Response response = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode({
        'journeyId': journeyId,
        'paymentMethod': paymentMethod,
      }),
    );

    return _decodeMapResponse(
      response,
      fallbackMessage: 'Unable to process payment.',
    );
  }

  Future<Map<String, dynamic>> initializePaystack({
    required String token,
    required int journeyId,
  }) async {
    final Uri uri = Uri.parse('$_baseUrl/api/payments/paystack/initialize');

    final http.Response response = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode({'journeyId': journeyId}),
    );

    return _decodeMapResponse(
      response,
      fallbackMessage: 'Unable to initialize Paystack payment.',
    );
  }

  Future<Map<String, dynamic>> verifyPaystack({
    required String token,
    required String reference,
  }) async {
    final Uri uri = Uri.parse(
      '$_baseUrl/api/payments/paystack/verify/'
      '${Uri.encodeComponent(reference)}',
    );

    final http.Response response = await http.post(
      uri,
      headers: _headers(token),
    );

    return _decodeMapResponse(
      response,
      fallbackMessage: 'Unable to verify Paystack payment.',
    );
  }

  Map<String, String> _headers(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Map<String, dynamic> _decodeMapResponse(
    http.Response response, {
    required String fallbackMessage,
  }) {
    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map) {
        throw Exception('Link Ride returned an invalid payment response.');
      }

      return Map<String, dynamic>.from(decoded);
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Your Link Ride session is no longer valid.');
    }

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
}
