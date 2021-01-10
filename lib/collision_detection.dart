import 'dart:math' as math;

import 'components.dart';

class Hull {
  /// The list of vertices used for collision detection and to define whether
  /// a point is inside of the component or not, so that the tap detection etc
  /// can be more accurately performed.
  /// The hull is defined from the center of the component and with percentages
  /// of the size of the component.
  /// Example: [[0.5, 0.0], [0.0, 0.5], [-0.5, 0.0], [0.0, -0.5]]
  /// This will form a square with a 45 degree angle (pi/4 rad) within the
  /// bounding size box.
  List<Vector2> vertices;
  
  /// The [PositionComponent] that the hull belongs to
  final PositionComponent component;
  
  Hull(this.component, {this.vertices});

  Iterable<Vector2> _scaledHull;
  Vector2 _lastScaledSize;

  /// Whether the hull has defined vertices or not
  /// An empty list of vertices is also accepted as valid hull
  bool hasVertices() => vertices != null;

  /// Gives back the hull vectors multiplied by the size of the component and
  /// positioned from the component's current center position.
  Iterable<Vector2> get scaledHull {
    if (_lastScaledSize != component.size || _scaledHull == null) {
      _lastScaledSize = component.size;
      _scaledHull = vertices?.map((p) => p.clone()..multiply(component.size));
    }
    return _scaledHull;
  }


  // These variables are used to see whether the bounding vertices cache is
  // valid or not
  Vector2 _lastBoundingVerticesPosition;
  Vector2 _lastBoundingVerticesSize;
  double _lastBoundingVerticesAngle;
  bool _hadVertices = false;
  List<Vector2> _cachedBoundingVertices;
  
  bool _isBoundingVerticesCacheValid(PositionComponent component) {
    final position = component.position;
    final angle = component.angle;
    final size = component.size;
    return _lastBoundingVerticesAngle == angle &&
        _lastBoundingVerticesSize == size &&
        _lastBoundingVerticesPosition == position &&
        _hadVertices == hasVertices();
}

  /// Gives back the bounding vertices (bounding box if no hull is specified)
  /// represented as a list of points which are the "corners" of the hull/box
  /// rotated with [angle].
  List<Vector2> boundingVertices() {
    final position = component.position;
    final angle = component.angle;
    final size = component.size;
    final topLeftPosition = component.topLeftPosition;
    // Rotates the [point] with [angle] around [position]
    Vector2 rotatePoint(Vector2 point) {
      return Vector2(
        math.cos(angle) * (point.x - position.x) -
            math.sin(angle) * (point.y - position.y) +
            position.x,
        math.sin(angle) * (point.x - position.x) +
            math.cos(angle) * (point.y - position.y) +
            position.y,
      );
    }

    // Use cached bounding vertices if state of the component hasn't changed
    if (!_isBoundingVerticesCacheValid(component)) {
      // Uses a the vertices as a hull if defined, otherwise just using the size rectangle
      _cachedBoundingVertices = scaledHull
          ?.map((point) => rotatePoint(component.center + point))
          ?.toList(growable: false) ??
          [
            rotatePoint(topLeftPosition), // Top-left
            rotatePoint(topLeftPosition + Vector2(0.0, size.y)), // Bottom-left
            rotatePoint(topLeftPosition + size), // Bottom-right
            rotatePoint(topLeftPosition + Vector2(size.x, 0.0)), // Top-right
          ];
      _lastBoundingVerticesPosition = position;
      _lastBoundingVerticesSize = size;
      _lastBoundingVerticesAngle = angle;
      _hadVertices = hasVertices();
    }

    return _cachedBoundingVertices;
  }
}

/// Checks whether the [polygon] represented by the list of [Vector2] contains
/// the [point].
bool containsPoint(Vector2 point, List<Vector2> polygon) {
  for (int i = 0; i < polygon.length; i++) {
    final previousNode = polygon[i];
    final node = polygon[(i + 1) % polygon.length];
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
