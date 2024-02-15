import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';

class CameraFollowAndWorldBoundsExample extends FlameGame
    with HasKeyboardHandlerComponents {
  static const description = '''
    This example demonstrates camera following the player, but also obeying the
    world bounds (which are set up to leave a small margin around the visible
    part of the ground).
    
    Use arrows or keys W,A,D to move the player around. The camera should follow
    the player horizontally, but not jump with the player.
  ''';

  @override
  Future<void> onLoad() async {
    final player = Player()..position = Vector2(250, 0);
    camera
      ..viewfinder.visibleGameSize = Vector2(400, 100)
      ..follow(player, horizontalOnly: true)
      ..setBounds(Rectangle.fromLTRB(190, -50, 810, 50));
    world.add(Ground());
    world.add(player);
  }
}

class Ground extends PositionComponent {
  Ground()
      : pebbles = [],
        super(size: Vector2(1000, 30)) {
    final random = Random();
    for (var i = 0; i < 25; i++) {
      pebbles.add(
        Vector3(
          random.nextDouble() * size.x,
          random.nextDouble() * size.y / 3,
          random.nextDouble() * 0.5 + 1,
        ),
      );
    }
  }

  final Paint groundPaint = Paint()
    ..shader = Gradient.linear(
      Offset.zero,
      const Offset(0, 30),
      [const Color(0xFFC9C972), const Color(0x22FFFF88)],
    );
  final Paint pebblePaint = Paint()..color = const Color(0xFF685A2B);

  final List<Vector3> pebbles;

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), groundPaint);
    for (final pebble in pebbles) {
      canvas.drawCircle(Offset(pebble.x, pebble.y), pebble.z, pebblePaint);
    }
  }
}

class Player extends PositionComponent with KeyboardHandler {
  Player()
      : body = Path()
          ..moveTo(10, 0)
          ..cubicTo(17, 0, 28, 20, 10, 20)
          ..cubicTo(-8, 20, 3, 0, 10, 0)
          ..close(),
        eyes = Path()
          ..addOval(const Rect.fromLTWH(12.5, 9, 4, 6))
          ..addOval(const Rect.fromLTWH(6.5, 9, 4, 6)),
        pupils = Path()
          ..addOval(const Rect.fromLTWH(14, 11, 2, 2))
          ..addOval(const Rect.fromLTWH(8, 11, 2, 2)),
        velocity = Vector2.zero(),
        super(size: Vector2(20, 20), anchor: Anchor.bottomCenter);

  final Path body;
  final Path eyes;
  final Path pupils;
  final Paint borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..color = const Color(0xffffc67c);
  final Paint innerPaint = Paint()..color = const Color(0xff9c0051);
  final Paint eyesPaint = Paint()..color = const Color(0xFFFFFFFF);
  final Paint pupilsPaint = Paint()..color = const Color(0xFF000000);
  final Paint shadowPaint = Paint()
    ..shader = Gradient.radial(
      Offset.zero,
      10,
      [const Color(0x88000000), const Color(0x00000000)],
    );

  final Vector2 velocity;
  final double runSpeed = 150.0;
  final double jumpSpeed = 300.0;
  final double gravity = 1000.0;
  bool facingRight = true;
  int nJumpsLeft = 2;

  @override
  void update(double dt) {
    position.x += velocity.x * dt;
    position.y += velocity.y * dt;
    if (position.y > 0) {
      position.y = 0;
      velocity.y = 0;
      nJumpsLeft = 2;
    }
    if (position.y < 0) {
      velocity.y += gravity * dt;
    }
    if (position.x < 0) {
      position.x = 0;
    }
    if (position.x > 1000) {
      position.x = 1000;
    }
  }

  @override
  void render(Canvas canvas) {
    {
      final h = -position.y; // height above the ground
      canvas.save();
      canvas.translate(width / 2, height + 1 + h * 1.05);
      canvas.scale(1 - h * 0.003, 0.3 - h * 0.001);
      canvas.drawCircle(Offset.zero, 10, shadowPaint);
      canvas.restore();
    }
    canvas.drawPath(body, innerPaint);
    canvas.drawPath(body, borderPaint);
    canvas.drawPath(eyes, eyesPaint);
    canvas.drawPath(pupils, pupilsPaint);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isKeyDown = event is KeyDownEvent;
    final keyLeft = (event.logicalKey == LogicalKeyboardKey.arrowLeft) ||
        (event.logicalKey == LogicalKeyboardKey.keyA);
    final keyRight = (event.logicalKey == LogicalKeyboardKey.arrowRight) ||
        (event.logicalKey == LogicalKeyboardKey.keyD);
    final keyUp = (event.logicalKey == LogicalKeyboardKey.arrowUp) ||
        (event.logicalKey == LogicalKeyboardKey.keyW);

    if (isKeyDown) {
      if (keyLeft) {
        velocity.x = -runSpeed;
      } else if (keyRight) {
        velocity.x = runSpeed;
      } else if (keyUp && nJumpsLeft > 0) {
        velocity.y = -jumpSpeed;
        nJumpsLeft -= 1;
      }
    } else {
      final hasLeft = keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
          keysPressed.contains(LogicalKeyboardKey.keyA);
      final hasRight = keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
          keysPressed.contains(LogicalKeyboardKey.keyD);
      if (hasLeft && hasRight) {
        // Leave the current speed unchanged
      } else if (hasLeft) {
        velocity.x = -runSpeed;
      } else if (hasRight) {
        velocity.x = runSpeed;
      } else {
        velocity.x = 0;
      }
    }
    if ((velocity.x > 0) && !facingRight) {
      facingRight = true;
      flipHorizontally();
    }
    if ((velocity.x < 0) && facingRight) {
      facingRight = false;
      flipHorizontally();
    }
    return super.onKeyEvent(event, keysPressed);
  }
}
