import 'package:behavior_tree/behavior_tree.dart';

/// A decorator that fails if its child keeps running for too long.
///
/// When the child has been running for [seconds] it is aborted and this node
/// fails. Time is measured by adding up [TickContext.dt].
class TimeLimit(super.child, this.seconds) extends Decorator {
  /// How long the child is allowed to run, in seconds.
  final double seconds;

  double _elapsed = 0;

  @override
  void onEnter(TickContext context) => _elapsed = 0;

  @override
  Status onTick(TickContext context) {
    final status = child.tick(context);
    if (status != Status.running) {
      return status;
    }
    _elapsed += context.dt;
    if (_elapsed >= seconds) {
      child.abort(context);
      return Status.failure;
    }
    return Status.running;
  }
}

/// A decorator that stops its child from being run again for a while after it
/// finished.
///
/// While cooling down, this node fails without ticking the child. This is
/// useful for things like attacks or abilities. Time is measured by adding up
/// [TickContext.dt].
class Cooldown(super.child, this.seconds) extends Decorator {
  /// How long the child is blocked for after it finishes, in seconds.
  final double seconds;

  double _remaining = 0;

  @override
  Status onTick(TickContext context) {
    if (_remaining > 0) {
      _remaining -= context.dt;
      if (_remaining > 0) {
        return Status.failure;
      }
    }
    final status = child.tick(context);
    if (status != Status.running) {
      _remaining = seconds;
    }
    return status;
  }
}
