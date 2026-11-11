import 'package:flame_devtools/widgets/incremental_number_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IncrementalNumberFormField', () {
    Future<void> pumpField(WidgetTester tester, {required double value}) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                IncrementalNumberFormField<double>(
                  label: 'X',
                  initialValue: value,
                ),
                const TextField(key: Key('other_field')),
              ],
            ),
          ),
        ),
      );
    }

    String fieldText(WidgetTester tester) {
      return tester
          .widget<TextField>(find.byType(TextField).first)
          .controller!
          .text;
    }

    testWidgets('shows a new value', (tester) async {
      await pumpField(tester, value: 1);
      await pumpField(tester, value: 2);

      expect(fieldText(tester), '2.0');
    });

    testWidgets('does not overwrite a value that is being edited', (
      tester,
    ) async {
      await pumpField(tester, value: 1);
      await tester.enterText(find.byType(TextField).first, '5');

      await pumpField(tester, value: 2);

      expect(fieldText(tester), '5');
    });

    testWidgets('shows the latest value when it loses focus', (tester) async {
      await pumpField(tester, value: 1);
      await tester.enterText(find.byType(TextField).first, '5');
      await pumpField(tester, value: 2);

      await tester.tap(find.byKey(const Key('other_field')));
      await tester.pump();

      expect(fieldText(tester), '2.0');
    });

    testWidgets(
      'keeps the edited value when it loses focus without a new value',
      (tester) async {
        await pumpField(tester, value: 1);
        await tester.enterText(find.byType(TextField).first, '5');

        await tester.tap(find.byKey(const Key('other_field')));
        await tester.pump();

        expect(fieldText(tester), '5');
      },
    );
  });
}
