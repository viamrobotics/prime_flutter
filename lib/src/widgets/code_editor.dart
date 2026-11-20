import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/rendering.dart' show RenderEditable;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/prime_colors.dart';
import '../theme/prime_theme.dart';
import '../theme/prime_theme_data.dart';
import 'input.dart';
import 'internal/pressable.dart';
import 'prime_icons.dart';
import 'raw_input.dart';

/// Fixes common JSON slips, currently trailing commas before `}` and `]`,
/// and returns the result when it is valid JSON, or null when it is not.
String? tryFixJson(String input) {
  final buffer = StringBuffer();
  bool inString = false, escape = false;
  for (int index = 0; index < input.length; index++) {
    final char = input[index];
    if (escape) {
      escape = false;
    } else if (char == r'\' && inString) {
      escape = true;
    } else if (char == '"') {
      inString = !inString;
    } else if (!inString && char == ',') {
      // A comma whose next non-space character closes the object or array goes.
      int next = index + 1;
      while (next < input.length && input[next].trim().isEmpty) {
        next++;
      }
      if (next < input.length && (input[next] == '}' || input[next] == ']')) continue;
    }
    buffer.write(char);
  }
  final fixed = buffer.toString();
  try {
    jsonDecode(fixed);
    return fixed;
  } on FormatException {
    return null;
  }
}

/// A grammar [CodeEditor] highlights the document with.
enum CodeEditorLanguage { go, javascript, json, python, sql, typescript, json5 }

/// Colored spans for [source] in [language], with Prime's code token colors
/// for the theme. Used by [CodeEditor] and [CodeSnippet].
List<TextSpan> highlightCode(String source, CodeEditorLanguage? language, PrimeThemeData theme) =>
    _highlight(source, language, _CodePalette.of(theme));

/// The diff view's layout. [unified] interleaves deleted and inserted lines,
/// [split] puts the original beside the current value.
enum CodeEditorDiff { unified, split }

// --- Highlighting ----------------------------------------------------------

class _CodePalette {
  final Color comment, keyword, type, function, string, number, boolean, nullValue, property, lineNumber;

