import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';

import '../components/component.dart';

mixin FcsRoot {
  final Map<Component, Queue<Component>> childrenQueue = {};
  final Map<Component, Queue<Component>> addQueue = {};

  Vector2 canvasSize = Vector2.zero();

  /// This method is called for every component before it is added to the
  /// component tree.
  /// It does preparation on a component before any update or render method is
  /// called on it.
  void prepareComponent(Component c) {}

  /// Ensure that all pending tree operations finish.
  ///
  /// This is mainly intended for testing purposes: awaiting on this future
  /// ensures that the game is fully loaded, and that all pending operations
  /// of adding the components into the tree are fully materialized.
  Future<void> ready() {
    return Future.doWhile(() async {
      processComponentQueues();
      return addQueue.isNotEmpty || childrenQueue.isNotEmpty;
    });
  }

  /// Must not be called when iterating the component tree.
  @internal
  void processComponentQueues() {
    _processAddQueue();
    _processChildrenQueue();
  }

  void _processAddQueue() {
    final keysToRemove = <Component>[];
    addQueue.forEach((Component parent, Queue<Component> queue) {
      if (parent.isMounted) {
        queue.forEach(parent.add);
        keysToRemove.add(parent);
      }
    });
    keysToRemove.forEach(addQueue.remove);
  }

  void _processChildrenQueue() {
    final keysToRemove = <Component>[];
    childrenQueue.forEach((Component parent, Queue<Component> queue) {
      while (queue.isNotEmpty) {
        final x = queue.first;
        if (x.isLoaded) {
          queue.removeFirst();
          x.onMount();
          parent.children.addInstant(x);
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
}
