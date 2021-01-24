import 'dart:math';
import 'dart:ui';

import '../../components.dart';
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
  final List<Vector2> definition;

  Polygon(
    this.definition, {
    Vector2 position,
    Vector2 size,
    double angle,
  }) : super(position: position, size: size, angle: angle = 0);

  /// With this helper method you can create your [Polygon] from absolute
  /// positions instead of percentages. This helper will also calculate the size
  /// and center of the Polygon.
  factory Polygon.fromPositions(
    List<Vector2> positions, {
    double angle = 0,
  }) {
    final center = positions.fold<Vector2>(
          Vector2.zero(),
          (sum, v) => sum + v,
        ) /
        positions.length.toDouble();
    final bottomRight = positions.fold<Vector2>(
      Vector2.zero(),
      (bottomRight, v) {
        return Vector2(
          max(bottomRight.x, v.x),
          max(bottomRight.y, v.y),
        );
      },
    );
    final halfSize = bottomRight - center;
    final definition =
        positions.map<Vector2>((v) => (v - center)..divide(halfSize)).toList();
    return Polygon(
      definition,
      position: center,
      size: halfSize * 2,
      angle: angle,
    );
  }

  Iterable<Vector2> _scaledShape;
  Vector2 _lastScaledSize;

  /// Gives back the shape vectors multiplied by the size of the component
  Iterable<Vector2> get scaled {
    if (_lastScaledSize != size || _scaledShape == null) {
      _lastScaledSize = size;
      _scaledShape = definition?.map((p) => p.clone()..multiply(size / 2));
    }
    return _scaledShape;
  }

  @override
  void render(Canvas canvas, Paint paint) {
    // TODO: Add render cache
    final path = Path()
      ..addPolygon(
        scaled
            .map((point) => (point + position + parentSize / 2).toOffset())
            .toList(),
        true,
      );
    canvas.drawPath(path, paint);
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

  /// Gives back the vertices represented as a list of points which
  /// are the "corners" of the hitbox rotated with [angle].
  List<Vector2> get hitbox {
    // Use cached bounding vertices if state of the component hasn't changed
    if (!_isHitboxCacheValid()) {
      _cachedHitbox = scaled
              .map((point) => (point + position + origin)..rotate(angle))
              .toList(growable: false) ??
          [];
      _lastCachePosition = origin;
      _lastCacheSize = size.clone();
      _lastCacheAngle = angle;
    }
    return _cachedHitbox;
  }

  /// Checks whether the polygon represented by the list of [Vector2] contains
  /// the [point].
  @override
  bool containsPoint(Vector2 point) {
    for (int i = 0; i < hitbox.length; i++) {
      final previousNode = hitbox[i];
      final node = hitbox[(i + 1) % hitbox.length];
      final isOutside = (node.x - previousNode.x) * (point.y - previousNode.y) -
              (point.x - previousNode.x) * (node.y - previousNode.y) >
          0;
      if (isOutside) {
        // Point is outside of convex polygon
        return false;
      }
    }
    return true;
  }
}

class HitboxPolygon extends Polygon with HitboxShape {
  HitboxPolygon(List<Vector2> definition) : super(definition);
}
