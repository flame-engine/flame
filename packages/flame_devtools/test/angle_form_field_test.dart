import 'dart:math';

import 'package:flame_devtools/widgets/angle_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AngleFormField', () {
    Future<void> pumpField(
      WidgetTester tester, {
      required double radians,
      ValueChanged<double>? onChanged,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AngleFormField(
              radians: radians,
              onChanged: onChanged ?? (_) {},
            ),
          ),
        ),
      );
    }

    String fieldText(WidgetTester tester) {
      return tester.widget<TextField>(find.byType(TextField)).controller!.text;
    }

    testWidgets('shows the angle in degrees', (tester) async {
      await pumpField(tester, radians: pi / 2);

      expect(find.text('Degrees'), findsOneWidget);
      expect(fieldText(tester), '90.0');
    });

    testWidgets('reports a typed angle in radians', (tester) async {
      double? reported;
      await pumpField(tester, radians: 0, onChanged: (v) => reported = v);

      await tester.enterText(find.byType(TextField), '180');

      expect(reported, closeTo(pi, 1e-12));
    });

    testWidgets('steps the angle by one degree', (tester) async {
      double? reported;
      await pumpField(tester, radians: 0, onChanged: (v) => reported = v);

      await tester.tap(find.byIcon(Icons.add));

      expect(fieldText(tester), '1.0');
      expect(reported, closeTo(pi / 180, 1e-12));
    });

    testWidgets(
      'shows a typed angle without drift when read back from the game',
      (tester) async {
        double? reported;
        await pumpField(tester, radians: 0, onChanged: (v) => reported = v);

        await tester.enterText(find.byType(TextField), '30');
        // The game stores the angle in radians and the form reads it back.
        await pumpField(tester, radians: reported!);

        expect(fieldText(tester), '30.0');
      },
    );
  });

  group('radiansToDisplayDegrees', () {
    test('round-trips whole degrees without drift', () {
      for (var degrees = -720; degrees <= 720; degrees++) {
        final radians = degreesToRadians(degrees.toDouble());
        expect(
          radiansToDisplayDegrees(radians),
          degrees.toDouble(),
          reason: '$degrees',
        );
      }
    });
  });
}
