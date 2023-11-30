import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';

class ComposabilityExample extends FlameGame {
  static const String description = '''
    In this example we showcase how you can add children to a component and how
    they transform together with their parent, if the parent is a
    `PositionComponent`. This example is not interactive.
  ''';

  late ParentSquare parentSquare;

  @override
  bool debugMode = true;

  @override
  Future<void> onLoad() async {
    parentSquare = ParentSquare(Vector2.all(200), Vector2.all(300))
      ..anchor = Anchor.center;
    add(parentSquare);
  }

  @override
  void update(double dt) {
    super.update(dt);
    parentSquare.angle += dt;
  }
}

class ParentSquare extends RectangleComponent with HasGameRef {
  static final defaultPaint = BasicPalette.white.paint()
    ..style = PaintingStyle.stroke;

  ParentSquare(Vector2 position, Vector2 size)
      : super(
          position: position,
          size: size,
          paint: defaultPaint,
        );

  @override
  Future<void> onLoad() async {
    createChildren();
  }

  void createChildren() {
    // All positions here are in relation to the parent's position
    const childSize = 50.0;
    final children = [
      RectangleComponent.square(
        position: Vector2(100, 100),
        size: childSize,
        angle: 2,
        paint: defaultPaint,
      ),
      RectangleComponent.square(
        position: Vector2(160, 100),
        size: childSize,
        angle: 3,
        paint: defaultPaint,
      ),
      RectangleComponent.square(
        position: Vector2(170, 150),
        size: childSize,
        angle: 4,
        paint: defaultPaint,
      ),
      RectangleComponent.square(
        position: Vector2(70, 200),
        size: childSize,
        angle: 5,
        paint: defaultPaint,
      ),
    ];

    addAll(children);
  }
}
