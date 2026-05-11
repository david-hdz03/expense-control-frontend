import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../services/google_sign_in_service.dart';
import '../theme/tokens.dart';
import '../widgets/flowcash_widgets.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      await ref.read(authProvider.notifier).login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      final tokens = await GoogleSignInService.signIn();
      if (tokens == null) return; // user cancelled
      if (tokens.idToken == null && tokens.accessToken == null) {
        if (mounted) setState(() => _errorMessage = 'No se obtuvo token de Google. Verifica la configuración.');
        return;
      }
      await ref.read(authProvider.notifier).loginWithGoogle(
            idToken: tokens.idToken,
            accessToken: tokens.accessToken,
          );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWeb = constraints.maxWidth >= 900;
        return isWeb ? _buildWebLayout(context) : _buildMobileLayout(context);
      },
    );
  }

  // -------------------------------------------------------------------------
  // Mobile layout (unchanged)
  // -------------------------------------------------------------------------
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: FlowCashTokens.bgDark,
      body: AmbientGradient(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top + 26),
                    // Logo + title
                    Column(
                      children: [
                        const FlowCashLogoMark(size: 64),
                        const SizedBox(height: 16),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              FlowCashTokens.indigo,
                              FlowCashTokens.teal,
                            ],
                          ).createShader(bounds),
                          child: const Text(
                            'FlowCash',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tu dinero, finalmente en flujo.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: FlowCashTokens.textDarkMuted,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildForm(context),
                    const SizedBox(height: 32),
                    _buildRegisterLink(context),
                    SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Web layout — two-column (deco panel left + form right)
  // -------------------------------------------------------------------------
  Widget _buildWebLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: FlowCashTokens.bgDark,
      body: Row(
        children: [
          // Left: deco panel
          Expanded(
            child: WebDecoPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Headline
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: 'Space Grotesk',
                        fontSize: 52,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -2,
                        height: 1.1,
                        color: FlowCashTokens.textDark,
                      ),
                      children: [
                        TextSpan(text: 'Tu dinero,\n'),
                        TextSpan(text: 'finalmente en '),
                        // "flow." handled below via ShaderMask inline trick
                      ],
                    ),
                  ),
                  // Gradient "flow." on its own line
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [FlowCashTokens.indigo, FlowCashTokens.teal],
                    ).createShader(bounds),
                    child: const Text(
                      'flow.',
                      style: TextStyle(
                        fontFamily: 'Space Grotesk',
                        fontSize: 52,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -2,
                        height: 1.1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const SizedBox(
                    width: 440,
                    child: Text(
                      'Registra cada peso, identifica patrones y mantén el control de tus gastos sin complicaciones.',
                      style: TextStyle(
                        fontSize: 16,
                        color: FlowCashTokens.textDarkMuted,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right: form column
          Expanded(
            child: WebFormColumn(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bienvenido de nuevo',
                    style: TextStyle(
                      fontFamily: 'Space Grotesk',
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1,
                      color: FlowCashTokens.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Inicia sesión para continuar.',
                    style: TextStyle(
                      fontSize: 14,
                      color: FlowCashTokens.textDarkMuted,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildForm(context),
                  const SizedBox(height: 28),
                  _buildRegisterLink(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Shared form content
  // -------------------------------------------------------------------------
  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          FloatingInput(
            key: const Key('login-email'),
            label: 'Correo electrónico',
            value: '',
            icon: Icons.mail_outline,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ingresa tu correo';
              }
              if (!value.contains('@')) return 'Correo inválido';
              return null;
            },
          ),
          const SizedBox(height: 14),
          FloatingInput(
            key: const Key('login-password'),
            label: 'Contraseña',
            value: '',
            icon: Icons.lock_outline,
            controller: _passwordController,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Ingresa tu contraseña';
              return null;
            },
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _submitting
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ForgotPasswordScreen(
                          initialEmail: _emailController.text.trim(),
                        ),
                      ),
                    ),
              child: const Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: FlowCashTokens.teal,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: FlowCashTokens.coral.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: FlowCashTokens.coral.withOpacity(0.5),
                ),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  fontSize: 13,
                  color: FlowCashTokens.coral,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          GradientButton(
            key: const Key('login-submit'),
            text: 'Iniciar sesión',
            onPressed: _submit,
            isLoading: _submitting,
            enabled: !_submitting,
          ),
          const SizedBox(height: 22),
          // Divider
          Row(
            children: [
              Expanded(
                child: Container(height: 1, color: FlowCashTokens.borderDark),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'o continuar con',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: FlowCashTokens.textDarkDim,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              Expanded(
                child: Container(height: 1, color: FlowCashTokens.borderDark),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Google button
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withOpacity(0.04),
              border: Border.all(color: FlowCashTokens.borderDarkStrong),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _submitting ? null : _googleSignIn,
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    GoogleGMark(size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Continuar con Google',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: FlowCashTokens.textDark,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterLink(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: '¿No tienes cuenta? ',
          style: const TextStyle(
            fontSize: 14,
            color: FlowCashTokens.textDarkMuted,
          ),
          children: [
            TextSpan(
              text: 'Regístrate',
              style: const TextStyle(
                color: FlowCashTokens.teal,
                fontWeight: FontWeight.w600,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const RegisterScreen(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
