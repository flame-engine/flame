import 'package:flame/game.dart';

class Forge2DCamera extends Camera {
  @override
  Vector2 unprojectVector(Vector2 screenCoordinates) {
    return position
      ..add(screenCoordinates / zoom)
      ..y *= -1;
  }

  @override
  Vector2 projectVector(Vector2 worldCoordinates) {
    return ((worldCoordinates.clone()..y *= -1) - position)..scale(zoom);
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
