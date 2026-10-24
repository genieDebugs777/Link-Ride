import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class AuthService {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/api/users/login');

    final http.Response response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final Map<String, dynamic> responseData =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return responseData;
    }

    throw Exception(responseData['message'] ?? 'Login failed');
  }

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/api/users/register');

    final http.Response response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
      }),
    );

    Map<String, dynamic> responseData = {};

    if (response.body.trim().isNotEmpty) {
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        responseData = decoded;
      } else if (decoded is Map) {
        responseData = Map<String, dynamic>.from(decoded);
      }
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return responseData;
    }

    throw Exception(
      responseData['message'] ?? 'Unable to create your Link Ride account.',
    );
  }

  Future<void> verifyEmail({
    required String email,
    required String verificationCode,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/api/users/verify-email');

    final http.Response response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'verificationCode': verificationCode}),
    );

    if (response.statusCode == 204 || response.statusCode == 200) {
      return;
    }

    Map<String, dynamic> responseData = {};

    if (response.body.trim().isNotEmpty) {
      try {
        final dynamic decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          responseData = decoded;
        } else if (decoded is Map) {
          responseData = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        // Preserve fallback message below.
      }
    }

    throw Exception(
      responseData['message'] ?? 'Unable to verify your email address.',
    );
  }

  Future<void> resendVerificationCode({required String email}) async {
    final Uri url = Uri.parse(
      '${ApiConfig.baseUrl}/api/users/resend-verification',
    );

    final http.Response response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 204 || response.statusCode == 200) {
      return;
    }

    Map<String, dynamic> responseData = {};

    if (response.body.trim().isNotEmpty) {
      try {
        final dynamic decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          responseData = decoded;
        } else if (decoded is Map) {
          responseData = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        // Preserve fallback message below.
      }
    }

    throw Exception(
      responseData['message'] ?? 'Unable to resend the verification code.',
    );
  }

  Future<Map<String, dynamic>> requestPasswordReset({
    required String email,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/api/users/forgot-password');

    final http.Response response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    Map<String, dynamic> responseData = {};

    if (response.body.trim().isNotEmpty) {
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        responseData = decoded;
      } else if (decoded is Map) {
        responseData = Map<String, dynamic>.from(decoded);
      }
    }

    if (response.statusCode == 200) {
      return responseData;
    }

    throw Exception(
      responseData['message'] ?? 'Unable to start password reset.',
    );
  }

  Future<void> resetPassword({
    required String email,
    required String resetCode,
    required String newPassword,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/api/users/reset-password');

    final http.Response response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'resetCode': resetCode,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 204 || response.statusCode == 200) {
      return;
    }

    Map<String, dynamic> responseData = {};

    if (response.body.trim().isNotEmpty) {
      try {
        final dynamic decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          responseData = decoded;
        } else if (decoded is Map) {
          responseData = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        // Preserve fallback message below.
      }
    }

    throw Exception(responseData['message'] ?? 'Unable to reset password.');
  }
}
