import 'dart:ui';

import 'package:flame/components/mixins/hitbox.dart';

import '../collision_detection/collision_detection.dart' as collision_detection;
import '../extensions/vector2.dart';
import 'shape.dart';

// TODO: Split this up and move some down
/// The list of vertices used for collision detection and to define whether
/// a point is inside of the component or not, so that the tap detection etc
/// can be more accurately performed.
/// The hitbox is defined from the center of the component and with
/// percentages of the size of the component.
/// Example: [[1.0, 0.0], [0.0, 1.0], [-1.0, 0.0], [0.0, -1.0]]
/// This will form a rectangle with a 45 degree angle (pi/4 rad) within the
/// bounding size box.
/// NOTE: Always define your shape is a clockwise fashion
class Polygon extends Shape {
  final List<Vector2> shape;

  Polygon(this.shape);

  Iterable<Vector2> _scaledShape;
  Vector2 _lastScaledSize;

  /// Gives back the shape vectors multiplied by the size of the component
  Iterable<Vector2> get scaledShape {
    if (_lastScaledSize != size || _scaledShape == null) {
      _lastScaledSize = size;
      _scaledShape = shape?.map(
        (p) => p.clone()..multiply(size / 2),
      );
    }
    return _scaledShape;
  }

  @override
  void render(Canvas canvas, Paint paint) {
    final hitboxPath = Path()
      ..addPolygon(
        scaledShape.map((point) => (point + size / 2).toOffset()).toList(),
        true,
      );
    canvas.drawPath(hitboxPath, paint);
  }

  // These variables are used to see whether the bounding vertices cache is
  // valid or not
  Vector2 _lastCachePosition;
  Vector2 _lastCacheSize;
  double _lastCacheAngle;
  List<Vector2> _cachedHitbox;

  bool _isHitboxCacheValid() {
    return _lastCachePosition == position &&
        _lastCacheSize == size &&
        _lastCacheAngle == angle;
  }

  /// Gives back the bounding vertices represented as a list of points which
  /// are the "corners" of the hitbox rotated with [angle].
  List<Vector2> get hitbox {
    // Use cached bounding vertices if state of the component hasn't changed
    if (!_isHitboxCacheValid()) {
      _cachedHitbox = scaledShape
              .map((point) => (point + center)..rotate(angle))
              .toList(growable: false) ??
          [];
      _lastCachePosition = position.clone();
      _lastCacheSize = size.clone();
      _lastCacheAngle = angle;
    }
    return _cachedHitbox;
  }

  /// Checks whether the polygon represented by the list of [Vector2] contains
  /// the [point].
  @override
  bool containsPoint(Vector2 point) {
    return collision_detection.containsPoint(point, hitbox);
  }
}

class HitboxPolygon extends Polygon with HitboxShape {
  HitboxPolygon(List<Vector2> shape) : super(shape);
}
