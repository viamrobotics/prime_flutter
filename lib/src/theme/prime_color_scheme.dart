import 'package:flutter/widgets.dart';
import 'prime_colors.dart';
import 'prime_syntax_colors.dart';

/// Every color a Prime widget draws with.
///
/// Widgets read their colors from here and nowhere else, so a scheme is a
/// complete theme: [PrimeColorScheme.light] and [PrimeColorScheme.dark] are
/// two of them, and any other can be built with the constructor or by
/// changing one with [copyWith].
///
/// Only the original colors are required. The rest default to the values of
/// the light scheme, so set the ones your theme needs to change.
class PrimeColorScheme {
  // --- Surface (Backgrounds) ---
  /// Scaffold background, Bottom sheet background
  final Color surfaceBase;

  /// App bar, Filter pill section/unselected
  final Color surfaceOffset;

  /// Hover state for interactive surfaces (between offset and highlight)
  final Color surfaceHover;

  /// Badge background, Avatar fill, pressed state
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

  /// Primary button and dark icon button bg while hovered
  final Color actionPrimaryHover;

  /// Primary button and dark icon button bg while pressed
  final Color actionPrimaryPressed;

  /// Text and icons on a solid status button (danger, success)
  final Color actionStatusFg;

  /// Blended over a surface at low opacity while it is hovered or pressed
  final Color interactionTint;

  // --- Status (Feedback) ---
  final Color statusDangerLight;

  final Color statusDangerDark;

  final Color statusInfoLight;

  final Color statusInfoDark;

  final Color statusSuccessLight;

  final Color statusSuccessDark;

  final Color statusWarningLight;

  final Color statusWarningDark;

  /// Border of a danger surface
  final Color statusDangerMedium;

  /// Border of an info surface
  final Color statusInfoMedium;

  /// Border of a success surface
  final Color statusSuccessMedium;

  /// Border of a warning surface, search match highlight
  final Color statusWarningMedium;

  /// Warning icons, dots and accents
  final Color statusWarningBright;

  /// Pending surface
  final Color statusPendingLight;

  /// Border of a pending surface
  final Color statusPendingMedium;

  /// Pending text and accents
  final Color statusPendingDark;

  /// Titles on a status surface (banners). Pair it with the `status*Light` colors, not with [surfaceBase]
  final Color statusTextPrimary;

  /// Body text on a status surface
  final Color statusTextSecondary;

  /// Neutral icons on a status surface, such as a dismiss button
  final Color statusIcon;

  // --- Inverse (surfaces that contrast with the page) ---
  /// Announcement banner background
  final Color surfaceInverse;

  /// Dark pill background
  final Color surfaceInverseOffset;

  /// Dark pill border
  final Color borderInverse;

  /// Emphasized text on an inverse surface
  final Color textInversePrimary;

  /// Body text on an inverse surface
  final Color textInverseSecondary;

  /// Subtle text on an inverse surface
  final Color textInverseTertiary;

  /// Icons on an inverse surface
  final Color iconInverse;

  // --- Charts ---
  /// Chart grid lines
  final Color chartGrid;

  /// Chart axis lines and tick marks
  final Color chartAxis;

  /// Chart tick labels
  final Color chartAxisLabel;

  /// The colors a [Chart] gives its series, in order, wrapping at the end.
  /// Choose ones that hold against [surfaceBase].
  final List<Color> chartSeries;

  // --- Code ---
  /// Syntax highlighting colors for [CodeEditor] and [CodeSnippet]. When
  /// null, a light or dark set is chosen to suit [surfaceBase].
  final PrimeSyntaxColors? syntax;

