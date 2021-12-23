import '../../components.dart';
import '../../geometry.dart';

// TODO(spydon): implement CollisionItem?
mixin HitboxShape on Shape {
  late PositionComponent component;

  @override
  bool isCanvasPrepared = true;

  @override
  Vector2 get size => component.size;

  @override
  Vector2 get scale => component.scale;

  @override
  double get parentAngle => component.absoluteAngle;

  @override
  Vector2 get position => component.absoluteCenter;

  /// Assign your own [CollisionCallback] if you want a callback when this
  /// shape collides with another [HitboxShape]
  CollisionCallback onCollision = emptyCollisionCallback;

  /// Assign your own [CollisionCallback] if you want a callback when this
  /// shape starts to collide with another [HitboxShape].
  CollisionCallback onCollisionStart = emptyCollisionCallback;

  /// Assign your own [CollisionEndCallback] if you want a callback when this
  /// shape stops colliding with another [HitboxShape]
  CollisionEndCallback onCollisionEnd = emptyCollisionEndCallback;
}

typedef CollisionCallback = void Function(
  Set<Vector2> intersectionPoints,
  HitboxShape other,
);

typedef CollisionEndCallback = void Function(HitboxShape other);

void emptyCollisionCallback(Set<Vector2> _, HitboxShape __) {}
void emptyCollisionEndCallback(HitboxShape _) {}
