import 'package:behavior_tree/behavior_tree.dart';

/// The type of callback used by the [Task] node.
typedef TaskCallback = NodeStatus Function();

/// This is a leaf node that will execute the given task when ticked.
class Task extends BaseNode implements INode {
  /// Creates a task node for given [taskCallback].
  Task(this.taskCallback);

  /// The callback that will be executed when the task is ticked.
  /// It should return the status of the task.
  final TaskCallback taskCallback;

  @override
  void tick() => status = taskCallback();
}
