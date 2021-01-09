import '../position_component.dart';
import '../../extensions/vector2.dart';
import '../../game/base_game.dart';

mixin Collidable on PositionComponent {
  void setHullFromSize() {
    if (size == null || (size?.length ?? 0) == 0) {
      hull = [];
    } else {
      hull = [
        size / 2,
        (size / 2)..multiply(Vector2(1, -1)),
        (size / 2)..multiply(Vector2(-1, -1)),
        (size / 2)..multiply(Vector2(-1, 1)),
      ];
    }
  }

  /// Override this to define what will happen to your component when it
  /// collides with another component
  bool collisionCallback(
    PositionComponent otherComponent,
    List<Vector2> collisionPoints,
  );

  /// Override this to define what will happen to your component when it
  /// collides with a wall
  bool wallCollisionCallback(List<Vector2> collisionPoints);
}

mixin HasCollidableComponents on BaseGame {}
