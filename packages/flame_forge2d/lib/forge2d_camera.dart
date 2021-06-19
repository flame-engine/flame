import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:forge2d/forge2d.dart' hide Timer;

class Forge2DCamera extends Camera {
  @override
  Vector2 unprojectVector(Vector2 screenCoordinates) {
    return position
      ..add(screenCoordinates / zoom)
      ..y *= -1;
  }

  @override
  Vector2 projectVector(Vector2 worldCoordinates) {
    return ((worldCoordinates..y *= -1) - position)..scale(zoom);
  }

  @override
  Vector2 unscaleVector(Vector2 screenCoordinates) {
    return screenCoordinates / zoom;
  }

  @override
  Vector2 scaleVector(Vector2 worldCoordinates) {
    return worldCoordinates * zoom;
  }
}
