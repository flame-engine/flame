import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boundaries.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/style.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:material_ui/material_ui.dart';

class Ball(
  final Vector2 _position, {
  final double radius = 2,
  final BodyType bodyType = BodyType.dynamic,
  Color? color,
}) extends BodyComponent with ContactCallbacks, GlowingBody {
  late Paint originalPaint;
  bool giveNudge = false;
  double _timeSinceNudge = 0.0;
  static const double _minNudgeRest = 2.0;

  this {
    originalPaint = Paint()..color = color ?? randomColor();
    paint = originalPaint;
  }

  static int _colorIndex = 0;

  /// Cycles through the palette so that neighboring balls stay readable.
  Color randomColor() =>
      ExampleColors.dynamicColor(_colorIndex++ % ExampleColors.dynamics.length);

  Paint randomPaint() => Paint()..color = randomColor();

  @override
  Body createBody() {
    final shapeDef = ShapeDef(
      material: SurfaceMaterial(restitution: 0.7),
      enableContactEvents: true,
    );

    final bodyDef = BodyDef(
      userData: this,
      angularDamping: 0.8,
      position: _position,
      type: bodyType,
    );

    return world.createBody(bodyDef)
      ..createShape(Circle(radius: radius), shapeDef);
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

class WhiteBall(super.position) extends Ball with ContactCallbacks {
  this {
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
