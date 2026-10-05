import 'package:behavior_tree/behavior_tree.dart';

/// A leaf node that returns [Status.running] for [seconds] and then succeeds.
///
/// Time is measured by adding up [TickContext.dt] of every tick, so it follows
/// the game time and not the wall clock.
class Wait(this.seconds) extends Node {
  /// How long to wait, in seconds.
  final double seconds;

  double _elapsed = 0;

  @override
  void onEnter(TickContext context) => _elapsed = 0;

  @override
  Status onTick(TickContext context) {
    _elapsed += context.dt;
    return _elapsed >= seconds ? Status.success : Status.running;
  }
}
