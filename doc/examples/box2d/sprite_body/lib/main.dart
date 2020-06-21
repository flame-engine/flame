import 'dart:math' as math;
import 'package:flame/box2d/body_component.dart';
import 'package:flame/box2d/box2d_game.dart';
import 'package:flame/box2d/contact_callbacks.dart';
import 'package:flame/box2d/sprite_body_component.dart';
import 'package:flame/flame.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:box2d_flame/box2d.dart';

import 'boundaries.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.util.fullScreen();
  runApp(MyGame().widget);
}

class Ship extends SpriteBodyComponent {
  Paint originalPaint, currentPaint;
  bool giveNudge = false;

  Ship(Vector2 position, Box2DGame box2d) : super(box2d) {
    originalPaint = _randomPaint();
    currentPaint = originalPaint;
    final worldPosition = viewport.getScreenToWorld(position);
    _createBody(5.0, worldPosition);
  }

  Paint _randomPaint() {
    final rng = math.Random();
    return PaletteEntry(
      Color.fromARGB(
        100 + rng.nextInt(155),
        100 + rng.nextInt(155),
        100 + rng.nextInt(155),
        255,
      ),
    ).paint;
  }

  void _createBody(double radius, Vector2 position) {
    final CircleShape shape = CircleShape();
    shape.radius = radius;

    final fixtureDef = FixtureDef()
      ..shape = shape
      ..restitution = 1.0
      ..density = 1.0
      ..friction = 0.1;

    final bodyDef = BodyDef()
      // To be able to determine object in collision
      ..setUserData(this)
      ..position = position
      ..type = BodyType.DYNAMIC;

    body = world.createBody(bodyDef)..createFixtureFromFixtureDef(fixtureDef);
  }

  @override
  bool destroy() {
    // Implement your logic for when the component should be removed
    return false;
  }

  @override
  void renderCircle(Canvas c, Offset p, double radius) {
    final blue = const PaletteEntry(Colors.blue).paint;
    c.drawCircle(p, radius, currentPaint);

    final angle = body.getAngle();
    final lineRotation =
        Offset(math.sin(angle) * radius, math.cos(angle) * radius);
    c.drawLine(p, p + lineRotation, blue);
  }

  @override
  void update(double t) {
    super.update(t);
    if (giveNudge) {
      body.applyLinearImpulse(Vector2(0, 10000), body.getLocalCenter(), true);
      giveNudge = false;
    }
  }
}

class WhiteBall extends Ship {
  WhiteBall(Vector2 position, Box2DGame game) : super(position, game) {
    originalPaint = BasicPalette.white.paint;
    currentPaint = originalPaint;
  }
}

class BallContactCallback extends ContactCallback<Ship, Ship> {
  @override
  void begin(Ship ball1, Ship ball2, Contact contact) {
    if (ball1 is WhiteBall || ball2 is WhiteBall) {
      return;
    }
    if (ball1.currentPaint != ball1.originalPaint) {
      ball1.currentPaint = ball2.currentPaint;
    } else {
      ball2.currentPaint = ball1.currentPaint;
    }
  }

  @override
  void end(Ship ball1, Ship ball2, Contact contact) {}
}

class WhiteBallContactCallback extends ContactCallback<Ship, WhiteBall> {
  @override
  void begin(Ship ball, WhiteBall whiteBall, Contact contact) {
    ball.giveNudge = true;
  }

  @override
  void end(Ship ball, WhiteBall whiteBall, Contact contact) {}
}

class BallWallContactCallback extends ContactCallback<Ship, Wall> {
  @override
  void begin(Ship ball, Wall wall, Contact contact) {
    wall.paint = ball.currentPaint;
  }

  @override
  void end(Ship ball1, Wall wall, Contact contact) {}
}

class MyGame extends Box2DGame with TapDetector {
  MyGame() : super(scale: 4.0, gravity: Vector2(0, -10.0)) {
    final boundaries = createBoundaries(this);
    boundaries.forEach(add);
    addContactCallback(BallContactCallback());
    addContactCallback(BallWallContactCallback());
    addContactCallback(WhiteBallContactCallback());
  }

  @override
  void onTapDown(TapDownDetails details) {
    super.onTapDown(details);
    final Vector2 position =
        Vector2(details.globalPosition.dx, details.globalPosition.dy);
    if (math.Random().nextInt(10) < 2) {
      add(WhiteBall(position, this));
    } else {
      add(Ship(position, this));
    }
  }
}
