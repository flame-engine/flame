import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boundaries.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

class Ball extends BodyComponent with ContactCallbacks {
  late Paint originalPaint;
  bool giveNudge = false;
  final double radius;
  final BodyType bodyType;
  final Vector2 _position;
  double _timeSinceNudge = 0.0;
  static const double _minNudgeRest = 2.0;

  final Paint _blue = BasicPalette.blue.paint();

  Ball(
    this._position, {
    this.radius = 2,
    this.bodyType = BodyType.dynamic,
    Color? color,
  }) {
    if (color != null) {
      originalPaint = PaletteEntry(color).paint();
    } else {
      originalPaint = randomPaint();
    }
    paint = originalPaint;
  }

  Paint randomPaint() => PaintExtension.random(withAlpha: 0.9, base: 100);

  @override
  Body createBody() {
    final shape = CircleShape();
    shape.radius = radius;

    final fixtureDef = FixtureDef(
      shape,
      restitution: 0.8,
      friction: 0.4,
    );

    final bodyDef = BodyDef(
      userData: this,
      angularDamping: 0.8,
      position: _position,
      type: bodyType,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void renderCircle(Canvas canvas, Offset center, double radius) {
    super.renderCircle(canvas, center, radius);
    final lineRotation = Offset(0, radius);
    canvas.drawLine(center, center + lineRotation, _blue);
  }

  final _impulseForce = Vector2(0, 1000);

  @override
  @mustCallSuper
  void update(double dt) {
    _timeSinceNudge += dt;
    if (giveNudge) {
      giveNudge = false;
      if (_timeSinceNudge > _minNudgeRest) {
        body.applyLinearImpulse(_impulseForce);
        _timeSinceNudge = 0.0;
      }
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Wall) {
      other.paint = paint;
    }

    if (other is WhiteBall) {
      return;
    }

    if (other is Ball) {
      if (paint != originalPaint) {
        paint = other.paint;
      } else {
        other.paint = paint;
      }
    }
  }
}

class WhiteBall extends Ball with ContactCallbacks {
  WhiteBall(super.position) {
    originalPaint = BasicPalette.white.paint();
    paint = originalPaint;
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Ball) {
      other.giveNudge = true;
    }
  }
}
