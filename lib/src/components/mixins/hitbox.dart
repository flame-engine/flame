
import '../../../components.dart';
import '../../../collision_detection.dart' as collision_detection;

mixin Hitbox on PositionComponent {
  List<Vector2> _hitbox;

  /// The list of vertices used for collision detection and to define whether
  /// a point is inside of the component or not, so that the tap detection etc
  /// can be more accurately performed.
  /// The hitbox is defined from the center of the component and with
  /// percentages of the size of the component.
  /// Example: [[0.5, 0.0], [0.0, 0.5], [-0.5, 0.0], [0.0, -0.5]]
  /// This will form a square with a 45 degree angle (pi/4 rad) within the
  /// bounding size box.
  set hitbox(List<Vector2> vertices) => _hitbox = vertices;
  List<Vector2> get hitbox => _hitbox ?? [];

  /// Whether the hitbox has defined vertices or not
  /// An empty list of vertices is also accepted as valid hitbox
  bool hasVertices() => _hitbox?.isNotEmpty ?? false;

  Iterable<Vector2> _scaledHitbox;
  Vector2 _lastScaledSize;

  /// Gives back the hitbox vectors multiplied by the size of the component and
  /// positioned from the component's current center position.
  Iterable<Vector2> get scaledHitbox {
    if (_lastScaledSize != size || _scaledHitbox == null) {
      _lastScaledSize = size;
      _scaledHitbox = _hitbox?.map(
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

  /// Gives back the bounding vertices represented as a list of points which
  /// are the "corners" of the hitbox rotated with [angle].
  List<Vector2> boundingVertices() {
    // Use cached bounding vertices if state of the component hasn't changed
    if (!_isBoundingVerticesCacheValid()) {
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

  /// Checks whether the hitbox represented by the list of [Vector2] contains
  /// the [point].
  @override
  bool containsPoint(Vector2 point) {
    return collision_detection.containsPoint(point, boundingVertices());
  }
}
