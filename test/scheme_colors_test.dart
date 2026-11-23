// Every color a Prime widget draws with comes from PrimeColorScheme, so a
// scheme is a complete theme. These tests give each slot a color no built-in
// scheme uses and check the widget picks it up, and guard against a widget
// reaching past the scheme for a fixed color.
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime_flutter/prime_flutter.dart';

const Color medium = Color(0xFF010101);
const Color bright = Color(0xFF020202);
const Color pendingLight = Color(0xFF030303);
const Color pendingDark = Color(0xFF040404);
const Color statusText = Color(0xFF050505);
const Color statusBody = Color(0xFF060606);
const Color hover = Color(0xFF080808);
const Color pressed = Color(0xFF090909);
const Color inverse = Color(0xFF0A0A0A);
const Color inverseText = Color(0xFF0D0D0D);
const Color statusFg = Color(0xFF101010);
const Color keyword = Color(0xFF111111);

final PrimeColorScheme scheme = PrimeColorScheme.light().copyWith(
  statusDangerMedium: medium,
  statusInfoMedium: medium,
  statusSuccessMedium: medium,
  statusWarningMedium: medium,
  statusWarningBright: bright,
  statusPendingLight: pendingLight,
  statusPendingMedium: medium,
  statusPendingDark: pendingDark,
  statusTextPrimary: statusText,
  statusTextSecondary: statusBody,
  actionPrimaryHover: hover,
  actionPrimaryPressed: pressed,
  actionStatusFg: statusFg,
  surfaceInverse: inverse,
  textInverse: inverseText,
);

Widget host(Widget child, {PrimeColorScheme? colors}) {
  final c = colors ?? scheme;
  return PrimeApp(
    theme: PrimeThemeData(colorScheme: c, textTheme: PrimeTextTheme.withColorScheme(c), cornerRadius: 8),
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );
}

/// Every color the widgets under [within] fill, outline, or write with.
Set<Color> colorsOf(WidgetTester tester, Finder within) {
  final colors = <Color>{};
  void decoration(Decoration? value) {
    if (value is! BoxDecoration) return;
    if (value.color != null) colors.add(value.color!);
    final border = value.border;
    if (border is Border) colors.addAll([border.top.color, border.left.color, border.right.color, border.bottom.color]);
  }

  void span(InlineSpan value, Color? inherited) {
    final color = value.style?.color ?? inherited;
    if (value is TextSpan) {
      if (value.text != null && color != null) colors.add(color);
      for (final child in value.children ?? const <InlineSpan>[]) {
        span(child, color);
      }
    }
  }

  for (final element in find.descendant(of: within, matching: find.byWidgetPredicate((_) => true)).evaluate()) {
    final widget = element.widget;
    if (widget is Container) {
      decoration(widget.decoration);
      if (widget.color != null) colors.add(widget.color!);
    } else if (widget is DecoratedBox) {
      decoration(widget.decoration);
    } else if (widget is ColoredBox) {
      colors.add(widget.color);
    } else if (widget is RichText) {
      span(widget.text, null);
    } else if (widget is Icon) {
      final color = widget.color ?? IconTheme.of(element).color;
      if (color != null) colors.add(color);
    }
  }
  return colors;
}

