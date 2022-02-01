import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';

import '../../components/component.dart';
import 'game.dart';

/// This mixin is used to designate a class as a root of the component tree.
///
/// There should be only one [ComponentTreeRoot] in an application. Usually this
/// role is fulfilled by the `FlameGame`, so you rarely use this mixin directly.
///
/// The purpose of this mixin is to host common facilities for component
/// lifecycle management. These include: lifecycle event queues, and the canvas
/// size used during [Component.onGameResize].
///
/// In order to use this mixin in a custom [Game], do the following:
///   - add this mixin to your game class;
///   - set it as the default [Component.root];
///   - call [processComponentQueues] on every game tick.
mixin ComponentTreeRoot on Game {
  /// Global queues for adding children to components.
  ///
  /// The keys in this map are the parents, and the values are the queues of
  /// components that need to be added to the parents.
  ///
  /// When the user `add()`s a component to a parent, we immediately place it
  /// into the parent's queue, and only after that do the standard lifecycle
  /// processing: resizing, loading, mounting, etc. After all that is finished,
  /// the component is retrieved from the queue and placed into the parent's
  /// children list.
  ///
  /// Since the components are processed in the FIFO order, this ensures that
  /// they will be added to the parent in exactly the same order as the user
  /// invoked `add()`s, even though they are loading asynchronously and may
  /// finish loading in arbitrary order.
  final Map<Component, Queue<Component>> childrenQueue = {};

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
  Future<void> ready() async {
    while (childrenQueue.isNotEmpty) {
      // Give chance to other futures to execute first
      await Future<void>.delayed(const Duration());
      processComponentQueues();
    }
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
  }

  /// Enlist [child] to be added to [parent]'s `children` when the child becomes
  /// ready.
  @internal
  void enqueueChild({required Component parent, required Component child}) {
    assert(child.parent == parent);
    (childrenQueue[parent] ??= Queue()).add(child);
  }

  /// Attempt to resolve pending events in all lifecycle event queues.
  ///
  /// This method must be periodically invoked by the game engine, in order to
  /// ensure that the components get properly added/removed from the component
  /// tree.
  ///
  /// This method must not be called when iterating the component tree, as it
  /// may attempt to modify that tree, which would result in a "concurrent
  /// modification during iteration" error.
  void processComponentQueues() {
    _processChildrenQueue();
  }

  void _processChildrenQueue() {
    final numChildrenQueues = childrenQueue.length;
    for (final queue in childrenQueue.values) {
      while (queue.isNotEmpty) {
        final mounted = queue.first.tryMounting();
        if (mounted) {
          queue.removeFirst();
        } else {
          break;
        }
      }
      // Check if [childrenQueue] was modified, in which case we need to stop
      // iteration, or otherwise an exception will occur.
      if (childrenQueue.length != numChildrenQueues) {
        break;
      }
    }
    childrenQueue.removeWhere((parent, queue) => queue.isEmpty);
  }
}
