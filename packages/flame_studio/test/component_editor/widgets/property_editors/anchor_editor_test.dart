import 'package:flame_studio/component_editor/widgets/widgets.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(AnchorEditor, () {
    late List<ComponentAnchor> changes;

    setUp(() => changes = []);

    Future<void> pumpSubject(
      WidgetTester tester, {
      ComponentAnchor value = ComponentAnchor.topLeft,
    }) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnchorEditor(value: value, onChanged: changes.add),
        ),
      ),
    );

    testWidgets('has a button for every Flame anchor', (tester) async {
      await pumpSubject(tester);

      for (final name in ComponentAnchor.presets.keys) {
        expect(find.byTooltip(name), findsOneWidget);
      }
    });

    testWidgets('selects the button of the current anchor', (tester) async {
      await pumpSubject(tester, value: ComponentAnchor.bottomCenter);

      bool isSelected(String name) => tester
          .widget<IconButton>(
            find.ancestor(
              of: find.byTooltip(name),
              matching: find.byType(IconButton),
            ),
          )
          .isSelected!;

      expect(isSelected('bottomCenter'), isTrue);
      expect(isSelected('topLeft'), isFalse);
    });

    testWidgets('picks a Flame anchor', (tester) async {
      await pumpSubject(tester);

      await tester.tap(find.byTooltip('centerRight'));

      expect(changes, equals([ComponentAnchor.centerRight]));
    });

    testWidgets('edits a custom x', (tester) async {
      await pumpSubject(tester, value: ComponentAnchor.center);

      await tester.enterText(find.widgetWithText(TextField, 'X'), '0.25');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(changes, equals([const ComponentAnchor(x: 0.25, y: 0.5)]));
    });

    testWidgets('edits a custom y', (tester) async {
      await pumpSubject(tester, value: ComponentAnchor.center);

      await tester.enterText(find.widgetWithText(TextField, 'Y'), '-1');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(changes, equals([const ComponentAnchor(x: 0.5, y: -1)]));
    });
  });
}