void main() {
  group('PrimeColorScheme', () {
    test('copyWith replaces the given colors and keeps the rest', () {
      final light = PrimeColorScheme.light();
      final next = light.copyWith(surfaceBase: inverse, chartSeries: const [bright]);
      expect(next.surfaceBase, inverse);
      expect(next.chartSeries, const [bright]);
      expect(next.textPrimary, light.textPrimary);
      expect(next.statusWarningBright, light.statusWarningBright);
      expect(next.syntax, light.syntax);
    });

    test('a scheme built from the required colors alone gets the light defaults', () {
      final light = PrimeColorScheme.light();
      final minimal = PrimeColorScheme(
        surfaceBase: light.surfaceBase,
        surfaceOffset: light.surfaceOffset,
        surfaceHover: light.surfaceHover,
        surfaceHighlight: light.surfaceHighlight,
        textPrimary: light.textPrimary,
        textSecondary: light.textSecondary,
        textTertiary: light.textTertiary,
        textPlaceholder: light.textPlaceholder,
        iconPrimary: light.iconPrimary,
        iconSecondary: light.iconSecondary,
        iconDisabled: light.iconDisabled,
        actionPrimaryBg: light.actionPrimaryBg,
        actionPrimaryFg: light.actionPrimaryFg,
        actionNeutralBg: light.actionNeutralBg,
        borderSubtle: light.borderSubtle,
        inputText: light.inputText,
        inputFocus: light.inputFocus,
        statusDangerLight: light.statusDangerLight,
        statusDangerDark: light.statusDangerDark,
        statusInfoLight: light.statusInfoLight,
        statusInfoDark: light.statusInfoDark,
        statusSuccessLight: light.statusSuccessLight,
        statusSuccessDark: light.statusSuccessDark,
        statusWarningLight: light.statusWarningLight,
        statusWarningDark: light.statusWarningDark,
      );
      expect(minimal.statusInfoMedium, light.statusInfoMedium);
      expect(minimal.actionPrimaryHover, light.actionPrimaryHover);
      expect(minimal.surfaceInverse, light.surfaceInverse);
      expect(minimal.chartSeries, light.chartSeries);
      // Left null, the syntax colors follow the surface.
      expect(minimal.syntax, isNull);
    });

    test('the dark primary button does not hover to near-black under dark text', () {
      final dark = PrimeColorScheme.dark();
      expect(dark.actionPrimaryHover.computeLuminance(), greaterThan(0.5));
      expect(dark.actionPrimaryPressed.computeLuminance(), greaterThan(0.3));
    });
  });

  group('widgets draw with the scheme', () {
    testWidgets('PrimeBanner', (tester) async {
      await tester.pumpWidget(
        host(PrimeBanner(variant: BannerVariant.warning, title: const Text('Heads up'), subtitle: const Text('Details'), onClose: () {})),
      );
      final colors = colorsOf(tester, find.byType(PrimeBanner));
      expect(colors, containsAll([medium, bright, statusText, statusBody, statusBody.withValues(alpha: 0.7)]));

      await tester.pumpWidget(host(const PrimeBanner(variant: BannerVariant.pending, title: Text('Working'))));
      expect(colorsOf(tester, find.byType(PrimeBanner)), containsAll([pendingLight, medium]));
    });

    testWidgets('Pill and StatusPill', (tester) async {
      await tester.pumpWidget(
        host(
          Column(
            children: [
              Pill(value: 'info', variant: PillVariant.info, onRemove: (_) {}),
              Pill(value: 'dark', variant: PillVariant.dark, icon: PrimeIcons.close, onRemove: (_) {}),
              const StatusPill(label: 'Warning', variant: StatusPillVariant.warning),
            ],
          ),
        ),
      );
      expect(
        colorsOf(tester, find.byType(Column).first),
        containsAll([medium, bright, inverseText, Color.alphaBlend(inverseText.withValues(alpha: 0.45), inverse)]),
      );
    });

    testWidgets('Badge, StatusDot and Kbd', (tester) async {
      await tester.pumpWidget(
        host(
          const Column(
            children: [
              Badge(variant: BadgeVariant.pending, child: Text('Pending')),
              StatusDot(state: StatusDotState.warning, label: 'Warning'),
              Kbd(variant: KbdVariant.dark, child: Text('K')),
            ],
          ),
        ),
      );
      final colors = colorsOf(tester, find.byType(Column).first);
      expect(colors, containsAll([pendingLight, pendingDark, bright]));
      expect(colors, contains(inverseText.withValues(alpha: 0.2)));
    });

    testWidgets('SiteBanner', (tester) async {
      await tester.pumpWidget(
        host(
          Column(
            children: [
              SiteBanner(variant: SiteBannerVariant.warning, heading: 'Maintenance', value: 'Tonight', onDismiss: () {}),
              const SiteBanner(
                variant: SiteBannerVariant.announcement,
                badge: 'New',
                segments: [
                  SiteBannerSegment('Charts are here.'),
                  SiteBannerSegment('Really.', style: SiteBannerSegmentStyle.strong),
                  SiteBannerSegment('Soon more.', style: SiteBannerSegmentStyle.subtle),
                ],
              ),
            ],
          ),
        ),
      );
      final colors = colorsOf(tester, find.byType(Column).first);
      expect(
        colors,
        containsAll([bright, statusText, inverse, inverseText, inverseText.withValues(alpha: 0.83), inverseText.withValues(alpha: 0.45)]),
      );
    });

    testWidgets('Button hover and press, and solid status text', (tester) async {
      await tester.pumpWidget(
        host(
          Column(
            children: [
              Button(label: const Text('Save'), variant: ButtonVariant.primary, onPressed: () {}),
              Button(label: const Text('Delete'), variant: ButtonVariant.danger, onPressed: () {}),
            ],
          ),
        ),
      );
      expect(colorsOf(tester, find.byType(Column).first), contains(statusFg));

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.text('Save')));
      await tester.pumpAndSettle();
      expect(colorsOf(tester, find.byType(Button).first), contains(hover));

      await mouse.down(tester.getCenter(find.text('Save')));
      // A press is only recognized once it has been held past the tap timeout.
      await tester.pump(kPressTimeout + const Duration(milliseconds: 10));
      await tester.pumpAndSettle();
      expect(colorsOf(tester, find.byType(Button).first), contains(pressed));
      await mouse.up();
      await tester.pumpAndSettle();
    });

    testWidgets('other buttons tint their background with the text color on hover', (tester) async {
      const text = Color(0xFF123456);
      final colors = scheme.copyWith(textPrimary: text);
      await tester.pumpWidget(
        host(
          Button(label: const Text('Cancel'), onPressed: () {}),
          colors: colors,
        ),
      );

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.text('Cancel')));
      await tester.pumpAndSettle();
      expect(colorsOf(tester, find.byType(Button)), contains(Color.alphaBlend(text.withValues(alpha: 0.1), colors.actionNeutralBg)));
    });

    testWidgets('code takes the scheme\'s syntax colors, and follows the surface without them', (tester) async {
      Color keywordColor(PrimeColorScheme colors) {
        final theme = PrimeThemeData(colorScheme: colors, textTheme: PrimeTextTheme.withColorScheme(colors), cornerRadius: 8);
        return highlightCode('return x', CodeEditorLanguage.javascript, theme).firstWhere((span) => span.text == 'return').style!.color!;
      }

      const custom = PrimeSyntaxColors(
        comment: keyword,
        keyword: keyword,
        type: keyword,
        function: keyword,
        string: keyword,
        number: keyword,
        boolean: keyword,
        nullValue: keyword,
        property: keyword,
        lineNumber: keyword,
      );
      expect(keywordColor(PrimeColorScheme.light().copyWith(syntax: custom)), keyword);
      expect(keywordColor(PrimeColorScheme.light()), PrimeSyntaxColors.light.keyword);
      expect(keywordColor(PrimeColorScheme.dark()), PrimeSyntaxColors.dark.keyword);
    });
  });

  // Fixed colors a widget may still use: full transparency, the scrim behind
  // a modal, a fallback for when there is no PrimeTheme at all, and the four
  // drop shadows that are still to be removed.
  test('no widget reaches past the scheme for a fixed color', () {
    const allowed = {
      'bottom_sheet.dart': ['const Color(0x66000000)'],
      'modal.dart': ['const Color(0x66000000)'],
      'dialog.dart': ['ui.Color.fromARGB(128, 0, 0, 0)', 'ui.Color.fromARGB(38, 0, 0, 0)'],
      'dropdown.dart': ['ui.Color.fromARGB(38, 0, 0, 0)'],
      'switch_toggle.dart': ['const Color(0x1F000000)'],
      'scroll_behavior.dart': ['?? PrimeColors.gray5'],
      // The status bar's icon brightness is the platform's, chosen to suit the scaffold's background.
      'prime_scaffold.dart': [
        'effectiveBackgroundColor.computeLuminance()',
        'Brightness.dark : Brightness.light',
        'Brightness.light : Brightness.dark',
      ],
      'text_selection.dart': ['?? PrimeColors.focusBlue'],
    };
    final fixed = RegExp(r'PrimeColors\.|Color\(0x|Color\.from(ARGB|RGBO)\(|Brightness\.(dark|light)\s*\?|computeLuminance');
    final offenders = <String>[];
    for (final file in Directory('lib/src/widgets').listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      final name = file.uri.pathSegments.last;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        var line = lines[i];
        if (line.trimLeft().startsWith('//')) continue;
        line = line.replaceAll('Color(0x00000000)', '');
        for (final ok in allowed[name] ?? const <String>[]) {
          line = line.replaceAll(ok, '');
        }
        if (fixed.hasMatch(line)) offenders.add('${file.path}:${i + 1}: ${lines[i].trim()}');
      }
    }
    expect(offenders, isEmpty, reason: 'Read the color from PrimeColorScheme, adding a slot if none fits.');
  });
}
