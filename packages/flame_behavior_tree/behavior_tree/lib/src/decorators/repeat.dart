import 'package:behavior_tree/behavior_tree.dart';

/// A decorator that runs its child again every time it finishes.
///
/// The child is restarted on the next tick, never in the same tick, so a child
/// that finishes instantly cannot freeze the game. While there are runs left
/// this node returns [Status.running]. After [times] runs it returns the status
/// of the last one. With a null [times] it repeats forever and is always
/// running.
class Repeat(super.child, {this.times}) extends Decorator {
  // At least one run is needed, otherwise the node could never finish.
  this : assert(times == null || times > 0);

  /// How many times the child is run, or null to repeat forever.
  final int? times;

  var _completed = 0;

  @override
  void onEnter(TickContext context) => _completed = 0;

  @override
  Status onTick(TickContext context) {
    final status = child.tick(context);
    if (status == Status.running) {
      return status;
    }
    _completed++;
    final times = this.times;
    return (times != null && _completed >= times) ? status : Status.running;
  }
}

/// A decorator that runs its child again after each failure, up to [times]
/// attempts.
///
/// It succeeds as soon as the child succeeds, and fails if the child failed on
/// all [times] attempts. In between attempts it returns [Status.running]; the
/// next attempt starts on the next tick.
class RetryOnFailure(super.child, {required this.times}) extends Decorator {
  // At least one attempt is needed, otherwise the node could never finish.
  this : assert(times > 0);

  /// The maximum number of attempts.
  final int times;

  var _failures = 0;

  @override
  void onEnter(TickContext context) => _failures = 0;

  @override
  Status onTick(TickContext context) {
    final status = child.tick(context);
    if (status != Status.failure) {
      return status;
    }
    _failures++;
    return _failures >= times ? Status.failure : Status.running;
  }
}
