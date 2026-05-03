import 'dart:math' show pi;
import 'package:flutter/material.dart';
import '../theme/tokens.dart';

// ---------------------------------------------------------------------------
// FlowCashLogoMark — gradient container with custom SVG-derived painter
// ---------------------------------------------------------------------------

class FlowCashLogoMark extends StatelessWidget {
  final double size;
  final bool showShine;

  const FlowCashLogoMark({
    Key? key,
    this.size = 64,
    this.showShine = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FlowCashTokens.indigoDeep,
            FlowCashTokens.indigo,
            FlowCashTokens.teal,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: FlowCashTokens.indigo.withOpacity(0.6),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showShine)
            Positioned(
              top: -20,
              left: -20,
              right: 20,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.5),
                      Colors.white.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
          CustomPaint(
            size: Size(size * 0.6, size * 0.6),
            painter: _FlowCashLogoPainter(iconSize: size * 0.6),
          ),
        ],
      ),
    );
  }
}

class _FlowCashLogoPainter extends CustomPainter {
  final double iconSize;
  const _FlowCashLogoPainter({required this.iconSize});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;

    // Body path: M6,4 L19,4 L17,8 L9,8 L9,12 L16,12 L14,16 L9,16 L9,21 L5,23 L5,4 Z
    final bodyPaint = Paint()
      ..color = Colors.white.withOpacity(0.95)
      ..style = PaintingStyle.fill;

    final bodyPath = Path()
      ..moveTo(6 * scale, 4 * scale)
      ..lineTo(19 * scale, 4 * scale)
      ..lineTo(17 * scale, 8 * scale)
      ..lineTo(9 * scale, 8 * scale)
      ..lineTo(9 * scale, 12 * scale)
      ..lineTo(16 * scale, 12 * scale)
      ..lineTo(14 * scale, 16 * scale)
      ..lineTo(9 * scale, 16 * scale)
      ..lineTo(9 * scale, 21 * scale)
      ..lineTo(5 * scale, 23 * scale)
      ..lineTo(5 * scale, 4 * scale)
      ..close();

    canvas.drawPath(bodyPath, bodyPaint);

    // Tilde wave: M4,18 C7,17 9,19 12,18 C15,17 17,19 20,18
    final wavePaint = Paint()
      ..color = FlowCashTokens.lime
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * (size.width / 24)
      ..strokeCap = StrokeCap.round;

    final wavePath = Path()
      ..moveTo(4 * scale, 18 * scale)
      ..cubicTo(
        7 * scale, 17 * scale,
        9 * scale, 19 * scale,
        12 * scale, 18 * scale,
      )
      ..cubicTo(
        15 * scale, 17 * scale,
        17 * scale, 19 * scale,
        20 * scale, 18 * scale,
      );

    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(_FlowCashLogoPainter oldDelegate) =>
      oldDelegate.iconSize != iconSize;
}

// ---------------------------------------------------------------------------
// GoogleGMark — 4-color Google G logo using CustomPaint
// ---------------------------------------------------------------------------

class GoogleGMark extends StatelessWidget {
  final double size;
  const GoogleGMark({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleGPainter(size: size)),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  final double size;
  const _GoogleGPainter({required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final cx = canvasSize.width / 2;
    final cy = canvasSize.height / 2;
    final outerR = canvasSize.width * 0.45;
    final innerR = outerR * 0.58;
    final strokeW = outerR - innerR;
    final midR = (outerR + innerR) / 2;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: midR);

    // Blue: -90° to 0°
    _drawArc(canvas, rect, strokeW, -pi / 2, pi / 2, const Color(0xFF4285F4));
    // Green: 0° to 90°
    _drawArc(canvas, rect, strokeW, 0, pi / 2, const Color(0xFF34A853));
    // Yellow: 90° to 180°
    _drawArc(canvas, rect, strokeW, pi / 2, pi / 2, const Color(0xFFFBBC05));
    // Red: 180° to 270°
    _drawArc(canvas, rect, strokeW, pi, pi / 2, const Color(0xFFEA4335));

    // Blue horizontal bar (the crossbar of the G)
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    final barTop = cy - strokeW / 2;
    final barBottom = cy + strokeW / 2;
    final barLeft = cx; // from center to right edge
    final barRight = cx + outerR;

    canvas.drawRect(
      Rect.fromLTRB(barLeft, barTop, barRight, barBottom),
      barPaint,
    );
  }

  void _drawArc(
    Canvas canvas,
    Rect rect,
    double strokeWidth,
    double startAngle,
    double sweepAngle,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(_GoogleGPainter oldDelegate) => oldDelegate.size != size;
}

// ---------------------------------------------------------------------------
// GradientButton — full-width CTA with gradient fill and shine overlay
// ---------------------------------------------------------------------------

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool enabled;

  const GradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: enabled
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  FlowCashTokens.indigo,
                  FlowCashTokens.teal,
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  FlowCashTokens.indigo.withOpacity(0.5),
                  FlowCashTokens.teal.withOpacity(0.5),
                ],
              ),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: FlowCashTokens.indigo.withOpacity(0.55),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled && !isLoading ? onPressed : null,
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 28,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(18)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FloatingInput — styled TextFormField with label + prefix icon
// ---------------------------------------------------------------------------

