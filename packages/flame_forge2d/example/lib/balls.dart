import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import 'boundaries.dart';

class Ball extends BodyComponent with ContactListener {
  late Paint originalPaint;
  bool giveNudge = false;
  final double radius;
  final Vector2 _position;
  double _timeSinceNudge = 0.0;
  static const double _minNudgeRest = 2.0;

  final Paint _blue = BasicPalette.blue.paint();

  Ball(this._position, {this.radius = 2}) {
    originalPaint = randomPaint();
    paint = originalPaint;
  }

  Paint randomPaint() => PaintExtension.random(withAlpha: 0.9, base: 100);

  @override
  Body createBody() {
    final shape = CircleShape();
    shape.radius = radius;

    final fixtureDef = FixtureDef(shape)
      ..restitution = 0.8
      ..density = 1.0
      ..friction = 0.4;

    final bodyDef = BodyDef()
      // To be able to determine object in collision
      ..userData = this
      ..angularDamping = 0.8
      ..position = _position
      ..type = BodyType.dynamic;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void renderCircle(Canvas c, Offset center, double radius) {
    super.renderCircle(c, center, radius);
    final lineRotation = Offset(0, radius);
    c.drawLine(center, center + lineRotation, _blue);
  }

  @override
  @mustCallSuper
  void update(double dt) {
    _timeSinceNudge += dt;
    if (giveNudge) {
      giveNudge = false;
      if (_timeSinceNudge > _minNudgeRest) {
        body.applyLinearImpulse(Vector2(0, 1000));
        _timeSinceNudge = 0.0;
      }
    }
  }

  @override
  void beginContact(Contact contact) {
    final otherObject = contact.bodyA.userData == this
        ? contact.bodyB.userData
        : contact.bodyA.userData;

    if (otherObject is Wall) {
      otherObject.paint = paint;
    }

    if (otherObject is WhiteBall) {
      return;
    }

    if (otherObject is Ball) {
      if (paint != originalPaint) {
        paint = otherObject.paint;
      } else {
        otherObject.paint = paint;
      }
    }
  }

  @override
  void endContact(Contact contact) {}

  @override
  void postSolve(Contact contact, ContactImpulse impulse) {}

  @override
  void preSolve(Contact contact, Manifold oldManifold) {}
}

class WhiteBall extends Ball with ContactListener {
  WhiteBall(Vector2 position) : super(position) {
    originalPaint = BasicPalette.white.paint();
    paint = originalPaint;
  }

  @override
  void beginContact(Contact contact) {
    final otherObject = contact.bodyA.userData == this
        ? contact.bodyB.userData
        : contact.bodyA.userData;

    if (otherObject is Ball) {
      otherObject.giveNudge = true;
    }
  }

  @override
  void endContact(Contact contact) {}

  @override
  void postSolve(Contact contact, ContactImpulse impulse) {}

  @override
  void preSolve(Contact contact, Manifold oldManifold) {}
}
