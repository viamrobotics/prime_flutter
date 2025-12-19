// ignore_for_file: provide_deprecation_message

import 'dart:ui';

class PrimeColors {
  PrimeColors._();

  // --- Primitives ---

  // Grayscale
  static const Color gray9 = Color(0xFF282829);
  static const Color gray8 = Color(0xFF4E4F52);
  static const Color gray7 = Color(0xFF7A7C80);
  static const Color gray6 = Color(0xFF9C9CA4);
  static const Color gray5 = Color(0xFFC5C6CC);
  static const Color gray2 = Color(0xFFEDEEF0);
  static const Color gray1 = Color(0xFFFBFBFC);
  static const Color gray0 = Color(0xFFFFFFFF);

  // Status/Semantic Primitives
  // TODO: prefer light / dark names isntead of Bg / Fg
  static const Color dangerBg = Color(0xFFFCECEA);
  static const Color dangerFg = Color(0xFFBE3536);
  static const Color infoBg = Color(0xFFE1F3FF);
  static const Color infoFg = Color(0xFF2E67D3);
  static const Color successFg = Color(0xFF3D7D3F);
  static const Color warningFg = Color(0xFFD97706);

  // Hardcoded / Specific
  static const Color focusBlue = Color(0xFF007AFF);
  static const Color borderSubtle = Color(0x14000000);
}