class FloatingInput extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const FloatingInput({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  State<FloatingInput> createState() => _FloatingInputState();
}

class _FloatingInputState extends State<FloatingInput> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: FlowCashTokens.textDark,
      ),
      decoration: InputDecoration(
        label: Text(widget.label),
        prefixIcon: Icon(
          widget.icon,
          color: FlowCashTokens.textDarkMuted,
          size: 20,
        ),
        suffixIcon: widget.isPassword
            ? GestureDetector(
                onTap: () {
                  setState(() => _obscureText = !_obscureText);
                },
                child: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: FlowCashTokens.textDarkMuted,
                  size: 20,
                ),
              )
            : null,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        filled: true,
        fillColor: const Color(0xFF1A1A2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: FlowCashTokens.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: FlowCashTokens.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: FlowCashTokens.teal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: FlowCashTokens.coral),
        ),
        labelStyle: const TextStyle(
          color: FlowCashTokens.teal,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: FlowCashTokens.textDarkMuted,
        suffixIconColor: FlowCashTokens.textDarkMuted,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PasswordStrengthMeter
// ---------------------------------------------------------------------------

class PasswordStrengthMeter extends StatelessWidget {
  final String password;

  const PasswordStrengthMeter({
    Key? key,
    required this.password,
  }) : super(key: key);

  int _calculateStrength() {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    return strength;
  }

  @override
  Widget build(BuildContext context) {
    final strength = _calculateStrength();
    final colors = [
      FlowCashTokens.coral,
      FlowCashTokens.amber,
      FlowCashTokens.lime,
      FlowCashTokens.teal,
    ];
    final labels = ['Débil', 'Regular', 'Buena', 'Fuerte', 'Excelente'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(
            4,
            (i) => Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: i < strength
                      ? colors[strength - 1]
                      : const Color(0xFF2A2A3E),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Fortaleza de contraseña',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: FlowCashTokens.textDarkDim,
                letterSpacing: 0.2,
              ),
            ),
            Text(
              strength == 0 ? '' : labels[strength - 1],
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color:
                    strength == 0 ? Colors.transparent : colors[strength - 1],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// AmbientGradient — decorative radial blob overlay
// ---------------------------------------------------------------------------

class AmbientGradient extends StatelessWidget {
  final Widget child;

  const AmbientGradient({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -140,
          left: -80,
          child: Container(
            width: 340,
            height: 340,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  FlowCashTokens.indigo.withOpacity(0.55),
                  FlowCashTokens.indigo.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 80,
          right: -120,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  FlowCashTokens.teal.withOpacity(0.4),
                  FlowCashTokens.teal.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 200,
          left: 40,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  FlowCashTokens.coral.withOpacity(0.22),
                  FlowCashTokens.coral.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// WebDecoPanel — left decorative panel for auth web layout
// ---------------------------------------------------------------------------

class WebDecoPanel extends StatelessWidget {
  final Widget child;
  const WebDecoPanel({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: FlowCashTokens.bgDark2,
      child: Stack(
        children: [
          // Ambient blobs
          Positioned(
            top: -160,
            left: -100,
            child: Container(
              width: 480,
              height: 480,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    FlowCashTokens.indigo.withOpacity(0.45),
                    FlowCashTokens.indigo.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -80,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    FlowCashTokens.teal.withOpacity(0.35),
                    FlowCashTokens.teal.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 300,
            left: 80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    FlowCashTokens.coral.withOpacity(0.18),
                    FlowCashTokens.coral.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          // Logo top-left
          Positioned(
            top: 56,
            left: 64,
            child: Row(
              children: [
                const FlowCashLogoMark(size: 40, showShine: true),
                const SizedBox(width: 12),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [FlowCashTokens.indigo, FlowCashTokens.teal],
                  ).createShader(bounds),
                  child: const Text(
                    'FlowCash',
                    style: TextStyle(
                      fontFamily: 'Space Grotesk',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom content
          Positioned(
            bottom: 56,
            left: 64,
            right: 64,
            child: child,
          ),
          // Copyright
          const Positioned(
            bottom: 24,
            left: 64,
            child: Text(
              '© 2025 FlowCash. All rights reserved.',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 11,
                color: FlowCashTokens.textDarkDim,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// WebFormColumn — right column container for auth web layout
// ---------------------------------------------------------------------------

class WebFormColumn extends StatelessWidget {
  final Widget child;
  const WebFormColumn({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: FlowCashTokens.bgDark,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: child,
          ),
        ),
      ),
    );
  }
}