  const _CodePalette({
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

  static const light = _CodePalette(
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

  static const dark = _CodePalette(
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

  static _CodePalette of(PrimeThemeData theme) => theme.colorScheme.surfaceBase.computeLuminance() < 0.5 ? dark : light;
}

class _Grammar {
  final RegExp pattern;
  final Set<String> keywords;
  final Set<String> booleans;
  final Set<String> nulls;
  final bool caseInsensitive;
  final bool capitalizedTypes;
  final bool propertyStrings;

  /// Bare words before a colon are property keys, as in JSON5.
  final bool propertyWords;

  _Grammar({
    required String comment,
    required String string,
    this.keywords = const {},
    this.booleans = const {'true', 'false'},
    this.nulls = const {'null'},
    this.caseInsensitive = false,
    this.capitalizedTypes = true,
    this.propertyStrings = false,
    this.propertyWords = false,
  }) : pattern = RegExp(
         '(?<comment>$comment)|(?<string>$string)|(?<number>\\b0[xX][0-9a-fA-F]+\\b|\\b\\d+(?:\\.\\d+)?(?:[eE][+-]?\\d+)?\\b)|(?<word>[A-Za-z_\$][A-Za-z0-9_\$]*)',
         multiLine: true,
       );
}

const String _cComment = r'//[^\n]*|/\*[\s\S]*?(?:\*/|$(?![\s\S]))';
const String _dq = r'"(?:\\.|[^"\\\n])*"?';
const String _sq = r"'(?:\\.|[^'\\\n])*'?";
const String _bt = r'`(?:\\[\s\S]|[^`\\])*`?';
const String _never = r'(?!)';

const Set<String> _jsKeywords = {
  'async', 'await', 'break', 'case', 'catch', 'class', 'const', 'continue', 'debugger', 'default', 'delete', 'do', 'else', 'export', //
  'extends', 'finally', 'for', 'from', 'function', 'if', 'import', 'in', 'instanceof', 'let', 'new', 'of', 'return', 'static', 'super',
  'switch', 'this', 'throw', 'try', 'typeof', 'var', 'void', 'while', 'with', 'yield',
};

final Map<CodeEditorLanguage, _Grammar> _grammars = {
  CodeEditorLanguage.json: _Grammar(comment: _never, string: _dq, capitalizedTypes: false, propertyStrings: true),
  CodeEditorLanguage.json5: _Grammar(
    comment: _cComment,
    string: '$_dq|$_sq',
    capitalizedTypes: false,
    propertyStrings: true,
    propertyWords: true,
  ),
  CodeEditorLanguage.javascript: _Grammar(
    comment: _cComment,
    string: '$_dq|$_sq|$_bt',
    keywords: _jsKeywords,
    nulls: const {'null', 'undefined'},
  ),
  CodeEditorLanguage.typescript: _Grammar(
    comment: _cComment,
    string: '$_dq|$_sq|$_bt',
    keywords: {
      ..._jsKeywords,
      'abstract', 'any', 'as', 'boolean', 'declare', 'enum', 'implements', 'interface', 'is', 'keyof', 'namespace', 'never', 'number', //
      'private', 'protected', 'public', 'readonly', 'satisfies', 'string', 'type', 'unknown',
    },
    nulls: const {'null', 'undefined'},
  ),
  CodeEditorLanguage.go: _Grammar(
    comment: _cComment,
    string: '$_dq|$_sq|`[^`]*`?',
    keywords: const {
      'break', 'case', 'chan', 'const', 'continue', 'default', 'defer', 'else', 'fallthrough', 'for', 'func', 'go', 'goto', 'if', //
      'import', 'interface', 'map', 'package', 'range', 'return', 'select', 'struct', 'switch', 'type', 'var', 'any', 'bool', 'byte',
      'error', 'float32', 'float64', 'int', 'int8', 'int16', 'int32', 'int64', 'rune', 'string', 'uint', 'uint8', 'uint16', 'uint32',
      'uint64', 'uintptr',
    },
    nulls: const {'nil'},
  ),
  CodeEditorLanguage.python: _Grammar(
    comment: r'#[^\n]*',
    string: '"""[\\s\\S]*?(?:"""|\$(?![\\s\\S]))|\'\'\'[\\s\\S]*?(?:\'\'\'|\$(?![\\s\\S]))|$_dq|$_sq',
    keywords: const {
      'and', 'as', 'assert', 'async', 'await', 'break', 'class', 'continue', 'def', 'del', 'elif', 'else', 'except', 'finally', 'for', //
      'from', 'global', 'if', 'import', 'in', 'is', 'lambda', 'nonlocal', 'not', 'or', 'pass', 'raise', 'return', 'try', 'while', 'with',
      'yield', 'self',
    },
    booleans: const {'True', 'False'},
    nulls: const {'None'},
  ),
  CodeEditorLanguage.sql: _Grammar(
    comment: r'--[^\n]*|/\*[\s\S]*?(?:\*/|$(?![\s\S]))',
    string: _sq,
    keywords: const {
      'add', 'all', 'alter', 'and', 'as', 'asc', 'between', 'by', 'case', 'create', 'cross', 'delete', 'desc', 'distinct', 'drop', //
      'else', 'end', 'exists', 'from', 'full', 'group', 'having', 'in', 'index', 'inner', 'insert', 'into', 'is', 'join', 'left', 'like',
      'limit', 'not', 'offset', 'on', 'or', 'order', 'outer', 'primary', 'key', 'right', 'select', 'set', 'table', 'then', 'union',
      'update', 'values', 'view', 'when', 'where', 'with',
    },
    caseInsensitive: true,
    capitalizedTypes: false,
  ),
};

final RegExp _callAhead = RegExp(r'\s*\(');
final RegExp _colonAhead = RegExp(r'\s*:');

/// A colored run of source. [opaque] marks comments and strings, whose
/// brackets do not count for folding.
typedef _Token = ({int start, int end, Color color, bool opaque});

/// Finds the colored runs of [source] for [language], in order.
List<_Token> _tokenize(String source, CodeEditorLanguage? language, _CodePalette palette) {
  final grammar = language == null ? null : _grammars[language];
  if (grammar == null || source.isEmpty) return const [];

  final tokens = <_Token>[];
  for (final match in grammar.pattern.allMatches(source)) {
    if (match.end == match.start) continue;
    Color? color;
    bool opaque = false;
    if (match.namedGroup('comment') != null) {
      color = palette.comment;
      opaque = true;
    } else if (match.namedGroup('string') != null) {
      color = grammar.propertyStrings && _colonAhead.matchAsPrefix(source, match.end) != null ? palette.property : palette.string;
      opaque = true;
    } else if (match.namedGroup('number') != null) {
      color = palette.number;
    } else {
      final raw = match.group(0)!;
      final word = grammar.caseInsensitive ? raw.toLowerCase() : raw;
      if (grammar.booleans.contains(word)) {
        color = palette.boolean;
      } else if (grammar.nulls.contains(word)) {
        color = palette.nullValue;
      } else if (grammar.keywords.contains(word)) {
        color = palette.keyword;
      } else if (grammar.propertyWords && _colonAhead.matchAsPrefix(source, match.end) != null) {
        color = palette.property;
      } else if (_callAhead.matchAsPrefix(source, match.end) != null) {
        color = palette.function;
      } else if (grammar.capitalizedTypes && raw.length > 1 && raw[0] != raw[0].toLowerCase()) {
        color = palette.type;
      }
    }
    if (color != null) tokens.add((start: match.start, end: match.end, color: color, opaque: opaque));
  }
  return tokens;
}

/// Splits [source] into colored spans for [language].
List<TextSpan> _highlight(String source, CodeEditorLanguage? language, _CodePalette palette) {
  final spans = <TextSpan>[];
  int cursor = 0;
  for (final token in _tokenize(source, language, palette)) {
    if (token.start > cursor) spans.add(TextSpan(text: source.substring(cursor, token.start)));
    spans.add(
      TextSpan(
        text: source.substring(token.start, token.end),
        style: TextStyle(color: token.color),
      ),
    );
    cursor = token.end;
  }
  if (cursor < source.length) spans.add(TextSpan(text: source.substring(cursor)));
  return spans;
}

/// Folded regions are stood in for by one private-use character each, so the
/// document the text field edits stays a plain string.
const int _foldFirst = 0xE000;
const int _foldLast = 0xF8FF;

bool _isFoldChar(int codeUnit) => codeUnit >= _foldFirst && codeUnit <= _foldLast;

/// In the editable diff, each run of deleted lines is one character from this
/// upper part of the range, alone on a line of its own.
const int _chunkFirst = 0xF000;

bool _isChunkChar(int codeUnit) => codeUnit >= _chunkFirst && codeUnit <= _foldLast;

class _CodeController extends TextEditingController {
  CodeEditorLanguage? language;
  _CodePalette palette = _CodePalette.light;

  /// Search hits to paint, in order, and which one is current.
  List<TextRange> matches = const [];
  int activeMatch = -1;
  Color matchColor = const Color(0x00000000);
  Color activeMatchColor = const Color(0x00000000);

  /// Builds the chip shown in place of a fold character.
  Widget Function(int codeUnit)? foldChipBuilder;

  _CodeController({super.text});

  /// Repaints after a change to [matches] or the fold set.
  void refresh() => notifyListeners();

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    final source = text;
    final tokens = _tokenize(source, language, palette);
    final folds = <int>[
      for (int i = 0; i < source.length; i++)
        if (_isFoldChar(source.codeUnitAt(i))) i,
    ];
    if (matches.isEmpty && folds.isEmpty) {
      return TextSpan(style: style, children: _highlight(source, language, palette));
    }

    // Every offset where the color, the search background, or a fold chip starts or stops.
    final cuts = <int>{0, source.length};
    for (final token in tokens) {
      cuts
        ..add(token.start)
        ..add(token.end);
    }
    for (final match in matches) {
      if (match.end <= source.length) {
        cuts
          ..add(match.start)
          ..add(match.end);
      }
    }
    for (final index in folds) {
      cuts
        ..add(index)
        ..add(index + 1);
    }
    final sorted = cuts.toList()..sort();

    final children = <InlineSpan>[];
    int tokenIndex = 0, matchIndex = 0;
    for (int n = 0; n + 1 < sorted.length; n++) {
      final start = sorted[n], end = sorted[n + 1];
      if (end == start + 1 && _isFoldChar(source.codeUnitAt(start)) && foldChipBuilder != null) {
        children.add(
          WidgetSpan(
            // A deleted run fills its line exactly; a fold chip sits mid-line.
            alignment: _isChunkChar(source.codeUnitAt(start)) ? PlaceholderAlignment.bottom : PlaceholderAlignment.middle,
            child: foldChipBuilder!(source.codeUnitAt(start)),
          ),
        );
        continue;
      }
      while (tokenIndex < tokens.length && tokens[tokenIndex].end <= start) {
        tokenIndex++;
      }
      while (matchIndex < matches.length && matches[matchIndex].end <= start) {
        matchIndex++;
      }
      final token = tokenIndex < tokens.length && tokens[tokenIndex].start <= start ? tokens[tokenIndex] : null;
      final inMatch = matchIndex < matches.length && matches[matchIndex].start <= start;
      children.add(
        TextSpan(
          text: source.substring(start, end),
          style: token == null && !inMatch
              ? null
              : TextStyle(
                  color: token?.color,
                  backgroundColor: inMatch ? (matchIndex == activeMatch ? activeMatchColor : matchColor) : null,
                ),
        ),
      );
    }
    return TextSpan(style: style, children: children);
  }
}

// --- Diff ------------------------------------------------------------------

enum _DiffKind { same, added, removed }

class _DiffLine {
  final _DiffKind kind;
  final String text;
  final int? oldNumber;
  final int? newNumber;

  const _DiffLine(this.kind, this.text, this.oldNumber, this.newNumber);
}

/// Line-based diff via longest common subsequence.
List<_DiffLine> _diffLines(String original, String value) {
  final a = original.split('\n');
  final b = value.split('\n');

  // Trim the common prefix and suffix so the table only covers what changed.
  int prefix = 0;
  while (prefix < a.length && prefix < b.length && a[prefix] == b[prefix]) {
    prefix++;
  }
  int suffix = 0;
  while (suffix < a.length - prefix && suffix < b.length - prefix && a[a.length - 1 - suffix] == b[b.length - 1 - suffix]) {
    suffix++;
  }
  final am = a.sublist(prefix, a.length - suffix);
  final bm = b.sublist(prefix, b.length - suffix);

  final lines = <_DiffLine>[];
  int oldNumber = 1, newNumber = 1;
  void same(String text) => lines.add(_DiffLine(_DiffKind.same, text, oldNumber++, newNumber++));
  void removed(String text) => lines.add(_DiffLine(_DiffKind.removed, text, oldNumber++, null));
  void added(String text) => lines.add(_DiffLine(_DiffKind.added, text, null, newNumber++));

  for (int i = 0; i < prefix; i++) {
    same(a[i]);
  }

  final n = am.length, m = bm.length;
  if (n * m > 4000000) {
    // Too large for the table: report the middle as one replaced block.
    am.forEach(removed);
    bm.forEach(added);
  } else {
    final table = List.generate(n + 1, (_) => List<int>.filled(m + 1, 0));
    for (int i = n - 1; i >= 0; i--) {
      for (int j = m - 1; j >= 0; j--) {
        table[i][j] = am[i] == bm[j] ? table[i + 1][j + 1] + 1 : math.max(table[i + 1][j], table[i][j + 1]);
      }
    }
    int i = 0, j = 0;
    while (i < n && j < m) {
      if (am[i] == bm[j]) {
        same(am[i]);
        i++;
        j++;
      } else if (table[i + 1][j] >= table[i][j + 1]) {
        removed(am[i++]);
      } else {
        added(bm[j++]);
      }
    }
    while (i < n) {
      removed(am[i++]);
    }
    while (j < m) {
      added(bm[j++]);
    }
  }

  for (int i = a.length - suffix; i < a.length; i++) {
    same(a[i]);
  }
  return lines;
}

// --- Widget ----------------------------------------------------------------

/// A code editor with syntax highlighting, a line-number gutter, and a diff
/// view.
///
/// ```dart
/// CodeEditor(
///   semanticLabel: 'Config',
///   language: CodeEditorLanguage.json,
///   value: config,
///   onChanged: (next) => setState(() => config = next),
/// )
/// ```
///
/// Set [original] to open the diff view of [original] against [value]. It
/// stays editable: deleted lines show in place, read-only, and edits update
/// the diff as you type. It is read-only when [readOnly] is set or there is
/// no [onChanged].
///
/// Ctrl/Cmd+F opens a search bar with replace. Blocks fold from the gutter or
/// with Ctrl/Cmd+Shift+[ and unfold with Ctrl/Cmd+Shift+].
///
/// The editor grows with its content. Give it a bounded height (a `SizedBox`
/// or `Expanded`) and it fills that height and scrolls instead.
class CodeEditor extends StatefulWidget {
  /// The document.
  final String value;

  /// Called on every edit.
  final ValueChanged<String>? onChanged;

  /// The grammar used for highlighting. Null renders plain text.
  final CodeEditorLanguage? language;

  /// Blocks edits. The document stays focusable, selectable, and copyable.
  final bool readOnly;

  /// Turns the editor off: no editing, focus, or selection. Wins over
  /// [readOnly].
  final bool disabled;

  /// Text shown while the document is empty.
  final String? placeholder;

  /// Shows the line-number gutter.
  final bool lineNumbers;

  /// Wraps long lines instead of scrolling them horizontally.
  final bool wrapLines;

  /// The text [value] is compared against. Setting it opens the diff view.
  final String? original;

  /// The diff view's layout while [original] is set.
  final CodeEditorDiff diff;

  /// Folds each long run of unchanged lines in the diff view into one row
  /// that expands on tap.
  final bool collapseUnchanged;

  /// Marks the document invalid and paints the error border.
  final bool invalid;

  /// The accessible name of the editing surface.
  final String? semanticLabel;

  final FocusNode? focusNode;
  final bool autofocus;

  /// Removes trailing commas when the editor loses focus, if that leaves
  /// valid JSON. Only for [CodeEditorLanguage.json].
  final bool fixJsonOnBlur;

  /// Whether Ctrl/Cmd+F opens the search bar, with find, replace, and
  /// replace all.
  final bool searchable;

  /// Whether the gutter offers fold markers. Folding also works from the
  /// keyboard: Ctrl/Cmd+Shift+[ folds the block at the cursor and
  /// Ctrl/Cmd+Shift+] unfolds it. Needs [lineNumbers].
  final bool foldable;

  const CodeEditor({
    super.key,
    required this.value,
    this.onChanged,
    this.language,
    this.readOnly = false,
    this.disabled = false,
    this.placeholder,
    this.lineNumbers = true,
    this.wrapLines = false,
    this.original,
    this.diff = CodeEditorDiff.unified,
    this.collapseUnchanged = false,
    this.invalid = false,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    this.searchable = true,
    this.foldable = true,
    this.fixJsonOnBlur = false,
  });

  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  static const double _fontSize = 13;
  static const double _lineHeight = 20;
  static const double _padding = 8;

  late final _CodeController _controller = _CodeController(text: widget.value)..foldChipBuilder = _buildFoldChip;
  FocusNode? _ownFocusNode;
  bool _focused = false;

  /// Indices of collapsed runs the user has expanded in the diff view.
  final Set<int> _expandedRuns = {};

  /// Folded regions by the private-use character standing in for each.
  final Map<int, String> _folds = {};

  /// Deleted runs of the editable diff by the character standing in for each.
  final Map<int, String> _chunks = {};

  /// What each line of the editable diff's text is, in order.
  List<_DiffKind> _viewKinds = const [];

  /// The height the text layout actually gave each line of the editable diff,
  /// and the text and width they were measured for.
  List<double> _lineHeights = const [];
  String? _measuredText;
  double _measuredWidth = -1;
  final GlobalKey _fieldKey = GlobalKey();

  /// Reads the laid-out line positions back from the text field, so the
  /// gutter and the line tints sit exactly on their lines whatever height the
  /// engine gave a deleted run or a wrapped line.
  void _measureLines() {
    if (!mounted || !_diffEditable) return;
    RenderEditable? editable;
    void visit(RenderObject object) {
      if (editable != null) return;
      if (object is RenderEditable) {
        editable = object;
      } else {
        object.visitChildren(visit);
      }
    }

    final root = _fieldKey.currentContext?.findRenderObject();
    if (root == null) return;
    visit(root);
    final render = editable;
    if (render == null || !render.hasSize) return;

    final text = _controller.text;
    final tops = <double>[];
    int offset = 0;
    for (final line in text.split('\n')) {
      // A deleted run's line is as tall as its block, and the caret there sits at the foot of it,
      // so the top of that line is the top of the block itself.
      final isChunk = line.codeUnits.any(_isChunkChar);
      final boxes = isChunk ? render.getBoxesForSelection(TextSelection(baseOffset: offset, extentOffset: offset + 1)) : const <TextBox>[];
      tops.add(boxes.isNotEmpty ? boxes.first.top : render.getLocalRectForCaret(TextPosition(offset: offset)).top);
      offset += line.length + 1;
    }
    final heights = <double>[for (int i = 0; i < tops.length; i++) (i + 1 < tops.length ? tops[i + 1] : render.size.height) - tops[i]];
    final same =
        _measuredText == text &&
        _measuredWidth == render.size.width &&
        heights.length == _lineHeights.length &&
        Iterable<int>.generate(heights.length).every((i) => (heights[i] - _lineHeights[i]).abs() < 0.5);
    if (same) return;
    setState(() {
      _lineHeights = heights;
      _measuredText = text;
      _measuredWidth = render.size.width;
    });
  }

  bool _searchOpen = false;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _replaceController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();

  FocusNode get _focusNode => widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocus);
    if (_diffEditable) _setDiffView(widget.value, collapse: widget.collapseUnchanged);
  }

  // --- Editable diff ---

  /// Whether the diff view is shown as an editor rather than a static listing.
  bool get _diffEditable => widget.original != null && !widget.readOnly && !widget.disabled && widget.onChanged != null;

  /// The document itself: the editor text without deleted-line stand-ins, with folds put back.
  String _real(String view) => _expand(_stripChunks(view));

  String _stripChunks(String view) {
    if (_chunks.isEmpty && !view.codeUnits.any(_isChunkChar)) return view;
    final kept = <String>[];
    for (final line in view.split('\n')) {
      if (!line.codeUnits.any(_isChunkChar)) {
        kept.add(line);
        continue;
      }
      // Anything typed onto a stand-in's line stays, as a line of its own.
      final rest = String.fromCharCodes(line.codeUnits.where((unit) => !_isChunkChar(unit)));
      if (rest.isNotEmpty) kept.add(rest);
    }
    return kept.join('\n');
  }

  /// Rebuilds the editor text for [real]: its own lines, with one stand-in
  /// line wherever lines of the original were deleted.
  void _setDiffView(String real, {int? realCursor, bool collapse = false}) {
    final lines = <String>[];
    final kinds = <_DiffKind>[];
    final chunks = <int, String>{};
    final pending = <String>[];
    void flush() {
      if (pending.isEmpty) return;
      final unit = _chunkFirst + chunks.length;
      chunks[unit] = pending.join('\n');
      lines.add(String.fromCharCode(unit));
      kinds.add(_DiffKind.removed);
      pending.clear();
    }

    for (final line in _diffLines(widget.original!, real)) {
      if (line.kind == _DiffKind.removed) {
        pending.add(line.text);
      } else {
        flush();
        lines.add(line.text);
        kinds.add(line.kind);
      }
    }
    flush();

    // Keeps a run of unchanged lines folded: [content] is those lines, standing behind [unit].
    bool foldRun(int unit, String content) {
      final hidden = content.split('\n');
      for (int start = 0; start + hidden.length <= lines.length; start++) {
        bool matches = true;
        for (int n = 0; n < hidden.length && matches; n++) {
          matches = kinds[start + n] == _DiffKind.same && lines[start + n] == hidden[n];
        }
        if (!matches) continue;
        lines.replaceRange(start, start + hidden.length, [String.fromCharCode(unit)]);
        kinds.replaceRange(start, start + hidden.length, [_DiffKind.same]);
        return true;
      }
      return false;
    }

    if (collapse) {
      // A fresh layout folds each long unchanged run, leaving a few lines of context around the changes.
      const context = 3, minRun = 4;
      _folds.clear();
      final runs = <String>[];
      for (int index = 0; index < lines.length;) {
        if (kinds[index] != _DiffKind.same) {
          index++;
          continue;
        }
        int end = index;
        while (end < lines.length && kinds[end] == _DiffKind.same) {
          end++;
        }
        final head = index == 0 ? 0 : context, tail = end == lines.length ? 0 : context;
        if (end - index - head - tail >= minRun) runs.add(lines.sublist(index + head, end - tail).join('\n'));
        index = end;
      }
      for (final run in runs) {
        final unit = _foldFirst + _folds.length;
        if (foldRun(unit, run)) _folds[unit] = run;
      }
    } else {
      // An edit keeps the folds that still cover unchanged lines and drops the rest.
      _folds.removeWhere((unit, content) => !foldRun(unit, content));
    }

    final view = lines.join('\n');
    _viewKinds = kinds;
    final sameChunks = chunks.length == _chunks.length && chunks.entries.every((entry) => _chunks[entry.key] == entry.value);
    if (view == _controller.text && sameChunks) return;
    _chunks
      ..clear()
      ..addAll(chunks);

    // Carry the cursor across by its place in the document.
    int offset = -1;
    if (realCursor != null) {
      int remaining = realCursor;
      offset = 0;
      for (int i = 0; i < lines.length; i++) {
        final isChunk = kinds[i] == _DiffKind.removed;
        if (!isChunk) {
          // A folded line stands for all the characters behind it.
          final realLength = _expand(lines[i]).length;
          if (remaining <= realLength) {
            offset += math.min(remaining, lines[i].length);
            remaining = -1;
            break;
          }
          remaining -= realLength + 1;
        }
        offset += lines[i].length + 1;
      }
      if (remaining >= 0) offset = view.length;
    }
    _controller.value = TextEditingValue(
      text: view,
      selection: TextSelection.collapsed(offset: offset.clamp(-1, view.length)),
    );
  }

  /// The cursor's place in the document, given its place in the editor text.
  int _realOffset(String view, int offset) {
    if (offset < 0) return offset;
    return _real(view.substring(0, offset.clamp(0, view.length))).length;
  }

  @override
  void didUpdateWidget(CodeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      (oldWidget.focusNode ?? _ownFocusNode)?.removeListener(_handleFocus);
      _focusNode.addListener(_handleFocus);
    }
    final wasDiffEditable = _chunks.isNotEmpty || _viewKinds.isNotEmpty;
    if (_diffEditable) {
      // Rebuilds only when the document, the original, or the mode changed.
      if (widget.value != _real(_controller.text) || widget.original != oldWidget.original || !wasDiffEditable) {
        _setDiffView(
          widget.value,
          realCursor: _realOffset(_controller.text, _controller.selection.baseOffset),
          collapse: widget.collapseUnchanged,
        );
        _updateMatches();
      }
    } else if (widget.value != _real(_controller.text) || wasDiffEditable) {
      // Compare against the whole document, folded regions included.
      _folds.clear();
      _chunks.clear();
      _viewKinds = const [];
      final offset = math.min(_controller.selection.baseOffset, widget.value.length);
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: offset < 0 ? const TextSelection.collapsed(offset: -1) : TextSelection.collapsed(offset: offset),
      );
      _updateMatches();
    }
    if (widget.original != oldWidget.original) _expandedRuns.clear();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocus);
    _ownFocusNode?.dispose();
    _controller.dispose();
    _searchController.dispose();
    _replaceController.dispose();
    _searchFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleFocus() {
    if (_focused != _focusNode.hasFocus) setState(() => _focused = _focusNode.hasFocus);
    if (!_focusNode.hasFocus &&
        widget.fixJsonOnBlur &&
        widget.language == CodeEditorLanguage.json &&
        !widget.readOnly &&
        widget.original == null) {
      final current = _real(_controller.text);
      final fixed = tryFixJson(current);
      if (fixed != null && fixed != current) {
        _folds.clear();
        _controller.text = fixed;
        _handleChanged(fixed);
      }
    }
  }

  // --- Folding ---

  /// The document with every folded region put back.
  String _expand(String view) {
    if (_folds.isEmpty) return view;
    String text = view;
    // A folded region can itself hold folds, so expand until none are left.
    for (int pass = 0; pass < 64; pass++) {
      bool found = false;
      final buffer = StringBuffer();
      for (int i = 0; i < text.length; i++) {
        final unit = text.codeUnitAt(i);
        final content = _isFoldChar(unit) ? _folds[unit] : null;
        if (content != null) {
          buffer.write(content);
          found = true;
        } else {
          buffer.writeCharCode(unit);
        }
      }
      text = buffer.toString();
      if (!found) break;
    }
    return text;
  }

  /// The foldable region opened on each line of [view], keyed by line index.
  Map<int, TextRange> _foldRanges(String view) {
    final ranges = <int, TextRange>{};
    final lineStarts = <int>[0];
    for (int i = 0; i < view.length; i++) {
      if (view.codeUnitAt(i) == 0x0A) lineStarts.add(i + 1);
    }
    int lineOf(int offset) {
      int low = 0, high = lineStarts.length - 1;
      while (low < high) {
        final mid = (low + high + 1) >> 1;
        if (lineStarts[mid] <= offset) {
          low = mid;
        } else {
          high = mid - 1;
        }
      }
      return low;
    }

    // Brackets, skipping the ones inside strings and comments.
    final opaque = [
      for (final token in _tokenize(view, widget.language, _controller.palette))
        if (token.opaque) token,
    ];
    int opaqueIndex = 0;
    final stack = <int>[];
    for (int i = 0; i < view.length; i++) {
      while (opaqueIndex < opaque.length && opaque[opaqueIndex].end <= i) {
        opaqueIndex++;
      }
      if (opaqueIndex < opaque.length && opaque[opaqueIndex].start <= i) {
        i = opaque[opaqueIndex].end - 1;
        continue;
      }
      final unit = view.codeUnitAt(i);
      if (unit == 0x7B || unit == 0x5B || unit == 0x28) {
        stack.add(i);
      } else if ((unit == 0x7D || unit == 0x5D || unit == 0x29) && stack.isNotEmpty) {
        final open = stack.removeLast();
        final line = lineOf(open);
        if (lineOf(i) > line) ranges.putIfAbsent(line, () => TextRange(start: open + 1, end: i));
      }
    }

    // Indented blocks, for Python and for plain text.
    if (widget.language == CodeEditorLanguage.python || widget.language == null) {
      int indentOf(int line) {
        final end = line + 1 < lineStarts.length ? lineStarts[line + 1] - 1 : view.length;
        int indent = 0;
        for (int i = lineStarts[line]; i < end; i++) {
          final unit = view.codeUnitAt(i);
          if (unit == 0x20) {
            indent++;
          } else if (unit == 0x09) {
            indent += 4;
          } else {
            return indent;
          }
        }
        return -1; // blank
      }

      for (int line = 0; line + 1 < lineStarts.length; line++) {
        if (ranges.containsKey(line)) continue;
        final indent = indentOf(line);
        if (indent < 0) continue;
        int last = line;
        for (int next = line + 1; next < lineStarts.length; next++) {
          final nextIndent = indentOf(next);
          if (nextIndent < 0) continue;
          if (nextIndent <= indent) break;
          last = next;
        }
        if (last > line) {
          final lineEnd = lineStarts[line + 1] - 1;
          final blockEnd = last + 1 < lineStarts.length ? lineStarts[last + 1] - 1 : view.length;
          ranges[line] = TextRange(start: lineEnd, end: blockEnd);
        }
      }
    }
    return ranges;
  }

  int _lineAt(String view, int offset) => '\n'.allMatches(view.substring(0, offset.clamp(0, view.length))).length;

  void _setView(String view, {int? cursor}) {
    final offset = (cursor ?? _controller.selection.baseOffset).clamp(0, view.length);
    _controller.value = TextEditingValue(
      text: view,
      selection: TextSelection.collapsed(offset: offset),
    );
    _updateMatches();
    setState(() {});
  }

  void _foldLine(int line) {
    final view = _controller.text;
    final range = _foldRanges(view)[line];
    if (range == null) return;
    int unit = _foldFirst;
    while (_folds.containsKey(unit) && unit < _foldLast) {
      unit++;
    }
    _folds[unit] = view.substring(range.start, range.end);
    final cursor = _controller.selection.baseOffset;
    // A cursor inside the folded region moves to just before the chip.
    final nextCursor = cursor <= range.start ? cursor : (cursor >= range.end ? cursor - (range.end - range.start) + 1 : range.start);
    _setView(view.replaceRange(range.start, range.end, String.fromCharCode(unit)), cursor: nextCursor);
  }

  void _unfold(int unit) {
    final view = _controller.text;
    final index = view.indexOf(String.fromCharCode(unit));
    if (_diffEditable) {
      // Lay the diff out again without this fold, so the line tints stay in step.
      final real = _real(view);
      final cursor = _realOffset(view, _controller.selection.baseOffset);
      _folds.remove(unit);
      _setDiffView(real, realCursor: cursor);
      _updateMatches();
      setState(() {});
      return;
    }
    final content = _folds.remove(unit);
    if (index < 0 || content == null) return;
    _setView(view.replaceRange(index, index + 1, content));
  }

  void _unfoldLine(int line) {
    final lines = _controller.text.split('\n');
    if (line >= lines.length) return;
    for (final unit in lines[line].codeUnits) {
      if (_folds.containsKey(unit)) {
        _unfold(unit);
        return;
      }
    }
  }

  void _handleChanged(String view) {
    if (_diffEditable) {
      // The edit may have added or removed deleted runs, so lay the diff out again.
      final real = _real(view);
      _setDiffView(real, realCursor: _realOffset(view, _controller.selection.baseOffset));
      _updateMatches();
      setState(() {});
      widget.onChanged?.call(real);
      return;
    }
    // Drop the folds whose chip the edit deleted.
    if (_folds.isNotEmpty) {
      final live = <int>{};
      void collect(String text) {
        for (final unit in text.codeUnits) {
          if (_folds.containsKey(unit) && live.add(unit)) collect(_folds[unit]!);
        }
      }

      collect(view);
      _folds.removeWhere((unit, _) => !live.contains(unit));
    }
    _updateMatches();
    // Rebuild so the gutter tracks the line count.
    setState(() {});
    widget.onChanged?.call(_expand(view));
  }

  // --- Search ---

  void _updateMatches() {
    final query = _searchOpen ? _searchController.text : '';
    final matches = <TextRange>[];
    if (query.isNotEmpty && _folds.isNotEmpty) {
      // A match hidden in a fold opens that fold; the rest stay folded.
      final needle = query.toLowerCase();
      for (final unit in _folds.keys.toList()) {
        if (_folds.containsKey(unit) &&
            _expand(_folds[unit]!).toLowerCase().contains(needle) &&
            _controller.text.contains(String.fromCharCode(unit))) {
          _unfold(unit);
          return; // _unfold runs this again for what is left.
        }
      }
    }
    if (query.isNotEmpty) {
      final haystack = _controller.text.toLowerCase();
      final needle = query.toLowerCase();
      for (int index = haystack.indexOf(needle); index >= 0; index = haystack.indexOf(needle, index + needle.length)) {
        matches.add(TextRange(start: index, end: index + needle.length));
      }
    }
    _controller
      ..matches = matches
      ..activeMatch = matches.isEmpty ? -1 : _controller.activeMatch.clamp(0, matches.length - 1)
      ..refresh();
  }

  void _openSearch() {
    if (!widget.searchable || widget.disabled || (widget.original != null && !_diffEditable)) return;
    final selection = _controller.selection;
    if (selection.isValid && !selection.isCollapsed) {
      final selected = selection.textInside(_controller.text);
      if (!selected.contains('\n')) _searchController.text = selected;
    }
    setState(() => _searchOpen = true);
    _updateMatches();
    _searchFocus.requestFocus();
    _searchController.selection = TextSelection(baseOffset: 0, extentOffset: _searchController.text.length);
  }

  void _closeSearch() {
    if (!_searchOpen) return;
    setState(() => _searchOpen = false);
    _updateMatches();
    _focusNode.requestFocus();
  }

  void _stepMatch(int direction) {
    final count = _controller.matches.length;
    if (count == 0) return;
    final next = (_controller.activeMatch + direction) % count;
    _controller
      ..activeMatch = next < 0 ? count - 1 : next
      ..refresh();
    _revealMatch();
    setState(() {});
  }

  /// Scrolls the current match into view when the editor scrolls itself.
  void _revealMatch() {
    final index = _controller.activeMatch;
    if (index < 0 || !_scrollController.hasClients) return;
    final position = _scrollController.position;
    final target = _lineAt(_controller.text, _controller.matches[index].start) * _lineHeight - position.viewportDimension / 3;
    _scrollController.jumpTo(target.clamp(position.minScrollExtent, position.maxScrollExtent));
  }

  void _replaceCurrent() {
    final index = _controller.activeMatch;
    if (index < 0 || widget.readOnly) return;
    final match = _controller.matches[index];
    final view = _controller.text.replaceRange(match.start, match.end, _replaceController.text);
    _controller.value = TextEditingValue(
      text: view,
      selection: TextSelection.collapsed(offset: match.start + _replaceController.text.length),
    );
    _handleChanged(view);
    // The next hit slides into this index; past the last one, wrap to the first.
    final count = _controller.matches.length;
    _controller
      ..activeMatch = count == 0 ? -1 : index % count
      ..refresh();
    _revealMatch();
  }

  void _replaceAll() {
    if (_controller.matches.isEmpty || widget.readOnly) return;
    final buffer = StringBuffer();
    int cursor = 0;
    for (final match in _controller.matches) {
      buffer
        ..write(_controller.text.substring(cursor, match.start))
        ..write(_replaceController.text);
      cursor = match.end;
    }
    buffer.write(_controller.text.substring(cursor));
    final view = buffer.toString();
    _controller.value = TextEditingValue(
      text: view,
      selection: TextSelection.collapsed(offset: math.min(_controller.selection.baseOffset, view.length).clamp(0, view.length)),
    );
    _handleChanged(view);
  }

  Widget _buildSearchBar(PrimeThemeData theme) {
    final c = theme.colorScheme;
    final count = _controller.matches.length;
    final status = _searchController.text.isEmpty ? '' : (count == 0 ? 'No results' : '${_controller.activeMatch + 1} of $count');

    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): _closeSearch},
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: c.surfaceBase,
          border: Border(bottom: BorderSide(color: c.borderSubtle)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            Row(
              children: [
                Expanded(
                  child: Input(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    dense: true,
                    placeholder: 'Find',
                    autocorrect: false,
                    leading: const Icon(PrimeIcons.magnify),
                    textInputAction: TextInputAction.search,
                    onChanged: (_) {
                      _controller.activeMatch = 0;
                      _updateMatches();
                      _revealMatch();
                      setState(() {});
                    },
                    onSubmitted: () {
                      _stepMatch(1);
                      // Submitting takes focus away; keep it so Enter steps again.
                      _searchFocus.requestFocus();
                    },
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 64,
                  child: Text(
                    status,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall.copyWith(fontSize: 12, height: 1.2, color: c.textTertiary),
                  ),
                ),
                _BarButton(icon: PrimeIcons.chevronUp, label: 'Previous match', onTap: () => _stepMatch(-1)),
                _BarButton(icon: PrimeIcons.chevronDown, label: 'Next match', onTap: () => _stepMatch(1)),
                _BarButton(icon: PrimeIcons.close, label: 'Close search', onTap: _closeSearch),
              ],
            ),
            if (!widget.readOnly)
              Row(
                children: [
                  Expanded(
                    child: Input(
                      controller: _replaceController,
                      dense: true,
                      placeholder: 'Replace',
                      autocorrect: false,
                      onSubmitted: _replaceCurrent,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _BarButton(text: 'Replace', label: 'Replace match', onTap: _replaceCurrent),
                  _BarButton(text: 'All', label: 'Replace all matches', onTap: _replaceAll),
                ],
              ),
          ],
        ),
      ),
    );
  }

  TextStyle _codeStyle(PrimeThemeData theme) => TextStyle(
    fontFamily: 'RobotoMono',
    package: 'prime_flutter',
    fontSize: _fontSize,
    height: _lineHeight / _fontSize,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: widget.disabled ? theme.colorScheme.textPlaceholder : theme.colorScheme.textPrimary,
  );

  StrutStyle get _strut => const StrutStyle(
    fontFamily: 'RobotoMono',
    package: 'prime_flutter',
    fontSize: _fontSize,
    height: _lineHeight / _fontSize,
    forceStrutHeight: true,
  );

  double _measure(String text, TextStyle style, {double maxWidth = double.infinity}) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      strutStyle: _strut,
    )..layout(maxWidth: maxWidth);
    final size = maxWidth.isFinite ? painter.height : painter.width;
    painter.dispose();
    return size;
  }

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final c = theme.colorScheme;
    final palette = _CodePalette.of(theme);
    _controller
      ..language = widget.language
      ..palette = palette
      ..matchColor = PrimeColors.warningMedium.withValues(alpha: 0.55)
      ..activeMatchColor = PrimeColors.warningBright.withValues(alpha: 0.75);
    final isEditor = widget.original == null || _diffEditable;

    final borderColor = widget.invalid ? c.statusDangerDark : (_focused && isEditor ? c.inputFocus : c.borderSubtle);
    final radius = BorderRadius.circular(theme.cornerRadius / 2);

    return Semantics(
      container: true,
      label: widget.semanticLabel,
      textField: isEditor,
      readOnly: widget.readOnly || !isEditor,
      enabled: !widget.disabled,
      child: Container(
        decoration: BoxDecoration(
          color: widget.disabled ? c.surfaceHighlight : c.surfaceOffset,
          borderRadius: radius,
          border: Border.all(color: borderColor, width: _focused && isEditor ? 2 : 1),
        ),
        // Keep the content from shifting when the focus border thickens.
        padding: EdgeInsets.all(_focused && isEditor ? 0 : 1),
        child: ClipRRect(
          borderRadius: radius,
          child: LayoutBuilder(
            builder: (context, outer) {
              final body = LayoutBuilder(
                builder: (context, constraints) {
                  final Widget content;
                  if (!isEditor) {
                    content = _buildDiff(context, theme, palette, constraints);
                  } else if (_diffEditable && widget.diff == CodeEditorDiff.split) {
                    // The original on the left, read-only; the document on the right, editable.
                    final half = BoxConstraints(maxWidth: math.max(0, (constraints.maxWidth - 1) / 2));
                    content = Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: half.maxWidth,
                          child: _buildDiff(context, theme, palette, half, only: _DiffSide.original),
                        ),
                        Container(
                          width: half.maxWidth + 1,
                          decoration: BoxDecoration(
                            border: Border(left: BorderSide(color: c.borderSubtle)),
                          ),
                          child: _buildEditor(context, theme, palette, half),
                        ),
                      ],
                    );
                  } else {
                    content = _buildEditor(context, theme, palette, constraints);
                  }
                  if (!constraints.hasBoundedHeight) return content;
                  return SizedBox(
                    height: constraints.maxHeight,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: content,
                      ),
                    ),
                  );
                },
              );
              final bounded = outer.hasBoundedHeight;
              final column = Column(
                mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_searchOpen && isEditor) _buildSearchBar(theme),
                  bounded ? Expanded(child: body) : body,
                ],
              );
              if (!isEditor || widget.disabled) return column;

              int cursorLine() => _lineAt(_controller.text, math.max(0, _controller.selection.baseOffset));
              return CallbackShortcuts(
                bindings: {
                  if (widget.searchable) ...{
                    const SingleActivator(LogicalKeyboardKey.keyF, meta: true): _openSearch,
                    const SingleActivator(LogicalKeyboardKey.keyF, control: true): _openSearch,
                  },
                  if (widget.foldable) ...{
                    const SingleActivator(LogicalKeyboardKey.bracketLeft, meta: true, shift: true): () => _foldLine(cursorLine()),
                    const SingleActivator(LogicalKeyboardKey.bracketLeft, control: true, shift: true): () => _foldLine(cursorLine()),
                    const SingleActivator(LogicalKeyboardKey.bracketRight, meta: true, shift: true): () => _unfoldLine(cursorLine()),
                    const SingleActivator(LogicalKeyboardKey.bracketRight, control: true, shift: true): () => _unfoldLine(cursorLine()),
                  },
                },
                child: column,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFoldChip(int codeUnit) {
    final c = PrimeTheme.of(context).colorScheme;
    if (_isChunkChar(codeUnit)) return _buildChunk(codeUnit);
    return Semantics(
      button: true,
      label: 'Unfold',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _unfold(codeUnit),
          child: Container(
            height: 14,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(color: c.surfaceHighlight, borderRadius: BorderRadius.circular(3)),
            child: Icon(PrimeIcons.dotsHorizontal, size: 14, color: c.textSecondary),
          ),
        ),
      ),
    );
  }

  /// The deleted lines a stand-in character shows: the lines themselves in
  /// the unified diff, a blank block of the same height in the split one.
  Widget _buildChunk(int codeUnit) {
    final theme = PrimeTheme.of(context);
    final removed = _chunks[codeUnit] ?? '';
    final count = '\n'.allMatches(removed).length + 1;
    if (widget.diff == CodeEditorDiff.split) return SizedBox(width: 1, height: count * _lineHeight);
    return ExcludeSemantics(
      child: IgnorePointer(
        child: Text.rich(
          TextSpan(children: _highlight(removed, widget.language, _controller.palette)),
          style: _codeStyle(theme),
          strutStyle: _strut,
          softWrap: false,
        ),
      ),
    );
  }

  Widget _gutterNumber(String text, _CodePalette palette, PrimeThemeData theme, {double height = _lineHeight}) {
    return SizedBox(
      height: height,
      child: Align(
        alignment: Alignment.topRight,
        child: Text(
          text,
          style: _codeStyle(theme).copyWith(color: palette.lineNumber),
          strutStyle: _strut,
        ),
      ),
    );
  }

  Widget _buildEditor(BuildContext context, PrimeThemeData theme, _CodePalette palette, BoxConstraints constraints) {
    final c = theme.colorScheme;
    final style = _codeStyle(theme);
    final lines = _controller.text.split('\n');
    final inDiff = _diffEditable;
    final isSplit = widget.diff == CodeEditorDiff.split;
    final showFolds = widget.lineNumbers && widget.foldable && !widget.disabled && !inDiff;
    final foldRanges = showFolds ? _foldRanges(_controller.text) : const <int, TextRange>{};

    // What each line is in the diff, and how many lines of the original a deleted run stands for.
    _DiffKind kindOf(int i) => inDiff && i < _viewKinds.length ? _viewKinds[i] : _DiffKind.same;
    int chunkLines(int i) {
      final unit = lines[i].codeUnits.where(_isChunkChar).firstOrNull;
      return unit == null ? 1 : '\n'.allMatches(_chunks[unit] ?? '').length + 1;
    }

    // A folded line stands for several lines of the document, so numbers skip ahead after it;
    // a deleted run is not a line of the document at all.
    final lineNumbers = <int?>[];
    int number = 1;
    for (int i = 0; i < lines.length; i++) {
      if (kindOf(i) == _DiffKind.removed) {
        lineNumbers.add(null);
        continue;
      }
      lineNumbers.add(number);
      number += 1 + (_folds.isEmpty ? 0 : '\n'.allMatches(_expand(lines[i])).length);
    }
    const foldColumn = 16.0;
    const signColumn = 14.0;
    final gutterWidth = widget.lineNumbers
        ? _measure('${math.max(1, number - 1)}'.padLeft(2, '0'), style) +
              _padding * 2 +
              (showFolds ? foldColumn : 0) +
              (inDiff ? signColumn : 0)
        : 0.0;
    final textWidth = math.max(0.0, constraints.maxWidth - gutterWidth - _padding * 2);

    // A wrapped line takes several rows, and a deleted run takes one per deleted line.
    if (inDiff) WidgetsBinding.instance.addPostFrameCallback((_) => _measureLines());
    final measured = inDiff && _measuredText == _controller.text && _lineHeights.length == lines.length;
    final heights = measured
        ? _lineHeights
        : <double>[
            for (int i = 0; i < lines.length; i++)
              kindOf(i) == _DiffKind.removed
                  ? chunkLines(i) * _lineHeight
                  : (widget.wrapLines && textWidth > 0
                        ? _measure(lines[i].isEmpty ? ' ' : lines[i], style, maxWidth: textWidth)
                        : _lineHeight),
          ];

    final field = RawInput(
      key: _fieldKey,
      controller: _controller,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      enabled: !widget.disabled,
      readOnly: widget.readOnly,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      autocorrect: false,
      enableSuggestions: false,
      smartDashesType: SmartDashesType.disabled,
      smartQuotesType: SmartQuotesType.disabled,
      textCapitalization: TextCapitalization.none,
      style: style,
      // A deleted run is taller than one line, so the diff must not force every line to the strut.
      // It has to say so outright: left null, the text field forces a strut of its own.
      strutStyle: inDiff
          ? const StrutStyle(fontFamily: 'RobotoMono', package: 'prime_flutter', fontSize: _fontSize, height: _lineHeight / _fontSize)
          : _strut,
      cursorColor: c.textPrimary,
      cursorWidth: 1.5,
      placeholder: widget.placeholder,
      placeholderStyle: style.copyWith(color: c.textTertiary),
      onChanged: _handleChanged,
    );

    final Widget textArea;
    if (widget.wrapLines) {
      textArea = Padding(padding: const EdgeInsets.all(_padding), child: field);
    } else {
      textArea = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(_padding),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: textWidth),
          child: IntrinsicWidth(child: field),
        ),
      );
    }

    Widget editor = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.lineNumbers)
          Container(
            width: gutterWidth,
            padding: EdgeInsets.fromLTRB(_padding, _padding, showFolds || inDiff ? 0 : _padding, _padding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < lines.length; i++)
                  () {
                    final numberCell = _gutterNumber(lineNumbers[i]?.toString() ?? '', palette, theme, height: heights[i]);
                    if (inDiff) {
                      final kind = kindOf(i);
                      // The split view shows deletions on the other side, so only additions are signed here.
                      final sign = kind == _DiffKind.added ? '+' : (kind == _DiffKind.removed && !isSplit ? '-' : '');
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: numberCell),
                          SizedBox(
                            width: signColumn,
                            child: Text(
                              [for (int n = 0; n < (kind == _DiffKind.removed ? chunkLines(i) : 1); n++) sign].join('\n'),
                              textAlign: TextAlign.center,
                              style: style.copyWith(color: kind == _DiffKind.added ? c.statusSuccessDark : c.statusDangerDark),
                              strutStyle: _strut,
                            ),
                          ),
                        ],
                      );
                    }
                    if (!showFolds) return numberCell;
                    final isFolded = lines[i].codeUnits.any(_folds.containsKey);
                    final canFold = foldRanges.containsKey(i);
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: numberCell),
                        SizedBox(
                          width: foldColumn,
                          height: _lineHeight,
                          child: isFolded || canFold
                              ? Pressable(
                                  semanticLabel: isFolded ? 'Unfold line ${lineNumbers[i]}' : 'Fold line ${lineNumbers[i]}',
                                  onTap: () => isFolded ? _unfoldLine(i) : _foldLine(i),
                                  builder: (context, hovered, pressed) => Icon(
                                    isFolded ? PrimeIcons.chevronRight : PrimeIcons.chevronDown,
                                    size: 14,
                                    color: hovered || isFolded ? c.textPrimary : palette.lineNumber,
                                  ),
                                )
                              : null,
                        ),
                      ],
                    );
                  }(),
              ],
            ),
          ),
        Expanded(child: textArea),
      ],
    );

    if (inDiff) {
      // Full-width tints behind the changed lines, under the gutter and the text alike.
      final addedFill = Color.alphaBlend(c.statusSuccessDark.withValues(alpha: 0.14), c.surfaceOffset);
      final removedFill = isSplit ? c.surfaceHighlight : Color.alphaBlend(c.statusDangerDark.withValues(alpha: 0.14), c.surfaceOffset);
      editor = Stack(
        children: [
          Positioned.fill(
            child: ExcludeSemantics(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: _padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int i = 0; i < lines.length; i++)
                      Container(
                        height: heights[i],
                        color: switch (kindOf(i)) {
                          _DiffKind.added => addedFill,
                          _DiffKind.removed => removedFill,
                          _DiffKind.same => null,
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
          editor,
        ],
      );
    }

    return editor;
  }

  /// Groups diff lines into visible lines and collapsed runs of unchanged ones.
  List<Object> _diffRows(List<_DiffLine> lines) {
    if (!widget.collapseUnchanged) return lines;
    const context = 3;
    const minRun = 4;
    final rows = <Object>[];
    int index = 0;
    int runId = 0;
    while (index < lines.length) {
      if (lines[index].kind != _DiffKind.same) {
        rows.add(lines[index++]);
        continue;
      }
      int end = index;
      while (end < lines.length && lines[end].kind == _DiffKind.same) {
        end++;
      }
      final head = index == 0 ? 0 : context;
      final tail = end == lines.length ? 0 : context;
      final hidden = end - index - head - tail;
      final id = runId++;
      if (hidden < minRun || _expandedRuns.contains(id)) {
        rows.addAll(lines.sublist(index, end));
      } else {
        rows.addAll(lines.sublist(index, index + head));
        rows.add((id: id, count: hidden));
        rows.addAll(lines.sublist(end - tail, end));
      }
      index = end;
    }
    return rows;
  }

  Widget _buildDiff(BuildContext context, PrimeThemeData theme, _CodePalette palette, BoxConstraints constraints, {_DiffSide? only}) {
    final c = theme.colorScheme;
    final style = _codeStyle(theme);
    final rows = _diffRows(_diffLines(widget.original!, only == null ? widget.value : _real(_controller.text)));
    final addedFill = Color.alphaBlend(c.statusSuccessDark.withValues(alpha: 0.14), c.surfaceOffset);
    final removedFill = Color.alphaBlend(c.statusDangerDark.withValues(alpha: 0.14), c.surfaceOffset);
    final numberWidth = _measure('${rows.length + 1}'.padLeft(2, '0'), style);

    Widget collapsed(({int id, int count}) run) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _expandedRuns.add(run.id)),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          color: c.surfaceHighlight,
          padding: const EdgeInsets.symmetric(horizontal: _padding, vertical: 4),
          child: Text('${run.count} unchanged lines', style: style.copyWith(color: c.textSecondary)),
        ),
      ),
    );

    /// One side of the diff. [side] null renders the unified view.
    Widget column(_DiffSide? side) {
      final children = <Widget>[];
      for (final row in rows) {
        if (row is! _DiffLine) {
          children.add(collapsed(row as ({int id, int count})));
          continue;
        }
        final hiddenHere =
            (side == _DiffSide.original && row.kind == _DiffKind.added) || (side == _DiffSide.current && row.kind == _DiffKind.removed);
        final number = side == _DiffSide.original
            ? row.oldNumber
            : (side == _DiffSide.current ? row.newNumber : (row.newNumber ?? row.oldNumber));
        final sign = hiddenHere ? ' ' : (row.kind == _DiffKind.added ? '+' : (row.kind == _DiffKind.removed ? '-' : ' '));
        final fill = hiddenHere ? null : (row.kind == _DiffKind.added ? addedFill : (row.kind == _DiffKind.removed ? removedFill : null));

        children.add(
          Container(
            color: fill,
            padding: const EdgeInsets.symmetric(horizontal: _padding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.lineNumbers)
                  SizedBox(
                    width: numberWidth,
                    child: Text(
                      hiddenHere || number == null ? '' : '$number',
                      textAlign: TextAlign.right,
                      style: style.copyWith(color: palette.lineNumber),
                      strutStyle: _strut,
                    ),
                  ),
                SizedBox(
                  width: 24,
                  child: Text(
                    sign,
                    textAlign: TextAlign.center,
                    style: style.copyWith(color: row.kind == _DiffKind.added ? c.statusSuccessDark : c.statusDangerDark),
                    strutStyle: _strut,
                  ),
                ),
                if (widget.wrapLines)
                  Expanded(child: _diffText(hiddenHere ? '' : row.text, style, palette))
                else
                  _diffText(hiddenHere ? '' : row.text, style, palette),
              ],
            ),
          ),
        );
      }

      final body = Padding(
        padding: const EdgeInsets.symmetric(vertical: _padding),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
      );
      if (widget.wrapLines) return body;
      final width = side == null || only != null ? constraints.maxWidth : (constraints.maxWidth - 1) / 2;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: math.max(0.0, width)),
          child: IntrinsicWidth(child: body),
        ),
      );
    }

    if (only != null) return column(only);
    if (widget.diff == CodeEditorDiff.unified) return column(null);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: column(_DiffSide.original)),
          Container(width: 1, color: c.borderSubtle),
          Expanded(child: column(_DiffSide.current)),
        ],
      ),
    );
  }

  Widget _diffText(String text, TextStyle style, _CodePalette palette) {
    return Text.rich(
      TextSpan(children: _highlight(text.isEmpty ? ' ' : text, widget.language, palette)),
      style: style,
      strutStyle: _strut,
      softWrap: widget.wrapLines,
    );
  }
}

/// Which document a column of the split diff shows.
enum _DiffSide { original, current }

/// A small icon or text button for the search bar.
class _BarButton extends StatelessWidget {
  final IconData? icon;
  final String? text;
  final String label;
  final VoidCallback onTap;

  const _BarButton({this.icon, this.text, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final c = theme.colorScheme;
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      builder: (context, hovered, pressed) => Container(
        height: 28,
        constraints: const BoxConstraints(minWidth: 28),
        margin: const EdgeInsets.only(left: 2),
        padding: EdgeInsets.symmetric(horizontal: text != null ? 8 : 0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: pressed ? c.surfaceHighlight : (hovered ? c.surfaceHover : null),
          borderRadius: BorderRadius.circular(4),
          border: text != null ? Border.all(color: c.borderSubtle) : null,
        ),
        child: icon != null
            ? Icon(icon, size: 16, color: c.textSecondary)
            : ExcludeSemantics(
                child: Text(text!, style: theme.textTheme.bodySmall.copyWith(fontSize: 12, height: 1.2, color: c.textPrimary)),
              ),
      ),
    );
  }
}
