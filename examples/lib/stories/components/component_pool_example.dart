import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class ComponentPoolExample extends FlameGame {
  static const String description =
      'Tap on the screen to spawn a burst of pooled bullets. '
      'Watch the stats to see active vs pooled bullets and observe '
      'how the pool efficiently reuses objects.';

  static const gameWidth = 800.0;
  static const gameHeight = 600.0;

  ComponentPoolExample()
    : super(
        world: _BulletWorld(),
        camera: CameraComponent.withFixedResolution(
          width: gameWidth,
          height: gameHeight,
        ),
      ) {
    camera.moveTo(Vector2(gameWidth / 2, gameHeight / 2));
  }
}

class _BulletWorld extends World with TapCallbacks {
  late final ComponentPool<_PooledBullet> bulletPool;
  late final _StatsDisplay statsDisplay;
  final Random _random = Random();

  static const bulletsPerTap = 12;

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
    // and a maximum size to accommodate multiple bullet bursts
    bulletPool = ComponentPool<_PooledBullet>(
      factory: _PooledBullet.new,
      initialSize: 30,
      maxSize: 200,
    );

    // Add a stats display to show pool information
    statsDisplay = _StatsDisplay(pool: bulletPool);
    await add(statsDisplay);
  }

  @override
  void onTapDown(TapDownEvent event) {
    final tapPosition = event.localPosition;

    for (var i = 0; i < bulletsPerTap; i++) {
      final bullet = bulletPool.acquire();
      bullet.position.setFrom(tapPosition);

      // Create a spread pattern - bullets go out in all directions
      final angle = (i / bulletsPerTap) * 2 * pi;
      final speed = 150.0 + _random.nextDouble() * 100;
      bullet.velocity = Vector2(cos(angle) * speed, sin(angle) * speed);

      // Add slight random variation to velocity
      bullet.velocity.add(
        Vector2(
          (_random.nextDouble() - 0.5) * 30,
          (_random.nextDouble() - 0.5) * 30,
        ),
      );

      add(bullet);
    }
  }
}

/// A simple bullet component that can be pooled.
class _PooledBullet extends CircleComponent
    with Poolable, HasGameReference, ParentIsA<_BulletWorld> {
  Vector2 velocity = Vector2.zero();

  _PooledBullet()
    : super(
        radius: 4,
        paint: Paint()
          ..color = Colors.yellowAccent
          ..style = PaintingStyle.fill,
      );

  @override
  void reset() {
    // Reset all properties to their initial state
    position.setZero();
    velocity.setZero();
    angle = 0;
  }

  @override
  void update(double dt) {
    position.add(velocity * dt);

    // Check if bullet is outside the game bounds
    final isOutOfBounds =
        position.x < 0 ||
        position.x > ComponentPoolExample.gameWidth ||
        position.y < 0 ||
        position.y > ComponentPoolExample.gameHeight;

    if (isOutOfBounds) {
      parent.bulletPool.release(this);
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw a glow effect
    final glowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(Offset.zero, radius * 2, glowPaint);

    // Draw the main bullet
    super.render(canvas);
  }
}

/// Displays statistics about the bullet pool.
class _StatsDisplay extends TextComponent with ParentIsA<_BulletWorld> {
  final ComponentPool<_PooledBullet> pool;
  int _activeBullets = 0;

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

    // Count active bullets (in the world but not in the pool)
    _activeBullets = parent.children.whereType<_PooledBullet>().length;

    text =
        'Active Bullets: $_activeBullets\n'
        'In Pool (Ready): ${pool.availableCount}\n'
        '\nTap to spawn ${_BulletWorld.bulletsPerTap} bullets!';
  }
}
