import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/rendering.dart';

/// The main [FlameGame] class uses [HasTappableComponents] in order to enable
/// tap events propagation.
class TapEventsGame extends FlameGame with HasTappableComponents {
  @override
  Future<void> onLoad() async {
    add(TapTarget());
  }
}

/// This component is the tappable blue-ish rectangle in the center of the
/// game. It uses the [TapCallbacks] mixin in order to inform the game that it
/// wants to receive tap events.
class TapTarget extends PositionComponent with TapCallbacks {
  TapTarget() : super(anchor: Anchor.center);

  final Paint _paint = Paint()..color = const Color(0x448BA8FF);

  /// We will store all current circles into this map, keyed by the `pointerId`
  /// of the event that created the circle.
  final Map<int, ExpandingCircle> _circles = {};

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    size = canvasSize - Vector2(100, 75);
    if (size.x < 100 || size.y < 100) {
      size = canvasSize * 0.9;
    }
    position = canvasSize / 2;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _paint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    final circle = ExpandingCircle(event.localPosition);
    _circles[event.pointerId] = circle;
    add(circle);
  }

  @override
  void onLongTapDown(TapDownEvent event) {
    _circles[event.pointerId]!.accent();
  }

  @override
  void onTapUp(TapUpEvent event) {
    _circles.remove(event.pointerId)!.release();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _circles.remove(event.pointerId)!.cancel();
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
  bool _released = false;
  bool _cancelled = false;
  late final Paint _paint = Paint()
    ..style = PaintingStyle.stroke
    ..color = _baseColor;
  /// "Accent" is thin white circle generated by `onLongTapDown`. We use
  /// negative radius to indicate that the circle should not be drawn yet.
  double _accentRadius = -1e10;
  late final Paint _accentPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0
    ..color = const Color(0xFFFFFFFF);

  /// At this radius the circle will disappear.
  static const maxRadius = 175;
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
      _innerRadius += dt * 100; // implosion
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
