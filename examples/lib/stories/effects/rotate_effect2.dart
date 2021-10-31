import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/effects2/rotate_effect.dart'; // ignore: implementation_imports
import 'package:flame/src/effects2/standard_effect_controller.dart'; // ignore: implementation_imports
import 'package:flutter/animation.dart';

class RotateEffect2Game extends FlameGame {
  @override
  void onMount() {
    camera.viewport = FixedResolutionViewport(Vector2(400, 600));
    final compass = Compass(200)..position = Vector2(200, 300);
    add(compass);

    compass.rim.add(
      RotateEffect.by(
        1.0,
        StandardEffectController(
          duration: 6,
          reverseDuration: 3,
          curve: Curves.ease,
          infinite: true,
        ),
      ),
    );
    compass.arrow
      ..add(RotateEffect.to(
          Transform2D.tau,
          StandardEffectController(
            duration: 20,
            infinite: true,
          )))
      ..add(RotateEffect.by(
          Transform2D.tau * 0.015,
          StandardEffectController(
            duration: 0.1,
            reverseDuration: 0.1,
            infinite: true,
          )))
      ..add(RotateEffect.by(
          Transform2D.tau * 0.021,
          StandardEffectController(
            duration: 0.13,
            reverseDuration: 0.13,
            infinite: true,
          )));
  }
}

class Compass extends PositionComponent {
  Compass(double size)
      : _radius = size / 2,
        super(
          size: Vector2.all(size),
          anchor: Anchor.center,
        );

  late PositionComponent arrow;
  late PositionComponent rim;

  final double _radius;
  late Paint _bgPaint;
  late Paint _marksPaint;
  late Path _marksPath;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _bgPaint = Paint()..color = const Color(0xffeacb31);
    _marksPaint = Paint()
      ..color = const Color(0xFF7F6D36)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    _marksPath = Path();
    for (var i = 0; i < 12; i++) {
      final angle = Transform2D.tau * (i / 12);
      // Note: rim takes up 0.1radius, so the lengths must be > than that
      final markLength = (i % 3 == 0) ? _radius * 0.2 : _radius * 0.15;
      _marksPath
        ..moveTo(
          _radius + _radius * sin(angle),
          _radius + _radius * cos(angle),
        );
      _marksPath
        ..lineTo(
          _radius + (_radius - markLength) * sin(angle),
          _radius + (_radius - markLength) * cos(angle),
        );
    }

    arrow = CompassArrow(width: _radius * 0.3, radius: _radius * 0.7)
      ..position = Vector2(_radius, _radius);
    rim = CompassRim(radius: _radius, width: _radius * 0.1)
      ..position = Vector2(_radius, _radius);
    add(arrow);
    add(rim);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(Offset(_radius, _radius), _radius, _bgPaint);
    canvas.drawPath(_marksPath, _marksPaint);
  }
}

class CompassArrow extends PositionComponent {
  CompassArrow({required double width, required double radius})
      : assert(width <= radius),
        _radius = radius,
        _width = width,
        super(size: Vector2(width, 2 * radius), anchor: Anchor.center);

  final double _radius;
  final double _width;
  late final Path _northPath, _southPath;
  late final Paint _northPaint, _southPaint;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _northPaint = Paint()..color = const Color(0xff387fcb);
    _southPaint = Paint()..color = const Color(0xffa83636);
    _northPath = Path()
      ..moveTo(0, _radius)
      ..lineTo(_width / 2, 0)
      ..lineTo(_width, _radius)
      ..close();
    _southPath = Path()
      ..moveTo(0, _radius)
      ..lineTo(_width, _radius)
      ..lineTo(_width / 2, 2 * _radius)
      ..close();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawPath(_northPath, _northPaint);
    canvas.drawPath(_southPath, _southPaint);
  }
}

class CompassRim extends PositionComponent {
  CompassRim({required double radius, required double width})
      : assert(radius > width),
        _radius = radius,
        _width = width,
        super(
          size: Vector2.all(2 * radius),
          anchor: Anchor.center,
        );

  static const int numberOfNotches = 144;
  final double _radius;
  final double _width;
  late final Paint _bgPaint;
  late final Paint _marksPaint;
  late final Path _marksPath;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _width
      ..color = const Color(0xffb6a241);
    _marksPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xff3d3b26);
    _marksPath = Path();
    final innerRadius = _radius - _width;
    final midRadius = _radius - _width / 3;
    for (var i = 0; i < numberOfNotches; i++) {
      final angle = Transform2D.tau * (i / numberOfNotches);
      _marksPath.moveTo(
        _radius + innerRadius * sin(angle),
        _radius + innerRadius * cos(angle),
      );
      _marksPath.lineTo(
        _radius + midRadius * sin(angle),
        _radius + midRadius * cos(angle),
      );
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(Offset(_radius, _radius), _radius - _width / 2, _bgPaint);
    canvas.drawCircle(Offset(_radius, _radius), _radius - _width, _marksPaint);
    canvas.drawPath(_marksPath, _marksPaint);
  }
}
