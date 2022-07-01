import 'dart:ui';

import 'package:flame/components.dart';

enum _ClipType {
  rect,
  circle,
  polygon,
}

/// {@template clip_component}
/// A component that will clip its content.
/// {@endtemplate}
class ClipComponent extends PositionComponent {
  /// {@macro clip_component}
  ///
  /// Creates a circle clip based on the components size.
  ClipComponent.circle({
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
  }) : _clipType = _ClipType.circle;

  /// {@macro clip_component}
  ///
  /// Creates a rectangle clip based on the [size].
  ClipComponent.rect({
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
  }) : _clipType = _ClipType.rect;

  /// {@macro clip_component}
  ///
  /// Creates a polygon clip based on the given [points].
  ClipComponent.polygon({
    required List<Vector2> points,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
  })  : assert(
          points.length > 2,
          'ClipComponent.polygon requires at least 3 points.',
        ),
        _clipType = _ClipType.polygon {
    final _points = [...points];
    final firstPoint = _points.removeAt(0);

    _path = _points.fold(Path()..moveTo(firstPoint.x, firstPoint.y),
        (previousValue, value) {
      return previousValue..lineTo(value.x, value.y);
    });
  }

  late Path _path;
  final _ClipType _clipType;

  @override
  Future<void> onLoad() async {
    _buildPath();
    size.addListener(_buildPath);
  }

  void _buildPath() {
    switch (_clipType) {
      case _ClipType.rect:
        _path = Path()..addRect(size.toRect());
        break;
      case _ClipType.circle:
        _path = Path()..addOval(Rect.fromLTWH(0, 0, size.x, size.y));
        break;
      case _ClipType.polygon:
        // nothing to do here, path is set in the constructor.
        break;
    }
  }

  @override
  void render(Canvas canvas) => canvas.clipPath(_path);
}
