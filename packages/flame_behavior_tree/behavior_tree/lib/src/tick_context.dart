import 'package:behavior_tree/behavior_tree.dart';

/// Everything a [Node] needs to know about the world when it is ticked.
///
/// A new context is created by [BehaviorTree] for every tick and passed down
/// the tree, so nodes never have to store a reference to the blackboard or the
/// owner themselves.
class const TickContext(this.dt, this.blackboard, [this._owner]) {
  /// The time, in seconds, that has passed since the previous tick.
  final double dt;

  /// The blackboard shared by all the nodes of the tree.
  final Blackboard blackboard;

  final Object? _owner;

  /// Returns the owner of the tree as [T].
  ///
  /// The owner is the object that owns the tree, for example a Flame
  /// component. Throws a [StateError] if the tree has no owner or if it is not
  /// a [T].
  T owner<T extends Object>() {
    final owner = _owner;
    if (owner is! T) {
      throw StateError(
        'Expected the owner of the behavior tree to be a $T but it is '
        '${owner == null ? 'not set' : owner.runtimeType}.',
      );
    }
    return owner;
  }

  /// Shortcut for [Blackboard.get] on [blackboard].
  T get<T>(BlackboardKey<T> key) => blackboard.get(key);

  /// Shortcut for [Blackboard.getOrNull] on [blackboard].
  T? getOrNull<T>(BlackboardKey<T> key) => blackboard.getOrNull(key);

  /// Shortcut for [Blackboard.set] on [blackboard].
  void set<T>(BlackboardKey<T> key, T value) => blackboard.set(key, value);
}
