import 'package:flame_studio/component_editor/widgets/widgets.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(AngleEditor, () {
    late List<ComponentAngle> changes;

    setUp(() => changes = []);

    Future<void> pumpSubject(
      WidgetTester tester, {
      ComponentAngle value = ComponentAngle.zero,
    }) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AngleEditor(value: value, onChanged: changes.add),
        ),
      ),
    );

    testWidgets('shows the angle in degrees', (tester) async {
      await pumpSubject(tester, value: ComponentAngle.fromDegrees(45));

      expect(find.widgetWithText(TextField, '45'), findsOneWidget);
    });

    testWidgets('edits the angle in degrees', (tester) async {
      await pumpSubject(tester);

      await tester.enterText(find.widgetWithText(TextField, 'Degrees'), '-90');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(changes, equals([ComponentAngle.fromDegrees(-90)]));
    });

    testWidgets('keeps the typed degrees when the edited angle comes back', (
      tester,
    ) async {
      await pumpSubject(tester);

      await tester.enterText(find.widgetWithText(TextField, 'Degrees'), '45');
      await pumpSubject(tester, value: changes.single);

      expect(find.widgetWithText(TextField, '45'), findsOneWidget);
    });
  });
}
