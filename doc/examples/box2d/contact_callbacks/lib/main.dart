import 'dart:math' as math;
import 'package:box2d_contact_callbacks/boundaries.dart';
import 'package:flame/box2d/box2d_component.dart';
import 'package:flame/box2d/box2d_game.dart';
import 'package:flame/box2d/contact_listeners.dart';
import 'package:flame/flame.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:box2d_flame/box2d.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.util.fullScreen();
  runApp(GameController().widget);
}

class Ball extends BodyComponent {
  Paint originalPaint, currentPaint;

  Ball(Vector2 position, Box2DComponent box) : super(box) {
    originalPaint = _randomPaint();
    currentPaint = originalPaint;
    Vector2 worldPosition = viewport.getScreenToWorld(position);
    _createBody(5.0, worldPosition);
  }

  Paint _randomPaint() {
    math.Random rng = math.Random();
    return PaletteEntry(Color.fromARGB(rng.nextInt(255), rng.nextInt(255),
        rng.nextInt(255), rng.nextInt(255))).paint;
  }

  void _createBody(double radius, Vector2 position) {
    final CircleShape shape = CircleShape();
    shape.radius = radius;

    final fixtureDef = FixtureDef();
    // To be able to determine object in collision
    fixtureDef.setUserData(this);
    fixtureDef.shape = shape;
    fixtureDef.restitution = 1.0;
    fixtureDef.density = 1.0;
    fixtureDef.friction = 0.1;

    final bodyDef = BodyDef();
    bodyDef.position = position;
    bodyDef.type = BodyType.DYNAMIC;

    body = world.createBody(bodyDef)..createFixtureFromFixtureDef(fixtureDef);
  }

  @override
  bool destroy() {
    // Implement your logic for when the component should be removed
    return false;
  }

  @override
  void renderCircle(Canvas c, Offset p, double radius) {
    Paint blue = PaletteEntry(Colors.blue).paint;
    c.drawCircle(p, radius, currentPaint);
    double angle = body.getAngle();
    Offset lineRotation =
        Offset(math.sin(angle) * radius, math.cos(angle) * radius);
    c.drawLine(p, p + lineRotation, blue);
  }
}

class BallContactCallback implements ContactCallback {
  @override
  List<Type> objects = [Ball, Ball];

  BallContactCallback();

  @override
  void begin(Object contact1, Object contact2) {
    Ball ball1 = contact1 as Ball;
    Ball ball2 = contact2 as Ball;
    if (ball1.currentPaint != ball1.originalPaint) {
      ball1.currentPaint = ball2.currentPaint;
    } else {
      ball2.currentPaint = ball1.currentPaint;
    }
  }

  @override
  void end(Object ship, Object material) {}
}

class MyGame extends Box2DGame {
  MyGame(Box2DComponent box) : super(box) {
    final List<BodyComponent> boundaries = createBoundaries(box);
    boundaries.forEach(add);
    addContactCallback(BallContactCallback());
  }

  @override
  void onTapDown(TapDownDetails details) {
    super.onTapDown(details);
    final Vector2 position =
        Vector2(details.globalPosition.dx, details.globalPosition.dy);
    add(Ball(position, box));
  }
}

class MyBox2D extends Box2DComponent {
  MyBox2D() : super(scale: 4.0, gravity: -10.0);

  @override
  void initializeWorld() {}
}

class GameController {
  MyGame _game;

  GameController() {
    final MyBox2D box = MyBox2D();
    _game = MyGame(box);
  }

  Widget get widget => _game.widget;
}
