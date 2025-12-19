import 'package:flutter/widgets.dart';
import 'prime_colors.dart';

class PrimeColorScheme {
  // --- Surface (Backgrounds) ---
  /// Scaffold background, Bottom sheet background
  // TODO rename to background
  final Color surfaceBase;

  /// App bar, Filter pill section/unselected
  // TODO rename to surface
  final Color surfaceOffset;

  /// Badge background, Avatar fill
  final Color surfaceHighlight;

  // --- Typography (Content) ---
  /// Titles, Headers, Primary text
  final Color textPrimary;

  /// Secondary text, Unselected tabs
  final Color textSecondary;

  /// Subtitles, Meta data, Placeholder
  final Color textTertiary;

  /// Placeholders, Count badges
  final Color textPlaceholder;

  // --- Icons ---
  /// Selected icons
  final Color iconPrimary;

  /// Navigation, Action icons
  final Color iconSecondary;

  /// Disabled/Inactive icons
  final Color iconDisabled;

  // --- Interactive (Buttons & Inputs) ---
  /// Primary button bg, Selected states
  final Color actionPrimaryBg;

  /// Primary button text
  final Color actionPrimaryFg;

  /// Neutral button bg
  final Color actionNeutralBg;

  /// Button borders
  final Color borderSubtle;

  /// Input text
  final Color inputText;

  /// Input focus ring/border
  final Color inputFocus;

  // --- Status (Feedback) ---
  final Color statusDangerLight;
  final Color statusDangerDark;
  final Color statusInfoLight;
  final Color statusInfoDark;
  final Color statusSuccessLight;
  final Color statusSuccessDark;
  final Color statusWarningLight;
  final Color statusWarningDark;

  const PrimeColorScheme({
    required this.surfaceBase,
    required this.surfaceOffset,
    required this.surfaceHighlight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textPlaceholder,
    required this.iconPrimary,
    required this.iconSecondary,
    required this.iconDisabled,
    required this.actionPrimaryBg,
    required this.actionPrimaryFg,
    required this.actionNeutralBg,
    required this.borderSubtle,
    required this.inputText,
    required this.inputFocus,
    required this.statusDangerLight,
    required this.statusDangerDark,
    required this.statusInfoLight,
    required this.statusInfoDark,
    required this.statusSuccessLight,
    required this.statusSuccessDark,
    required this.statusWarningLight,
    required this.statusWarningDark,
  });

  factory PrimeColorScheme.light() {
    return const PrimeColorScheme(
      // Surface
      surfaceBase: PrimeColors.gray0,
      surfaceOffset: PrimeColors.gray1,
      surfaceHighlight: PrimeColors.gray2,

      // Typography
      textPrimary: PrimeColors.gray9,
      textSecondary: PrimeColors.gray8,
      textTertiary: PrimeColors.gray7,
      textPlaceholder: PrimeColors.gray6,

      // Icons
      iconPrimary: PrimeColors.gray9,
      iconSecondary: PrimeColors.gray6,
      iconDisabled: PrimeColors.gray5,

      // Interactive
      actionPrimaryBg: PrimeColors.gray9,
      actionPrimaryFg: PrimeColors.gray0,
      actionNeutralBg: PrimeColors.gray1,
      borderSubtle: PrimeColors.borderSubtle,
      inputText: PrimeColors.gray6,
      inputFocus: PrimeColors.focusBlue,

      // Status
      statusDangerLight: PrimeColors.dangerLight,
      statusDangerDark: PrimeColors.dangerDark,
      statusInfoLight: PrimeColors.infoLight,
      statusInfoDark: PrimeColors.infoDark,
      statusSuccessLight: PrimeColors.successLight,
      statusSuccessDark: PrimeColors.successDark,
      statusWarningLight: PrimeColors.warningLight,
      statusWarningDark: PrimeColors.warningDark,
    );
  }
}
