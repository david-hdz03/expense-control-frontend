import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../theme/tokens.dart';
import '../widgets/flowcash_widgets.dart';


class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _paternalLastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreeToTerms = false;
  bool _submitting = false;
  String? _errorMessage;
  String _selectedCurrency = 'USD';

  @override
  void dispose() {
    _nameController.dispose();
    _paternalLastNameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa una contraseÃ±a';
    if (value.length < 8) return 'MÃ­nimo 8 caracteres';
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Incluye al menos una mayÃºscula';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Incluye al menos un nÃºmero';
    }
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(value)) {
      return 'Incluye al menos un sÃ­mbolo';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      setState(() => _errorMessage = 'Debes aceptar los Términos de Servicio');
      return;
    }
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      final age = int.tryParse(_ageController.text) ?? 0;
      await ref.read(authProvider.notifier).register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim(),
            paternalLastName: _paternalLastNameController.text.trim(),
            age: age,
            currencyCode: _selectedCurrency,
          );
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top + 12),
                    // Back button
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white.withOpacity(0.06),
                        border: Border.all(color: FlowCashTokens.borderDark),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(12),
                          child: const Icon(
                            Icons.chevron_left,
                            color: FlowCashTokens.textDark,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Heading
                    const Text(
                      'Crea tu ',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1,
                        color: FlowCashTokens.textDark,
                        height: 1.05,
                      ),
                    ),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [FlowCashTokens.indigo, FlowCashTokens.teal],
                      ).createShader(bounds),
                      child: const Text(
                        'flujo',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                          color: Colors.white,
                          height: 1.05,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Empieza a registrar en menos de un minuto.',
                      style: TextStyle(
                        fontSize: 14,
                        color: FlowCashTokens.textDarkMuted,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildForm(context),
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
  // Web layout — two-column
  // -------------------------------------------------------------------------
  Widget _buildWebLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: FlowCashTokens.bgDark,
      body: Row(
        children: [
          // Left: deco panel with features
          Expanded(
            child: WebDecoPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Headline
                  const Text(
                    'Únete a miles de personas\nque ya controlan su ',
                    style: TextStyle(
                      fontFamily: 'Space Grotesk',
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.5,
                      height: 1.1,
                      color: FlowCashTokens.textDark,
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [FlowCashTokens.indigo, FlowCashTokens.teal],
                    ).createShader(bounds),
                    child: const Text(
                      'flujo.',
                      style: TextStyle(
                        fontFamily: 'Space Grotesk',
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.5,
                        height: 1.1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Feature list
                  _FeatureItem(
                    icon: Icons.bolt,
                    gradientColors: const [
                      FlowCashTokens.indigo,
                      FlowCashTokens.teal
                    ],
                    title: 'Registra en segundos',
                    subtitle: 'Registra cualquier movimiento con un toque.',
                  ),
                  const SizedBox(height: 16),
                  _FeatureItem(
                    icon: Icons.bar_chart,
                    gradientColors: const [
                      FlowCashTokens.teal,
                      FlowCashTokens.lime
                    ],
                    title: 'Ve el panorama completo',
                    subtitle: 'Desglose mensual por categoría.',
                  ),
                  const SizedBox(height: 16),
                  _FeatureItem(
                    icon: Icons.auto_awesome,
                    gradientColors: const [
                      FlowCashTokens.indigoDeep,
                      FlowCashTokens.indigo
                    ],
                    title: 'Análisis inteligente',
                    subtitle: 'Detecta tendencias antes de que te cuesten.',
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
                    'Crear cuenta',
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
                    'Empieza a registrar en menos de un minuto.',
                    style: TextStyle(
                      fontSize: 14,
                      color: FlowCashTokens.textDarkMuted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildForm(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Shared form (used by both layouts)
  // -------------------------------------------------------------------------
  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FloatingInput(
            label: 'Nombre completo',
            value: '',
            icon: Icons.person_outline,
            controller: _nameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ingresa tu nombre completo';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          FloatingInput(
            label: 'Apellido paterno',
            value: '',
            icon: Icons.person_outline,
            controller: _paternalLastNameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ingresa tu apellido paterno';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FloatingInput(
                  label: 'Edad',
                  value: '',
                  icon: Icons.cake_outlined,
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa tu edad';
                    }
                    final age = int.tryParse(value);
                    if (age == null || age < 13 || age > 120) {
                      return 'Edad inválida';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFF1A1A2E),
                    border: Border.all(color: FlowCashTokens.borderDark),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedCurrency,
                    isExpanded: true,
                    underline: const SizedBox(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: FlowCashTokens.textDark,
                    ),
                    dropdownColor: const Color(0xFF232340),
                    items: ['USD', 'EUR', 'MXN', 'ARS', 'CLP'].map((v) {
                      return DropdownMenuItem<String>(
                        value: v,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(v),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedCurrency = v);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FloatingInput(
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
          const SizedBox(height: 12),
          FloatingInput(
            label: 'Contraseña',
            value: '',
            icon: Icons.lock_outline,
            controller: _passwordController,
            isPassword: true,
            validator: _validatePassword,
          ),
          const SizedBox(height: 12),
          PasswordStrengthMeter(password: _passwordController.text),
          const SizedBox(height: 12),
          FloatingInput(
            label: 'Confirmar contraseña',
            value: '',
            icon: Icons.lock_outline,
            controller: _confirmPasswordController,
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
          const SizedBox(height: 18),
          // Terms checkbox
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    gradient: _agreeToTerms
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              FlowCashTokens.indigo,
                              FlowCashTokens.teal,
                            ],
                          )
                        : null,
                    border: !_agreeToTerms
                        ? Border.all(
                            color: FlowCashTokens.borderDark, width: 1.5)
                        : null,
                    boxShadow: _agreeToTerms
                        ? [
                            BoxShadow(
                              color: FlowCashTokens.indigo.withOpacity(0.5),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () =>
                          setState(() => _agreeToTerms = !_agreeToTerms),
                      borderRadius: BorderRadius.circular(7),
                      child: _agreeToTerms
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: 'Acepto los ',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: FlowCashTokens.textDarkMuted,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: 'Términos de Servicio',
                          style: const TextStyle(
                            color: FlowCashTokens.teal,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () =>
                                setState(() => _agreeToTerms = !_agreeToTerms),
                        ),
                        const TextSpan(
                          text: ' y la ',
                          style: TextStyle(color: FlowCashTokens.textDarkMuted),
                        ),
                        TextSpan(
                          text: 'Política de Privacidad',
                          style: const TextStyle(
                            color: FlowCashTokens.teal,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () =>
                                Navigator.of(context).pushNamed('/privacy'),
                        ),
                        const TextSpan(
                          text: ' de FlowCash.',
                          style: TextStyle(color: FlowCashTokens.textDarkMuted),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
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
            text: 'Crear cuenta',
            onPressed: _submit,
            isLoading: _submitting,
            enabled: !_submitting,
          ),
          const SizedBox(height: 20),
          Center(
            child: RichText(
              text: TextSpan(
                text: '¿Ya tienes cuenta? ',
                style: const TextStyle(
                  fontSize: 14,
                  color: FlowCashTokens.textDarkMuted,
                ),
                children: [
                  TextSpan(
                    text: 'Inicia sesión',
                    style: const TextStyle(
                      color: FlowCashTokens.teal,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _FeatureItem — icon tile + title + subtitle for web deco panel
// ---------------------------------------------------------------------------

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final List<Color> gradientColors;
  final String title;
  final String subtitle;

  const _FeatureItem({
    required this.icon,
    required this.gradientColors,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            boxShadow: [
              BoxShadow(
                color: gradientColors.first.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: FlowCashTokens.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: FlowCashTokens.textDarkMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
