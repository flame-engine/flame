import '../../components.dart';
import '../../extensions.dart';

mixin Collidable on Hitbox {
  bool hasScreenCollision = false;

  void collisionCallback(List<Vector2> points, Collidable other) {}

  /// Override this and set [hasScreenCollision] to true if you want to know
  /// when your component hits one of the edges of the screen
  void screenCollisionCallback(List<Vector2> points) {}
}
