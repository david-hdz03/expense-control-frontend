class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String,
      expiresIn: json['expires_in'] as int,
    );
  }
}

class RegisterResponse {
  final bool requiresVerification;
  final DateTime verificationExpiresAt;
  final String? verificationCode; // solo en DEBUG=true

  const RegisterResponse({
    required this.requiresVerification,
    required this.verificationExpiresAt,
    this.verificationCode,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      requiresVerification: json['requires_verification'] as bool? ?? true,
      verificationExpiresAt: DateTime.parse(
          json['verification_expires_at'] as String),
      verificationCode: json['verification_code'] as String?,
    );
  }
}
