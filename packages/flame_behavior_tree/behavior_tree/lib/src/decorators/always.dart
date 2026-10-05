import 'package:behavior_tree/behavior_tree.dart';

/// A decorator that succeeds once its child has finished, no matter how.
///
/// [Status.running] is passed through unchanged. Useful for optional steps
/// that should not make a [Sequence] fail.
class AlwaysSucceed(super.child) extends Decorator {
  @override
  Status onTick(TickContext context) {
    final status = child.tick(context);
    return status == Status.running ? status : Status.success;
  }
}

/// A decorator that fails once its child has finished, no matter how.
///
/// [Status.running] is passed through unchanged.
class AlwaysFail(super.child) extends Decorator {
  @override
  Status onTick(TickContext context) {
    final status = child.tick(context);
    return status == Status.running ? status : Status.failure;
  }
}
