import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:markdown/markdown.dart' as md;

import '../theme/prime_theme.dart';
import '../theme/prime_theme_data.dart';
import 'code_editor.dart';
import 'code_snippet.dart';
import 'divider.dart';
import 'prime_icons.dart';

/// Renders GitHub-flavored Markdown with Prime's type and color.
///
/// Supports headings, paragraphs, emphasis, strikethrough, inline code, links,
/// ordered, unordered and task lists, block quotes, rules, tables, and fenced
/// code, which renders as a [CodeSnippet]. Raw HTML is shown as text.
///
/// [data] can be incomplete, so text that is still streaming in can be
/// rendered as it grows.
///
/// ```dart
/// Markdown(
///   data: 'Lower `max_rpm` to **180**.',
///   onTapLink: (href) => launchUrl(Uri.parse(href)),
/// )
/// ```
class Markdown extends StatefulWidget {
  final String data;

  /// Called with a link's destination when it is tapped. Links are styled but
  /// inert when null.
  final ValueChanged<String>? onTapLink;

  /// Text style for body copy. Defaults to [PrimeTextTheme.bodyDefault].
  final TextStyle? style;

  /// Vertical gap between blocks.
  final double blockSpacing;

  /// Forwarded to each [CodeSnippet] after a copy attempt.
  final void Function(bool succeeded, String message)? onCopyCode;

  const Markdown({super.key, required this.data, this.onTapLink, this.style, this.blockSpacing = 12, this.onCopyCode});

  @override
  State<Markdown> createState() => _MarkdownState();
}

