import 'package:behavior_tree/src/node.dart';

/// A decorator node that limits the number of times [child] can be ticked.
class Limiter implements Node {
  /// Creates a limiter node for given [child] node and [limit].
  ///
  /// Once this node has been ticked [limit] number of times, it stops ticking
  /// the child node. After this, [status] will keep returning the status of
  /// child the last time it was ticked. This behavior can be overridden by
  /// providing an optional [statusAfterLimit].
  Limiter(
    this.child,
    this.limit, {
    NodeStatus? statusAfterLimit,
  }) : _statusAfterLimit = statusAfterLimit;

  var _tickCount = 0;
  final NodeStatus? _statusAfterLimit;

  /// The child node whose ticks are to be limited.
  final Node child;

  /// The max number of times [child] can be ticked.
  final int limit;

  /// Returns the number of times [child] has been ticked.
  int get tickCount => _tickCount;

  @override
  NodeStatus get status =>
      (_tickCount < limit) ? child.status : _statusAfterLimit ?? child.status;

  @override
  void tick() {
    if (_tickCount < limit) {
      child.tick();
      ++_tickCount;
    }
  }
}
