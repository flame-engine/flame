import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/effects/provider_interfaces.dart';
import 'package:flame/src/experimental/geometry/shapes/shape.dart';
import 'package:flame/src/extensions/vector2.dart';

/// This behavior ensures that the target's position stays within the specified
/// [bounds].
///
/// On each game tick this behavior checks whether the target's position remains
/// within the bounds. If it does, then no adjustment are made. However, if this
/// component detects that the target has left the permitted region, it will
/// return it into the [bounds] by moving towards the last known good position
/// and stopping as close to the boundary as possible. The [precision] parameter
/// controls how close to the boundary we want to get before stopping.
///
/// Here [target] is typically the component to which this behavior is attached,
/// but it can also be set explicitly in the constructor. If the target is not
/// passed explicitly in the constructor, then the parent component must be a
/// [PositionProvider].
class BoundedPositionBehavior extends Component {
  BoundedPositionBehavior({
    required Shape bounds,
    PositionProvider? target,
    double precision = 0.5,
    super.priority,
  })  : assert(precision > 0, 'Precision must be positive: $precision'),
        _bounds = bounds,
        _target = target,
        _previousPosition = Vector2.zero(),
        _precision = precision;

  /// The region within which the target's position must be kept.
  Shape get bounds => _bounds;
  Shape _bounds;
  set bounds(Shape newBounds) {
    _bounds = newBounds;
    if (!isValidPoint(_previousPosition)) {
      _previousPosition.setFrom(_bounds.center);
      update(0);
    }
  }

  bool isValidPoint(Vector2 point) => _bounds.containsPoint(point);

  PositionProvider get target => _target!;
  PositionProvider? _target;

  double get precision => _precision;
  final double _precision;

  /// Saved position from the last game tick.
  final Vector2 _previousPosition;

  @override
  void onMount() {
    if (_target == null) {
      assert(
        parent is PositionProvider,
        'Can only apply this behavior to a PositionProvider',
      );
      _target = parent! as PositionProvider;
    }
    if (isValidPoint(target.position)) {
      _previousPosition.setFrom(target.position);
    } else {
      _previousPosition.setFrom(_bounds.center);
      update(0);
    }
  }

  @override
  void update(double dt) {
    final currentPosition = _target!.position;
    if (isValidPoint(currentPosition)) {
      _previousPosition.setFrom(currentPosition);
    } else {
      var inBoundsPoint = _previousPosition;
      var outOfBoundsPoint = currentPosition;
      while (inBoundsPoint.taxicabDistanceTo(outOfBoundsPoint) > _precision) {
        final newPoint = (inBoundsPoint + outOfBoundsPoint)..scale(0.5);
        if (isValidPoint(newPoint)) {
          inBoundsPoint = newPoint;
        } else {
          outOfBoundsPoint = newPoint;
        }
      }
      _previousPosition.setFrom(inBoundsPoint);
      _target!.position = inBoundsPoint;
    }
  }
}
