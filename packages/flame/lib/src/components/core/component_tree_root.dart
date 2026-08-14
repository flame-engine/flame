part of 'component.dart';

/// **ComponentTreeRoot** is a component that can be used as a root node of a
/// component tree.
///
/// This class is just a regular [Component], with some additional
/// functionality, namely: it contains global lifecycle events for the component
/// tree.
class ComponentTreeRoot extends Component {
  ComponentTreeRoot({
    super.children,
    super.key,
  }) : queue = RecycledQueue(LifecycleEvent.new),
       _blocked = <Component>{};

  @internal
  final RecycledQueue<LifecycleEvent> queue;

  /// Components whose events are blocked during the current
  /// [processLifecycleEvents] pass. Compared by identity, since [Component]
  /// does not override equality.
  final Set<Component> _blocked;
  late final Map<ComponentKey, Component> _index = {};
  Completer<void>? _lifecycleEventsCompleter;
  Completer<void>? _lifecycleEventMutationCompleter;

  /// A future that completes the next time the lifecycle event queue is
  /// mutated: when a new event is enqueued or an existing event is cancelled.
  ///
  /// This is used by `FlameGame.ready` to re-evaluate the queue when it is
  /// changed by something other than a component finishing its load, for
  /// example when a component is removed while it is still loading.
  @internal
  Future<void> get nextLifecycleEventMutation =>
      (_lifecycleEventMutationCompleter ??= Completer<void>()).future;

  void _notifyLifecycleEventMutation() {
    if (_lifecycleEventMutationCompleter != null) {
      _lifecycleEventMutationCompleter!.complete();
      _lifecycleEventMutationCompleter = null;
    }
  }

  void _enqueueAdd(Component child, Component parent) {
    queue.addLast()
      ..kind = LifecycleEventKind.add
      ..child = child
      ..parent = parent;
    _notifyLifecycleEventMutation();
  }

  /// Cancels the pending ADD event for [child] into [parent].
  ///
  /// Scans the queue without using its iterator, so this is safe to call while
  /// [processLifecycleEvents] is iterating over the queue (for example from a
  /// component's [Component.onMount]).
  void _dequeueAdd(Component child, Component parent) {
    var found = false;
    queue.forEachWhere(
      (event) =>
          !found &&
          event.kind == LifecycleEventKind.add &&
          event.child == child &&
          event.parent == parent,
      (event) {
        event.kind = LifecycleEventKind.unknown;
        found = true;
      },
    );
    if (!found) {
      throw AssertionError(
        'Cannot find a lifecycle event Add(child=$child, parent=$parent)',
      );
    }
    _notifyLifecycleEventMutation();
  }

  void _enqueueRemove(Component child, Component parent) {
    queue.addLast()
      ..kind = LifecycleEventKind.remove
      ..child = child
      ..parent = parent;
    _notifyLifecycleEventMutation();
  }

  /// Cancels all pending REMOVE events for [child].
  ///
  /// Scans the queue without using its iterator, so this is safe to call while
  /// [processLifecycleEvents] is iterating over the queue (for example from a
  /// component's [Component.onMount]).
  void _dequeueRemove(Component child) {
    var dequeuedAny = false;
    queue.forEachWhere(
      (event) =>
          event.kind == LifecycleEventKind.remove && event.child == child,
      (event) {
        event.kind = LifecycleEventKind.unknown;
        dequeuedAny = true;
      },
    );
    if (dequeuedAny) {
      _notifyLifecycleEventMutation();
    }
  }

  /// Finds all children in [candidates] that have a pending REMOVE event,
  /// cancels those events, and adds the matched children to [result].
  ///
  /// Scans the queue once in O(Q) time. Safe to call during queue iteration.
  void _cancelQueuedRemoves(
    List<Component> candidates,
    Set<Component> result,
  ) {
    final candidateSet = candidates.toSet();
    queue.forEachWhere(
      (event) =>
          event.kind == LifecycleEventKind.remove &&
          candidateSet.contains(event.child),
      (event) {
        result.add(event.child!);
        event.kind = LifecycleEventKind.unknown;
      },
    );
    if (result.isNotEmpty) {
      _notifyLifecycleEventMutation();
    }
  }

  void _enqueueMove(Component child, Component newParent) {
    queue.addLast()
      ..kind = LifecycleEventKind.move
      ..child = child
      ..parent = newParent;
    _notifyLifecycleEventMutation();
  }

  void _enqueuePriorityChange(
    Component parent,
    Component child,
  ) {
    queue.addLast()
      ..kind = LifecycleEventKind.rebalance
      ..child = child
      ..parent = parent;
    _notifyLifecycleEventMutation();
  }

  bool get hasLifecycleEvents => queue.isNotEmpty;

  /// The flattened pre-order list of all components below this root, stopping
  /// at (and including) `CustomTraversal` barriers, whose subtrees are
  /// traversed by their own `updateSubtree` implementations.
  final List<Component> _flatUpdateList = [];

  /// The [ComponentList._structureVersion] that [_flatUpdateList] was built
  /// against.
  int _flatVersion = -1;

  /// Updates every component below this root using the flattened traversal
  /// list, rebuilding the list first when the tree structure has possibly
  /// changed since the previous tick.
  ///
  /// The visit order is identical to the recursive
  /// standard traversal: pre-order, children in
  /// priority order. Components mixing in `CustomTraversal` are treated as
  /// barriers: they appear in the list themselves, and their `updateSubtree`
  /// drives their subtree.
  @internal
  void updateChildrenFlat(double dt) {
    if (_flatVersion != ComponentList._structureVersion) {
      // The version is captured before the pass: structural changes made by
      // update callbacks (pause toggles, detached-tree edits) invalidate the
      // list that is being built and must trigger a rebuild next tick.
      _flatVersion = ComponentList._structureVersion;
      _flatUpdateList.clear();
      _updateAndFlattenInto(_flatUpdateList, dt);
    } else {
      Component._updateFlatList(_flatUpdateList, dt);
    }
  }

