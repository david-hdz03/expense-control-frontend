import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/auth_provider.dart';
import 'providers/auth_state.dart';
import 'screens/email_verification_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/theme.dart';

class ExpenseControlApp extends ConsumerWidget {
  const ExpenseControlApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return MaterialApp(
      title: 'FlowCash',
      debugShowCheckedModeBanner: false,
      theme: FlowCashTheme.darkTheme(),
      darkTheme: FlowCashTheme.darkTheme(),
      themeMode: ThemeMode.dark,
      home: switch (authState) {
        AuthUnknown() => const SplashScreen(),
        AuthUnauthenticated() => const LoginScreen(),
        AuthPendingVerification(:final email, :final debugCode) =>
          EmailVerificationScreen(email: email, debugCode: debugCode),
        AuthAuthenticated() => const HomeScreen(),
      },
    );
  }
}
