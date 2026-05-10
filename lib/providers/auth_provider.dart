import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../services/token_storage.dart';
import 'auth_state.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    authService: ref.watch(authServiceProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final TokenStorage _tokenStorage;

  AuthNotifier({
    required AuthService authService,
    required TokenStorage tokenStorage,
  })  : _authService = authService,
        _tokenStorage = tokenStorage,
        super(const AuthUnknown());

  Future<void> bootstrap() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null) {
      state = const AuthUnauthenticated();
      return;
    }
    try {
      final tokens = await _authService.refresh(refreshToken);
      await _tokenStorage.saveTokens(tokens);
      final user = await _authService.fetchMe(tokens.accessToken);
      state = AuthAuthenticated(user);
    } on AuthException {
      await _tokenStorage.clear();
      state = const AuthUnauthenticated();
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      final tokens = await _authService.login(email: email, password: password);
      await _tokenStorage.saveTokens(tokens);
      final user = await _authService.fetchMe(tokens.accessToken);
      state = AuthAuthenticated(user);
    } on AuthException catch (e) {
      if (e.statusCode == 403) {
        state = AuthPendingVerification(email: email.trim());
        return;
      }
      state = AuthUnauthenticated(errorMessage: e.message);
      rethrow;
    }
  }

  Future<void> loginWithGoogle({String? idToken, String? accessToken}) async {
    try {
      final tokens = await _authService.loginWithGoogle(
        idToken: idToken,
        accessToken: accessToken,
      );
      await _tokenStorage.saveTokens(tokens);
      final user = await _authService.fetchMe(tokens.accessToken);
      state = AuthAuthenticated(user);
    } on AuthException catch (e) {
      state = AuthUnauthenticated(errorMessage: e.message);
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String paternalLastName,
    required int age,
    required String currencyCode,
  }) async {
    try {
      final result = await _authService.register(
        email: email,
        password: password,
        name: name,
        paternalLastName: paternalLastName,
        age: age,
        currencyCode: currencyCode,
      );
      state = AuthPendingVerification(
        email: email.trim(),
        debugCode: result.verificationCode,
      );
    } on AuthException catch (e) {
      state = AuthUnauthenticated(errorMessage: e.message);
      rethrow;
    }
  }

  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    final tokens = await _authService.verifyEmail(email: email, code: code);
    await _tokenStorage.saveTokens(tokens);
    final user = await _authService.fetchMe(tokens.accessToken);
    state = AuthAuthenticated(user);
  }

  Future<String?> resendCode({required String email}) async {
    final normalizedEmail = email.trim();
    final result = await _authService.resendCode(email: normalizedEmail);
    final currentState = state;
    if (currentState is AuthPendingVerification &&
        currentState.email == normalizedEmail) {
      state = AuthPendingVerification(
        email: normalizedEmail,
        debugCode: result.verificationCode ?? currentState.debugCode,
      );
    }
    return result.verificationCode;
  }

  Future<void> logout() async {
    await _tokenStorage.clear();
    state = const AuthUnauthenticated();
  }

  Future<void> forceLogout() async {
    await _tokenStorage.clear();
    state = const AuthUnauthenticated(
      errorMessage: 'Sesión expirada. Inicia sesión nuevamente.',
    );
  }
}
