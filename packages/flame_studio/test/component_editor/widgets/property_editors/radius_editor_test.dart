import 'package:flame_studio/component_editor/widgets/widgets.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(RadiusEditor, () {
    testWidgets('edits the radius', (tester) async {
      final changes = <ComponentRadius>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RadiusEditor(
              value: const ComponentRadius(radius: 10),
              onChanged: changes.add,
            ),
          ),
        ),
      );

      await tester.enterText(find.widgetWithText(TextField, 'Radius'), '30');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(changes, equals([const ComponentRadius(radius: 30)]));
    });
  });
}
