import 'package:flame_studio/component_editor/widgets/widgets.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(PositionEditor, () {
    late List<ComponentPosition> changes;

    setUp(() => changes = []);

    Future<void> pumpSubject(WidgetTester tester) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PositionEditor(
            value: const ComponentPosition(x: 10, y: 20),
            onChanged: changes.add,
          ),
        ),
      ),
    );

    testWidgets('edits x', (tester) async {
      await pumpSubject(tester);

      await tester.enterText(find.widgetWithText(TextField, 'X'), '-30');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(changes, equals([const ComponentPosition(x: -30, y: 20)]));
    });

    testWidgets('edits y', (tester) async {
      await pumpSubject(tester);

      await tester.enterText(find.widgetWithText(TextField, 'Y'), '40');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(changes, equals([const ComponentPosition(x: 10, y: 40)]));
    });
  });
}
