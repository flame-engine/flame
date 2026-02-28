import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class ComponentPoolExample extends FlameGame {
  static const String description =
      'Tap on the screen to spawn a burst of pooled balls. '
      'Watch the stats to see active vs pooled balls and observe '
      'how the pool efficiently reuses objects.';

  static const gameWidth = 800.0;
  static const gameHeight = 600.0;

  ComponentPoolExample()
    : super(
        world: _BallWorld(),
        camera: CameraComponent.withFixedResolution(
          width: gameWidth,
          height: gameHeight,
        ),
      ) {
    camera.moveTo(Vector2(gameWidth / 2, gameHeight / 2));
  }
}

class _BallWorld extends World with TapCallbacks {
  late final ComponentPool<_PooledBall> ballPool;
  late final _StatsDisplay statsDisplay;
  final Random _random = Random();

  static const ballsPerTap = 12;

  @override
  Future<void> onLoad() async {
    // Add a background
    add(
      RectangleComponent(
        size: Vector2(
          ComponentPoolExample.gameWidth,
          ComponentPoolExample.gameHeight,
        ),
        paint: Paint()..color = Colors.green,
      ),
    );

    // Create a pool with a larger initial size to handle bursts
    // and a maximum size to accommodate multiple ball bursts
    ballPool = ComponentPool<_PooledBall>(
      factory: _PooledBall.new,
      initialSize: 30,
      maxSize: 200,
    );

    // Add a stats display to show pool information
    statsDisplay = _StatsDisplay(pool: ballPool);
    await add(statsDisplay);
  }

  @override
  void onTapDown(TapDownEvent event) {
    final tapPosition = event.localPosition;

    for (var i = 0; i < ballsPerTap; i++) {
      final ball = ballPool.acquire();
      ball.position.setFrom(tapPosition);

      // Create a spread pattern - balls go out in all directions
      final angle = (i / ballsPerTap) * 2 * pi;
      final speed = 150.0 + _random.nextDouble() * 100;
      ball.velocity = Vector2(cos(angle) * speed, sin(angle) * speed);

      // Add slight random variation to velocity
      ball.velocity.add(
        Vector2(
          (_random.nextDouble() - 0.5) * 30,
          (_random.nextDouble() - 0.5) * 30,
        ),
      );

      add(ball);
    }
  }
}

/// A ball component that can be pooled.
///
/// Uses two child [CircleComponent]s for visuals: a shadow (rendered first via
/// lower priority) and the ball itself on top. A bouncing scale effect
/// simulates the ball bouncing up and down as it travels outward.
class _PooledBall extends PositionComponent
    with HasGameReference, ParentIsA<_BallWorld> {
  static const _radius = 4.0;
  static const _bounceSpeed = 8.0;
  static const _maxShadowOffset = 16.0;

  Vector2 velocity = Vector2.zero();
  double _bouncePhase = 0;

  late final CircleComponent _shadow;
  late final CircleComponent _ball;

  _PooledBall() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    _shadow = CircleComponent(
      radius: _radius,
      anchor: Anchor.center,
      position: Vector2(0, _maxShadowOffset),
      priority: 0,
      paint: Paint()..color = Colors.black.withValues(alpha: 0.6),
    );

    _ball = CircleComponent(
      radius: _radius,
      anchor: Anchor.center,
      priority: 1,
      paint: Paint()
        ..color = Colors.yellowAccent
        ..style = PaintingStyle.fill,
    );

    addAll([_shadow, _ball]);
  }

  @override
  void onMount() {
    super.onMount();
    // Only reset internal visual state — velocity and position are set by the
    // caller between acquire() and add(), so we must not touch them here.
    _bouncePhase = 0;
    _ball.scale = Vector2.all(1);
  }

  @override
  void update(double dt) {
    position.add(velocity * dt);
    _bouncePhase += dt * _bounceSpeed;

    // t ranges from 0 (ground) to 1 (peak of bounce)
    final t = (1 + sin(_bouncePhase)) / 2;

    // Ball grows as it "rises" toward the camera
    _ball.scale = Vector2.all(1.0 + 0.5 * t);

    // Shadow drifts down and shrinks as ball rises away from ground
    _shadow.position.y = _maxShadowOffset * t;
    _shadow.scale = Vector2.all(1.0 - 0.2 * t);

    // Check if ball is outside the game bounds
    final isOutOfBounds =
        position.x < 0 ||
        position.x > ComponentPoolExample.gameWidth ||
        position.y < 0 ||
        position.y > ComponentPoolExample.gameHeight;

    if (isOutOfBounds) {
      removeFromParent();
    }
  }
}

/// Displays statistics about the ball pool.
class _StatsDisplay extends TextComponent with ParentIsA<_BallWorld> {
  final ComponentPool<_PooledBall> pool;
  int _activeBalls = 0;

  _StatsDisplay({required this.pool})
    : super(
        position: Vector2(10, 10),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      );

  @override
  void update(double dt) {
    super.update(dt);

    // Count active balls (in the world but not in the pool)
    _activeBalls = parent.children.whereType<_PooledBall>().length;

    text =
        'Active Balls: $_activeBalls\n'
        'In Pool (Ready): ${pool.availableCount}\n'
        '\nTap to spawn ${_BallWorld.ballsPerTap} balls!';
  }
}
