import 'hitbox.dart';
import '../../extensions/vector2.dart';

mixin Collidable on Hitbox {
  bool hasScreenCollision = false;

  void collisionCallback(Set<Vector2> points, Collidable other) {}

  /// Override this and set [hasScreenCollision] to true if you want to know
  /// when your component hits one of the edges of the screen
  void screenCollisionCallback(Set<Vector2> points) {}
}
