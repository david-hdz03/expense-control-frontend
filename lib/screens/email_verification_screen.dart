import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../theme/tokens.dart';
import '../widgets/flowcash_widgets.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  final String email;
  final String? debugCode;

  const EmailVerificationScreen({
    super.key,
    required this.email,
    this.debugCode,
  });

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _submitting = false;
  bool _resending = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    // En modo DEBUG el código viene en la respuesta
    if (widget.debugCode != null) _fillDebugCode(widget.debugCode!);
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _fullCode => _controllers.map((c) => c.text).join();

  void _fillDebugCode(String code) {
    if (code.length != 6) return;
    for (var i = 0; i < 6; i++) {
      _controllers[i].text = code[i];
    }
  }

  Future<void> _submit() async {
    final code = _fullCode;
    if (code.length < 6) {
      setState(() => _errorMessage = 'Ingresa los 6 dígitos del código');
      return;
    }
    setState(() {
      _submitting = true;
      _errorMessage = null;
      _successMessage = null;
    });
    try {
      await ref
          .read(authProvider.notifier)
          .verifyEmail(email: widget.email, code: code);
      // El notifier pone estado AuthUnauthenticated → app navega al login
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _resend() async {
    setState(() {
      _resending = true;
      _errorMessage = null;
      _successMessage = null;
    });
    try {
      final debugCode =
          await ref.read(authProvider.notifier).resendCode(email: widget.email);
      if (!mounted) return;
      if (debugCode != null && debugCode.length == 6) {
        _fillDebugCode(debugCode);
      }
      setState(() {
        _successMessage = debugCode != null
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

  // ── Mobile layout ──────────────────────────────────────────────────────────
  Widget _buildMobileLayout() {
    return AmbientGradient(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _buildForm(),
            ),
          ),
        ),
      ),
    );
  }

  // ── Web layout ─────────────────────────────────────────────────────────────
  Widget _buildWebLayout() {
    return Row(
      children: [
        Expanded(
          child: WebDecoPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Verifica tu\ncorreo electrónico.',
                  style: TextStyle(
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
                  'Te enviamos un código de 6 dígitos a ${widget.email}. '
                  'Ingrésalo para activar tu cuenta.',
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
            child: _buildForm(),
          ),
        ),
      ],
    );
  }

  // ── Shared form ────────────────────────────────────────────────────────────
  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const FlowCashLogoMark(size: 56),
        const SizedBox(height: 24),
        const Text(
          'Verifica tu correo',
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
              const TextSpan(text: 'Enviamos un código a '),
              TextSpan(
                text: widget.email,
                style: const TextStyle(
                  color: FlowCashTokens.teal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // 6-digit boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
              6,
              (i) => _CodeBox(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    onChanged: (v) {
                      if (v.length == 1 && i < 5) {
                        _focusNodes[i + 1].requestFocus();
                      } else if (v.isEmpty && i > 0) {
                        _focusNodes[i - 1].requestFocus();
                      }
                      setState(() {});
                    },
                  )),
        ),
        const SizedBox(height: 24),
        // Error / success
        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: FlowCashTokens.coral.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: FlowCashTokens.coral.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline,
                    color: FlowCashTokens.coral, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_errorMessage!,
                      style: const TextStyle(
                          color: FlowCashTokens.coral, fontSize: 13)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (_successMessage != null) ...[
          Container(
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
                  child: Text(_successMessage!,
                      style: const TextStyle(
                          color: FlowCashTokens.teal, fontSize: 13)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        // Submit
        GradientButton(
          text: 'Verificar cuenta',
          onPressed: _submit,
          isLoading: _submitting,
          enabled: !_submitting && _fullCode.length == 6,
        ),
        const SizedBox(height: 20),
        // Resend
        Center(
          child: _resending
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : GestureDetector(
                  onTap: _resend,
                  child: RichText(
                    text: const TextSpan(
                      text: '¿No recibiste el código? ',
                      style: TextStyle(
                          fontSize: 14, color: FlowCashTokens.textDarkMuted),
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

// ── Single digit box ──────────────────────────────────────────────────────────

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
