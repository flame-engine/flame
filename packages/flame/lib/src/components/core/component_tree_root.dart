import 'package:flame/components.dart';
import 'package:flame/src/components/core/recycled_queue.dart';
import 'package:meta/meta.dart';

/// **ComponentTreeRoot** is a component that can be used as a root node of a
/// component tree.
///
/// This class is just a regular [Component], with some additional
/// functionality, namely: it contains global lifecycle events for the component
/// tree.
class ComponentTreeRoot extends Component {
  ComponentTreeRoot({super.children})
      : _queue = RecycledQueue(_LifecycleEvent.new),
        _blocked = <int>{},
        _componentsToRebalance = <Component>{};

  final RecycledQueue<_LifecycleEvent> _queue;
  final Set<int> _blocked;
  final Set<Component> _componentsToRebalance;
  late final Map<ComponentKey, Component> _index = {};

  @internal
  void enqueueAdd(Component child, Component parent) {
    _queue.addLast()
      ..kind = _LifecycleEventKind.add
      ..child = child
      ..parent = parent;
  }

  @internal
  void dequeueAdd(Component child, Component parent) {
    for (final event in _queue) {
      if (event.kind == _LifecycleEventKind.add &&
          event.child == child &&
          event.parent == parent) {
        event.kind = _LifecycleEventKind.unknown;
        return;
      }
    }
    throw AssertionError(
      'Cannot find a lifecycle event Add(child=$child, parent=$parent)',
    );
  }

  @internal
  void enqueueRemove(Component child, Component parent) {
    _queue.addLast()
      ..kind = _LifecycleEventKind.remove
      ..child = child
      ..parent = parent;
  }

  @internal
  void dequeueRemove(Component child) {
    for (final event in _queue) {
      if (event.kind == _LifecycleEventKind.remove && event.child == child) {
        event.kind = _LifecycleEventKind.unknown;
      }
    }
  }

  @internal
  void enqueueMove(Component child, Component newParent) {
    _queue.addLast()
      ..kind = _LifecycleEventKind.move
      ..child = child
      ..parent = newParent;
  }

  @internal
  void enqueueRebalance(Component parent) {
    _componentsToRebalance.add(parent);
  }

  bool get hasLifecycleEvents => _queue.isNotEmpty;

  void processLifecycleEvents() {
    assert(_blocked.isEmpty);
    var repeatLoop = true;
    while (repeatLoop) {
      repeatLoop = false;
      for (final event in _queue) {
        final child = event.child!;
        final parent = event.parent!;
        if (_blocked.contains(identityHashCode(child)) ||
            _blocked.contains(identityHashCode(parent))) {
          continue;
        }
        var status = LifecycleEventStatus.done;
        switch (event.kind) {
          case _LifecycleEventKind.add:
            status = child.handleLifecycleEventAdd(parent);
            break;
          case _LifecycleEventKind.remove:
            status = child.handleLifecycleEventRemove(parent);
            break;
          case _LifecycleEventKind.move:
            status = child.handleLifecycleEventMove(parent);
            break;
          case _LifecycleEventKind.unknown:
            break;
        }
        switch (status) {
          case LifecycleEventStatus.done:
            _queue.removeCurrent();
            repeatLoop = true;
            break;
          case LifecycleEventStatus.block:
            _blocked.add(identityHashCode(child));
            _blocked.add(identityHashCode(parent));
            break;
          default:
            break;
        }
      }
      _blocked.clear();
    }
  }

  void processRebalanceEvents() {
    for (final component in _componentsToRebalance) {
      component.children.reorder();
    }
    _componentsToRebalance.clear();
  }

  @mustCallSuper
  @override
  @internal
  void handleResize(Vector2 size) {
    super.handleResize(size);
    _queue.forEach((event) {
      if ((event.kind == _LifecycleEventKind.add) &&
          (event.child!.isLoading || event.child!.isLoaded)) {
        event.child!.onGameResize(size);
      }
    });
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
enum LifecycleEventStatus {
  /// The event cannot be processed, move over to the next one.
  skip,

  /// Same as [skip], but also prevent processing of any other events for the
  /// same child or parent.
  block,

  /// The event was fully processed and can now be removed from the queue.
  done,
}

enum _LifecycleEventKind {
  unknown,
  add,
  remove,
  move,
}

class _LifecycleEvent implements Disposable {
  _LifecycleEventKind kind = _LifecycleEventKind.unknown;
  Component? child;
  Component? parent;

  @override
  void dispose() {
    kind = _LifecycleEventKind.unknown;
    child = null;
    parent = null;
  }

  @override
  String toString() {
    return 'LifecycleEvent.${kind.name}(child: $child, parent: $parent)';
  }
}