  /// A future that will complete once all lifecycle events have been
  /// processed.
  ///
  /// If there are no lifecycle events to be processed ([hasLifecycleEvents]
  /// is `false`), then this future returns immediately.
  ///
  /// This is useful when you modify the component tree
  /// (by adding, moving or removing a component) and you want to make sure
  /// you react to the changed state, not the current one.
  /// Remember, methods like [Component.add] don't act immediately and instead
  /// enqueue their action. They are synchronous and return nothing, so the
  /// action cannot be awaited directly. To wait for a specific component, await
  /// its [Component.loaded], [Component.mounted] or [Component.removed] future;
  /// to wait for the whole queue to drain, await this future.
  ///
  /// Don't await this from inside a component's [Component.onLoad]: that
  /// component's own mount is part of the queue, and it can only be processed
  /// after [Component.onLoad] has completed, so the wait would deadlock. Await
  /// the child's [Component.loaded] future there instead.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// player.inventory.addAll(enemy.inventory.children);
  /// await game.lifecycleEventsProcessed;
  /// updateUi(player.inventory);
  /// ```
  Future<void> get lifecycleEventsProcessed {
    return !hasLifecycleEvents
        ? Future.value()
        : (_lifecycleEventsCompleter ??= Completer<void>()).future;
  }

  void processLifecycleEvents() {
    if (!hasLifecycleEvents) {
      assert(
        _lifecycleEventsCompleter == null,
        'The completer is only ever created while events are queued, so it '
        'should never exist while the queue is empty',
      );
      return;
    }
    // reorder events to process later grouped by parent
    Set<Component>? reorderParents;
    _LifecycleEventStatus handleReorderEvent(Component parent) {
      (reorderParents ??= {}).add(parent);
      return _LifecycleEventStatus.done;
    }

    assert(_blocked.isEmpty);
    var repeatLoop = true;
    while (repeatLoop) {
      repeatLoop = false;
      for (final event in queue) {
        final child = event.child!;
        final parent = event.parent!;
        if (_blocked.contains(child) || _blocked.contains(parent)) {
          continue;
        }

        final status = switch (event.kind) {
          LifecycleEventKind.add => child._handleLifecycleEventAdd(parent),
          LifecycleEventKind.remove => child._handleLifecycleEventRemove(
            parent,
          ),
          LifecycleEventKind.move => child._handleLifecycleEventMove(parent),
          LifecycleEventKind.rebalance => handleReorderEvent(parent),
          LifecycleEventKind.unknown => _LifecycleEventStatus.done,
        };

        switch (status) {
          case _LifecycleEventStatus.done:
            queue.removeCurrent();
            repeatLoop = true;
          case _LifecycleEventStatus.block:
            _blocked.add(child);
            _blocked.add(parent);
        }
      }
      _blocked.clear();
    }

    for (final parent in reorderParents ?? const <Component>{}) {
      parent.rebalanceChildren();
    }

    if (!hasLifecycleEvents && _lifecycleEventsCompleter != null) {
      _lifecycleEventsCompleter!.complete();
      _lifecycleEventsCompleter = null;
    }
  }

  @mustCallSuper
  @override
  @internal
  void handleResize(Vector2 size) {
    super.handleResize(size);
    queue.forEachWhere(
      _isPendingAddOfLoadingOrLoadedChild,
      (event) => event.child!.onGameResize(size),
    );
  }

  @mustCallSuper
  @override
  @internal
  void handleHotReload() {
    super.handleHotReload();
    queue.forEachWhere(
      _isPendingAddOfLoadingOrLoadedChild,
      (event) => event.child!.onHotReload(),
    );
  }

  static bool _isPendingAddOfLoadingOrLoadedChild(LifecycleEvent event) {
    return event.kind == LifecycleEventKind.add &&
        (event.child!.isLoading || event.child!.isLoaded);
  }

  @mustCallSuper
  @internal
  void registerKey(ComponentKey key, Component component) {
    assert(!_index.containsKey(key), 'Key $key is already registered');
    _index[key] = component;
  }

  @mustCallSuper
  @internal
  void unregisterKey(ComponentKey key) {
    _index.remove(key);
  }

  T? findByKey<T extends Component>(ComponentKey key) {
    final component = _index[key];
    return component as T?;
  }

  T? findByKeyName<T extends Component>(String name) {
    return findByKey(ComponentKey.named(name));
  }
}

/// The status of processing a Lifecycle event.
enum _LifecycleEventStatus {
  /// The event cannot be processed yet: move over to the next one, and skip
  /// any other events for the same child or parent in this pass.
  block,

  /// The event was fully processed and can now be removed from the queue.
  done,
}

@internal
enum LifecycleEventKind {
  unknown,
  add,
  remove,
  move,
  rebalance,
}

@visibleForTesting
class LifecycleEvent implements Disposable {
  LifecycleEventKind kind = LifecycleEventKind.unknown;
  Component? child;
  Component? parent;

  @override
  void dispose() {
    kind = LifecycleEventKind.unknown;
    child = null;
    parent = null;
  }

  @override
  String toString() {
    return 'LifecycleEvent.${kind.name}(child: $child, parent: $parent)';
  }
}
