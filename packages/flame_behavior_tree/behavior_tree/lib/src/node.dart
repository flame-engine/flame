import 'package:behavior_tree/behavior_tree.dart';
import 'package:meta/meta.dart';

/// The base class of all the nodes of a behavior tree.
///
/// To create a custom node, extend this class and implement [onTick]. A node
/// that needs more than one tick to finish returns [Status.running]; it will be
/// ticked again until it returns [Status.success] or [Status.failure], or until
/// it is aborted by its parent.
///
/// The lifecycle of a node is:
///
/// 1. [onEnter] is called before the first tick, and again before the first
///    tick after the node finished or got aborted.
/// 2. [onTick] is called on every tick and decides the [Status].
/// 3. [onExit] is called after [onTick] returned success or failure, or
///    [onAbort] is called if the parent interrupted the node while running.
abstract class Node() {
  /// An optional name for this node, which tools use to tell nodes apart.
  ///
  /// It does not have any effect on how the node behaves, but it makes a tree
  /// a lot easier to read in the Flame DevTools. A cascade is a good way to
  /// set it where the node is created:
  ///
  /// ```dart
  /// Condition((context) => context.get(isHungry))..name = 'is hungry?'
  /// ```
  String? name;

  bool _isRunning = false;
  Status? _lastStatus;

  /// Whether this node returned [Status.running] on its last tick.
  bool get isRunning => _isRunning;

  /// The status returned by the last tick, or null if the node was never
  /// ticked or was aborted since.
  ///
  /// This is meant for debugging and should not be used to drive the logic.
  Status? get lastStatus => _lastStatus;

  /// Ticks this node and returns its resulting [Status].
  ///
  /// Do not override this, override [onTick] instead.
  Status tick(TickContext context) {
    if (!_isRunning) {
      onEnter(context);
    }
    final status = onTick(context);
    _lastStatus = status;
    _isRunning = status == Status.running;
    if (!_isRunning) {
      onExit(context, status);
    }
    return status;
  }

  /// Interrupts this node if it is running.
  ///
  /// Parents call this when they stop ticking a running child, for example
  /// when an earlier child of a reactive sequence starts failing. Does nothing
  /// if the node is not running.
  void abort(TickContext context) {
    if (_isRunning) {
      _isRunning = false;
      _lastStatus = null;
      onAbort(context);
    }
  }

  /// Called before the first tick of a run.
  @protected
  void onEnter(TickContext context) {}

  /// Called on every tick. Must return the status of the node.
  @protected
  Status onTick(TickContext context);

  /// Called when [onTick] returned [Status.success] or [Status.failure].
  @protected
  void onExit(TickContext context, Status status) {}

  /// Called when a running node is interrupted by its parent, instead of
  /// [onExit]. Release anything that was started in [onEnter] or [onTick]
  /// here. [Composite] and [Decorator] already abort their children, so
  /// custom nodes only have to do that if they hold children themselves.
  @protected
  void onAbort(TickContext context) {}
}
