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
        LifecycleEventStatus status;
        switch (event.kind) {
          case _LifecycleEventKind.add:
            status = child.handleLifecycleEventAdd(parent!);
            break;
          case _LifecycleEventKind.remove:
          default:
            throw UnsupportedError('Event ${event.kind} not supported');
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
