import 'package:EmberQuest/main.dart';
import 'package:EmberQuest/objects/ground_block.dart';
import 'package:EmberQuest/objects/platform_block.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/services.dart';

class EmberPlayer extends SpriteAnimationComponent
    with KeyboardHandler, CollisionCallbacks, HasGameRef<EmberQuestGame> {
  EmberPlayer({
    required super.position,
  }) : super(size: Vector2.all(64), anchor: Anchor.center);

  final Vector2 _velocity = Vector2.zero();
  int _hAxisInput = 0;
  final Vector2 _up = Vector2(0, -1);
  bool _jumpInput = false;
  bool _isOnGround = false;
  final double _gravity = 15;
  final double _jumpSpeed = 600;
  double moveSpeed = 200;

  @override
  Future<void> onLoad() async {
    animation = SpriteAnimation.fromFrameData(
      await gameRef.images.load('ember.png'),
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2.all(16),
        stepTime: 0.12,
      ),
    );

    //debugMode = true; //Set to true to see the bounding boxes
    add(
      CircleHitbox()..collisionType = CollisionType.active,
    );
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    //if (isAlive) {
    _hAxisInput = 0;

    _hAxisInput += (keysPressed.contains(LogicalKeyboardKey.keyA) ||
            keysPressed.contains(LogicalKeyboardKey.arrowLeft))
        ? -1
        : 0;
    _hAxisInput += (keysPressed.contains(LogicalKeyboardKey.keyD) ||
            keysPressed.contains(LogicalKeyboardKey.arrowRight))
        ? 1
        : 0;

    _jumpInput = keysPressed.contains(LogicalKeyboardKey.space);

    // }

    return true;
  }

  @override
  void update(double dt) {
    _velocity.x = _hAxisInput * moveSpeed;
    if (position.x - 36 <= 0 && _hAxisInput < 0) {
      _velocity.x = 0;
    }
    if (position.x + 64 >= gameRef.size.x / 2 && _hAxisInput > 0) {
      _velocity.x = 0;
    }
    _velocity.y += _gravity;

    if (_jumpInput) {
      if (_isOnGround) {
        _velocity.y = -_jumpSpeed;
        _isOnGround = false;
      }
      _jumpInput = false;
    }

    _velocity.y = _velocity.y.clamp(-_jumpSpeed, 150);

    position += _velocity * dt;

    // Flip player if needed.
    if (_hAxisInput < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (_hAxisInput > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is GroundBlock || other is PlatformBlock) {
      if (intersectionPoints.length == 2) {
        // Calculate the collision normal and separation distance.
        final mid = (intersectionPoints.elementAt(0) +
                intersectionPoints.elementAt(1)) /
            2;

        final collisionNormal = absoluteCenter - mid;
        final separationDistance = (size.x / 2) - collisionNormal.length;
        collisionNormal.normalize();

        // If collision normal is almost upwards,
        // player must be on ground.
        if (_up.dot(collisionNormal) > 0.9) {
          _isOnGround = true;
        }

        // Resolve collision by moving player along
        // collision normal by separation distance.
        position += collisionNormal.scaled(separationDistance);
      }
    }

    if (other is ScreenHitbox) {
      removeFromParent();
    }
    super.onCollision(intersectionPoints, other);
  }

  // This method runs an opacity effect on player
  // to make it blink.
  void hit() {
    add(
      OpacityEffect.fadeOut(
        EffectController(
          alternate: true,
          duration: 0.1,
          repeatCount: 5,
        ),
      ),
    );
  }

  // Makes the player jump forcefully.
  void jump() {
    _jumpInput = true;
    _isOnGround = true;
  }
}
