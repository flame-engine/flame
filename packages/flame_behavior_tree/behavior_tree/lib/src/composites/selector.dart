import 'package:behavior_tree/behavior_tree.dart';

/// A composite node that tries its children in order until one does not fail.
///
/// - It succeeds as soon as a child succeeds.
/// - It is running while a child is running.
/// - It fails when all the children have failed.
///
/// By default the selector remembers which child was running and resumes from
/// there on the next tick. Set [reactive] to true to re-check the earlier
/// children on every tick instead; if one of them stops failing, the running
/// child is aborted.
class Selector(super.children, {this.reactive = false}) extends Composite {
  /// Whether to re-evaluate from the first child on every tick.
  final bool reactive;

  @override
  Status onTick(TickContext context) {
    return tickChildren(
      context,
      continueOn: Status.failure,
      reactive: reactive,
    );
  }
}
