import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static const _webClientId =
      String.fromEnvironment('GOOGLE_CLIENT_ID_WEB');

  static GoogleSignIn? _webInstance;
  static GoogleSignIn? _mobileInstance;

  static GoogleSignIn _getWeb() {
    if (_webClientId.isEmpty) {
      throw Exception(
        'GOOGLE_CLIENT_ID_WEB no configurado. '
        'Ejecuta con: flutter run --dart-define=GOOGLE_CLIENT_ID_WEB=<client-id>',
      );
    }
    return _webInstance ??= GoogleSignIn(
      clientId: _webClientId,
      scopes: ['email', 'profile'],
    );
  }

  static GoogleSignIn _getMobile() {
    if (_webClientId.isEmpty) {
      throw Exception(
        'GOOGLE_CLIENT_ID_WEB no configurado. '
        'Ejecuta con: flutter run --dart-define=GOOGLE_CLIENT_ID_WEB=<client-id>',
      );
    }
    return _mobileInstance ??= GoogleSignIn(
      serverClientId: _webClientId,
      scopes: ['email', 'profile'],
    );
  }

  static GoogleSignIn get _instance => kIsWeb ? _getWeb() : _getMobile();

  static Future<({String? idToken, String? accessToken})?> signIn() async {
    final account = await _instance.signIn();
    if (account == null) return null;
    final auth = await account.authentication;
    return (idToken: auth.idToken, accessToken: auth.accessToken);
  }

  static Future<void> signOut() async {
    await _instance.signOut();
  }
}
