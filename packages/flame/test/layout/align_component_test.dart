import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/layout.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AlignComponent', () {
    testWithFlameGame('Valid parent', (game) async {
      expectLater(
        () async {
          final parent = Component();
          game.add(parent);
          parent.add(
            AlignComponent(
              child: PositionComponent(),
              alignment: Anchor.center,
            ),
          );
          await game.ready();
        },
        failsAssert("An AlignComponent's parent must have a size"),
      );
    });

    testGolden(
      'Align placement: golden',
      (game, tester) async {
        final stroke = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.0
          ..color = const Color(0xaaffff00);
        game.add(
          AlignComponent(
            alignment: Anchor.center,
            child: CircleComponent(radius: 20),
          ),
        );
        for (final alignment in [
          Anchor.topLeft,
          Anchor.topRight,
          Anchor.bottomLeft,
          Anchor.bottomRight,
        ]) {
          game.add(
            AlignComponent(
              child: CircleComponent(
                radius: 60,
                paint: stroke,
                anchor: Anchor.center,
              ),
              alignment: alignment,
              keepChildAnchor: true,
            ),
          );
        }
      },
      goldenFile: '../_goldens/align_component_1.png',
      size: Vector2(150, 100),
    );

    testWithFlameGame(
      "Child's alignment remains valid when game resizes",
      (game) async {
        final component = CircleComponent(radius: 20);
        game.add(
          AlignComponent(child: component, alignment: Anchor.center),
        );
        await game.ready();

        expect(component.anchor, Anchor.center);
        expect(component.position, Vector2(400, 300));
        expect(component.size, Vector2.all(40));

        game.onGameResize(Vector2(1000, 2000));
        expect(component.position, Vector2(500, 1000));
        expect(component.size, Vector2.all(40));
      },
    );

    testWithFlameGame(
      'Changing alignment value',
      (game) async {
        final component = CircleComponent(radius: 20);
        final alignComponent = AlignComponent(
          child: component,
          alignment: Anchor.center,
        );
        game.add(alignComponent);
        await game.ready();

        expect(component.anchor, Anchor.center);
        expect(component.position, Vector2(400, 300));

        alignComponent.alignment = Anchor.bottomLeft;
        expect(component.position, Vector2(0, 600));
        expect(component.anchor, Anchor.bottomLeft);
      },
    );
  });
}
