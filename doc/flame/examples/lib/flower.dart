import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/rendering.dart';

const tau = 2 * pi;

class Flower extends PositionComponent with TapCallbacks {
  Flower({
    required double size,
    void Function(Flower)? onTap,
    Decorator? decorator,
    super.position,
  })  : _onTap = onTap,
        super(size: Vector2.all(size), anchor: Anchor.center) {
    this.decorator.addLast(decorator);
    final radius = size * 0.38;
    _paths.add(_makePath(radius * 1.4, 6, -0.05, 0.8));
    _paths.add(_makePath(radius, 6, 0.25, 1.5));
    _paths.add(_makePath(radius * 0.8, 6, 0.3, 1.4));
    _paths.add(_makePath(radius * 0.55, 6, 0.2, 1.5));
    _paths.add(_makePath(radius * 0.1, 12, 0.1, 6));
    _paints.add(Paint()..color = const Color(0xff255910));
    _paints.add(Paint()..color = const Color(0xffee3f3f));
    _paints.add(Paint()..color = const Color(0xffffbd66));
    _paints.add(Paint()..color = const Color(0xfff6f370));
    _paints.add(Paint()..color = const Color(0xfffffff0));
  }

  final List<Path> _paths = [];
  final List<Paint> _paints = [];
  final void Function(Flower)? _onTap;

  Path _makePath(double radius, int n, double sharpness, double f) {
    final radius2 = radius * f;
    final p0 = Vector2(radius, 0)..rotate(0);
    final path = Path()..moveTo(p0.x, p0.y);
    for (var i = 0; i < n; i++) {
      final p1 = Vector2(radius2, 0)..rotate(tau / n * (i + sharpness));
      final p2 = Vector2(radius2, 0)..rotate(tau / n * (i + 1 - sharpness));
      final p3 = Vector2(radius, 0)..rotate(tau / n * (i + 1));
      path.cubicTo(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y);
    }
    path.close();
    return path.shift(Offset(width / 2, height / 2));
  }

  @override
  void render(Canvas canvas) {
    for (var i = 0; i < _paths.length; i++) {
      canvas.drawPath(_paths[i], _paints[i]);
    }
  }

  @override
  void onTapUp([TapUpEvent? event]) => _onTap?.call(this);
}
