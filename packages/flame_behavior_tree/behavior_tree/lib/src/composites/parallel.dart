import 'package:behavior_tree/behavior_tree.dart';

/// Decides when a [Parallel] node is finished.
enum ParallelPolicy() {
  /// Succeeds when all the children succeed, fails as soon as one fails.
  requireAll,

  /// Succeeds as soon as one child succeeds, fails when all of them fail.
  requireOne,
}

/// A composite node that runs all its children at the same time.
///
/// On every tick, each child that has not finished yet is ticked. The result
/// is decided according to [policy]; as soon as it is known, the children that
/// are still running are aborted.
class Parallel(super.children, {this.policy = ParallelPolicy.requireAll})
    extends Composite {
  /// Decides when this node succeeds or fails.
  final ParallelPolicy policy;

  late final List<Status?> _results = List.filled(children.length, null);

  @override
  Status onTick(TickContext context) {
    for (var i = 0; i < children.length; i++) {
      if (_results[i] == null || _results[i] == Status.running) {
        _results[i] = children[i].tick(context);
      }
    }

    final status = _decide();
    if (status != Status.running) {
      // Stop the children that are still running and forget all the results,
      // so that the next tick starts over.
      onAbort(context);
    }
    return status;
  }

  // With requireAll a single failure is decisive and success needs all of the
  // children to succeed. With requireOne it is the other way around.
  Status _decide() {
    final (decisive, other) = switch (policy) {
      ParallelPolicy.requireAll => (Status.failure, Status.success),
      ParallelPolicy.requireOne => (Status.success, Status.failure),
    };
    if (_results.contains(decisive)) {
      return decisive;
    }
    return _results.every((status) => status == other) ? other : Status.running;
  }

  @override
  void onAbort(TickContext context) {
    for (var i = 0; i < children.length; i++) {
      children[i].abort(context);
      _results[i] = null;
    }
  }
}
