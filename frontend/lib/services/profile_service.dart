import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class ProfileService {
  Future<Map<String, dynamic>> getUserProfile({
    required int userId,
    required String token,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/api/users/$userId');

    final http.Response response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Unable to load profile. Please try again.');
  }

  Future<Map<String, dynamic>> updateUserProfile({
    required int userId,
    required String token,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/api/users/$userId');

    final http.Response response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Unable to update profile. Please try again.');
  }

  Future<void> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/api/users/password');

    final http.Response response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 204) {
      return;
    }

    String message = 'Unable to change password. Please try again.';

    try {
      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      message = responseData['message']?.toString() ?? message;
    } catch (_) {
      // Keep the fallback message if the response has no JSON body.
    }

    throw Exception(message);
  }
}
