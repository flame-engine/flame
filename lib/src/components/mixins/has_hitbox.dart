import '../../../collision_detection.dart' as collision_detection;
import '../../../components.dart';

mixin HasHitbox on PositionComponent {
  List<Vector2> vertexScales;

  /// The list of vertices used for collision detection and to define whether
  /// a point is inside of the component or not, so that the tap detection etc
  /// can be more accurately performed.
  /// The hull is defined from the center of the component and with percentages
  /// of the size of the component.
  /// Example: [[0.5, 0.0], [0.0, 0.5], [-0.5, 0.0], [0.0, -0.5]]
  /// This will form a square with a 45 degree angle (pi/4 rad) within the
  /// bounding size box.
  set hitbox(List<Vector2> vertices) => vertexScales = vertices;

  Iterable<Vector2> _scaledHitbox;
  Vector2 _lastScaledSize;

  /// Whether the hull has defined vertices or not
  /// An empty list of vertices is also accepted as valid hull
  bool hasVertices() => vertexScales != null;

  /// Gives back the hull vectors multiplied by the size of the component and
  /// positioned from the component's current center position.
  Iterable<Vector2> get scaledHitbox {
    if (_lastScaledSize != size || _scaledHitbox == null) {
      _lastScaledSize = size;
      _scaledHitbox = vertexScales?.map(
        (p) => p.clone()..multiply(size),
      );
    }
    return _scaledHitbox;
  }

  // These variables are used to see whether the bounding vertices cache is
  // valid or not
  Vector2 _lastCachePosition;
  Vector2 _lastCacheSize;
  double _lastCacheAngle;
  bool _hadVertices = false;
  List<Vector2> _cachedVertices;

  bool _isBoundingVerticesCacheValid() {
    return _lastCacheAngle == angle &&
        _lastCacheSize == size &&
        _lastCachePosition == position &&
        _hadVertices == hasVertices();
  }

  /// Gives back the bounding vertices (bounding box if no hull is specified)
  /// represented as a list of points which are the "corners" of the hull/box
  /// rotated with [angle].
  List<Vector2> boundingVertices() {
    // Use cached bounding vertices if state of the component hasn't changed
    if (!_isBoundingVerticesCacheValid()) {
      // Uses a the vertices as a hull if defined, otherwise just using the size rectangle
      _cachedVertices = scaledHitbox
              .map((point) => rotatePoint(center + point))
              .toList(growable: false) ??
          [];
      _lastCachePosition = position.clone();
      _lastCacheSize = size.clone();
      _lastCacheAngle = angle;
      _hadVertices = hasVertices();
    }
    return _cachedVertices;
  }

  /// Checks whether the [polygon] represented by the list of [Vector2] contains
  /// the [point].
  @override
  bool containsPoint(Vector2 point) {
    return collision_detection.containsPoint(point, boundingVertices());
  }
}
