import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'push_registration_service.dart';

class AuthService {
  final PushRegistrationService _pushRegistrationService =
      PushRegistrationService();

  Future<void> _syncPushRegistration(Map<String, dynamic> responseData) async {
    final dynamic tokenValue = responseData['token'];
    if (tokenValue is! String || tokenValue.trim().isEmpty) {
      return;
    }

    try {
      await _pushRegistrationService.syncWithToken(token: tokenValue);
    } catch (_) {
      // Push registration is best-effort and must never fail authentication.
    }
  }

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
        // Keep the fallback error below if the
        // backend response is not valid JSON.
      }
    }

    if (response.statusCode == 200) {
      await _syncPushRegistration(responseData);
      return responseData;
    }

    throw Exception(
      responseData['message'] ??
          'Unable to sign in. Server returned ${response.statusCode}.',
    );
  }

  Future<Map<String, dynamic>> verifyMfa({
    required String email,
    required String code,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/api/users/verify-mfa');

    final http.Response response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
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
      await _syncPushRegistration(responseData);
      return responseData;
    }

    throw Exception(
      responseData['message'] ?? 'Unable to verify the sign-in code.',
    );
  }

  Future<void> resendMfaCode({required String email}) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/api/users/resend-mfa');

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
      responseData['message'] ?? 'Unable to resend the sign-in code.',
    );
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

  Future<List<Map<String, dynamic>>> getAllUsers({
    required String token,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/api/users');

    final http.Response response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
      throw Exception('Unexpected user list response from the server.');
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
      } catch (_) {}
    }

    if (response.statusCode == 401) {
      throw Exception('Your Link Ride session is no longer valid.');
    }
    if (response.statusCode == 403) {
      throw Exception('This account is not allowed to view Link Ride users.');
    }

    throw Exception(
      responseData['message'] ??
          'Unable to load users. Server returned ${response.statusCode}.',
    );
  }

  Future<Map<String, dynamic>> updateUserRole({
    required String token,
    required int userId,
    required String role,
  }) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/api/users/$userId/role');

    final http.Response response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'role': role}),
    );

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
        // Preserve the fallback error below for non-JSON responses.
      }
    }

    if (response.statusCode == 200) {
      return responseData;
    }

    if (response.statusCode == 400) {
      throw Exception(
        responseData['message'] ?? 'This role change is not allowed.',
      );
    }

    if (response.statusCode == 401) {
      throw Exception('Your Link Ride session is no longer valid.');
    }

    if (response.statusCode == 403) {
      throw Exception('This account is not allowed to manage operator roles.');
    }

    if (response.statusCode == 404) {
      throw Exception('The selected Link Ride user could not be found.');
    }

    throw Exception(
      responseData['message'] ??
          'Unable to update the user role. '
              'Server returned ${response.statusCode}.',
    );
  }
}
