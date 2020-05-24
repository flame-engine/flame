import 'dart:math' as math;
import 'package:flame/box2d/box2d_component.dart';
import 'package:flame/box2d/box2d_game.dart';
import 'package:flame/flame.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:box2d_flame/box2d.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.util.fullScreen();
  final MyBox2D box = MyBox2D();
  final MyGame game = MyGame(box);
  runApp(game.widget);
}

class MyPlanet extends BodyComponent {
  static final red = const PaletteEntry(Colors.red).paint;
  static final black = const PaletteEntry(Colors.black).paint;
  static final blue = const PaletteEntry(Colors.blue).paint;

  double totalTime = 0;
  // Creates a BodyComponent that renders a red circle (with a black moving
  // pulsating circle on the inside) that can interact with other body
  // components that are added to the same Box2DGame/Box2DComponent.
  // After 20 seconds the circle will be removed, to show that we don't get
  // any concurrent modification exceptions.
  MyPlanet(Box2DComponent box) : super(box) {
    _createBody(50.0, Vector2.zero());
  }

  void _createBody(double radius, Vector2 position) {
    final CircleShape shape = CircleShape();
    shape.radius = radius;

    final fixtureDef = FixtureDef();
    // To be able to determine object in collision
    fixtureDef.setUserData(this);
    fixtureDef.shape = shape;
    fixtureDef.restitution = 0.0;
    fixtureDef.density = 1.0;
    fixtureDef.friction = 0.1;

    final bodyDef = BodyDef();
    bodyDef.position = position;
    bodyDef.angularVelocity = 4.0;
    bodyDef.type = BodyType.DYNAMIC;

    body = world.createBody(bodyDef)..createFixtureFromFixtureDef(fixtureDef);
  }

  @override
  bool destroy() {
    // Implement your logic for when the component should be removed
    return totalTime > 20;
  }

  @override
  void renderCircle(Canvas c, Offset p, double radius) {
    c.drawCircle(p, radius, red);

    final angle = body.getAngle();
    c.drawCircle(p, math.sin(angle) * radius, black);

    final lineRotation =
        Offset(math.sin(angle) * radius, math.cos(angle) * radius);
    c.drawLine(p, p + lineRotation, blue);
  }

  @override
  void update(double t) {
    super.update(t);
    totalTime += t;
  }
}

class MyGame extends Box2DGame {
  MyGame(Box2DComponent box) : super(box) {
    add(MyPlanet(box));
  }
}

class MyBox2D extends Box2DComponent {
  MyBox2D() : super(scale: 4.0, gravity: 0.0);

  @override
  void initializeWorld() {}
}
