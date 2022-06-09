import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';

/// The main [FlameGame] class uses [HasDraggableComponents] in order to enable
/// tap events propagation.
class DragEventsGame extends FlameGame with HasDraggableComponents {
  @override
  Future<void> onLoad() async {
    add(DragTarget());
    add(
      Star(n: 5, radius1: 40, radius2: 20, sharpness: 0.2)
        ..position = Vector2(70, 70),
    );
    add(
      Star(n: 3, radius1: 50, radius2: 40, sharpness: 0.3)
        ..position = Vector2(70, 160),
    );
    add(
      Star(n: 12, radius1: 10, radius2: 75, sharpness: 1.3)
        ..position = Vector2(70, 270),
    );
  }
}

/// This component is the tappable blue-ish rectangle in the center of the
/// game. It uses the [TapCallbacks] mixin in order to inform the game that it
/// wants to receive tap events.
class DragTarget extends PositionComponent with DragCallbacks {
  DragTarget() : super(anchor: Anchor.center);

  final _paint = Paint()..color = const Color(0x44EA8BFF);

  /// We will store all current circles into this map, keyed by the `pointerId`
  /// of the event that created the circle.
  final Map<int, Trail> _trails = {};

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
  void onDragStart(DragStartEvent event) {
    final trail = Trail(event.localPosition);
    _trails[event.pointerId] = trail;
    add(trail);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    _trails[event.pointerId]!.addPoint(event.localPosition);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    _trails.remove(event.pointerId)!.end();
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    _trails.remove(event.pointerId)!.cancel();
  }
}

class Trail extends Component {
  Trail(Vector2 origin)
      : _paths = [Path()..moveTo(origin.x, origin.y)],
        _opacities = [1],
        _lastPoint = origin.clone(),
        _color =
            HSLColor.fromAHSL(1, random.nextDouble() * 360, 1, 0.8).toColor();

  final List<Path> _paths;
  final List<double> _opacities;
  Color _color;
  late final _linePaint = Paint()..style = PaintingStyle.stroke;
  late final _circlePaint = Paint()..color = _color;
  bool _released = false;
  double _timer = 0;
  final _vanishInterval = 0.02;
  final Vector2 _lastPoint;

  static final random = Random();

  @override
  void render(Canvas canvas) {
    assert(_paths.length == _opacities.length);
    for (var i = 0; i < _paths.length; i++) {
      final path = _paths[i];
      final opacity = _opacities[i];
      if (opacity > 0) {
        _linePaint.color = _color.withOpacity(opacity);
        _linePaint.strokeWidth = 4 * opacity;
        canvas.drawPath(path, _linePaint);
      }
    }
    canvas.drawCircle(_lastPoint.toOffset(), 4, _circlePaint);
  }

  @override
  void update(double dt) {
    assert(_paths.length == _opacities.length);
    _timer += dt;
    while (_timer > _vanishInterval) {
      _timer -= _vanishInterval;
      for (var i = 0; i < _paths.length; i++) {
        _opacities[i] -= 0.01;
        if (_opacities[i] <= 0) {
          _paths[i].reset();
        }
      }
      if (!_released) {
        _paths.add(Path()..moveTo(_lastPoint.x, _lastPoint.y));
        _opacities.add(1);
      }
    }
    if (_opacities.last < 0) {
      removeFromParent();
    }
  }

  void addPoint(Vector2 point) {
    if (!point.x.isNaN) {
      for (final path in _paths) {
        path.lineTo(point.x, point.y);
      }
      _lastPoint.setFrom(point);
    }
  }

  void end() => _released = true;

  void cancel() {
    _released = true;
    _color = const Color(0xFFFFFFFF);
  }
}

class Star extends PositionComponent with DragCallbacks {
  Star({
    required this.n,
    required this.radius1,
    required this.radius2,
    required this.sharpness,
  }) {
    _path = Path()..moveTo(radius1, 0);
    for (var i = 0; i < n; i++) {
      final p1 = Vector2(radius2, 0)..rotate(tau / n * (i + sharpness));
      final p2 = Vector2(radius2, 0)..rotate(tau / n * (i + 1 - sharpness));
      final p3 = Vector2(radius1, 0)..rotate(tau / n * (i + 1));
      _path.cubicTo(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y);
    }
    _path.close();
    _paint = Paint()
      ..color =
          HSLColor.fromAHSL(1, random.nextDouble() * 360, 0.5, 0.7).toColor();
    _borderPaint = Paint()
      ..color = const Color(0xFFffffff)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
  }

  final int n;
  final double radius1;
  final double radius2;
  final double sharpness;
  late final Path _path;
  late final Paint _paint;
  late final Paint _borderPaint;
  late final _shadowPaint = Paint()
    ..color = const Color(0xFF000000)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
  bool _isDragged = false;

  static final random = Random();

  @override
  bool containsLocalPoint(Vector2 point) {
    return _path.contains(point.toOffset());
  }

  @override
  void render(Canvas canvas) {
    if (_isDragged) {
      _paint.color = _paint.color.withOpacity(0.5);
      canvas.drawPath(_path, _paint);
      canvas.drawPath(_path, _borderPaint);
    } else {
      _paint.color = _paint.color.withOpacity(1);
      canvas.drawPath(_path, _shadowPaint);
      canvas.drawPath(_path, _paint);
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    _isDragged = true;
    priority = 10;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    _isDragged = false;
    priority = 0;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.delta;
  }
}

const tau = Transform2D.tau;