const _blockTags = {'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'p', 'ul', 'ol', 'pre', 'blockquote', 'hr', 'table'};

const _languages = {
  'go': CodeEditorLanguage.go,
  'golang': CodeEditorLanguage.go,
  'js': CodeEditorLanguage.javascript,
  'javascript': CodeEditorLanguage.javascript,
  'json': CodeEditorLanguage.json,
  'json5': CodeEditorLanguage.json5,
  'jsonc': CodeEditorLanguage.json5,
  'py': CodeEditorLanguage.python,
  'python': CodeEditorLanguage.python,
  'sql': CodeEditorLanguage.sql,
  'ts': CodeEditorLanguage.typescript,
  'typescript': CodeEditorLanguage.typescript,
};

class _MarkdownState extends State<Markdown> {
  List<md.Node> _nodes = const [];
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void initState() {
    super.initState();
    _parse();
  }

  @override
  void didUpdateWidget(Markdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) _parse();
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _parse() {
    _nodes = md.Document(extensionSet: md.ExtensionSet.gitHubFlavored, encodeHtml: false).parse(widget.data);
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();
    final theme = PrimeTheme.of(context);
    final body = widget.style ?? theme.textTheme.bodyDefault.copyWith(height: 1.45);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: widget.blockSpacing,
      children: _blocks(_nodes, theme, body),
    );
  }

  List<Widget> _blocks(List<md.Node> nodes, PrimeThemeData theme, TextStyle body) {
    final blocks = <Widget>[];
    var inline = <md.Node>[];
    void flush() {
      if (inline.isEmpty) return;
      final span = _span(inline, theme, body);
      if (span.toPlainText().trim().isNotEmpty) blocks.add(Text.rich(span));
      inline = [];
    }

    for (final node in nodes) {
      if (node is md.Element && _blockTags.contains(node.tag)) {
        flush();
        blocks.add(_block(node, theme, body));
      } else {
        inline.add(node);
      }
    }
    flush();
    return blocks;
  }

  Widget _block(md.Element element, PrimeThemeData theme, TextStyle body) {
    final c = theme.colorScheme;
    final children = element.children ?? const <md.Node>[];
    switch (element.tag) {
      case 'h1':
        return Text.rich(_span(children, theme, body.copyWith(fontSize: 20, fontWeight: FontWeight.w600, height: 1.3)));
      case 'h2':
        return Text.rich(_span(children, theme, body.copyWith(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3)));
      case 'h3' || 'h4' || 'h5' || 'h6':
        return Text.rich(_span(children, theme, body.copyWith(fontWeight: FontWeight.w600)));
      case 'ul' || 'ol':
        return _list(element, theme, body);
      case 'pre':
        final code = children.whereType<md.Element>().firstOrNull;
        final language = code?.attributes['class']?.replaceFirst('language-', '').toLowerCase();
        return CodeSnippet(
          code: element.textContent.replaceFirst(RegExp(r'\n$'), ''),
          language: _languages[language],
          onCopy: widget.onCopyCode,
        );
      case 'blockquote':
        return Container(
          padding: const EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: c.borderSubtle, width: 3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: widget.blockSpacing,
            children: _blocks(children, theme, body.copyWith(color: c.textSecondary)),
          ),
        );
      case 'hr':
        return const Divider();
      case 'table':
        return _table(element, theme, body);
      default:
        return Text.rich(_span(children, theme, body));
    }
  }

  Widget _list(md.Element list, PrimeThemeData theme, TextStyle body) {
    final ordered = list.tag == 'ol';
    var number = int.tryParse(list.attributes['start'] ?? '') ?? 1;
    final items = <Widget>[];
    for (final item in (list.children ?? const <md.Node>[]).whereType<md.Element>()) {
      var content = item.children ?? const <md.Node>[];
      Widget marker;
      // A loose list wraps each item's text, checkbox included, in a paragraph.
      final first = content.firstOrNull;
      final inParagraph = first is md.Element && first.tag == 'p';
      final checkbox = inParagraph ? first.children?.firstOrNull : first;
      if (checkbox is md.Element && checkbox.tag == 'input') {
        final checked = checkbox.attributes.containsKey('checked');
        marker = Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Icon(
            checked ? PrimeIcons.checkboxMarked : PrimeIcons.checkboxBlankOutline,
            size: 16,
            color: theme.colorScheme.iconSecondary,
          ),
        );
        content = inParagraph ? [md.Element('p', first.children!.sublist(1)), ...content.sublist(1)] : content.sublist(1);
      } else {
        marker = Text(ordered ? '${number++}.' : '•', style: body, textAlign: TextAlign.right);
      }
      items.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            ConstrainedBox(constraints: const BoxConstraints(minWidth: 14), child: marker),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 4, children: _blocks(content, theme, body)),
            ),
          ],
        ),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 4, children: items);
  }

  Widget _table(md.Element table, PrimeThemeData theme, TextStyle body) {
    final c = theme.colorScheme;
    final cellStyle = body.copyWith(fontSize: 14);
    final rows = <TableRow>[];
    var columns = 0;
    for (final section in (table.children ?? const <md.Node>[]).whereType<md.Element>()) {
      for (final row in (section.children ?? const <md.Node>[]).whereType<md.Element>()) {
        final cells = (row.children ?? const <md.Node>[]).whereType<md.Element>().toList();
        if (cells.length > columns) columns = cells.length;
        rows.add(
          TableRow(
            decoration: section.tag == 'thead' ? BoxDecoration(color: c.surfaceOffset) : null,
            children: [
              for (final cell in cells)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Text.rich(
                    _span(cell.children ?? const [], theme, cell.tag == 'th' ? cellStyle.copyWith(fontWeight: FontWeight.w600) : cellStyle),
                  ),
                ),
            ],
          ),
        );
      }
    }
    // Table needs every row to have the same number of cells.
    final padded = [
      for (final row in rows)
        TableRow(
          decoration: row.decoration,
          children: [...row.children, for (var i = row.children.length; i < columns; i++) const SizedBox.shrink()],
        ),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        border: TableBorder.all(color: c.borderSubtle, borderRadius: BorderRadius.circular(4)),
        children: padded,
      ),
    );
  }

  TextSpan _span(List<md.Node> nodes, PrimeThemeData theme, TextStyle style) {
    return TextSpan(style: style, children: [for (final node in nodes) _inline(node, theme, style)]);
  }

  InlineSpan _inline(md.Node node, PrimeThemeData theme, TextStyle style) {
    if (node is! md.Element) return TextSpan(text: node.textContent);
    final c = theme.colorScheme;
    final children = node.children ?? const <md.Node>[];
    switch (node.tag) {
      case 'strong':
        return _span(children, theme, style.copyWith(fontWeight: FontWeight.w600));
      case 'em':
        return _span(children, theme, style.copyWith(fontStyle: FontStyle.italic));
      case 'del':
        return _span(children, theme, style.copyWith(decoration: TextDecoration.lineThrough));
      case 'code':
        return TextSpan(
          text: node.textContent,
          style: theme.textTheme.label.copyWith(
            fontSize: (style.fontSize ?? 16) - 2,
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
            height: style.height,
            color: style.color,
            backgroundColor: c.surfaceHover,
          ),
        );
      case 'a':
        final href = node.attributes['href'];
        final onTapLink = widget.onTapLink;
        TapGestureRecognizer? recognizer;
        if (href != null && onTapLink != null) {
          recognizer = TapGestureRecognizer()..onTap = () => onTapLink(href);
          _recognizers.add(recognizer);
        }
        return TextSpan(
          text: node.textContent,
          style: style.copyWith(color: c.inputFocus, decoration: TextDecoration.underline, decorationColor: c.inputFocus),
          recognizer: recognizer,
        );
      case 'br':
        return const TextSpan(text: '\n');
      case 'img':
        return TextSpan(text: node.attributes['alt'] ?? '');
      default:
        return _span(children, theme, style);
    }
  }
}
