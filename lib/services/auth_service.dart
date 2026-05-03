import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/auth_tokens.dart';
import '../models/user.dart';
import 'api_config.dart';

class AuthException implements Exception {
  final int statusCode;
  final String message;

  AuthException(this.statusCode, this.message);

  @override
  String toString() => 'AuthException($statusCode): $message';
}

class AuthExpiredException extends AuthException {
  AuthExpiredException(String message) : super(401, message);
}

class VerificationRequestResult {
  final DateTime expiresAt;
  final String? verificationCode;

  const VerificationRequestResult({
    required this.expiresAt,
    this.verificationCode,
  });

  factory VerificationRequestResult.fromJson(Map<String, dynamic> json) {
    return VerificationRequestResult(
      expiresAt: DateTime.parse(json['expires_at'] as String),
      verificationCode: json['verification_code'] as String?,
    );
  }
}

class PasswordResetRequestResult {
  final DateTime expiresAt;
  final String? resetCode;

  const PasswordResetRequestResult({
    required this.expiresAt,
    this.resetCode,
  });

  factory PasswordResetRequestResult.fromJson(Map<String, dynamic> json) {
    return PasswordResetRequestResult(
      expiresAt: DateTime.parse(json['expires_at'] as String),
      resetCode: json['reset_code'] as String?,
    );
  }
}

class AuthService {
  final http.Client _client;

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  Future<RegisterResponse> register({
    required String email,
    required String password,
    required String name,
    required String paternalLastName,
    required int age,
    required String currencyCode,
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/register'),
      headers: const {'Content-Type': 'application/json'},
      body: utf8.encode(jsonEncode({
        'email': email,
        'password': password,
        'name': name,
        'paternal_last_name': paternalLastName,
        'age': age,
        'currency_code': currencyCode,
      })),
    );
    if (response.statusCode != 201) {
      throw AuthException(response.statusCode, _extractError(response.body));
    }
    return RegisterResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/login'),
      headers: const {'Content-Type': 'application/json'},
      body: utf8.encode(jsonEncode({'email': email, 'password': password})),
    );
    if (response.statusCode == 403) {
      throw AuthException(
          403, 'Cuenta no verificada. Revisa tu correo y confirma el código.');
    }
    if (response.statusCode != 200) {
      throw AuthException(response.statusCode, _extractError(response.body));
    }
    return AuthTokens.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<AuthTokens> verifyEmail({
    required String email,
    required String code,
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/verification/confirm'),
      headers: const {'Content-Type': 'application/json'},
      body: utf8.encode(jsonEncode({'email': email, 'code': code})),
    );
    if (response.statusCode == 400) {
      throw AuthException(400, 'Código inválido. Inténtalo de nuevo.');
    }
    if (response.statusCode == 410) {
      throw AuthException(410, 'El código ha expirado. Solicita uno nuevo.');
    }
    if (response.statusCode != 200) {
      throw AuthException(response.statusCode, _extractError(response.body));
    }
    return AuthTokens.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<VerificationRequestResult> resendCode({required String email}) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/verification/request'),
      headers: const {'Content-Type': 'application/json'},
      body: utf8.encode(jsonEncode({'email': email})),
    );
    if (response.statusCode == 409) {
      throw AuthException(409, 'La cuenta ya está verificada.');
    }
    if (response.statusCode != 200) {
      throw AuthException(response.statusCode, _extractError(response.body));
    }
    return VerificationRequestResult.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<AuthTokens> refresh(String refreshToken) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/refresh'),
      headers: const {'Content-Type': 'application/json'},
      body: utf8.encode(jsonEncode({'refresh_token': refreshToken})),
    );
    if (response.statusCode == 401) {
      throw AuthExpiredException(_extractError(response.body));
    }
    if (response.statusCode != 200) {
      throw AuthException(response.statusCode, _extractError(response.body));
    }
    return AuthTokens.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<User> fetchMe(String accessToken) async {
    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/me'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode == 401) {
      throw AuthExpiredException(_extractError(response.body));
    }
    if (response.statusCode != 200) {
      throw AuthException(response.statusCode, _extractError(response.body));
    }
    return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<PasswordResetRequestResult> requestPasswordReset({
    required String email,
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/forgot-password'),
      headers: const {'Content-Type': 'application/json'},
      body: utf8.encode(jsonEncode({'email': email})),
    );
    if (response.statusCode == 404) {
      throw AuthException(404, 'No existe una cuenta con ese correo.');
    }
    if (response.statusCode != 200) {
      throw AuthException(response.statusCode, _extractError(response.body));
    }
    return PasswordResetRequestResult.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/reset-password'),
      headers: const {'Content-Type': 'application/json'},
      body: utf8.encode(jsonEncode({
        'email': email,
        'code': code,
        'new_password': newPassword,
      })),
    );
    if (response.statusCode == 400) {
      throw AuthException(400, 'Código inválido. Inténtalo de nuevo.');
    }
    if (response.statusCode == 410) {
      throw AuthException(410, 'El código ha expirado. Solicita uno nuevo.');
    }
    if (response.statusCode == 404) {
      throw AuthException(404, _extractError(response.body));
    }
    if (response.statusCode != 200) {
      throw AuthException(response.statusCode, _extractError(response.body));
    }
  }

  String _extractError(String body) {
    if (body.isEmpty) return 'Error';
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['detail'] != null) {
        final detail = decoded['detail'];
        if (detail is String) return detail;
        if (detail is List && detail.isNotEmpty) {
          final first = detail.first;
          if (first is Map && first['msg'] != null) {
            return first['msg'].toString();
          }
          return first.toString();
        }
        return detail.toString();
      }
    } catch (_) {}
    return body;
  }
}
