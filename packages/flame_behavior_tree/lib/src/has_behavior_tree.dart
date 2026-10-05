import 'dart:math';

import 'package:behavior_tree/behavior_tree.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

/// A mixin on [Component] that gives it a behavior tree.
///
/// Set [behaviorTree] to give the component its AI. The tree is ticked on every
/// update of the component, with the delta time of that update. Increase
/// [tickInterval] to tick it less often; the tree then receives the time that
/// has accumulated since its last tick.
///
/// ```dart
/// class Enemy extends PositionComponent with HasBehaviorTree {
///   @override
///   Future<void> onLoad() async {
///     behaviorTree = BehaviorTree(
///       Selector([attack, chase, patrol]),
///       owner: this,
///     );
///   }
/// }
/// ```
///
/// The running nodes of the tree are aborted when the component is removed.
mixin HasBehaviorTree on Component {
  BehaviorTree? _behaviorTree;
  double _tickInterval = 0;
  double _accumulated = 0;
  bool _hasTicked = false;

  /// The behavior tree of this component.
  ///
  /// Throws a [StateError] if no tree has been set yet. Setting a new tree
  /// aborts the running nodes of the previous one.
  BehaviorTree get behaviorTree {
    final tree = _behaviorTree;
    if (tree == null) {
      throw StateError(
        'No behavior tree has been set on $this. Assign `behaviorTree` first.',
      );
    }
    return tree;
  }

  set behaviorTree(BehaviorTree tree) {
    _behaviorTree?.abort();
    _behaviorTree = tree;
    _accumulated = 0;
    _hasTicked = false;
  }

  /// The blackboard of the [behaviorTree], as a shortcut.
  Blackboard get blackboard => behaviorTree.blackboard;

  /// The minimum time, in seconds, between two ticks of the behavior tree.
  ///
  /// The default of 0 ticks the tree on every update. Negative values are
  /// treated as 0. This can be changed at any time.
  double get tickInterval => _tickInterval;
  set tickInterval(double interval) {
    _tickInterval = max(0, interval);
  }

  @override
  @mustCallSuper
  void update(double dt) {
    super.update(dt);

    final tree = _behaviorTree;
    if (tree == null) {
      return;
    }
    if (_tickInterval <= 0 || !_hasTicked) {
      _hasTicked = true;
      _accumulated = 0;
      tree.tick(dt);
      return;
    }

    _accumulated += dt;
    if (_accumulated >= _tickInterval) {
      final elapsed = _accumulated;
      _accumulated = 0;
      tree.tick(elapsed);
    }
  }

  @override
  @mustCallSuper
  void onRemove() {
    _behaviorTree?.abort();
    // A component that is mounted again starts with a tick, like a new one.
    _accumulated = 0;
    _hasTicked = false;
    super.onRemove();
  }
}
