import 'package:flame_studio/component_editor/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(NumberField, () {
    late List<double> changes;

    setUp(() => changes = []);

    Widget buildSubject(double value) => MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            NumberField(label: 'Width', value: value, onChanged: changes.add),
            const TextField(key: Key('other')),
          ],
        ),
      ),
    );

    testWidgets('shows whole numbers without decimals', (tester) async {
      await tester.pumpWidget(buildSubject(50));
      expect(find.text('50'), findsOneWidget);

      await tester.pumpWidget(buildSubject(12.5));
      expect(find.text('12.5'), findsOneWidget);
    });

    testWidgets('commits every valid edit while typing', (tester) async {
      await tester.pumpWidget(buildSubject(50));

      for (final input in ['1', '12', '12.', '12.5', '12.', '']) {
        await tester.enterText(find.byType(NumberField), input);
      }

      expect(changes, equals([1, 12, 12.5, 12]));
    });

    testWidgets('keeps the typed text when its value comes back', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(50));

      await tester.enterText(find.byType(NumberField), '1.50');
      await tester.pumpWidget(buildSubject(1.5));

      expect(find.text('1.50'), findsOneWidget);
    });

    testWidgets('shows values changed elsewhere', (tester) async {
      await tester.pumpWidget(buildSubject(50));

      await tester.pumpWidget(buildSubject(20));

      expect(find.text('20'), findsOneWidget);
    });

    testWidgets('reverts invalid input when losing focus', (tester) async {
      await tester.pumpWidget(buildSubject(50));

      await tester.enterText(find.byType(NumberField), '10');
      await tester.enterText(find.byType(NumberField), 'abc');
      await tester.tap(find.byKey(const Key('other')));
      await tester.pump();

      expect(find.text('10'), findsOneWidget);
      expect(changes, equals([10]));
    });

    testWidgets('reverts invalid input', (tester) async {
      await tester.pumpWidget(buildSubject(50));

      for (final input in ['abc', '-1']) {
        await tester.enterText(find.byType(NumberField), input);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        expect(find.text('50'), findsOneWidget);
      }
      expect(changes, isEmpty);
    });

    testWidgets('accepts negative numbers without a minimum', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberField(
              label: 'X',
              value: 0,
              min: null,
              onChanged: changes.add,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(NumberField), '-12.5');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(changes, equals([-12.5]));
    });

    testWidgets('does not commit an unchanged value', (tester) async {
      await tester.pumpWidget(buildSubject(50));

      await tester.enterText(find.byType(NumberField), '50.0');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(changes, isEmpty);
    });
  });
}
