import 'package:flame/src/components/component.dart';
import 'package:flame/src/components/position_component.dart';
import 'package:flame/src/effects/provider_interfaces.dart';
import 'package:flame/src/experimental/viewfinder.dart';
import 'package:flame/src/experimental/viewport.dart';

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
class FollowBehavior extends Component {
  FollowBehavior({
    required PositionProvider target,
    PositionProvider? owner,
    double maxSpeed = double.infinity,
    this.horizontalOnly = false,
    this.verticalOnly = false,
    super.priority,
  })  : _target = target,
        _owner = owner,
        _speed = maxSpeed,
        assert(maxSpeed > 0, 'maxSpeed must be positive: $maxSpeed'),
        assert(
          !(horizontalOnly && verticalOnly),
          'The behavior cannot be both horizontalOnly and verticalOnly',
        );

  PositionProvider get target => _target;
  final PositionProvider _target;

  PositionProvider get owner => _owner!;
  PositionProvider? _owner;

  double get maxSpeed => _speed;
  final double _speed;

  final bool horizontalOnly;
  final bool verticalOnly;

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
    final delta = target.position - owner.position;
    if (horizontalOnly) {
      delta.y = 0;
    }
    if (verticalOnly) {
      delta.x = 0;
    }
    final distance = delta.length;
    if (distance > _speed * dt) {
      delta.scale(_speed * dt / distance);
    }
    owner.position = delta..add(owner.position);
  }
}
