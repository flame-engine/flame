import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart' show Flutter3dFlameWidget;
import 'package:flame_flutter3d/src/host/bridge_priority.dart';
import 'package:flame_flutter3d/src/host/flutter3d_flame_widget.dart'
    show Flutter3dFlameWidget;
import 'package:flutter3d/flutter3d.dart' show GraphicsDevice;

/// The one place a bridged game's frame steps flutter3d's own systems,
/// riding Flame's own game loop rather than a second ticker.
///
/// **Why not a `Ticker` of its own.** Flame's `GameWidget` already runs one,
/// synced to vsync, and `FlameGame.update(dt)` fires from it every frame.
/// A second ticker driving flutter3d's side would need its own
/// synchronization with the first to avoid the two drifting apart — the
/// exact class of bug two clocks always risk. Adding this as an ordinary
/// [Component] to the same [FlameGame] instead means there is only ever one
/// clock in a bridged game, and it is the one Flame already owns.
///
/// [Flutter3dFlameWidget] adds one of these to the [FlameGame] it hosts and
/// calls [onTick] with every frame's own `dt`, after every other component's
/// `update` has run.
///
/// **That ordering is a priority, not an accident of when [add] was
/// called.** Flame breaks a tie between equal priorities by insertion order,
/// and [Flutter3dFlameWidget] adds this component from its first `build` —
/// which, when it opens its own [GraphicsDevice], happens *before*
/// `buildScene` returns and the host's own components exist to be tied
/// with. A [BridgeClock] left at the default priority would then run
/// *first*, not last, on that path. [priority] is set far past anything a
/// caller's own game would plausibly use instead, so the order holds
/// regardless of which of the two ever gets added first.
final class BridgeClock extends Component {
  BridgeClock({required this.onTick}) : super(priority: BridgePriority.clock);

  /// Called every time Flame updates this component, with Flame's own `dt`
  /// in seconds, not a second measurement of it: once a frame from the game
  /// loop, and with `dt == 0` when `GameWidget` updates the game from its own
  /// layout, which it does when it is rebuilt (its first frame, a resize).
  final void Function(double dt) onTick;

  @override
  void update(double dt) {
    super.update(dt);
    onTick(dt);
  }
}
