import 'dart:async';

import 'package:behavior_tree/behavior_tree.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

/// A mixin on [Component] to indicate that the component has a behavior tree.
///
/// Reference to the behavior tree for this component can be set or accessed
/// via [treeRoot]. The update frequency of the tree can be reduced by
/// increasing [tickInterval]. By default, the tree will be updated on every
/// update of the component.
///
/// An optional [blackboard] can be provided to share data between nodes in
/// the behavior tree. The blackboard is stored in this component and accessed
/// by nodes through their parent chain, so it doesn't need to be stored in
/// each node.
mixin HasBehaviorTree<T extends NodeInterface> on Component
    implements BlackboardProvider {
  T? _treeRoot;
  Timer? _timer;
  double _tickInterval = 0;
  Blackboard? _blackboard;

  /// The delay between any two ticks of the behavior tree.
  double get tickInterval => _tickInterval;
  set tickInterval(double interval) {
    _tickInterval = interval;

    if (_tickInterval > 0) {
      _timer ??= Timer(interval, repeat: true);
      _timer?.limit = interval;
    } else {
      _timer?.onTick = null;
      _timer = null;
      _tickInterval = 0;
    }
  }

  /// The blackboard for sharing data between nodes.
  ///
  /// If not set, nodes will receive null when they access the blackboard.
  /// Create a blackboard and assign it to enable data sharing:
  ///
  /// ```dart
  /// blackboard = Blackboard();
  /// blackboard.set('health', 100);
  /// ```
  ///
  /// The blackboard is stored in this component and accessed by nodes
  /// through their parent chain, eliminating the need to store it in each node.
  @override
  Blackboard? get blackboard => _blackboard;
  set blackboard(Blackboard? value) => _blackboard = value;

  /// The root node of the behavior tree.
  T get treeRoot => _treeRoot!;
  set treeRoot(T value) {
    _treeRoot = value;
    // Set this component as the blackboard provider for the root node
    if (value is BaseNode) {
      value.blackboardProvider = this;
    }
    _timer?.onTick = _treeRoot!.tick;
  }

  @override
  @mustCallSuper
  Future<void> onLoad() async {
    super.onLoad();
    _timer?.onTick = _treeRoot?.tick;
  }

  @override
  @mustCallSuper
  void update(double dt) {
    super.update(dt);
    if (_tickInterval > 0) {
      _timer?.update(dt);
    } else {
      _treeRoot?.tick();
    }
  }
}
