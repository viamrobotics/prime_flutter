import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime_flutter/prime_flutter.dart';

Widget host(Widget child) => PrimeApp(home: Scaffold(body: child));

void main() {
  group('InputFormField', () {
    String? notEmpty(String? value) => (value ?? '').isEmpty ? 'Required' : null;

    testWidgets('validate shows the error under the input and puts the field in error', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        host(
          Form(
            key: formKey,
            child: InputFormField(label: const Text('Name'), hint: const Text('Your name'), validator: notEmpty),
          ),
        ),
      );
      expect(find.text('Your name'), findsOneWidget);

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);
      expect(find.text('Your name'), findsNothing);
      expect(tester.widget<Field>(find.byType(Field)).state, InputState.error);

      await tester.enterText(find.byType(EditableText), 'Ada');
      expect(formKey.currentState!.validate(), isTrue);
      await tester.pump();
      expect(find.text('Required'), findsNothing);
      expect(tester.widget<Field>(find.byType(Field)).state, InputState.none);
    });

    testWidgets('follows a controller, saves, and resets to the initial value', (tester) async {
      final formKey = GlobalKey<FormState>();
      final controller = TextEditingController(text: 'start');
      addTearDown(controller.dispose);
      String? saved;
      await tester.pumpWidget(
        host(
          Form(
            key: formKey,
            child: InputFormField(controller: controller, validator: notEmpty, onSaved: (v) => saved = v),
          ),
        ),
      );

      controller.text = '';
      expect(formKey.currentState!.validate(), isFalse);
      controller.text = 'set from outside';
      expect(formKey.currentState!.validate(), isTrue);
      formKey.currentState!.save();
      expect(saved, 'set from outside');

      formKey.currentState!.reset();
      await tester.pump();
      expect(controller.text, 'start');
    });

    testWidgets('validates as the user types with AutovalidateMode.onUserInteraction', (tester) async {
      await tester.pumpWidget(
        host(InputFormField(initialValue: 'x', validator: notEmpty, autovalidateMode: AutovalidateMode.onUserInteraction)),
      );
      expect(find.text('Required'), findsNothing);
      await tester.enterText(find.byType(EditableText), '');
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);
    });
  });

  group('AppBar.automaticallyImplyLeading', () {
    Future<void> pushPage(WidgetTester tester, {required bool imply}) async {
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        PrimeApp(
          navigatorKey: navigator,
          home: const Scaffold(body: Text('home')),
        ),
      );
      navigator.currentState!.push(
        PrimePageRoute<void>(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('second'), automaticallyImplyLeading: imply),
            body: const SizedBox.expand(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows a back button on a poppable route by default', (tester) async {
      await pushPage(tester, imply: true);
      expect(find.byIcon(PrimeIcons.chevronLeft), findsOneWidget);
    });

    testWidgets('hides it when false', (tester) async {
      await pushPage(tester, imply: false);
      expect(find.text('second'), findsOneWidget);
      expect(find.byIcon(PrimeIcons.chevronLeft), findsNothing);
    });
  });
}
