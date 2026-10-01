import 'package:flame/components.dart' show Component;
import 'package:flame_flutter3d/src/host/bridge_priority.dart';
import 'package:flutter3d_game/flutter3d_game.dart' show FixtureVisuals;

/// A level's furniture drawn — doors on their colliders, keys spinning, a
/// taken coin gone — kept up to date on Flame's clock.
///
/// **What every level-loading game wrote by hand.** `FixtureVisuals` is the
/// engine's drawing of a level's fixtures, and it has two duties a game has to
/// remember: `sync` once a frame, after the step has moved the doors, and
/// `dispose` when the level goes, before its device does. A bridged game had
/// neither on any clock, and a level left behind by the next one kept its
/// meshes on the device for good. Added with the level and removed with it,
/// this does both.
final class FixtureVisualsComponent extends Component {
  FixtureVisualsComponent(
    this.fixtures, {
    super.priority = BridgePriority.camera - 1,
  });

  /// What draws the fixtures. Hand its `add` to the level's spawning.
  final FixtureVisuals fixtures;

  double _elapsed = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    fixtures.sync(_elapsed);
  }

  @override
  void onRemove() {
    fixtures.dispose();
    super.onRemove();
  }
}
