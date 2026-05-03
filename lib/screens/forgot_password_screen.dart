import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../theme/tokens.dart';
import '../widgets/flowcash_widgets.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  final String? initialEmail;

  const ForgotPasswordScreen({super.key, this.initialEmail});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  int _step = 1;
  String _email = '';

  // Step 1
  final _emailFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  // Step 2 - OTP
  final List<TextEditingController> _codeControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  // Step 2 - passwords
  final _passwordFormKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _submitting = false;
  bool _resending = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null) {
      _emailController.text = widget.initialEmail!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _fullCode => _codeControllers.map((c) => c.text).join();

  void _fillDebugCode(String code) {
    if (code.length != 6) return;
    for (var i = 0; i < 6; i++) {
      _codeControllers[i].text = code[i];
    }
  }

  Future<void> _submitStep1() async {
    if (!_emailFormKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      final result = await ref.read(authServiceProvider).requestPasswordReset(
            email: _emailController.text.trim(),
          );
      if (!mounted) return;
      _email = _emailController.text.trim();
      setState(() {
        _step = 2;
        if (result.resetCode != null) _fillDebugCode(result.resetCode!);
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _submitStep2() async {
    final code = _fullCode;
    if (code.length < 6) {
      setState(() => _errorMessage = 'Ingresa los 6 dígitos del código');
      return;
    }
    if (!_passwordFormKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _errorMessage = null;
      _successMessage = null;
    });
    try {
      await ref.read(authServiceProvider).confirmPasswordReset(
            email: _email,
            code: code,
            newPassword: _passwordController.text,
          );
      if (!mounted) return;
      if (Navigator.canPop(context)) Navigator.pop(context);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _resendCode() async {
    setState(() {
      _resending = true;
      _errorMessage = null;
      _successMessage = null;
    });
    try {
      final result = await ref.read(authServiceProvider).requestPasswordReset(
            email: _email,
          );
      if (!mounted) return;
      if (result.resetCode != null) _fillDebugCode(result.resetCode!);
      setState(() {
        _successMessage = result.resetCode != null
            ? 'Código reenviado y cargado automáticamente.'
            : 'Código reenviado. Revisa tu correo.';
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width >= 900;
    return Scaffold(
      backgroundColor: FlowCashTokens.bgDark,
      body: isWeb ? _buildWebLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return AmbientGradient(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _step == 1 ? _buildStep1Form() : _buildStep2Form(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebLayout() {
    return Row(
      children: [
        Expanded(
          child: WebDecoPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _step == 1
                      ? 'Olvidaste\ntu contraseña.'
                      : 'Revisa tu\ncorreo.',
                  style: const TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.5,
                    color: FlowCashTokens.textDark,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  _step == 1
                      ? 'Ingresa tu correo y te enviaremos un código para restablecer tu contraseña.'
                      : 'Enviamos un código de 6 dígitos a $_email. Úsalo junto con tu nueva contraseña.',
                  style: const TextStyle(
                    fontSize: 16,
                    color: FlowCashTokens.textDarkMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: WebFormColumn(
            child: _step == 1 ? _buildStep1Form() : _buildStep2Form(),
          ),
        ),
      ],
    );
  }

  Widget _buildStep1Form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FlowCashLogoMark(size: 56),
        const SizedBox(height: 24),
        const Text(
          'Restablecer contraseña',
          style: TextStyle(
            fontFamily: 'Space Grotesk',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
            color: FlowCashTokens.textDark,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ingresa tu correo para recibir un código de verificación.',
          style: TextStyle(
            fontSize: 14,
            color: FlowCashTokens.textDarkMuted,
          ),
        ),
        const SizedBox(height: 32),
        Form(
          key: _emailFormKey,
          child: FloatingInput(
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
        ),
        const SizedBox(height: 20),
        if (_errorMessage != null) ...[
          _ErrorBox(message: _errorMessage!),
          const SizedBox(height: 16),
        ],
        GradientButton(
          text: 'Enviar código',
          onPressed: _submitStep1,
          isLoading: _submitting,
          enabled: !_submitting,
        ),
        const SizedBox(height: 20),
        Center(
          child: GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
            child: RichText(
              text: const TextSpan(
                text: '← ',
                style: TextStyle(
                  fontSize: 14,
                  color: FlowCashTokens.textDarkMuted,
                ),
                children: [
                  TextSpan(
                    text: 'Volver al inicio de sesión',
                    style: TextStyle(
                      color: FlowCashTokens.teal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2Form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FlowCashLogoMark(size: 56),
        const SizedBox(height: 24),
        const Text(
          'Nueva contraseña',
          style: TextStyle(
            fontFamily: 'Space Grotesk',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
            color: FlowCashTokens.textDark,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14,
              color: FlowCashTokens.textDarkMuted,
            ),
            children: [
              const TextSpan(text: 'Código enviado a '),
              TextSpan(
                text: _email,
                style: const TextStyle(
                  color: FlowCashTokens.teal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            6,
            (i) => _CodeBox(
              controller: _codeControllers[i],
              focusNode: _focusNodes[i],
              onChanged: (v) {
                if (v.length == 1 && i < 5) {
                  _focusNodes[i + 1].requestFocus();
                } else if (v.isEmpty && i > 0) {
                  _focusNodes[i - 1].requestFocus();
                }
                setState(() {});
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        Form(
          key: _passwordFormKey,
          child: Column(
            children: [
              FloatingInput(
                label: 'Nueva contraseña',
                value: '',
                icon: Icons.lock_outline,
                controller: _passwordController,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa tu nueva contraseña';
                  }
                  if (value.length < 8) return 'Mínimo 8 caracteres';
                  if (!value.contains(RegExp(r'[A-Z]'))) {
                    return 'Debe contener al menos una mayúscula';
                  }
                  if (!value.contains(RegExp(r'[0-9]'))) {
                    return 'Debe contener al menos un número';
                  }
                  if (!value.contains(RegExp(r'[^A-Za-z0-9]'))) {
                    return 'Debe contener al menos un símbolo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              FloatingInput(
                label: 'Confirmar contraseña',
                value: '',
                icon: Icons.lock_outline,
                controller: _confirmController,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirma tu contraseña';
                  }
                  if (value != _passwordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (_errorMessage != null) ...[
          _ErrorBox(message: _errorMessage!),
          const SizedBox(height: 16),
        ],
        if (_successMessage != null) ...[
          _SuccessBox(message: _successMessage!),
          const SizedBox(height: 16),
        ],
        GradientButton(
          text: 'Cambiar contraseña',
          onPressed: _submitStep2,
          isLoading: _submitting,
          enabled: !_submitting && _fullCode.length == 6,
        ),
        const SizedBox(height: 20),
        Center(
          child: _resending
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : GestureDetector(
                  onTap: _resendCode,
                  child: RichText(
                    text: const TextSpan(
                      text: '¿No recibiste el código? ',
                      style: TextStyle(
                        fontSize: 14,
                        color: FlowCashTokens.textDarkMuted,
                      ),
                      children: [
                        TextSpan(
                          text: 'Reenviar',
                          style: TextStyle(
                            color: FlowCashTokens.teal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

// ── Error banner ──────────────────────────────────────────────────────────────

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FlowCashTokens.coral.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FlowCashTokens.coral.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: FlowCashTokens.coral, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: FlowCashTokens.coral, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Success banner ────────────────────────────────────────────────────────────

class _SuccessBox extends StatelessWidget {
  final String message;
  const _SuccessBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FlowCashTokens.teal.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FlowCashTokens.teal.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              color: FlowCashTokens.teal, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: FlowCashTokens.teal, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single digit box (copied from email_verification_screen.dart) ─────────────

class _CodeBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _CodeBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = controller.text.isNotEmpty;
    return SizedBox(
      width: 46,
      height: 56,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: FlowCashTokens.textDark,
          letterSpacing: 0,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: hasValue
              ? FlowCashTokens.indigo.withOpacity(0.15)
              : Colors.white.withOpacity(0.04),
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: hasValue
                  ? FlowCashTokens.teal.withOpacity(0.6)
                  : FlowCashTokens.borderDark,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: FlowCashTokens.teal, width: 2),
          ),
        ),
      ),
    );
  }
}
