import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/palette.dart';

class CollidableAnimationExample extends FlameGame with HasCollidables {
  static const description = '''
    In this example you can see four animated birds which are flying straight
    along the same route until they hit either another bird or the wall, which
    makes them turn. The birds have PolygonHitboxes which are marked with the
    green lines and dots.
  ''';

  @override
  Future<void> onLoad() async {
    add(ScreenCollidable());
    // Top left component
    add(
      AnimatedComponent(Vector2.all(200), Vector2.all(100))..flipVertically(),
    );
    // Bottom right component
    add(
      AnimatedComponent(
        Vector2(-100, -100),
        size.clone()..sub(Vector2.all(200)),
      ),
    );
    // Bottom left component
    add(
      AnimatedComponent(
        Vector2(100, -100),
        Vector2(100, size.y - 100),
        angle: pi / 4,
      ),
    );
    // Top right component
    add(
      AnimatedComponent(
        Vector2(-300, 300),
        Vector2(size.x - 100, 100),
        angle: pi / 4,
      )..flipVertically(),
    );
  }
}

class AnimatedComponent extends SpriteAnimationComponent
    with HasHitboxes, Collidable, HasGameRef {
  final Vector2 velocity;

  AnimatedComponent(this.velocity, Vector2 position, {double angle = -pi / 4})
      : super(
          position: position,
          size: Vector2(150, 100),
          angle: angle,
          anchor: Anchor.center,
        );

  late HitboxPolygon hitbox;

  @override
  Future<void> onLoad() async {
    animation = await gameRef.loadSpriteAnimation(
      'bomb_ptero.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(48),
      ),
    );
    hitbox = HitboxPolygon([
      Vector2(0.0, -1.0),
      Vector2(-1.0, -0.1),
      Vector2(-0.2, 0.4),
      Vector2(0.2, 0.4),
      Vector2(1.0, -0.1),
    ]);
    add(hitbox);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
  }

  final Paint hitboxPaint = BasicPalette.green.paint()
    ..style = PaintingStyle.stroke;
  final Paint dotPaint = BasicPalette.red.paint()..style = PaintingStyle.stroke;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // This is just to clearly see the vertices in the hitboxes
    hitbox.render(canvas, hitboxPaint);
    hitbox
        .localVertices()
        .forEach((p) => canvas.drawCircle(p.toOffset(), 4, dotPaint));
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, Collidable other) {
    super.onCollisionStart(intersectionPoints, other);
    velocity.negate();
    flipVertically();
  }
}
