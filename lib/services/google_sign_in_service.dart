import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static const _webClientId =
      String.fromEnvironment('GOOGLE_CLIENT_ID_WEB');

  static final GoogleSignIn _web = GoogleSignIn(
    clientId: _webClientId,
    scopes: ['email', 'profile'],
  );

  static final GoogleSignIn _mobile = GoogleSignIn(
    serverClientId: _webClientId,
    scopes: ['email', 'profile'],
  );

  static GoogleSignIn get _instance => kIsWeb ? _web : _mobile;

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
