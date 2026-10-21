import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime_flutter/prime_flutter.dart';

const _screen = Size(400, 800);
const _keyboard = 300.0;
const _navigationBarHeight = 60.0;

final _bodyKey = GlobalKey();

class _NavigationBar extends StatelessWidget implements PreferredSizeWidget {
  const _NavigationBar();

  @override
  Size get preferredSize => const Size.fromHeight(_navigationBarHeight);

  @override
  Widget build(BuildContext context) => const SizedBox(height: _navigationBarHeight);
}

Future<EdgeInsets> _pumpScaffold(WidgetTester tester, {Widget? bottomNavigationBar, bool resizeToAvoidBottomInset = true}) async {
  tester.view.physicalSize = _screen;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  late EdgeInsets bodyViewInsets;
  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(
        size: _screen,
        viewInsets: EdgeInsets.only(bottom: _keyboard),
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: PrimeTheme(
          data: PrimeThemeData.light(),
          child: PrimeScaffold(
            bottomNavigationBar: bottomNavigationBar,
            resizeToAvoidBottomInset: resizeToAvoidBottomInset,
            body: Builder(
              builder: (context) {
                bodyViewInsets = MediaQuery.viewInsetsOf(context);
                return SizedBox.expand(key: _bodyKey);
              },
            ),
          ),
        ),
      ),
    ),
  );
  return bodyViewInsets;
}

void main() {
  group('PrimeScaffold resizeToAvoidBottomInset', () {
    testWidgets('shrinks the body to end at the keyboard and consumes the inset', (tester) async {
      final bodyViewInsets = await _pumpScaffold(tester);

      expect(tester.getRect(find.byKey(_bodyKey)).bottom, _screen.height - _keyboard);
      expect(bodyViewInsets.bottom, 0);
    });

    testWidgets('leaves the bottom navigation bar under the keyboard', (tester) async {
      await _pumpScaffold(tester, bottomNavigationBar: const _NavigationBar());

      expect(tester.getRect(find.byKey(_bodyKey)).bottom, _screen.height - _keyboard);
      expect(tester.getRect(find.byType(_NavigationBar)).bottom, _screen.height);
    });

    testWidgets('does not resize when disabled', (tester) async {
      final bodyViewInsets = await _pumpScaffold(tester, resizeToAvoidBottomInset: false);

      expect(tester.getRect(find.byKey(_bodyKey)).bottom, _screen.height);
      expect(bodyViewInsets.bottom, _keyboard);
    });

    testWidgets('scrolls a focused text field above the keyboard', (tester) async {
      tester.view.physicalSize = _screen;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: PrimeTheme(
            data: PrimeThemeData.light(),
            child: PrimeScaffold(
              body: ListView(
                children: [
                  const SizedBox(height: 700),
                  const Input(placeholder: 'field'),
                ],
              ),
            ),
          ),
        ),
      );
      final field = find.byType(TextField);

      await tester.showKeyboard(field);
      tester.view.viewInsets = const FakeViewPadding(bottom: _keyboard);
      await tester.pumpAndSettle();

      expect(tester.getRect(field).bottom, lessThanOrEqualTo(_screen.height - _keyboard));
    });
  });
}
