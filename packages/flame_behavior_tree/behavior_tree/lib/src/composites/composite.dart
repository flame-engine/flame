import 'package:behavior_tree/behavior_tree.dart';
import 'package:meta/meta.dart';

/// A node that has multiple children.
///
/// The list of children is copied, so changing the list that was passed in
/// later has no effect on the tree.
abstract class Composite(Iterable<Node> children) extends Node {
  /// The children of this node, in the order they are evaluated.
  final List<Node> children = List.unmodifiable(children);

  // Index of the child that returned running on the last tick, or -1.
  int _runningIndex = -1;

  /// Ticks [children] in order for as long as they return [continueOn].
  ///
  /// Returns the first different status, or [continueOn] if all the children
  /// returned it. With [reactive] set to false, the child that was running on
  /// the previous tick is resumed directly; otherwise evaluation always starts
  /// from the first child. In both cases a running child that is not reached
  /// anymore gets aborted.
  @protected
  Status tickChildren(
    TickContext context, {
    required Status continueOn,
    required bool reactive,
  }) {
    final previous = _runningIndex;
    final start = (reactive || previous < 0) ? 0 : previous;

    var result = continueOn;
    var runningIndex = -1;
    for (var i = start; i < children.length; i++) {
      final status = children[i].tick(context);
      if (status != continueOn) {
        result = status;
        if (status == Status.running) {
          runningIndex = i;
        }
        break;
      }
    }

    if (previous >= 0 && previous != runningIndex) {
      children[previous].abort(context);
    }
    _runningIndex = runningIndex;
    return result;
  }

  @override
  void onAbort(TickContext context) {
    if (_runningIndex >= 0) {
      children[_runningIndex].abort(context);
      _runningIndex = -1;
    }
  }
}
