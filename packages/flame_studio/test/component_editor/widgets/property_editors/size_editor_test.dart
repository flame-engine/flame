import 'package:flame_studio/component_editor/widgets/widgets.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(SizeEditor, () {
    late List<ComponentSize> changes;

    setUp(() => changes = []);

    Future<void> pumpSubject(WidgetTester tester) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizeEditor(
            value: const ComponentSize(width: 10, height: 20),
            onChanged: changes.add,
          ),
        ),
      ),
    );

    testWidgets('edits the width', (tester) async {
      await pumpSubject(tester);

      await tester.enterText(find.widgetWithText(TextField, 'Width'), '30');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(changes, equals([const ComponentSize(width: 30, height: 20)]));
    });

    testWidgets('edits the height', (tester) async {
      await pumpSubject(tester);

      await tester.enterText(find.widgetWithText(TextField, 'Height'), '40');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(changes, equals([const ComponentSize(width: 10, height: 40)]));
    });
  });
}
