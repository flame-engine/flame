import 'dart:math';

import 'package:behavior_tree/behavior_tree.dart';

/// A node that returns the statuses of [script] one by one, repeating the last
/// one forever, and records how it was used.
class ScriptedNode extends Node {
  ScriptedNode(this.script);

  ScriptedNode.always(Status status) : script = [status];

  final List<Status> script;

  int ticks = 0;
  int enters = 0;
  int exits = 0;
  int aborts = 0;

  @override
  void onEnter(TickContext context) => enters++;

  @override
  Status onTick(TickContext context) {
    return script[min(ticks++, script.length - 1)];
  }

  @override
  void onExit(TickContext context, Status status) => exits++;

  @override
  void onAbort(TickContext context) => aborts++;
}

TickContext context({double dt = 0, Blackboard? blackboard, Object? owner}) {
  return TickContext(dt, blackboard ?? Blackboard(), owner);
}
