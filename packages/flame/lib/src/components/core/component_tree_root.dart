import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/components/core/recycled_queue.dart';
import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';

/// **ComponentTreeRoot** is a component that can be used as a root node of a
/// component tree.
///
/// This class is just a regular [Component], with some additional
/// functionality, namely: it contains global lifecycle events for the component
/// tree.
class ComponentTreeRoot extends Component {
  ComponentTreeRoot({super.children})
      : _queue = RecycledQueue(_LifecycleEvent.new),
        _blocked = <int>{};

  final RecycledQueue<_LifecycleEvent> _queue;
  final Set<int> _blocked;

  @internal
  void enqueueAdd(Component child, Component parent) {
    _queue.addLast()
      ..kind = _LifecycleEventKind.add
      ..child = child
      ..parent = parent;
  }

  bool get hasLifecycleEvents => _queue.isNotEmpty;

  void processLifecycleEvents() {
    assert(_blocked.isEmpty);
    var repeatLoop = true;
    while (repeatLoop) {
      repeatLoop = false;
      for (final event in _queue) {
        final child = event.child!;
        final parent = event.parent;
        if (_blocked.contains(identityHashCode(child)) ||
            _blocked.contains(identityHashCode(parent))) {
          continue;
        }
        switch (event.kind) {
          case _LifecycleEventKind.add:
            if (parent!.isMounted && child.isLoaded) {
              child.internalMount(parent: parent);
              _queue.removeCurrent();
            } else {
              if (parent.isMounted && !child.isLoading) {
                child.internalStartLoading();
              }
              _blocked.add(identityHashCode(child));
              _blocked.add(identityHashCode(parent));
            }
            break;
          case _LifecycleEventKind.remove:
            break;
          default:
            throw UnsupportedError('Event ${event.kind} not supported');
        }
      }
      _blocked.clear();
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _queue.forEach((event) {
      if ((event.kind == _LifecycleEventKind.add) &&
          (event.child!.isLoading || event.child!.isLoaded)) {
        event.child!.onGameResize(size);
      }
    });
  }
}

enum _LifecycleEventKind {
  unknown,
  add,
  remove,
  // reparent,
  // rebalance,
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
