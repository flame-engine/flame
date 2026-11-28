import 'dart:async';

import 'package:flame_devtools/material.dart';
import 'package:flame_devtools/widgets/incremental_number_form_field.dart';
import 'package:flutter/gestures.dart';
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

  group('IncrementalNumberFormField scrubbing', () {
    Future<void> pumpField(
      WidgetTester tester, {
      required double value,
      double? scrubStep,
      FutureOr<void> Function(double)? onChanged,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IncrementalNumberFormField<double>(
              label: 'X',
              initialValue: value,
              scrubStep: scrubStep,
              onChanged: onChanged,
            ),
          ),
        ),
      );
    }

    String fieldText(WidgetTester tester) {
      return tester.widget<TextField>(find.byType(TextField)).controller!.text;
    }

    Future<TestGesture> startScrub(WidgetTester tester) async {
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('X')),
        kind: PointerDeviceKind.mouse,
      );
      // Moves past the drag slop, so that the next moves are scrubs.
      await gesture.moveBy(const Offset(20, 0));
      await tester.pump();
      return gesture;
    }

    testWidgets('changes the value by the step per logical pixel', (
      tester,
    ) async {
      final sent = <double>[];
      await pumpField(tester, value: 10, scrubStep: 1, onChanged: sent.add);

      final gesture = await startScrub(tester);
      final before = double.parse(fieldText(tester));
      await gesture.moveBy(const Offset(15, 0));
      await tester.pump();
      expect(double.parse(fieldText(tester)), before + 15);

      await gesture.moveBy(const Offset(-25, 0));
      await tester.pump();
      expect(double.parse(fieldText(tester)), before - 10);
      await gesture.up();

      expect(sent.last, before - 10);
    });

    testWidgets('rounds the value to the precision of the step', (
      tester,
    ) async {
      await pumpField(tester, value: 0.1, scrubStep: 0.01);

      final gesture = await startScrub(tester);
      final before = double.parse(fieldText(tester));
      await gesture.moveBy(const Offset(20, 0));
      await tester.pump();
      await gesture.up();

      final text = fieldText(tester);
      expect(double.parse(text), closeTo(before + 0.2, 1e-9));
      // No floating point noise like 0.30000000000000004.
      expect(text.split('.').last.length, lessThanOrEqualTo(2));
    });

    testWidgets('can be dragged from anywhere above the text field', (
      tester,
    ) async {
      await pumpField(tester, value: 10, scrubStep: 1);

      // The label text "X" is only a few pixels wide, so this starts well to
      // the right of it, near the right edge of the text field.
      final field = tester.getRect(find.byType(TextField));
      final label = tester.getRect(find.text('X'));
      final gesture = await tester.startGesture(
        Offset(field.right - 5, label.center.dy),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.moveBy(const Offset(20, 0));
      await tester.pump();
      final before = double.parse(fieldText(tester));
      await gesture.moveBy(const Offset(10, 0));
      await tester.pump();
      await gesture.up();

      expect(double.parse(fieldText(tester)), before + 10);
      expect(before, greaterThan(10));
    });

    testWidgets('does nothing without a step', (tester) async {
      final sent = <double>[];
      await pumpField(tester, value: 10, onChanged: sent.add);

      final gesture = await startScrub(tester);
      await gesture.moveBy(const Offset(30, 0));
      await tester.pump();
      await gesture.up();

      expect(fieldText(tester), '10.0');
      expect(sent, isEmpty);
    });

    testWidgets('sends one value at a time, and then only the latest', (
      tester,
    ) async {
      final sent = <double>[];
      var completer = Completer<void>();
      await pumpField(
        tester,
        value: 10,
        scrubStep: 1,
        onChanged: (value) {
          sent.add(value);
          return completer.future;
        },
      );

      final gesture = await startScrub(tester);
      for (var i = 0; i < 5; i++) {
        await gesture.moveBy(const Offset(4, 0));
        await tester.pump();
      }
      expect(sent, hasLength(1));
      final latest = double.parse(fieldText(tester));

      final first = completer;
      completer = Completer<void>();
      first.complete();
      await tester.pump();
      expect(sent, hasLength(2));
      expect(sent.last, latest);

      completer.complete();
      await tester.pump();
      expect(sent, hasLength(2));
      await gesture.up();
    });

    testWidgets(
      'does not show a new value from the game until the drag ends',
      (tester) async {
        await pumpField(tester, value: 10, scrubStep: 1);

        final gesture = await startScrub(tester);
        await gesture.moveBy(const Offset(10, 0));
        await tester.pump();
        final scrubbed = fieldText(tester);

        await pumpField(tester, value: 50, scrubStep: 1);
        expect(fieldText(tester), scrubbed);

        await gesture.up();
        await tester.pump();
        expect(fieldText(tester), '50.0');
      },
    );
  });
}
