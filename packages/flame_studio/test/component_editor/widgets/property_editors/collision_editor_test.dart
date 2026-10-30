import 'package:flame_studio/component_editor/widgets/widgets.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(CollisionEditor, () {
    Future<List<ComponentCollision>> pump(WidgetTester tester) async {
      final changes = <ComponentCollision>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CollisionEditor(
              value: const ComponentCollision(),
              onChanged: changes.add,
            ),
          ),
        ),
      );
      return changes;
    }

    testWidgets('edits the collision type', (tester) async {
      final changes = await pump(tester);

      await tester.tap(find.text('Passive'));

      expect(
        changes,
        equals([const ComponentCollision(type: HitboxCollisionType.passive)]),
      );
    });

    testWidgets('edits whether the hitbox is solid', (tester) async {
      final changes = await pump(tester);

      await tester.tap(find.text('Solid'));

      expect(changes, equals([const ComponentCollision(isSolid: true)]));
    });
  });
}
