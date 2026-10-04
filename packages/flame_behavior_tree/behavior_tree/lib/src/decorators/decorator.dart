import 'package:behavior_tree/behavior_tree.dart';

/// A node that wraps exactly one [child] and changes how it behaves.
abstract class Decorator(this.child) extends Node {
  /// The wrapped node.
  final Node child;

  @override
  void onAbort(TickContext context) => child.abort(context);
}
