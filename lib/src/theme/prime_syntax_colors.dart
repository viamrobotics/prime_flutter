import 'dart:ui';

/// The syntax highlighting colors of [CodeEditor] and [CodeSnippet].
///
/// Set one on [PrimeColorScheme.syntax] to restyle code. [light] suits a
/// light background and [dark] a dark one.
class PrimeSyntaxColors {
  final Color comment;
  final Color keyword;
  final Color type;
  final Color function;
  final Color string;
  final Color number;
  final Color boolean;
  final Color nullValue;
  final Color property;

  /// The line numbers in the editor's gutter.
  final Color lineNumber;

  const PrimeSyntaxColors({
    required this.comment,
    required this.keyword,
    required this.type,
    required this.function,
    required this.string,
    required this.number,
    required this.boolean,
    required this.nullValue,
    required this.property,
    required this.lineNumber,
  });

  static const PrimeSyntaxColors light = PrimeSyntaxColors(
    comment: Color(0xFF008000),
    keyword: Color(0xFF0000FF),
    type: Color(0xFF1B6580),
    function: Color(0xFF795E26),
    string: Color(0xFF9C251D),
    number: Color(0xFF2F6447),
    boolean: Color(0xFF201293),
    nullValue: Color(0xFF770088),
    property: Color(0xFF000000),
    lineNumber: Color(0xFF4B758D),
  );

  static const PrimeSyntaxColors dark = PrimeSyntaxColors(
    comment: Color(0xFF7EC87E),
    keyword: Color(0xFF79B8FF),
    type: Color(0xFF6CC4E0),
    function: Color(0xFFDCDCAA),
    string: Color(0xFFF0A8A2),
    number: Color(0xFF7FC99A),
    boolean: Color(0xFFA9A1FF),
    nullValue: Color(0xFFE29CE2),
    property: Color(0xFFE4E4E6),
    lineNumber: Color(0xFF7FA9C0),
  );

  /// The set that suits a background: [dark] when it is dark, else [light].
  /// Used when a scheme leaves [PrimeColorScheme.syntax] null.
  static PrimeSyntaxColors forSurface(Color surface) => surface.computeLuminance() < 0.5 ? dark : light;
}
