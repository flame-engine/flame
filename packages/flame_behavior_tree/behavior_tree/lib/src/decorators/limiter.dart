import 'package:behavior_tree/behavior_tree.dart';

/// A decorator node that limits the number of times [child] can be ticked.
class Limiter extends BaseNode implements NodeInterface {
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
  }) : _statusAfterLimit = statusAfterLimit {
    status = (_tickCount < limit)
        ? child.status
        : _statusAfterLimit ?? child.status;
  }

  var _tickCount = 0;
  final NodeStatus? _statusAfterLimit;

  /// The child node whose ticks are to be limited.
  final NodeInterface child;

  /// The max number of times [child] can be ticked.
  final int limit;

  /// Returns the number of times [child] has been ticked.
  int get tickCount => _tickCount;

  @override
  void tick() {
    if (_tickCount < limit) {
      child.tick();
      ++_tickCount;
    }
    status = (_tickCount < limit)
        ? child.status
        : _statusAfterLimit ?? child.status;
  }

  @override
  void reset() {
    _tickCount = 0;
    child.reset();
    super.reset();
  }
}
