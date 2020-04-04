import 'dart:math' as math;
import 'package:flame/box2d/box2d_component.dart';
import 'package:flame/box2d/box2d_game.dart';
import 'package:flame/flame.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:box2d_flame/box2d.dart';

void main() async {
  await Flame.util.fullScreen();
  runApp(GameController().widget);
}

class MyPlanet extends BodyComponent {
  double totalTime = 0;
  // Creates a BodyComponent that renders a red circle (with a black moving
  // pulsating circle on the inside) that can interact with other body
  // components that are added to the same Box2DGame/Box2DComponent.
  // After 20 seconds the circle will be removed, to show that we don't get
  // any concurrent modification exceptions.
  MyPlanet(Box2DComponent box) : super(box) {
    Vector2 leftCorner = viewport.getScreenToWorld(Vector2.zero());
    _createBody(50.0, leftCorner);
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

    this.body = world.createBody(bodyDef)
      ..createFixtureFromFixtureDef(fixtureDef);
  }

  @override
  bool destroy() {
    // Implement your logic for when the component should be removed
    return totalTime > 20;
  }

  @override
  void renderCircle(Canvas c, Offset p, double radius) {
    Paint red = PaletteEntry(Colors.red).paint;
    Paint black = PaletteEntry(Colors.black).paint;
    Paint blue = PaletteEntry(Colors.blue).paint;
    c.drawCircle(p, radius, red);
    double angle = body.getAngle();
    c.drawCircle(p, math.sin(angle) * radius, black);
    Offset lineRotation =
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

class GameController {
  MyGame _game;

  GameController() {
    final MyBox2D box = MyBox2D();
    _game = MyGame(box);
    _game.add(MyPlanet(box));
  }

  Widget get widget => _game.widget;
}
