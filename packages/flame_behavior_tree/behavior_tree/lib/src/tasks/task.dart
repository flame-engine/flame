import 'package:behavior_tree/behavior_tree.dart';

/// The type of callback used by the [Task] node.
typedef TaskCallback = Status Function(TickContext context);

/// A leaf node that runs a callback every time it is ticked.
///
/// The callback decides the status. Return [Status.running] to keep the task
/// going on the next tick:
///
/// ```dart
/// Task((context) {
///   final target = context.get(targetPosition);
///   return moveTowards(target, context.dt) ? Status.success : Status.running;
/// })
/// ```
///
/// If the task has to clean something up when it is interrupted, pass
/// [onAbortCallback].
class Task(this.callback, {this.onAbortCallback}) extends Node {
  /// The callback that will be executed when the task is ticked.
  final TaskCallback callback;

  /// An optional callback that is called when this task is aborted while
  /// running.
  final void Function(TickContext context)? onAbortCallback;

  @override
  Status onTick(TickContext context) => callback(context);

  @override
  void onAbort(TickContext context) => onAbortCallback?.call(context);
}
