import 'package:flame/src/camera/viewfinder.dart';
import 'package:flame/src/camera/viewport.dart';
import 'package:flame/src/camera/world.dart';
import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/components/position_component.dart';
import 'package:flame/src/effects/provider_interfaces.dart';
import 'package:meta/meta.dart';
import 'package:vector_math/vector_math.dart';

/// This behavior will make the [owner] follow the [target].
///
/// Here, both the owner and the target are [PositionProvider]s, which could be
/// either [PositionComponent]s, or camera's [Viewfinder]/[Viewport], or any
/// other objects, including custom implementations.
///
/// The [maxSpeed] parameter controls the maximum speed with which the [owner]
/// is allowed to move as it pursues the [target]. By default, the max speed is
/// infinite, allowing the owner to stay on top of the target all the time.
///
/// The flags [horizontalOnly]/[verticalOnly] allow constraining the [owner]'s
/// movement to the horizontal/vertical directions respectively.
///
/// If the [target] is a [PositionComponent], the owner follows it wherever it
/// is in the component tree, even if it's a child of another
/// [PositionComponent].
class FollowBehavior({
  required final ReadOnlyPositionProvider _target,
  var PositionProvider? _owner,
  double maxSpeed = double.infinity,
  final bool horizontalOnly = false,
  final bool verticalOnly = false,
  super.priority,
  super.key,
}) extends Component {
  this
    : assert(maxSpeed > 0, 'maxSpeed must be positive: $maxSpeed'),
      assert(
        !(horizontalOnly && verticalOnly),
        'The behavior cannot be both horizontalOnly and verticalOnly',
      );

  ReadOnlyPositionProvider get target => _target;
  PositionProvider get owner => _owner!;
  double get maxSpeed => _speed;
  final double _speed = maxSpeed;

  final _tempDelta = Vector2.zero();

  @override
  void onMount() {
    if (_owner == null) {
      assert(
        parent is PositionProvider,
        'Can only apply this behavior to a PositionProvider',
      );
      _owner = parent! as PositionProvider;
    }
  }

  /// The position of the [target] in the coordinate system of the [owner]'s
  /// position.
  ///
  /// The position of a [PositionComponent] is relative to its parent, so if
  /// the target is a [PositionComponent] with another parent than the owner,
  /// its position is converted into the coordinate system of the owner's
  /// parent. The position of an owner that isn't a [PositionComponent], such
  /// as a [Viewfinder], is in the coordinate system of the [World] that the
  /// target is in, which is rendered without the transforms of the
  /// components that the world itself is in.
  @internal
  Vector2 get targetPosition {
    final target = _target;
    if (target is! PositionComponent) {
      return target.position;
    }
    final owner = _owner;
    if (owner is PositionComponent) {
      if (owner.parent == target.parent) {
        return target.position;
      }
      // The owner's parent is used rather than the owner itself, so that the
      // owner's own transform, e.g. a zero scale, doesn't affect the result.
      final absolutePosition = target.absolutePosition;
      return owner.findParent<PositionComponent>()?.absoluteToLocal(
            absolutePosition,
          ) ??
          absolutePosition;
    }
    Vector2 position = target.position;
    for (final ancestor in target.ancestors()) {
      if (ancestor is World) {
        break;
      }
      if (ancestor is PositionComponent) {
        position = ancestor.positionOf(position);
      }
    }
    return position;
  }

  @override
  void update(double dt) {
    final targetPosition = this.targetPosition;
    _tempDelta.setValues(
      verticalOnly ? 0 : targetPosition.x - owner.position.x,
      horizontalOnly ? 0 : targetPosition.y - owner.position.y,
    );

    final distance = _tempDelta.length;
    final deltaOffset = _speed * dt;
    if (distance > deltaOffset) {
      _tempDelta.scale(deltaOffset / distance);
    }
    if (_tempDelta.x != 0 || _tempDelta.y != 0) {
      owner.position = _tempDelta..add(owner.position);
    }
  }
}
