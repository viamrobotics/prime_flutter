import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/prime_theme.dart';
import 'code_editor.dart';
import 'icon_button.dart';
import 'prime_icons.dart';

/// An inline code fragment.
///
/// ```dart
/// InlineCode('viam-server')
/// ```
class InlineCode extends StatelessWidget {
  final String code;

  const InlineCode(this.code, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(color: theme.colorScheme.surfaceHover, borderRadius: BorderRadius.circular(2)),
      child: Text(
        code,
        style: theme.textTheme.label.copyWith(fontWeight: FontWeight.w500, letterSpacing: 0, color: theme.colorScheme.textSecondary),
      ),
    );
  }
}

enum _CopyState { copy, copied, failed }

/// A read-only block of code with an optional copy-to-clipboard button.
///
/// Set [language] to highlight Go, JavaScript, TypeScript, JSON, JSON5,
/// Python, or SQL; other code renders plain. Pass [spans] to supply your own
/// highlighted text.
///
/// ```dart
/// CodeSnippet(
///   code: '{ "myThing": true }',
///   caption: const Text('This text captions the code snippet.'),
/// )
/// ```
class CodeSnippet extends StatefulWidget {
  /// The code to render, and the text copied to the clipboard.
  final String code;

  /// Pre-highlighted text to render instead of plain [code].
  final InlineSpan? spans;

  /// Highlights [code] in this language. Null renders plain text.
  final CodeEditorLanguage? language;

  /// Optional caption shown above the code.
  final Widget? caption;

  final bool showCopyButton;

  /// Wrap long lines instead of scrolling horizontally.
  final bool wrapLines;

  /// Called after a copy attempt.
  final void Function(bool succeeded, String message)? onCopy;

  const CodeSnippet({
    super.key,
    required this.code,
    this.spans,
    this.language,
    this.caption,
    this.showCopyButton = true,
    this.wrapLines = false,
    this.onCopy,
  });

  @override
  State<CodeSnippet> createState() => _CodeSnippetState();
}

class _CodeSnippetState extends State<CodeSnippet> {
  _CopyState _copyState = _CopyState.copy;
  Timer? _resetTimer;

  Future<void> _copy() async {
    try {
      await Clipboard.setData(ClipboardData(text: widget.code));
      if (!mounted) return;
      setState(() => _copyState = _CopyState.copied);
      widget.onCopy?.call(true, 'Successfully copied snippet to the clipboard');
    } catch (_) {
      if (!mounted) return;
      setState(() => _copyState = _CopyState.failed);
      widget.onCopy?.call(false, 'Failed to copy snippet to the clipboard');
    }
    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copyState = _CopyState.copy);
    });
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final codeStyle = theme.textTheme.label.copyWith(
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.5,
      color: theme.colorScheme.textPrimary,
    );

    final text = Text.rich(
      widget.spans ?? TextSpan(children: highlightCode(widget.code, widget.language, theme)),
      style: codeStyle,
      softWrap: widget.wrapLines,
    );
    final (icon, label) = switch (_copyState) {
      _CopyState.copy => (PrimeIcons.contentCopy, 'Copy'),
      _CopyState.copied => (PrimeIcons.check, 'Copied'),
      _CopyState.failed => (PrimeIcons.close, 'Copy failed'),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.caption != null) ...[
          DefaultTextStyle(
            style: theme.textTheme.bodySmall.copyWith(color: theme.colorScheme.textSecondary),
            child: widget.caption!,
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceOffset,
            borderRadius: BorderRadius.circular(theme.cornerRadius),
            border: Border.all(color: theme.colorScheme.borderSubtle),
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(12, 12, widget.showCopyButton ? 56 : 12, 12),
                child: widget.wrapLines
                    ? SizedBox(width: double.infinity, child: text)
                    : SingleChildScrollView(scrollDirection: Axis.horizontal, child: text),
              ),
              if (widget.showCopyButton)
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(icon: Icon(icon), label: label, variant: IconButtonVariant.secondary, onPressed: _copy),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
