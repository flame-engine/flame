import 'package:examples/commons/ember.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/math.dart';

class SpawnComponentExample extends FlameGame with TapDetector {
  static String description =
      'Tap on the screen to start spawning Embers within different shapes.';

  @override
  void onTapDown(TapDownInfo info) {
    final shapeType = Shapes.values.random();
    final Shape shape;
    final position = info.eventPosition.game;
    switch (shapeType) {
      case Shapes.rectangle:
        shape = Rectangle.fromCenter(
          center: info.eventPosition.game,
          size: Vector2.all(200),
        );
      case Shapes.circle:
        shape = Circle(info.eventPosition.game, 150);
      case Shapes.polygon:
        shape = Polygon(
          [
            Vector2(-1.0, 0.0),
            Vector2(-0.8, 0.6),
            Vector2(0.0, 1.0),
            Vector2(0.6, 0.9),
            Vector2(1.0, 0.0),
            Vector2(0.3, -0.2),
            Vector2(0.0, -1.0),
            Vector2(-0.8, -0.5),
          ].map((vertex) {
            return vertex
              ..scale(200)
              ..add(position);
          }).toList(),
        );
    }

    add(
      SpawnComponent(
        factory: (_) => Ember(),
        period: 0.5,
        area: shape,
        within: randomFallback.nextBool(),
      ),
    );
  }
}

enum Shapes {
  rectangle,
  circle,
  polygon,
}
