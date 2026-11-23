// ignore_for_file: provide_deprecation_message

import 'dart:ui';

class PrimeColors {
  PrimeColors._();

  // --- Primitives ---

  // Grayscale
  static const Color black = Color(0xFF000000);
  static const Color gray9_5 = Color(0xFF131414);
  static const Color gray9 = Color(0xFF282829);
  static const Color gray8 = Color(0xFF4E4F52);
  static const Color gray7_5 = Color(0xFF646569);
  static const Color gray7 = Color(0xFF7A7C80);
  static const Color gray6 = Color(0xFF9C9CA4);
  static const Color gray5 = Color(0xFFC5C6CC);
  static const Color gray2 = Color(0xFFEDEEF0);
  static const Color gray1_5 = Color(0xFFF1F1F4);
  static const Color gray1 = Color(0xFFFBFBFC);
  static const Color gray0 = Color(0xFFFFFFFF);

  // Status/Semantic Primitives
  static const Color dangerLight = Color(0xFFFCECEA);
  static const Color dangerDark = Color(0xFFBE3536);
  static const Color infoLight = Color(0xFFE1F3FF);
  static const Color infoDark = Color(0xFF2E67D3);
  static const Color successLight = Color(0xFFE0FAE3);
  static const Color successDark = Color(0xFF3D7D3F);
  static const Color warningLight = Color(0xFFFEF3E0);
  static const Color warningDark = Color(0xFFD97706);

  // Status mid-tones (borders on status surfaces) and bright accents
  static const Color dangerMedium = Color(0xFFEDC0BF);
  static const Color infoMedium = Color(0xFFB6D1F4);
  static const Color successMedium = Color(0xFFB9DCBC);
  static const Color warningMedium = Color(0xFFE9C89D);
  static const Color warningBright = Color(0xFFEFA300);
  static const Color pendingLight = Color(0xFFF5EBFF);
  static const Color pendingMedium = Color(0xFFD3C1F6);
  static const Color pendingDark = Color(0xFF7C2FCA);

  // Charts. The series colors are assigned in order and wrap after seven.
  static const List<Color> chartSeries = [
    Color(0xFF3F6DD7),
    Color(0xFFD55079),
    Color(0xFF8C54C3),
    Color(0xFF10A148),
    Color(0xFFA648A7),
    Color(0xFF970525),
    Color(0xFF069999),
  ];
  static const List<Color> chartSeriesDark = [
    Color(0xFF5686F2),
    Color(0xFFD24D76),
    Color(0xFFA56CDD),
    Color(0xFF1EA74E),
    Color(0xFFC161C0),
    Color(0xFFC8414B),
    Color(0xFF19A0A0),
  ];
  static const Color chartGrid = Color(0xFFEDEEF0);
  static const Color chartGridDark = Color(0xFF242426);
  static const Color chartAxis = Color(0xFFD7D7D9);
  static const Color chartAxisDark = Color(0xFF3A3A3D);
  static const Color chartAxisLabel = Color(0xFF6E7074);
  static const Color chartAxisLabelDark = Color(0xFF9C9CA4);

  // Hardcoded / Specific
  static const Color focusBlue = Color(0xFF007AFF);
  static const Color borderSubtle = Color(0x14000000);
}
