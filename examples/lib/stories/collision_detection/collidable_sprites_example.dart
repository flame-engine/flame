import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/palette.dart';

class CollidableSpritesExample() extends FlameGame with HasCollisionDetection {
  static const description = '''
    In this example you can see four spinning sprites which are moving
    straight along the same route as the birds of the animation example, until
    they hit either another sprite or the wall, which makes them turn back.
    The hitboxes of the sprites follow their outlines, which are traced from
    the pixels of their images that are not transparent, and are marked with
    the white lines.
  ''';

  @override
  Future<void> onLoad() async {
    camera.viewport.add(FpsTextComponent(position: Vector2(8, 4)));

    add(ScreenHitbox());
    const componentWidth = 150.0;
    // Top left component
    add(
      CollidableSpriteComponent(
        'assets/images/flame.png',
        Vector2.all(200),
        componentWidth * 2 / 3,
        position: Vector2.all(100),
      ),
    );
    // Bottom right component
    add(
      CollidableSpriteComponent(
        'assets/images/layers/player.png',
        Vector2(-100, -100),
        componentWidth / 2,
        position: size.clone()..sub(Vector2.all(200)),
      ),
    );
    // Bottom left component
    add(
      CollidableSpriteComponent(
        'assets/images/zap.png',
        Vector2(100, -100),
        componentWidth,
        position: Vector2(100, size.y - 100),
        angle: pi / 4,
      ),
    );
    // Top right component
    add(
      CollidableSpriteComponent(
        'assets/images/layers/enemy.png',
        Vector2(-300, 300),
        componentWidth / 3,
        position: Vector2(size.x - 100, 100),
        angle: pi / 4,
      ),
    );
  }
}

/// A sprite of the image at [path] that is [spriteWidth] wide, with the
/// aspect ratio of the image, and that moves with the [velocity] while it
/// keeps turning around its center, a full circle every 3 seconds. Its hitbox
/// follows the outline of the sprite, and a collision turns it back.
class CollidableSpriteComponent(
  final String path,
  final Vector2 velocity,
  final double spriteWidth, {
  required Vector2 position,
  double angle = -pi / 4,
}) extends SpriteComponent with CollisionCallbacks, HasGameRef {
  this
    : super(
        position: position,
        angle: angle,
        anchor: Anchor.center,
      );

  @override
  Future<void> onLoad() async {
    final sprite = this.sprite = await gameRef.loadSprite(path);
    size = sprite.srcSize..scale(spriteWidth / sprite.srcSize.x);
    // The outline is relative to the top left corner of the sprite, while the
    // hitbox moves it to its own origin, so the hitbox is placed where the
    // outline starts.
    final outline = await sprite.contour(size: size);
    final hitboxPaint = BasicPalette.white.paint()
      ..style = PaintingStyle.stroke;
    add(
      PathHitbox(
          path: outline,
          position: outline.getBounds().topLeft.toVector2(),
        )
        ..paint = hitboxPaint
        ..renderShape = true,
    );
    add(RotateEffect.by(tau, EffectController(duration: 3, infinite: true)));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
  }

  @override
  void onCollisionStart(
    List<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    // Only a sprite that moves towards what it hit turns back, so that two
    // collisions that start at the same time do not cancel each other out,
    // and a sprite that is caught up by a faster one keeps going.
    if (velocity.dot(_towards(other, intersectionPoints)) > 0) {
      velocity.negate();
    }
  }

  /// The direction of the [other] component that this one hit at the
  /// [intersectionPoints]: that of the walls that the points are on, or of
  /// the center of the other sprite.
  Vector2 _towards(PositionComponent other, List<Vector2> intersectionPoints) {
    if (other is! ScreenHitbox) {
      return other.absoluteCenter - absoluteCenter;
    }
    final towards = Vector2.zero();
    for (final point in intersectionPoints) {
      if (point.x <= 1) {
        towards.x = -1;
      } else if (point.x >= other.size.x - 1) {
        towards.x = 1;
      }
      if (point.y <= 1) {
        towards.y = -1;
      } else if (point.y >= other.size.y - 1) {
        towards.y = 1;
      }
    }
    return towards;
  }
}
