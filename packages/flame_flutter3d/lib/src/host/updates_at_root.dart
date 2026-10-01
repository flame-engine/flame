import 'package:flame/components.dart';

/// A component whose frame's work has to run at a place in the game's own
/// order — after Flame's camera, last of all — wherever the game added it.
///
/// **A priority orders siblings only.** Flame's `CameraComponent` is a child
/// of the game beside the world, and a component added to the world, where a
/// game adds its components, is updated inside the world's update: before
/// the camera, whatever its priority. A 3D camera synced there trailed
/// `camera.follow()` by a frame; the sound's listener stood where the camera
/// was the frame before; an input step closed there closed before the
/// viewport's buttons had read it.
///
/// So a component with this, mounted anywhere but the game's root, puts a
/// driver at the root at its own priority and does its work — [rootUpdate]
/// — from there. At the root it does the work itself.
mixin UpdatesAtRoot on Component {
  /// The frame's work that has to run at this component's place in the
  /// game's own order.
  void rootUpdate(double dt);

  /// Whether this component's work has to run at the root at all. True
  /// unless overridden; a component that only needs it in one of its modes
  /// says which.
  bool get needsRoot => true;

  _RootDriver? _driver;

  @override
  void onMount() {
    super.onMount();
    if (!needsRoot) {
      return;
    }
    final game = findGame();
    if (game == null || identical(parent, game)) {
      return;
    }
    game.add(_driver = _RootDriver(this, priority: priority));
  }

  @override
  void onRemove() {
    _driver?.removeFromParent();
    _driver = null;
    super.onRemove();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_driver == null) {
      rootUpdate(dt);
    }
  }
}

final class _RootDriver extends Component {
  _RootDriver(this.owner, {super.priority});

  final UpdatesAtRoot owner;

  @override
  void update(double dt) {
    super.update(dt);
    owner.rootUpdate(dt);
  }
}
