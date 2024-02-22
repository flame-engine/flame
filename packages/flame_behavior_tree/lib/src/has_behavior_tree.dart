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
mixin HasBehaviorTree<T extends INode> on Component {
  T? _treeRoot;
  Timer? _timer;
  double _tickInterval = 0;

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

  /// The root node of the behavior tree.
  T get treeRoot => _treeRoot!;
  set treeRoot(T value) {
    _treeRoot = value;
    _timer?.onTick = _treeRoot!.tick;
  }

  @override
  @mustCallSuper
  Future<void> onLoad() async {
    super.onLoad();
    assert(_treeRoot != null, 'A treeRoot must be provided.');
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
