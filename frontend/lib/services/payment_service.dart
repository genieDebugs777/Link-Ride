import 'dart:convert';

import 'package:http/http.dart' as http;

class PaymentService {
  static const String _baseUrl =
      'http://10.0.2.2:8080';

  Future<Map<String, dynamic>> processPayment({
    required String token,
    required int journeyId,
    required String paymentMethod,
  }) async {
    final Uri uri = Uri.parse(
      '$_baseUrl/api/payments/process',
    );

    final http.Response response =
        await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        {
          'journeyId': journeyId,
          'paymentMethod': paymentMethod,
        },
      ),
    );

    if (response.statusCode == 200) {
      final dynamic decoded =
          jsonDecode(response.body);

      if (decoded is! Map) {
        throw Exception(
          'Link Ride returned an invalid payment response.',
        );
      }

      return Map<String, dynamic>.from(
        decoded,
      );
    }

    if (response.statusCode == 401 ||
        response.statusCode == 403) {
      throw Exception(
        'Your Link Ride session is no longer valid.',
      );
    }

    if (response.statusCode == 400) {
      String message =
          'Unable to process payment.';

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
          message = response.body;
        }
      }

      throw Exception(
        message,
      );
    }

    throw Exception(
      'Unable to process payment. '
      'Status code: ${response.statusCode}',
    );
  }
}