  const PrimeColorScheme({
    required this.surfaceBase,
    required this.surfaceOffset,
    required this.surfaceHover,
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
    this.actionPrimaryHover = PrimeColors.gray9_5,
    this.actionPrimaryPressed = PrimeColors.black,
    this.actionStatusFg = PrimeColors.gray0,
    this.interactionTint = PrimeColors.black,
    this.statusDangerMedium = PrimeColors.dangerMedium,
    this.statusInfoMedium = PrimeColors.infoMedium,
    this.statusSuccessMedium = PrimeColors.successMedium,
    this.statusWarningMedium = PrimeColors.warningMedium,
    this.statusWarningBright = PrimeColors.warningBright,
    this.statusPendingLight = PrimeColors.pendingLight,
    this.statusPendingMedium = PrimeColors.pendingMedium,
    this.statusPendingDark = PrimeColors.pendingDark,
    this.statusTextPrimary = PrimeColors.gray9,
    this.statusTextSecondary = PrimeColors.gray8,
    this.statusIcon = PrimeColors.gray7,
    this.surfaceInverse = PrimeColors.gray9_5,
    this.surfaceInverseOffset = PrimeColors.gray7,
    this.borderInverse = PrimeColors.gray8,
    this.textInversePrimary = PrimeColors.gray0,
    this.textInverseSecondary = PrimeColors.chartAxis,
    this.textInverseTertiary = PrimeColors.gray7,
    this.iconInverse = PrimeColors.gray6,
    this.chartGrid = PrimeColors.gray2,
    this.chartAxis = PrimeColors.chartAxis,
    this.chartAxisLabel = PrimeColors.chartAxisLabel,
    this.chartSeries = PrimeColors.chartSeries,
    this.syntax,
  });

  factory PrimeColorScheme.light() {
    return const PrimeColorScheme(
      // Surface (Backgrounds)
      surfaceBase: PrimeColors.gray0,
      surfaceOffset: PrimeColors.gray1,
      surfaceHover: PrimeColors.gray1_5,
      surfaceHighlight: PrimeColors.gray2,

      // Typography (Content)
      textPrimary: PrimeColors.gray9,
      textSecondary: PrimeColors.gray8,
      textTertiary: PrimeColors.gray7,
      textPlaceholder: PrimeColors.gray6,

      // Icons
      iconPrimary: PrimeColors.gray9,
      iconSecondary: PrimeColors.gray6,
      iconDisabled: PrimeColors.gray5,

      // Interactive (Buttons & Inputs)
      actionPrimaryBg: PrimeColors.gray9,
      actionPrimaryFg: PrimeColors.gray0,
      actionNeutralBg: PrimeColors.gray1,
      borderSubtle: PrimeColors.borderSubtle,
      inputText: PrimeColors.gray9,
      inputFocus: PrimeColors.focusBlue,
      actionPrimaryHover: PrimeColors.gray9_5,
      actionPrimaryPressed: PrimeColors.black,
      actionStatusFg: PrimeColors.gray0,
      interactionTint: PrimeColors.black,

      // Status (Feedback)
      statusDangerLight: PrimeColors.dangerLight,
      statusDangerDark: PrimeColors.dangerDark,
      statusInfoLight: PrimeColors.infoLight,
      statusInfoDark: PrimeColors.infoDark,
      statusSuccessLight: PrimeColors.successLight,
      statusSuccessDark: PrimeColors.successDark,
      statusWarningLight: PrimeColors.warningLight,
      statusWarningDark: PrimeColors.warningDark,
      statusDangerMedium: PrimeColors.dangerMedium,
      statusInfoMedium: PrimeColors.infoMedium,
      statusSuccessMedium: PrimeColors.successMedium,
      statusWarningMedium: PrimeColors.warningMedium,
      statusWarningBright: PrimeColors.warningBright,
      statusPendingLight: PrimeColors.pendingLight,
      statusPendingMedium: PrimeColors.pendingMedium,
      statusPendingDark: PrimeColors.pendingDark,
      statusTextPrimary: PrimeColors.gray9,
      statusTextSecondary: PrimeColors.gray8,
      statusIcon: PrimeColors.gray7,

      // Inverse (surfaces that contrast with the page)
      surfaceInverse: PrimeColors.gray9_5,
      surfaceInverseOffset: PrimeColors.gray7,
      borderInverse: PrimeColors.gray8,
      textInversePrimary: PrimeColors.gray0,
      textInverseSecondary: PrimeColors.chartAxis,
      textInverseTertiary: PrimeColors.gray7,
      iconInverse: PrimeColors.gray6,

      // Charts
      chartGrid: PrimeColors.gray2,
      chartAxis: PrimeColors.chartAxis,
      chartAxisLabel: PrimeColors.chartAxisLabel,
      chartSeries: PrimeColors.chartSeries,

      // Code
      syntax: PrimeSyntaxColors.light,
    );
  }

