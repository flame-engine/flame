import 'dart:collection';

import '../components/component.dart';

mixin FcsRoot {
  final Map<Component, Queue<Component>> childrenQueue = {};
  final Map<Component, Queue<Component>> addQueue = {};

  /// Ensure that all pending loading / tree operations finish.
  ///
  /// This is mainly intended for testing purposes: awaiting on this future
  /// ensures that the game is fully loaded, and that all pending operations
  /// of adding the components into the tree are fully materialized.
  Future<void> ready() {
    return Future.doWhile(() async {
      Component.processComponentQueues();
      return addQueue.isNotEmpty || childrenQueue.isNotEmpty;
    });
  }
}
