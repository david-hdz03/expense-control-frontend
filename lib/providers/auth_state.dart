import '../models/user.dart';

sealed class AuthState {
  const AuthState();
}

class AuthUnknown extends AuthState {
  const AuthUnknown();
}

class AuthUnauthenticated extends AuthState {
  final String? errorMessage;
  const AuthUnauthenticated({this.errorMessage});
}

class AuthPendingVerification extends AuthState {
  final String email;
  final String? debugCode; // solo en DEBUG=true
  const AuthPendingVerification({required this.email, this.debugCode});
}

class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);
}
