import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/rendering.dart';

class TapEventsGame extends FlameGame with HasTappableComponents {
  @override
  Future<void> onLoad() async {
    add(TapTarget());
  }
}

class TapTarget extends PositionComponent with TapCallbacks {
  TapTarget() : super(anchor: Anchor.center);

  late Rect _rect;
  late final Paint _paint = Paint()..color = const Color(0x448BA8FF);
  ExpandingCircle? _currentCircle;

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    size = canvasSize - Vector2(100, 75);
    position = canvasSize / 2;
    _rect = size.toRect();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(_rect, _paint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    add(_currentCircle = ExpandingCircle(event.localPosition));
  }

  @override
  void onLongTapDown(TapDownEvent event) {
    _currentCircle!.accent();
  }

  @override
  void onTapUp(TapUpEvent event) {
    _currentCircle!.release();
    _currentCircle = null;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _currentCircle!.cancel();
    _currentCircle = null;
  }
}

class ExpandingCircle extends Component {
  ExpandingCircle(this._center)
      : _baseColor =
            HSLColor.fromAHSL(1, random.nextDouble() * 360, 1, 0.8).toColor();

  final Color _baseColor;
  final Vector2 _center;
  double _outerRadius = 0;
  double _innerRadius = 0;
  double _accentRadius = -double.infinity;
  bool _released = false;
  bool _cancelled = false;
  late final Paint _paint = Paint()
    ..style = PaintingStyle.stroke
    ..color = _baseColor;
  late final Paint _accentPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0
    ..color = const Color(0xFFFFFFFF);

  static const maxRadius = 150;
  static Random random = Random();

  double get radius => (_innerRadius + _outerRadius) / 2;

  void release() => _released = true;
  void cancel() => _cancelled = true;
  void accent() => _accentRadius = 0;

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(_center.toOffset(), radius, _paint);
    if (_accentRadius >= 0) {
      canvas.drawCircle(_center.toOffset(), _accentRadius, _accentPaint);
    }
  }

  @override
  void update(double dt) {
    if (_cancelled) {
      _innerRadius += dt * 100;
    } else {
      _outerRadius += dt * 20;
      _innerRadius += dt * (_released ? 20 : 6);
      _accentRadius += dt * 20;
    }
    if (radius >= maxRadius || _innerRadius > _outerRadius) {
      removeFromParent();
    } else {
      final opacity = 1 - radius / maxRadius;
      _paint.color = _baseColor.withOpacity(opacity);
      _paint.strokeWidth = _outerRadius - _innerRadius;
    }
  }
}
