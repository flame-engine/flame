import 'dart:ui';

import '../position_component.dart';
import '../../../extensions.dart';
import '../../collision_detection.dart' as collision_detection;

mixin Hitbox on PositionComponent {
  List<Vector2> _shape;

  /// The list of vertices used for collision detection and to define whether
  /// a point is inside of the component or not, so that the tap detection etc
  /// can be more accurately performed.
  /// The hitbox is defined from the center of the component and with
  /// percentages of the size of the component.
  /// Example: [[1.0, 0.0], [0.0, 1.0], [-1.0, 0.0], [0.0, -1.0]]
  /// This will form a square with a 45 degree angle (pi/4 rad) within the
  /// bounding size box.
  /// NOTE: Always define the shape clockwise
  set shape(List<Vector2> vertices) => _shape = vertices;
  List<Vector2> get shape => _shape ?? [];

  /// Whether the hitbox shape has defined vertices and is not an empty list
  bool hasShape() => _shape?.isNotEmpty ?? false;

  Iterable<Vector2> _scaledShape;
  Vector2 _lastScaledSize;

  /// Gives back the shape vectors multiplied by the size of the component
  Iterable<Vector2> get scaledShape {
    if (_lastScaledSize != size || _scaledShape == null) {
      _lastScaledSize = size;
      _scaledShape = _shape?.map(
        (p) => p.clone()..multiply(size / 2),
      );
    }
    return _scaledShape;
  }

  void renderContour(Canvas canvas) {
    final hitboxPath = Path()
      ..addPolygon(
        scaledShape.map((point) => (point + size / 2).toOffset()).toList(),
        true,
      );
    canvas.drawPath(hitboxPath, debugPaint);
  }

  // These variables are used to see whether the bounding vertices cache is
  // valid or not
  Vector2 _lastCachePosition;
  Vector2 _lastCacheSize;
  double _lastCacheAngle;
  bool _hadShape = false;
  List<Vector2> _cachedHitbox;

  bool _isHitboxCacheValid() {
    return _lastCacheAngle == angle &&
        _lastCacheSize == size &&
        _lastCachePosition == position &&
        _hadShape == hasShape();
  }

  /// Gives back the bounding vertices represented as a list of points which
  /// are the "corners" of the hitbox rotated with [angle].
  List<Vector2> get hitbox {
    // Use cached bounding vertices if state of the component hasn't changed
    if (!_isHitboxCacheValid()) {
      _cachedHitbox = scaledShape
              .map((point) => rotatePoint(center + point))
              .toList(growable: false) ??
          [];
      _lastCachePosition = position.clone();
      _lastCacheSize = size.clone();
      _lastCacheAngle = angle;
      _hadShape = hasShape();
    }
    return _cachedHitbox;
  }

  /// Checks whether the hitbox represented by the list of [Vector2] contains
  /// the [point].
  @override
  bool containsPoint(Vector2 point) {
    return collision_detection.containsPoint(point, hitbox);
  }
}
