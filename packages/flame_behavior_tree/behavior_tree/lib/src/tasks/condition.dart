import 'package:behavior_tree/behavior_tree.dart';

typedef ConditionCallback = bool Function();

/// This is a leaf node that will updates its [status] based on
/// [conditionCallback].
class Condition(
  /// The callback that will be executed when the condition is ticked.
  final ConditionCallback conditionCallback,
) extends BaseNode {
  @override
  void tick() {
    status = conditionCallback() ? NodeStatus.success : NodeStatus.failure;
  }
}
