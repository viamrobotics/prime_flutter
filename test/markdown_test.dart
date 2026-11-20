import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime_flutter/prime_flutter.dart';

Widget host(Widget child) {
  return PrimeApp(
    home: Scaffold(
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: child),
    ),
  );
}

const sample = '''
# Heading

Lower `max_rpm` on **motor-left**, see [the docs](https://docs.viam.com) ~~soon~~ *now*.

- A loose cable
- Too high a limit
  1. nested one
  2. nested two

- [x] done
- [ ] not done

> Quoted

---

| Pin | State |
| --- | --- |
| 31 | hi |
| 33 |

```json
{
  "max_rpm": 180
}
```
''';

TextSpan? findSpan(InlineSpan root, bool Function(TextSpan) test) {
  if (root is! TextSpan) return null;
  if (test(root)) return root;
  for (final child in root.children ?? const <InlineSpan>[]) {
    final found = findSpan(child, test);
    if (found != null) return found;
  }
  return null;
}

void main() {
  testWidgets('renders every supported block', (tester) async {
    await tester.pumpWidget(host(const Markdown(data: sample)));

    expect(find.text('Heading'), findsOneWidget);
    expect(find.text('A loose cable'), findsOneWidget);
    expect(find.text('•'), findsNWidgets(2));
    expect(find.text('2.'), findsOneWidget);
    expect(find.text('nested two'), findsOneWidget);
    expect(find.byIcon(PrimeIcons.checkboxMarked), findsOneWidget);
    expect(find.byIcon(PrimeIcons.checkboxBlankOutline), findsOneWidget);
    expect(find.text('Quoted'), findsOneWidget);
    expect(find.byType(Divider), findsOneWidget);
    expect(find.byType(Table), findsOneWidget);
    expect(find.text('hi'), findsOneWidget);

    final snippet = tester.widget<CodeSnippet>(find.byType(CodeSnippet));
    expect(snippet.code, '{\n  "max_rpm": 180\n}');
    expect(snippet.language, CodeEditorLanguage.json);
    expect(tester.takeException(), isNull);
  });

  testWidgets('styles inline code and emphasis', (tester) async {
    await tester.pumpWidget(host(const Markdown(data: 'Set `max_rpm` to **180**')));

    final paragraph = tester.widget<RichText>(find.byType(RichText)).text;
    expect(paragraph.toPlainText(), 'Set max_rpm to 180');
    expect(findSpan(paragraph, (s) => s.text == 'max_rpm')?.style?.fontFamily, contains('RobotoMono'));
    expect(findSpan(paragraph, (s) => s.toPlainText() == '180' && s.style?.fontWeight == FontWeight.w600), isNotNull);
  });

  testWidgets('reports tapped links', (tester) async {
    final tapped = <String>[];
    await tester.pumpWidget(host(Markdown(data: '[docs](https://docs.viam.com)', onTapLink: tapped.add)));

    final paragraph = tester.widget<RichText>(find.byType(RichText)).text;
    final link = findSpan(paragraph, (s) => s.text == 'docs')!;
    (link.recognizer! as TapGestureRecognizer).onTap!();
    expect(tapped, ['https://docs.viam.com']);
  });

  testWidgets('renders text that is still streaming in', (tester) async {
    await tester.pumpWidget(host(const Markdown(data: 'Try **this')));
    expect(find.text('Try **this'), findsOneWidget);

    await tester.pumpWidget(host(const Markdown(data: 'Try **this**:\n\n```json\n{"a":')));
    expect(find.text('Try this:'), findsOneWidget);
    expect(tester.widget<CodeSnippet>(find.byType(CodeSnippet)).code, '{"a":');
    expect(tester.takeException(), isNull);
  });
}
