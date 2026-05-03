import 'package:expense_control/models/auth_tokens.dart';
import 'package:expense_control/providers/auth_provider.dart';
import 'package:expense_control/providers/auth_state.dart';
import 'package:expense_control/screens/login_screen.dart';
import 'package:expense_control/services/auth_service.dart';
import 'package:expense_control/services/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTokenStorage implements TokenStorage {
  String? _access;
  String? _refresh;

  @override
  Future<String?> readAccessToken() async => _access;

  @override
  Future<String?> readRefreshToken() async => _refresh;

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    _access = tokens.accessToken;
    _refresh = tokens.refreshToken;
  }

  @override
  Future<void> clear() async {
    _access = null;
    _refresh = null;
  }
}

class _FakeAuthService extends AuthService {
  _FakeAuthService({
    this.loginStatusCode = 401,
    this.resendDebugCode,
  });

  final int loginStatusCode;
  final String? resendDebugCode;

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    if (loginStatusCode == 403) {
      throw AuthException(403, 'Cuenta no verificada');
    }
    throw AuthException(401, 'Credenciales invalidas');
  }

  @override
  Future<VerificationRequestResult> resendCode({required String email}) async {
    return VerificationRequestResult(
      expiresAt: DateTime.now().add(const Duration(minutes: 15)),
      verificationCode: resendDebugCode,
    );
  }
}

void main() {
  testWidgets('LoginScreen muestra campos y boton', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
          authServiceProvider.overrideWithValue(_FakeAuthService()),
          authProvider.overrideWith(
            (ref) => AuthNotifier(
              authService: ref.watch(authServiceProvider),
              tokenStorage: ref.watch(tokenStorageProvider),
            )..state = const AuthUnauthenticated(),
          ),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.byKey(const Key('login-email')), findsOneWidget);
    expect(find.byKey(const Key('login-password')), findsOneWidget);
    expect(find.byKey(const Key('login-submit')), findsOneWidget);
  });

  test('AuthNotifier envia a verificacion cuando login responde 403', () async {
    final notifier = AuthNotifier(
      authService: _FakeAuthService(loginStatusCode: 403),
      tokenStorage: _FakeTokenStorage(),
    );

    await notifier.login(email: 'no-verificado@example.com', password: 'x');

    final state = notifier.state;
    expect(state, isA<AuthPendingVerification>());
    expect(
        (state as AuthPendingVerification).email, 'no-verificado@example.com');
  });

  test('AuthNotifier actualiza debugCode cuando reenvia codigo', () async {
    final notifier = AuthNotifier(
      authService: _FakeAuthService(resendDebugCode: '654321'),
      tokenStorage: _FakeTokenStorage(),
    )..state = const AuthPendingVerification(email: 'demo@example.com');

    final debugCode = await notifier.resendCode(email: 'demo@example.com');

    expect(debugCode, '654321');
    final state = notifier.state;
    expect(state, isA<AuthPendingVerification>());
    expect((state as AuthPendingVerification).debugCode, '654321');
  });
}
