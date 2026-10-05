import 'package:behavior_tree/behavior_tree.dart';

/// The type of callback used by the [Condition] node.
typedef ConditionCallback = bool Function(TickContext context);

/// A leaf node that succeeds if [callback] returns true and fails otherwise.
///
/// A condition never returns [Status.running].
///
/// ```dart
/// Condition((context) => context.get(health) < 20)
/// ```
class Condition(this.callback) extends Node {
  /// The callback that is evaluated when the condition is ticked.
  final ConditionCallback callback;

  @override
  Status onTick(TickContext context) {
    return callback(context) ? Status.success : Status.failure;
  }
}
