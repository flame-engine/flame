import 'package:behavior_tree/behavior_tree.dart';

/// A tree of [Node]s together with the [Blackboard] and owner they share.
///
/// This is the entry point for running a behavior tree: build the nodes, pass
/// the root node to a [BehaviorTree] and call [tick] regularly.
///
/// ```dart
/// final tree = BehaviorTree(
///   Sequence([
///     Condition((context) => isHungry),
///     Task((context) => eat()),
///   ]),
/// );
/// tree.tick(dt);
/// ```
///
/// A new [Blackboard] is created if none is given. The optional [owner] is
/// available to the nodes through [TickContext.owner].
class BehaviorTree(this.root, {Blackboard? blackboard, this.owner}) {
  /// The root node of the tree.
  final Node root;

  /// The blackboard shared by all the nodes of this tree.
  final Blackboard blackboard = blackboard ?? Blackboard();

  /// The object that owns this tree.
  final Object? owner;

  /// The result of the last [tick], or null if the tree was not ticked yet.
  Status? get lastStatus => root.lastStatus;

  /// Ticks the tree. [dt] is the time in seconds since the previous tick.
  Status tick(double dt) => root.tick(_context(dt));

  /// Aborts all the running nodes of the tree.
  ///
  /// The tree can be ticked again afterwards, in which case it starts over from
  /// the root.
  void abort() => root.abort(_context(0));

  TickContext _context(double dt) => TickContext(dt, blackboard, owner);
}
