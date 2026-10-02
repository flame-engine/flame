import 'package:flame/src/camera/viewfinder.dart';
import 'package:flame/src/camera/viewport.dart';
import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/components/position_component.dart';
import 'package:flame/src/effects/provider_interfaces.dart';
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

  @override
  void update(double dt) {
    _tempDelta.setValues(
      verticalOnly ? 0 : target.position.x - owner.position.x,
      horizontalOnly ? 0 : target.position.y - owner.position.y,
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
