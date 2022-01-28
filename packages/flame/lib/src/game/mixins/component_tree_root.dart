import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';

import '../../components/component.dart';
import 'game.dart';

/// This mixin is used to designate a class as a root of the component tree.
///
/// There should be only one [ComponentTreeRoot] in an application. Usually this
/// role is fulfilled by the `FlameGame`, so this class is rarely used directly.
///
/// The purpose of this mixin is to collect common facilities for component
/// lifecycle management. These include: lifecycle event queues, and the canvas
/// size for [Component.onGameResize].
///
/// In order to use this mixin in a custom [Game], do the following:
///   - add this mixin to your game class;
///   - set it as the default [Component.root];
///   - call [processComponentQueues] on every game tick.
mixin ComponentTreeRoot on Game {
  final Map<Component, Queue<Component>> childrenQueue = {};
  final Queue<Component> mountQueue = Queue();

  /// Current size of the game widget.
  ///
  /// The [onGameResize] callback will keep this variable up-to-date whenever
  /// the size of the hosting widget changes.
  Vector2 get canvasSize => _canvasSize;
  final Vector2 _canvasSize = Vector2.zero();

  /// Ensure that all pending tree operations finish.
  ///
  /// This is mainly intended for testing purposes: awaiting on this future
  /// ensures that the game is fully loaded, and that all pending operations
  /// of adding the components into the tree are fully materialized.
  ///
  /// Warning: awaiting on a game that was not fully connected will result in an
  /// infinite loop. For example, this could occur if you run `x.add(y)` but
  /// then forget to mount `x` into the game.
  Future<void> ready() {
    return Future.doWhile(() async {
      processComponentQueues();
      return childrenQueue.isNotEmpty || mountQueue.isNotEmpty;
    });
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    canvasSize.setFrom(size);
    // Components that wait in the queues, still need to be informed about
    // changes in the game canvas size.
    childrenQueue.forEach((_, queue) {
      queue.forEach((c) => c.onGameResize(size));
    });
    mountQueue.forEach((c) => c.onGameResize(size));
  }

  /// Enlist [child] to be added to [parent]'s `children` when the child becomes
  /// ready.
  @internal
  void enqueueChild({required Component parent, required Component child}) {
    assert(child.parent == parent);
    (childrenQueue[parent] ??= Queue()).add(child);
  }

  @internal
  void enqueueMount(Component component) {
    mountQueue.add(component);
  }

  /// Attempts to resolve pending events in all lifecycle event queues.
  ///
  /// Must not be called when iterating the component tree.
  void processComponentQueues() {
    _processChildrenQueue();
    _processMountQueue();
  }

  void _processChildrenQueue() {
    final keysToRemove = <Component>[];
    childrenQueue.forEach((Component parent, Queue<Component> queue) {
      while (queue.isNotEmpty) {
        final x = queue.first;
        if (x.isReadyToMount) {
          queue.removeFirst();
          parent.children.addChild(x);
          x.isMounted = true;
        } else {
          break;
        }
      }
      if (queue.isEmpty) {
        keysToRemove.add(parent);
      }
    });
    keysToRemove.forEach(childrenQueue.remove);
  }

  void _processMountQueue() {
    if (mountQueue.isEmpty) {
      return;
    }
    var searchForMountCandidates = true;
    while (searchForMountCandidates) {
      searchForMountCandidates = false;
      // Find the first component eligible for mounting, and mount it. Then we
      // remove that element from the queue, and break out of loop because it's
      // illegal to continue iteration after modifying the queue.
      for (final component in mountQueue) {
        if (component.parent!.isMounted) {
          mountQueue.remove(component);
          component.mount();
          searchForMountCandidates = true;
          break;
        }
      }
    }
  }
}
