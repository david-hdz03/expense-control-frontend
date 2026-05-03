import 'package:flutter/material.dart';

/// FlowCash Design Tokens
/// Dark mode primary palette: Electric Indigo → Neon Teal
abstract class FlowCashTokens {
  // Backgrounds
  static const bgDark = Color(0xFF0B0B14);
  static const bgDark2 = Color(0xFF12121F);
  static const surface = Color(0xFF1A1A2E);
  static const surfaceElev = Color(0xFF232340);

  // Light mode
  static const bgLight = Color(0xFFF6F5FB);
  static const bgLight2 = Color(0xFFECEBF5);
  static const surfaceLight = Color(0xFFFFFFFF);

  // Text
  static const textDark = Color(0xFFFFFFFF);
  static const textDarkMuted = Color(0xFF9E9E9E);
  static const textDarkDim = Color(0xFF757575);
  static const textLight = Color(0xFF0B0B14);
  static const textLightMuted = Color(0xFF6B6B7F);
  static const textLightDim = Color(0xFF4D4D6B);

  // Brand neons
  static const indigo = Color(0xFF7B5CFF);
  static const indigoDeep = Color(0xFF4B2EFF);
  static const teal = Color(0xFF2EE6CA);
  static const tealDeep = Color(0xFF00C2A8);
  static const lime = Color(0xFFC6FF4B);
  static const coral = Color(0xFFFF5E7A);
  static const coralDeep = Color(0xFFFF3D5F);
  static const amber = Color(0xFFFFB545);

  // Category accents
  static const Map<String, Color> categoryColors = {
    'food': Color(0xFFFF8A3D),
    'transport': Color(0xFF4DA3FF),
    'salary': Color(0xFF2EE6CA),
    'entertainment': Color(0xFFB87BFF),
    'shopping': Color(0xFFFF5E7A),
    'bills': Color(0xFFFFB545),
    'health': Color(0xFF68E3A0),
    'gift': Color(0xFFFF7ACB),
  };

  // Borders
  static const borderDark = Color(0x14FFFFFF);
  static const borderDarkStrong = Color(0x24FFFFFF);
  static const borderLight = Color(0x08141428);
}
