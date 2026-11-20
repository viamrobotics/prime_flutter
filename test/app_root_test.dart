// PrimeApp as the app root, with no Material or Cupertino anywhere beneath
// it: theming, navigation, text editing, sheets, scrolling and the scaffold.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart' show SelectedContent;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime_flutter/prime_flutter.dart';

const mobile = TargetPlatformVariant({TargetPlatform.android, TargetPlatform.iOS});
const desktop = TargetPlatformVariant({TargetPlatform.macOS, TargetPlatform.linux, TargetPlatform.windows});

Widget host(Widget child) => PrimeApp(home: Scaffold(body: child));

Widget page(String name, {Widget? child}) {
  return Scaffold(
    appBar: AppBar(title: Text('$name bar')),
    body: Center(child: child ?? Text(name)),
  );
}

/// Records what the framework writes to the clipboard, and serves [contents] back.
class FakeClipboard {
  String? contents;

  void install(WidgetTester tester) {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      switch (call.method) {
        case 'Clipboard.setData':
          contents = (call.arguments as Map)['text'] as String?;
        case 'Clipboard.getData':
          return {'text': contents};
        case 'Clipboard.hasStrings':
          return {'value': contents?.isNotEmpty ?? false};
      }
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
  }
}

void main() {
  test('the library depends on the widgets layer only', () {
    final banned = RegExp(r'''package:(flutter/(material|cupertino)\.dart|material_ui/|cupertino_ui/|flutter_localizations/)''');
    final offenders = [
      for (final file in Directory('lib').listSync(recursive: true).whereType<File>())
        if (file.path.endsWith('.dart') && banned.hasMatch(file.readAsStringSync())) file.path,
    ];
    expect(offenders, isEmpty, reason: 'prime_flutter must build on package:flutter/widgets.dart alone');

    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, isNot(contains('flutter_localizations')));
    expect(pubspec, isNot(contains('material_ui')));
    expect(pubspec, isNot(contains('cupertino_ui')));
  });

  group('PrimeApp', () {
    testWidgets('provides the theme, text, icon, selection, scroll and hero defaults', (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        PrimeApp(
          home: Builder(
            builder: (c) {
              context = c;
              return const SizedBox();
            },
          ),
        ),
      );
      final theme = PrimeTheme.of(context);
      expect(theme.brightness, Brightness.light);
      expect(DefaultTextStyle.of(context).style.fontSize, theme.textTheme.bodyDefault.fontSize);
      expect(IconTheme.of(context).color, theme.colorScheme.iconPrimary);
      expect(DefaultSelectionStyle.of(context).cursorColor, theme.colorScheme.inputFocus);
      expect(ScrollConfiguration.of(context), isA<PrimeScrollBehavior>());
      expect(Directionality.of(context), TextDirection.ltr);
      expect(WidgetsLocalizations.of(context).copyButtonLabel, 'Copy');
      expect(ModalRoute.of(context), isA<PrimePageRoute<dynamic>>());
    });

    testWidgets('follows themeMode and the platform brightness', (tester) async {
      Widget app(PrimeThemeMode mode) {
        return PrimeApp(
          theme: PrimeThemeData.light(),
          darkTheme: PrimeThemeData.dark(),
          themeMode: mode,
          home: Builder(builder: (context) => Text(PrimeTheme.of(context).brightness.name)),
        );
      }

      await tester.pumpWidget(app(PrimeThemeMode.light));
      expect(find.text('light'), findsOneWidget);
      await tester.pumpWidget(app(PrimeThemeMode.dark));
      expect(find.text('dark'), findsOneWidget);

      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await tester.pumpWidget(app(PrimeThemeMode.system));
      await tester.pump();
      expect(find.text('dark'), findsOneWidget);
    });

    testWidgets('PrimeTheme.maybeOf is null outside an app', (tester) async {
      PrimeThemeData? found = PrimeThemeData.light();
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            found = PrimeTheme.maybeOf(context);
            return const SizedBox();
          },
        ),
      );
      expect(found, isNull);
    });

    testWidgets('named routes, onGenerateTitle and the builder all work', (tester) async {
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        PrimeApp(
          navigatorKey: navigator,
          onGenerateTitle: (context) => 'Generated',
          initialRoute: '/',
          routes: {'/': (_) => page('Home'), '/settings': (_) => page('Settings')},
          builder: (context, child) => Column(
            children: [
              // The builder sits above the navigator and still sees the theme.
              Text('themed ${PrimeTheme.of(context).cornerRadius}', textDirection: TextDirection.ltr),
              Expanded(child: child!),
            ],
          ),
        ),
      );
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('themed 8.0'), findsOneWidget);
      expect(tester.widget<Title>(find.byType(Title)).title, 'Generated');

      navigator.currentState!.pushNamed('/settings');
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Home'), findsNothing);

      // The app bar offers a way back on a pushed page.
      await tester.tap(find.byIcon(PrimeIcons.chevronLeft));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('PrimeApp.router shows PrimePage pages', (tester) async {
      final delegate = _StackRouterDelegate(['home']);
      addTearDown(delegate.dispose);
      await tester.pumpWidget(PrimeApp.router(routerDelegate: delegate, backButtonDispatcher: RootBackButtonDispatcher()));
      expect(find.text('home'), findsOneWidget);

      delegate.push('detail');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      // Mid-transition both pages are on screen.
      expect(find.text('home'), findsOneWidget);
      expect(find.text('detail'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('home'), findsNothing);

      // The system back button pops through the router.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('home'), findsOneWidget);
      expect(delegate.stack, ['home']);
    });

    testWidgets('heroes fly between pages', (tester) async {
      final navigator = GlobalKey<NavigatorState>();
      Widget hero(double size) => Hero(
        tag: 'logo',
        child: SizedBox.square(dimension: size, child: const Placeholder()),
      );
      await tester.pumpWidget(
        PrimeApp(
          navigatorKey: navigator,
          home: Align(alignment: Alignment.topLeft, child: hero(40)),
        ),
      );
      navigator.currentState!.push(
        PrimePageRoute<void>(
          builder: (_) => Align(alignment: Alignment.bottomRight, child: hero(200)),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      // In flight there is a single hero, somewhere between the two sizes.
      final size = tester.getSize(find.byType(Placeholder));
      expect(size.width, inExclusiveRange(40, 200));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(Placeholder)).width, 200);
    });
  });

  group('PrimePageRoute', () {
    testWidgets('slides in from the trailing edge on Apple platforms', (tester) async {
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(PrimeApp(navigatorKey: navigator, home: page('Home')));
      navigator.currentState!.push(PrimePageRoute<void>(builder: (_) => page('Detail')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      final dx = tester.getTopLeft(find.text('Detail bar')).dx;
      final settledHome = tester.getTopLeft(find.text('Home bar')).dx;
      await tester.pumpAndSettle();
      // The new page was still travelling in from the right.
      expect(dx, greaterThan(tester.getTopLeft(find.text('Detail bar')).dx));
      expect(settledHome, isNotNull);
      expect(find.text('Home'), findsNothing);
    }, variant: const TargetPlatformVariant({TargetPlatform.iOS, TargetPlatform.macOS}));

    testWidgets('fades through elsewhere', (tester) async {
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(PrimeApp(navigatorKey: navigator, home: page('Home')));
      navigator.currentState!.push(PrimePageRoute<void>(builder: (_) => page('Detail')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      final fade = tester.widget<FadeTransition>(find.ancestor(of: find.text('Detail'), matching: find.byType(FadeTransition)).first);
      expect(fade.opacity.value, inExclusiveRange(0, 1));
      // No horizontal travel.
      expect(tester.getCenter(find.text('Detail')).dx, 400);
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsNothing);
    }, variant: const TargetPlatformVariant({TargetPlatform.android, TargetPlatform.linux, TargetPlatform.windows}));

    testWidgets('a swipe from the leading edge pops the page on iOS', (tester) async {
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(PrimeApp(navigatorKey: navigator, home: page('Home')));
      navigator.currentState!.push(PrimePageRoute<void>(builder: (_) => page('Detail')));
      await tester.pumpAndSettle();

      // A short drag springs back.
      var gesture = await tester.startGesture(const Offset(5, 300));
      await gesture.moveBy(const Offset(40, 0));
      await gesture.moveBy(const Offset(120, 0));
      await tester.pump();
      expect(find.text('Home'), findsOneWidget, reason: 'the page below shows while dragging');
      expect(tester.getTopLeft(find.text('Detail bar')).dx, greaterThan(100));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.text('Detail'), findsOneWidget);
      expect(find.text('Home'), findsNothing);
      expect(navigator.currentState!.userGestureInProgress, isFalse);

      // A long one pops.
      gesture = await tester.startGesture(const Offset(5, 300));
      await gesture.moveBy(const Offset(40, 0));
      await gesture.moveBy(const Offset(500, 0));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.text('Detail'), findsNothing);
      expect(find.text('Home'), findsOneWidget);
      expect(navigator.currentState!.userGestureInProgress, isFalse);

      // The first page has nothing to swipe back to.
      gesture = await tester.startGesture(const Offset(5, 300));
      await gesture.moveBy(const Offset(400, 0));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets('a fullscreen dialog rises and has no back swipe', (tester) async {
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(PrimeApp(navigatorKey: navigator, home: page('Home')));
      navigator.currentState!.push(PrimePageRoute<void>(fullscreenDialog: true, builder: (_) => page('Dialog')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.getTopLeft(find.text('Dialog bar')).dy, greaterThan(100));
      expect(tester.getCenter(find.text('Dialog')).dx, 400);
      // The page below stays put.
      expect(tester.getCenter(find.text('Home')).dx, 400);
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(const Offset(5, 300));
      await gesture.moveBy(const Offset(40, 0));
      await gesture.moveBy(const Offset(500, 0));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.text('Dialog'), findsOneWidget);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets('the theme and the route can each choose the transition', (tester) async {
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        PrimeApp(
          navigatorKey: navigator,
          theme: PrimeThemeData.light().copyWith(
            pageTransitionsTheme: const PrimePageTransitionsTheme(builders: {TargetPlatform.android: _NoTransitionsBuilder()}),
          ),
          home: page('Home'),
        ),
      );
      navigator.currentState!.push(PrimePageRoute<void>(builder: (_) => page('Detail')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();
      expect(find.text('Home'), findsNothing, reason: 'the themed builder has no duration');

      navigator.currentState!.push(
        PrimePageRoute<void>(transitionsBuilder: const PrimeSlidePageTransitionsBuilder(), builder: (_) => page('Slid')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.getTopLeft(find.text('Slid bar')).dx, greaterThan(0));
      await tester.pumpAndSettle();
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));
  });

  group('Input without Material', () {
    testWidgets('types, reports changes and submits', (tester) async {
      final changes = <String>[];
      var submitted = 0;
      await tester.pumpWidget(host(Input(placeholder: 'Name', onChanged: changes.add, onSubmitted: () => submitted++)));
      expect(find.text('Name'), findsOneWidget);

      await tester.tap(find.byType(Input));
      await tester.pump();
      expect(tester.testTextInput.isVisible, isTrue, reason: 'tapping the box focuses the field');

      await tester.enterText(find.byType(Input), 'arm-1');
      await tester.pump();
      expect(changes, ['arm-1']);
      expect(find.text('Name'), findsNothing, reason: 'the placeholder leaves once there is text');
      expect(find.text('arm-1'), findsOneWidget);

      await tester.testTextInput.receiveAction(TextInputAction.done);
      expect(submitted, 1);
    });

    testWidgets('tapping the padding or an icon slot focuses the field', (tester) async {
      await tester.pumpWidget(host(const Input(leading: Icon(PrimeIcons.magnify))));
      final box = tester.getRect(find.byType(Input));
      await tester.tapAt(box.centerRight - const Offset(4, 0));
      await tester.pump();
      expect(tester.testTextInput.isVisible, isTrue);
    });

    testWidgets('keeps its size when the focus border thickens', (tester) async {
      await tester.pumpWidget(
        host(
          const Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: 300, child: Input()),
          ),
        ),
      );
      final before = tester.getRect(find.byType(EditableText));
      final boxBefore = tester.getSize(find.byType(Input));
      await tester.tap(find.byType(Input));
      await tester.pump();
      expect(tester.getRect(find.byType(EditableText)), before);
      expect(tester.getSize(find.byType(Input)), boxBefore);
    });

    testWidgets('disabled rejects focus; read-only focuses but does not edit', (tester) async {
      final controller = TextEditingController(text: 'fixed');
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        host(
          Column(
            children: [
              const Input(key: Key('off'), disabled: true),
              Input(key: const Key('ro'), readOnly: true, controller: controller),
            ],
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('off')), warnIfMissed: false);
      await tester.pump();
      expect(tester.testTextInput.isVisible, isFalse);
      expect(FocusManager.instance.primaryFocus?.context?.widget, isNot(isA<EditableText>()));

      await tester.tap(find.byKey(const Key('ro')));
      await tester.pump();
      expect(
        tester.widget<EditableText>(find.descendant(of: find.byKey(const Key('ro')), matching: find.byType(EditableText))).readOnly,
        isTrue,
      );
    });

    testWidgets('multi-line inputs grow and take newlines', (tester) async {
      await tester.pumpWidget(
        host(
          const Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: 300, child: Input(minLines: 2, maxLines: 4)),
          ),
        ),
      );
      final twoLines = tester.getSize(find.byType(Input)).height;
      await tester.enterText(find.byType(Input), 'a\nb\nc\nd\ne\nf');
      await tester.pump();
      final grown = tester.getSize(find.byType(Input)).height;
      expect(grown, greaterThan(twoLines));
      final editable = tester.widget<EditableText>(find.byType(EditableText));
      expect(editable.keyboardType, TextInputType.multiline);
      expect(editable.maxLines, 4);
    });

    testWidgets('a long press selects a word and offers Prime\'s copy menu on touch platforms', (tester) async {
      final clipboard = FakeClipboard()..install(tester);
      final controller = TextEditingController(text: 'hello world');
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        host(
          Center(
            child: SizedBox(width: 300, child: Input(controller: controller)),
          ),
        ),
      );

      await tester.longPressAt(tester.getTopLeft(find.byType(EditableText)) + const Offset(20, 8));
      await tester.pumpAndSettle();
      expect(controller.selection, const TextSelection(baseOffset: 0, extentOffset: 5));
      expect(find.byType(PrimeTextSelectionToolbar), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Cut'), findsOneWidget);
      // Both ends of the selection get a drag handle.
      expect(tester.widget<EditableText>(find.byType(EditableText)).showSelectionHandles, isTrue);

      await tester.tap(find.text('Copy'));
      await tester.pumpAndSettle();
      expect(clipboard.contents, 'hello');
      expect(find.byType(PrimeTextSelectionToolbar), findsNothing);

      // Paste what was copied over the whole text.
      await tester.longPressAt(tester.getTopLeft(find.byType(EditableText)) + const Offset(20, 8));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select all'));
      await tester.pumpAndSettle();
      expect(controller.selection, const TextSelection(baseOffset: 0, extentOffset: 11));
      await tester.tap(find.text('Paste'));
      await tester.pumpAndSettle();
      expect(controller.text, 'hello');
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));

    testWidgets('a right click opens the menu at the pointer on desktop, with no handles', (tester) async {
      final clipboard = FakeClipboard()..install(tester);
      final controller = TextEditingController(text: 'hello world');
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        host(
          Center(
            child: SizedBox(width: 300, child: Input(controller: controller)),
          ),
        ),
      );

      // Double-click a word, as a mouse user would.
      final at = tester.getTopLeft(find.byType(EditableText)) + const Offset(20, 8);
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.down(at);
      await mouse.up();
      await tester.pump(const Duration(milliseconds: 50));
      await mouse.down(at);
      await mouse.up();
      await tester.pumpAndSettle();
      expect(controller.selection, const TextSelection(baseOffset: 0, extentOffset: 5));
      expect(tester.widget<EditableText>(find.byType(EditableText)).showSelectionHandles, isFalse);
      expect(find.byType(PrimeTextSelectionToolbar), findsNothing);

      await tester.tapAt(at, buttons: kSecondaryButton, kind: PointerDeviceKind.mouse);
      await tester.pumpAndSettle();
      expect(find.byType(PrimeTextSelectionToolbar), findsOneWidget);
      // The menu opens beside the pointer rather than above the selection.
      final menu = tester.getRect(find.text('Copy'));
      expect(menu.top, greaterThan(at.dy - 1));
      expect(menu.left, greaterThan(at.dx - 1));

      await tester.tap(find.text('Cut'));
      await tester.pumpAndSettle();
      expect(clipboard.contents, 'hello');
      expect(controller.text, ' world');
    }, variant: desktop);

    testWidgets('keyboard shortcuts edit and select', (tester) async {
      final clipboard = FakeClipboard()..install(tester);
      final controller = TextEditingController(text: 'hello');
      addTearDown(controller.dispose);
      await tester.pumpWidget(host(Input(controller: controller, autofocus: true)));
      await tester.pump();

      Future<void> chord(LogicalKeyboardKey key) async {
        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
        await tester.sendKeyEvent(key);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
        await tester.pump();
      }

      await chord(LogicalKeyboardKey.keyA);
      expect(controller.selection, const TextSelection(baseOffset: 0, extentOffset: 5));
      await chord(LogicalKeyboardKey.keyC);
      expect(clipboard.contents, 'hello');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await chord(LogicalKeyboardKey.keyV);
      expect(controller.text, 'hellohello');
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

    testWidgets('RawInput takes a decoration of its own', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        host(
          RawInput(
            controller: controller,
            placeholder: 'Search',
            decorationBuilder: (context, editable) => Padding(key: const Key('chrome'), padding: const EdgeInsets.all(30), child: editable),
          ),
        ),
      );
      expect(find.text('Search'), findsOneWidget);
      // A tap on the decoration, well outside the text, still focuses.
      await tester.tapAt(tester.getTopLeft(find.byKey(const Key('chrome'))) + const Offset(5, 5));
      await tester.pump();
      expect(tester.testTextInput.isVisible, isTrue);
      await tester.enterText(find.byType(RawInput), 'x');
      await tester.pump();
      expect(controller.text, 'x');
      expect(find.text('Search'), findsNothing);
    });
  });

  group('SelectionArea', () {
    testWidgets('selects and copies static text', (tester) async {
      final clipboard = FakeClipboard()..install(tester);
      SelectedContent? selected;
      await tester.pumpWidget(
        host(
          SelectionArea(
            onSelectionChanged: (content) => selected = content,
            child: const Center(child: Text('machine online')),
          ),
        ),
      );
      await tester.longPressAt(tester.getTopLeft(find.text('machine online')) + const Offset(10, 8));
      await tester.pumpAndSettle();
      expect(selected?.plainText, 'machine');
      expect(find.byType(PrimeTextSelectionToolbar), findsOneWidget);
      await tester.tap(find.text('Copy'));
      await tester.pumpAndSettle();
      expect(clipboard.contents, 'machine');
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));
  });

  group('BottomSheet without Material', () {
    Future<List<Object?>> open(WidgetTester tester, {bool isDismissible = true, bool enableDrag = true}) async {
      final results = <Object?>[];
      await tester.pumpWidget(
        host(
          Builder(
            builder: (context) => Button(
              label: const Text('Open'),
              onPressed: () async {
                final result = await BottomSheet.show<String>(
                  context: context,
                  title: const Text('Sheet title'),
                  isDismissible: isDismissible,
                  enableDrag: enableDrag,
                  child: Column(
                    children: [
                      const SizedBox(height: 200, child: Text('Sheet body')),
                      Button(label: const Text('Pick'), onPressed: () => Navigator.of(context).pop('picked')),
                    ],
                  ),
                );
                results.add(result);
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      return results;
    }

    testWidgets('slides up from the bottom and returns a value', (tester) async {
      final results = await open(tester);
      expect(find.text('Sheet title'), findsOneWidget);
      expect(tester.getRect(find.byType(BottomSheet)).bottom, 600);
      expect(tester.getRect(find.byType(BottomSheet)).top, greaterThan(200));

      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();
      expect(results, ['picked']);
      expect(find.text('Sheet title'), findsNothing);
    });

    testWidgets('dismisses from the barrier and the back button', (tester) async {
      var results = await open(tester);
      await tester.tapAt(const Offset(400, 20));
      await tester.pumpAndSettle();
      expect(results, [null]);
      expect(find.text('Sheet title'), findsNothing);

      results = await open(tester);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(results, [null]);
    });

    testWidgets('a drag down dismisses; a nudge springs back', (tester) async {
      final results = await open(tester);
      final top = tester.getRect(find.byType(BottomSheet)).top;

      await tester.drag(find.text('Sheet title'), const Offset(0, 40));
      await tester.pump();
      expect(tester.getRect(find.byType(BottomSheet)).top, greaterThan(top), reason: 'the sheet follows the finger');
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byType(BottomSheet)).top, top);
      expect(results, isEmpty);

      await tester.drag(find.text('Sheet title'), const Offset(0, 260));
      await tester.pumpAndSettle();
      expect(results, [null]);
      expect(find.text('Sheet title'), findsNothing);
    });

    testWidgets('isDismissible and enableDrag turn those off', (tester) async {
      final results = await open(tester, isDismissible: false, enableDrag: false);
      await tester.tapAt(const Offset(400, 20));
      await tester.pumpAndSettle();
      await tester.drag(find.text('Sheet title'), const Offset(0, 300));
      await tester.pumpAndSettle();
      expect(find.text('Sheet title'), findsOneWidget);
      expect(results, isEmpty);
    });

    testWidgets('rises with the keyboard', (tester) async {
      await open(tester);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300 * 3);
      addTearDown(tester.view.resetViewInsets);
      await tester.pump();
      final dpr = tester.view.devicePixelRatio;
      expect(tester.getRect(find.text('Pick')).bottom, lessThanOrEqualTo(600 - 300 * 3 / dpr));
    });
  });

  group('Scaffold', () {
    testWidgets('shrinks the body above the keyboard and hides the insets from it', (tester) async {
      double? seenInset;
      Widget app({required bool resize}) {
        return PrimeApp(
          home: Scaffold(
            resizeToAvoidBottomInset: resize,
            bottomNavigationBar: const SizedBox(height: 50, child: Text('nav')),
            floatingActionButton: const SizedBox.square(dimension: 40, child: Text('fab')),
            body: Builder(
              builder: (context) {
                seenInset = MediaQuery.viewInsetsOf(context).bottom;
                return const SizedBox.expand(key: Key('body'));
              },
            ),
          ),
        );
      }

      await tester.pumpWidget(app(resize: true));
      expect(tester.getRect(find.byKey(const Key('body'))).bottom, 550);
      expect(tester.getRect(find.text('fab')).bottom, lessThan(550));

      final dpr = tester.view.devicePixelRatio;
      tester.view.viewInsets = FakeViewPadding(bottom: 300 * dpr);
      addTearDown(tester.view.resetViewInsets);
      await tester.pump();
      expect(tester.getRect(find.byKey(const Key('body'))).bottom, 300);
      expect(seenInset, 0);
      expect(find.text('nav').hitTestable(), findsNothing, reason: 'the bar stays under the keyboard');
      expect(tester.getRect(find.text('fab')).bottom, lessThan(300));

      await tester.pumpWidget(app(resize: false));
      expect(tester.getRect(find.byKey(const Key('body'))).bottom, 550);
      expect(seenInset, 300);
    });

    testWidgets('tells the platform how to draw the status bar', (tester) async {
      await tester.pumpWidget(
        PrimeApp(
          theme: PrimeThemeData.dark(),
          home: const Scaffold(body: SizedBox()),
        ),
      );
      final region = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(find.byType(AnnotatedRegion<SystemUiOverlayStyle>));
      expect(region.value.statusBarIconBrightness, Brightness.light);
    });
  });

  group('PrimeScrollBehavior', () {
    testWidgets('draws a scrollbar on desktop only', (tester) async {
      await tester.pumpWidget(host(ListView(children: [for (int i = 0; i < 50; i++) SizedBox(height: 40, child: Text('row $i'))])));
      expect(find.byType(RawScrollbar), debugDefaultTargetPlatformOverride == TargetPlatform.android ? findsNothing : findsOneWidget);
      expect(find.byType(GlowingOverscrollIndicator), findsNothing);
      expect(
        find.byType(StretchingOverscrollIndicator),
        debugDefaultTargetPlatformOverride == TargetPlatform.android ? findsOneWidget : findsNothing,
      );
    }, variant: const TargetPlatformVariant({TargetPlatform.android, TargetPlatform.macOS, TargetPlatform.windows}));
  });
}

class _NoTransitionsBuilder extends PageTransitionsBuilder {
  const _NoTransitionsBuilder();

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => child;
}

/// A minimal declarative router: a stack of names shown as [PrimePage]s.
class _StackRouterDelegate extends RouterDelegate<Object> with ChangeNotifier, PopNavigatorRouterDelegateMixin<Object> {
  _StackRouterDelegate(this.stack);

  final List<String> stack;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void push(String name) {
    stack.add(name);
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [for (final name in stack) PrimePage<void>(key: ValueKey(name), name: name, child: page(name))],
      onDidRemovePage: (page) {
        stack.remove(page.name);
      },
    );
  }

  @override
  Future<void> setNewRoutePath(Object configuration) async {}
}
