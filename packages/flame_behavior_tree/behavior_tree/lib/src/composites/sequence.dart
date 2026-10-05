import 'package:behavior_tree/behavior_tree.dart';

/// A composite node that ticks its children in order, for as long as they
/// succeed.
///
/// - It fails as soon as a child fails.
/// - It is running while a child is running.
/// - It succeeds when all the children have succeeded.
///
/// By default the sequence remembers which child was running and resumes from
/// there on the next tick. Set [reactive] to true to re-check the earlier
/// children on every tick instead; if one of them stops succeeding, the
/// running child is aborted.
class Sequence(super.children, {this.reactive = false}) extends Composite {
  /// Whether to re-evaluate from the first child on every tick.
  final bool reactive;

  @override
  Status onTick(TickContext context) {
    return tickChildren(
      context,
      continueOn: Status.success,
      reactive: reactive,
    );
  }
}