  // TODO improve dark theme
  factory PrimeColorScheme.dark() {
    return const PrimeColorScheme(
      // Surface (Backgrounds)
      surfaceBase: PrimeColors.gray9,
      surfaceOffset: PrimeColors.gray8,
      surfaceHover: PrimeColors.gray7_5,
      surfaceHighlight: PrimeColors.gray7,

      // Typography (Content)
      textPrimary: PrimeColors.gray0,
      textSecondary: PrimeColors.gray2,
      textTertiary: PrimeColors.gray5,
      textPlaceholder: PrimeColors.gray6,

      // Icons
      iconPrimary: PrimeColors.gray0,
      iconSecondary: PrimeColors.gray6,
      iconDisabled: PrimeColors.gray5,

      // Interactive (Buttons & Inputs)
      actionPrimaryBg: PrimeColors.gray0,
      actionPrimaryFg: PrimeColors.gray9,
      actionNeutralBg: PrimeColors.gray8,
      borderSubtle: PrimeColors.gray8,
      inputText: PrimeColors.gray0,
      inputFocus: PrimeColors.focusBlue,
      actionPrimaryHover: PrimeColors.gray2,
      actionPrimaryPressed: PrimeColors.gray5,
      actionStatusFg: PrimeColors.gray0,
      interactionTint: PrimeColors.black,

      // Status (Feedback)
      statusDangerLight: PrimeColors.dangerLight,
      statusDangerDark: PrimeColors.dangerDark,
      statusInfoLight: PrimeColors.infoLight,
      statusInfoDark: PrimeColors.infoDark,
      statusSuccessLight: PrimeColors.successLight,
      statusSuccessDark: PrimeColors.successDark,
      statusWarningLight: PrimeColors.warningLight,
      statusWarningDark: PrimeColors.warningDark,
      statusDangerMedium: PrimeColors.dangerMedium,
      statusInfoMedium: PrimeColors.infoMedium,
      statusSuccessMedium: PrimeColors.successMedium,
      statusWarningMedium: PrimeColors.warningMedium,
      statusWarningBright: PrimeColors.warningBright,
      statusPendingLight: PrimeColors.pendingLight,
      statusPendingMedium: PrimeColors.pendingMedium,
      statusPendingDark: PrimeColors.pendingDark,
      statusTextPrimary: PrimeColors.gray9,
      statusTextSecondary: PrimeColors.gray8,
      statusIcon: PrimeColors.gray7,

      // Inverse (surfaces that contrast with the page)
      surfaceInverse: PrimeColors.gray9_5,
      surfaceInverseOffset: PrimeColors.gray7,
      borderInverse: PrimeColors.gray8,
      textInversePrimary: PrimeColors.gray0,
      textInverseSecondary: PrimeColors.chartAxis,
      textInverseTertiary: PrimeColors.gray7,
      iconInverse: PrimeColors.gray6,

      // Charts
      chartGrid: PrimeColors.chartGridDim,
      chartAxis: PrimeColors.chartAxisDim,
      chartAxisLabel: PrimeColors.gray6,
      chartSeries: PrimeColors.chartSeriesBright,

      // Code
      syntax: PrimeSyntaxColors.dark,
    );
  }

  /// This scheme with the given colors replaced.
  PrimeColorScheme copyWith({
    Color? surfaceBase,
    Color? surfaceOffset,
    Color? surfaceHover,
    Color? surfaceHighlight,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textPlaceholder,
    Color? iconPrimary,
    Color? iconSecondary,
    Color? iconDisabled,
    Color? actionPrimaryBg,
    Color? actionPrimaryFg,
    Color? actionNeutralBg,
    Color? borderSubtle,
    Color? inputText,
    Color? inputFocus,
    Color? actionPrimaryHover,
    Color? actionPrimaryPressed,
    Color? actionStatusFg,
    Color? interactionTint,
    Color? statusDangerLight,
    Color? statusDangerDark,
    Color? statusInfoLight,
    Color? statusInfoDark,
    Color? statusSuccessLight,
    Color? statusSuccessDark,
    Color? statusWarningLight,
    Color? statusWarningDark,
    Color? statusDangerMedium,
    Color? statusInfoMedium,
    Color? statusSuccessMedium,
    Color? statusWarningMedium,
    Color? statusWarningBright,
    Color? statusPendingLight,
    Color? statusPendingMedium,
    Color? statusPendingDark,
    Color? statusTextPrimary,
    Color? statusTextSecondary,
    Color? statusIcon,
    Color? surfaceInverse,
    Color? surfaceInverseOffset,
    Color? borderInverse,
    Color? textInversePrimary,
    Color? textInverseSecondary,
    Color? textInverseTertiary,
    Color? iconInverse,
    Color? chartGrid,
    Color? chartAxis,
    Color? chartAxisLabel,
    List<Color>? chartSeries,
    PrimeSyntaxColors? syntax,
  }) {
    return PrimeColorScheme(
      surfaceBase: surfaceBase ?? this.surfaceBase,
      surfaceOffset: surfaceOffset ?? this.surfaceOffset,
      surfaceHover: surfaceHover ?? this.surfaceHover,
      surfaceHighlight: surfaceHighlight ?? this.surfaceHighlight,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textPlaceholder: textPlaceholder ?? this.textPlaceholder,
      iconPrimary: iconPrimary ?? this.iconPrimary,
      iconSecondary: iconSecondary ?? this.iconSecondary,
      iconDisabled: iconDisabled ?? this.iconDisabled,
      actionPrimaryBg: actionPrimaryBg ?? this.actionPrimaryBg,
      actionPrimaryFg: actionPrimaryFg ?? this.actionPrimaryFg,
      actionNeutralBg: actionNeutralBg ?? this.actionNeutralBg,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      inputText: inputText ?? this.inputText,
      inputFocus: inputFocus ?? this.inputFocus,
      actionPrimaryHover: actionPrimaryHover ?? this.actionPrimaryHover,
      actionPrimaryPressed: actionPrimaryPressed ?? this.actionPrimaryPressed,
      actionStatusFg: actionStatusFg ?? this.actionStatusFg,
      interactionTint: interactionTint ?? this.interactionTint,
      statusDangerLight: statusDangerLight ?? this.statusDangerLight,
      statusDangerDark: statusDangerDark ?? this.statusDangerDark,
      statusInfoLight: statusInfoLight ?? this.statusInfoLight,
      statusInfoDark: statusInfoDark ?? this.statusInfoDark,
      statusSuccessLight: statusSuccessLight ?? this.statusSuccessLight,
      statusSuccessDark: statusSuccessDark ?? this.statusSuccessDark,
      statusWarningLight: statusWarningLight ?? this.statusWarningLight,
      statusWarningDark: statusWarningDark ?? this.statusWarningDark,
      statusDangerMedium: statusDangerMedium ?? this.statusDangerMedium,
      statusInfoMedium: statusInfoMedium ?? this.statusInfoMedium,
      statusSuccessMedium: statusSuccessMedium ?? this.statusSuccessMedium,
      statusWarningMedium: statusWarningMedium ?? this.statusWarningMedium,
      statusWarningBright: statusWarningBright ?? this.statusWarningBright,
      statusPendingLight: statusPendingLight ?? this.statusPendingLight,
      statusPendingMedium: statusPendingMedium ?? this.statusPendingMedium,
      statusPendingDark: statusPendingDark ?? this.statusPendingDark,
      statusTextPrimary: statusTextPrimary ?? this.statusTextPrimary,
      statusTextSecondary: statusTextSecondary ?? this.statusTextSecondary,
      statusIcon: statusIcon ?? this.statusIcon,
      surfaceInverse: surfaceInverse ?? this.surfaceInverse,
      surfaceInverseOffset: surfaceInverseOffset ?? this.surfaceInverseOffset,
      borderInverse: borderInverse ?? this.borderInverse,
      textInversePrimary: textInversePrimary ?? this.textInversePrimary,
      textInverseSecondary: textInverseSecondary ?? this.textInverseSecondary,
      textInverseTertiary: textInverseTertiary ?? this.textInverseTertiary,
      iconInverse: iconInverse ?? this.iconInverse,
      chartGrid: chartGrid ?? this.chartGrid,
      chartAxis: chartAxis ?? this.chartAxis,
      chartAxisLabel: chartAxisLabel ?? this.chartAxisLabel,
      chartSeries: chartSeries ?? this.chartSeries,
      syntax: syntax ?? this.syntax,
    );
  }
}
