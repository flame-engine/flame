import 'dart:async';
import 'dart:collection';

import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';

import '../../components.dart';
import '../../game.dart';
import '../../input.dart';
import '../cache/value_cache.dart';

/// [Component]s are the basic building blocks for your game.
///
/// Components can be for example bullets flying on the screen, a spaceship, a
/// timer or an enemy. Anything that either needs to be rendered and/or updated
/// is a good idea to have as a [Component], since [update] and [render] will be
/// called automatically once the component is added to the component tree in
/// your game (with `game.add`).
class Component {
  Component({int? priority}) : _priority = priority ?? 0;

  /// What coordinate system this component should respect (i.e. should it
  /// observe camera, viewport, or use the raw canvas).
  ///
  /// Do note that this currently only works if the component is added directly
  /// to the root `FlameGame`.
  PositionType positionType = PositionType.game;

  var _state = LifecycleState.uninitialized;

  /// Whether this component has completed its [onLoad] step.
  bool get isLoaded {
    return (_state != LifecycleState.uninitialized) &&
        (_state != LifecycleState.loading);
  }

  /// Whether this component is currently added to a component tree.
  bool get isMounted {
    return (_state == LifecycleState.mounted) ||
        (_state == LifecycleState.removing);
  }

  /// The current parent of the component, or null if there is none.
  Component? get parent => _parent;
  Component? _parent;

  /// Returns the first child that matches the given type [T].
  ///
  /// As opposed to `children.whereType<T>().first`, this method returns null
  /// instead of a [StateError] when no matching children are found.
  T? firstChild<T extends Component>() {
    final it = children.whereType<T>().iterator;
    return it.moveNext() ? it.current : null;
  }

  /// Returns the last child that matches the given type [T].
  T? lastChild<T extends Component>() {
    final it = children.reversed().whereType<T>().iterator;
    return it.moveNext() ? it.current : null;
  }

  /// The children of the current component.
  ///
  /// This getter will automatically create the [ComponentSet] container within
  /// the current object if it didn't exist before. Check the [hasChildren]
  /// property in order to avoid instantiating the children container.
  ComponentSet get children => _children ??= createComponentSet();
  bool get hasChildren => _children?.isNotEmpty ?? false;
  ComponentSet? _children;

  Completer<void>? _mountCompleter;
  Completer<void>? _loadCompleter;

  @protected
  _LifecycleManager get lifecycle {
    return _lifecycleManager ??= _LifecycleManager(this);
  }

  _LifecycleManager? _lifecycleManager;

  /// Render priority of this component. This allows you to control the order in
  /// which your components are rendered.
  ///
  /// Components are always updated and rendered in the order defined by what
  /// this number is when the component is added to the game.
  /// The smaller the priority, the sooner your component will be
  /// updated/rendered.
  /// It can be any integer (negative, zero, or positive).
  /// If two components share the same priority, they will probably be drawn in
  /// the order they were added.
  ///
  /// Note that setting the priority is relatively expensive if the component is
  /// already added to a component tree since all siblings have to be re-added
  /// to the parent.
  int get priority => _priority;
  set priority(int newPriority) {
    if (parent == null) {
      _priority = newPriority;
    } else {
      parent!.children.changePriority(this, newPriority);
    }
  }

  int _priority;

  /// Whether this component should be removed or not.
  ///
  /// It will be checked once per component per tick, and if it is true,
  /// FlameGame will remove it.
  @nonVirtual
  bool get shouldRemove => _state == LifecycleState.removing;

  /// Setting [shouldRemove] to true will schedule the component to be removed
  /// from the game tree before the next game cycle.
  ///
  /// This property is equivalent to using the method [removeFromParent].
  @nonVirtual
  set shouldRemove(bool value) {
    assert(value, '"Resurrecting" a component is not allowed');
    removeFromParent();
  }

  /// Returns whether this [Component] is in debug mode or not.
  /// When a child is added to the [Component] it gets the same [debugMode] as
  /// its parent has when it is prepared.
  ///
  /// Returns `false` by default. Override it, or set it to true, to use debug
  /// mode.
  /// You can use this value to enable debug behaviors for your game and many
  /// components will
  /// show extra information on the screen when debug mode is activated.
  bool debugMode = false;

  /// How many decimal digits to print when displaying coordinates in the
  /// debug mode. Setting this to null will suppress all coordinates from
  /// the output.
  int? get debugCoordinatesPrecision => 0;

  /// The color that the debug output should be rendered with.
  Color debugColor = const Color(0xFFFF00FF);

  final ValueCache<Paint> _debugPaintCache = ValueCache<Paint>();
  final ValueCache<TextPaint> _debugTextPaintCache = ValueCache<TextPaint>();

  /// The [debugColor] represented as a [Paint] object.
  Paint get debugPaint {
    if (!_debugPaintCache.isCacheValid([debugColor])) {
      final paint = Paint()
        ..color = debugColor
        ..strokeWidth = 0 // hairline-width
        ..style = PaintingStyle.stroke;
      _debugPaintCache.updateCache(paint, [debugColor]);
    }
    return _debugPaintCache.value!;
  }

  /// Returns a [TextPaint] object with the [debugColor] set as color for the
  /// text.
  TextPaint get debugTextPaint {
    if (!_debugTextPaintCache.isCacheValid([debugColor])) {
      final textPaint = TextPaint(
        style: TextStyle(color: debugColor, fontSize: 12),
      );
      _debugTextPaintCache.updateCache(textPaint, [debugColor]);
    }
    return _debugTextPaintCache.value!;
  }

  //#region Component lifecycle methods

  /// Called whenever the size of the top-level Canvas changes.
  ///
  /// In addition, this method will be invoked once after the component is
  /// attached to the game tree, and before [onLoad] is called.
  @mustCallSuper
  void onGameResize(Vector2 size) => handleResize(size);

  @internal
  void handleResize(Vector2 size) {
    _children?.forEach((child) => child.onGameResize(size));
    _lifecycleManager?._children.forEach((child) {
      final state = child._state;
      if (state == LifecycleState.loading || state == LifecycleState.loaded) {
        child.onGameResize(size);
      }
    });
  }

  /// Late initialization method for [Component].
  ///
  /// Usually, this method is the main place where you initialize your
  /// component. This has several advantages over the traditional constructor:
  ///   - this method can be `async`;
  ///   - it is invoked when the size of the game canvas is already known.
  ///
  /// If your loading logic requires knowing the size of the game canvas, then
  /// add `HasGameRef` mixin and then query `gameRef.size` or
  /// `gameRef.canvasSize`.
  ///
  /// The default implementation returns `null`, indicating that there is no
  /// need to await anything. When overriding this method, you have a choice
  /// whether to create a regular or async function.
  ///
  /// If you need an asynchronous [onLoad], make your override return
  /// non-nullable `Future<void>`:
  /// ```dart
  /// @override
  /// Future<void> onLoad() async {
  ///   // your code here
  /// }
  /// ```
  ///
  /// Alternatively, if your [onLoad] function doesn't use any `await`ing, then
  /// you can declare it as a regular method and then return `null`:
  /// ```dart
  /// @override
  /// Future<void>? onLoad() {
  ///   // your code here
  ///   return null;
  /// }
  /// ```
  ///
  /// The engine ensures that this method will be called exactly once during
  /// the lifetime of the [Component] object. Do not call this method manually.
  Future<void>? onLoad() => null;

  /// A future that will complete once this component has finished loading.
  Future<void> get loaded {
    if (isLoaded) {
      return Future.value();
    }

    _loadCompleter ??= Completer<void>();

    return _loadCompleter!.future;
  }

  /// Called when the component is added to its parent.
  ///
  /// This method only runs when the component is fully loaded, i.e. after
  /// [onLoad]. However, [onLoad] only ever runs once for the component, whereas
  /// [onMount] runs every time the component is inserted into the game tree.
  ///
  /// This method runs when the component is about to be added to its parent.
  /// At this point the [parent] property already holds a reference to this
  /// component's parent, however the parent doesn't have this component among
  /// its [children] yet.
  ///
  /// After this method completes, the component is added to the parent's
  /// children set, and then the flag [isMounted] set to true.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void onMount() {
  ///   position = parent!.size / 2;
  /// }
  /// ```
  void onMount() {}

  /// Called right before the component is removed from the game.
  void onRemove() {}

  /// A future that will complete once the component is mounted on its parent
  Future<void> get mounted {
    if (isMounted) {
      return Future.value();
    }
    _mountCompleter ??= Completer<void>();
    return _mountCompleter!.future;
  }

  /// This method is called periodically by the game engine to request that your
  /// component updates itself.
  ///
  /// The time [dt] in seconds (with microseconds precision provided by Flutter)
  /// since the last update cycle.
  /// This time can vary according to hardware capacity, so make sure to update
  /// your state considering this.
  /// All components in the tree are always updated by the same amount. The time
  /// each one takes to update adds up to the next update cycle.
  void update(double dt) {}

  /// This method traverses the component tree and calls [update] on all its
  /// children according to their [priority] order, relative to the
  /// priority of the direct siblings, not the children or the ancestors.
  void updateTree(double dt) {
    _children?.updateComponentList();
    _lifecycleManager?.processQueues();
    update(dt);
    _children?.forEach((c) => c.updateTree(dt));
  }

  void render(Canvas canvas) {}

  void renderTree(Canvas canvas) {
    render(canvas);
    _children?.forEach((c) => c.renderTree(canvas));

    // Any debug rendering should be rendered on top of everything
    if (debugMode) {
      renderDebugMode(canvas);
    }
  }

  //#endregion

  void renderDebugMode(Canvas canvas) {}

  @protected
  Vector2 eventPosition(PositionInfo info) {
    switch (positionType) {
      case PositionType.game:
        return info.eventPosition.game;
      case PositionType.viewport:
        return info.eventPosition.viewport;
      case PositionType.widget:
        return info.eventPosition.widget;
    }
  }

  /// Remove the component from its parent in the next tick.
  void removeFromParent() {
    _parent?.remove(this);
  }

  /// Changes the current parent for another parent and prepares the tree under
  /// the new root.
  void changeParent(Component newParent) {
    newParent.lifecycle._adoption.add(this);
    _mountCompleter = null;
  }

  /// An iterator producing this component's parent, then its parent's parent,
  /// then the great-grand-parent, and so on, until it reaches a component
  /// without a parent.
  Iterable<Component> ancestors({bool includeSelf = false}) sync* {
    var current = includeSelf ? this : parent;
    while (current != null) {
      yield current;
      current = current.parent;
    }
  }

  /// Recursively enumerates all nested [children].
  ///
  /// The search is depth-first in preorder. In other words, it explores the
  /// first child completely before visiting the next sibling, and the root
  /// component is visited before its children.
  ///
  /// This ordering of descendants is considered standard in Flame: it is the
  /// same order in which the components will normally be updated and rendered
  /// on every game cycle. The optional parameter [reversed] allows iterating
  /// through the same set of descendants in reverse order.
  ///
  /// The [Iterable] produced by this method is "lazy", which means it will only
  /// traverse the component tree when required. This allows efficient chaining
  /// of various iterable methods, such as filtering, early stopping, folding,
  /// and so on -- see the documentation of the [Iterable] class for details.
  Iterable<Component> descendants({
    bool includeSelf = false,
    bool reversed = false,
  }) sync* {
    if (includeSelf && !reversed) {
      yield this;
    }
    if (hasChildren) {
      final childrenIterable = reversed ? children.reversed() : children;
      for (final child in childrenIterable) {
        yield* child.descendants(includeSelf: true, reversed: reversed);
      }
    }
    if (includeSelf && reversed) {
      yield this;
    }
  }

  //#region Add/remove components

  /// Schedules [component] to be added as a child to this component.
  ///
  /// This method is robust towards being called from any place in the user
  /// code: you can call it while iterating over the component tree, during
  /// mounting or async loading, when the Game object is already loaded or not.
  ///
  /// The cost of this flexibility is that the component won't be added right
  /// away. Instead, it will be placed into a queue, and then added later, after
  /// it has finished loading, but no sooner than on the next game tick.
  ///
  /// When multiple children are scheduled to be added to the same parent, we
  /// start loading all of them as soon as possible. Nevertheless, the children
  /// will end up being added to the parent in exactly the same order as they
  /// were originally scheduled by the user, regardless of how fast or slow
  /// each of them loads.
  ///
  /// A component can be added to a parent which may not be mounted to the game
  /// tree yet. In such case, the component will start loading immediately, but
  /// its mounting will be delayed until such time when the parent becomes
  /// mounted.
  ///
  /// This method returns a future that completes when the component is done
  /// loading, and mounting if the parent is currently mounted. However, this
  /// future will not guarantee that the component will become "fully mounted":
  /// it still needs to be added to the parent's children list, and that
  /// operation will only be done on the next game tick.
  ///
  /// A component can only be added to one parent at a time. It is an error to
  /// try to add it to multiple parents, or even to the same parent multiple
  /// times. If you need to change the parent of a component, use the
  /// [changeParent] method.
  Future<void>? add(Component component) => component.addToParent(this);

  /// A convenience method to [add] multiple children at once.
  Future<void> addAll(Iterable<Component> components) {
    final futures = <Future<void>>[];
    for (final component in components) {
      final future = add(component);
      if (future != null) {
        futures.add(future);
      }
    }
    return Future.wait(futures);
  }

  /// Adds this component to the provided [parent] (see [add] for details).
  Future<void>? addToParent(Component parent) {
    assert(
      _parent == null,
      '$this cannot be added to $parent because it already has a parent: '
      '$_parent',
    );
    assert(
      _state == LifecycleState.uninitialized ||
          _state == LifecycleState.removed,
    );
    _parent = parent;
    parent.lifecycle._children.add(this);

    if (!isLoaded) {
      final root = parent.findGame();
      if (root != null) {
        assert(
          root.hasLayout,
          'add() called before the game has a layout. Did you try to add '
          'components from the constructor? Use the onLoad() method instead.',
        );
        return _load();
      }
    }
    return null;
  }

  /// Removes a component from the component tree, calling [onRemove] for it and
  /// its children.
  void remove(Component component) {
    if (component._state != LifecycleState.removing) {
      lifecycle._removals.add(component);
      component._state = LifecycleState.removing;
    }
  }

  /// Removes all the children in the list and calls [onRemove] for all of them
  /// and their children.
  void removeAll(Iterable<Component> components) {
    components.forEach(remove);
  }

  Future<void>? _load() {
    assert(_parent != null);
    assert(_state == LifecycleState.uninitialized);
    _state = LifecycleState.loading;
    onGameResize(_parent!.findGame()!.canvasSize);
    final onLoadFuture = onLoad();
    if (onLoadFuture == null) {
      _state = LifecycleState.loaded;
    } else {
      return onLoadFuture.then((_) {
        _state = LifecycleState.loaded;
        _loadCompleter?.complete();
      });
    }
    return null;
  }

  /// Mount the component that is already loaded and has a mounted parent.
  ///
  /// The flag [existingChild] allows us to distinguish between components that
  /// are new versus those that are already children of their parents. The
  /// latter ones may exist if a parent was detached from the component tree,
  /// and later re-mounted. For these components we need to run [onGameResize]
  /// (since they haven't passed through [add]), but we don't have to add them
  /// to the parent's children because they are already there.
  void _mount({Component? parent, bool existingChild = false}) {
    _parent ??= parent;
    assert(_parent != null && _parent!.isMounted);
    assert(_state == LifecycleState.loaded || _state == LifecycleState.removed);
    if (existingChild || _state == LifecycleState.removed) {
      onGameResize(findGame()!.canvasSize);
    }
    _mountCompleter?.complete();
    _mountCompleter = null;
    debugMode |= _parent!.debugMode;
    onMount();
    _state = LifecycleState.mounted;
    if (!existingChild) {
      _parent!.children.add(this);
    }
    if (_children != null) {
      _children!.forEach(
        (child) => child._mount(parent: this, existingChild: true),
      );
    }
    _lifecycleManager?.processQueues();
  }

  // TODO(st-pasha): remove this after #1351 is done
  @internal
  void setMounted() => _state = LifecycleState.mounted;

  void _remove() {
    _parent!.children.remove(this);
    propagateToChildren(
      (Component component) {
        component.onRemove();
        component._state = LifecycleState.removed;
        component._parent = null;
        return true;
      },
      includeSelf: true,
    );
  }

  //#endregion

  bool get hasPendingLifecycleEvents {
    return _lifecycleManager?.hasPendingEvents ?? false;
  }

  /// Attempt to resolve any pending lifecycle events on this component.
  void processPendingLifecycleEvents() {
    if (_lifecycleManager != null) {
      _lifecycleManager!.processQueues();
      if (!_lifecycleManager!.hasPendingEvents) {
        _lifecycleManager = null;
      }
    }
  }

  @internal
  static Game? staticGameInstance;
  Game? findGame() {
    return staticGameInstance ??
        ((this is Game) ? (this as Game) : _parent?.findGame());
  }

  /// Whether the children list contains the given component.
  ///
  /// This method uses reference equality.
  bool contains(Component c) => _children?.contains(c) ?? false;

  /// Call this if any of this component's children priorities have changed
  /// at runtime.
  ///
  /// This will call [ComponentSet.rebalanceAll] on the [children] ordered set.
  void reorderChildren() => _children?.rebalanceAll();

  /// This method first calls the passed handler on the leaves in the tree,
  /// the children without any children of their own.
  /// Then it continues through all other children. The propagation continues
  /// until the handler returns false, which means "do not continue", or when
  /// the handler has been called with all children.
  ///
  /// This method is important to be used by the engine to propagate actions
  /// like rendering, taps, etc, but you can call it yourself if you need to
  /// apply an action to the whole component chain.
  /// It will only consider components of type T in the hierarchy,
  /// so use T = Component to target everything.
  bool propagateToChildren<T extends Component>(
    bool Function(T) handler, {
    bool includeSelf = false,
  }) {
    return descendants(reversed: true, includeSelf: includeSelf)
        .whereType<T>()
        .every(handler);
  }

  /// Returns the closest parent further up the hierarchy that satisfies type=T,
  /// or null if no such parent can be found.
  T? findParent<T extends Component>() {
    return (parent is T ? parent : parent?.findParent<T>()) as T?;
  }

  /// Called to check whether the point is to be counted as within the component
  /// It needs to be overridden to have any effect, like it is in
  /// PositionComponent.
  bool containsPoint(Vector2 point) => false;

  /// Usually this is not something that the user would want to call since the
  /// component list isn't re-ordered when it is called.
  /// See FlameGame.changePriority instead.
  void changePriorityWithoutResorting(int priority) => _priority = priority;

  /// `Component.childrenFactory` is the default method for creating children
  /// containers within all components. Replace this method if you want to have
  /// customized (non-default) [ComponentSet] instances in your project.
  static ComponentSetFactory childrenFactory = ComponentSet.createDefault;

  /// This method creates the children container for the current component.
  /// Override this method if you need to have a custom [ComponentSet] within
  /// a particular class.
  ComponentSet createComponentSet() => childrenFactory();
}

typedef ComponentSetFactory = ComponentSet Function();

/// This enum keeps track of the [Component]'s current stage in its lifecycle.
///
/// The progression between states happens as follows:
/// ```
///   uninitialized -> loading -> loaded -> mounted -> removing -> removed -.
///                                           ^-----------------------------'
/// ```
///
/// Publicly visible flags `isLoaded` and `isMounted` are derived from this
/// state:
///   - isLoaded = loaded | mounted | removed
///   - isMounted = mounted
enum LifecycleState {
  /// The original state of a [Component], when it was just constructed.
  uninitialized,

  /// The component is currently running its `onLoad` method.
  loading,

  /// The component has just finished running its `onLoad` step, but before it
  /// is mounted.
  loaded,

  /// The component has finished running its `onMount` step, and was added to
  /// its parent's `children` list.
  mounted,

  /// The component is scheduled to be removed on the next game tick.
  removing,

  /// The component which was mounted before, is now removed from its parent.
  removed,
}

/// Helper class to assist [Component] with its lifecycle.
///
/// Most lifecycle events -- add, remove, change parent -- live for a very short
/// period of time, usually until the next game tick. When such events are
/// resolved, there is no longer a need to carry around their supporting event
/// queues. Which is why these queues are placed into a separate class, so that
/// they can be easily disposed of at the end.
class _LifecycleManager {
  _LifecycleManager(this.owner);

  /// The component which is the owner of this [_LifecycleManager].
  final Component owner;

  /// Queue for adding children to a component.
  ///
  /// When the user `add()`s a child to a component, we immediately place it
  /// into that component's queue, and only after that do the standard lifecycle
  /// processing: resizing, loading, mounting, etc. After all that is finished,
  /// the child component is retrieved from the queue and placed into the
  /// children list.
  ///
  /// Since the components are processed in the FIFO order, this ensures that
  /// they will be added to the parent in exactly the same order as the user
  /// invoked `add()`s, even though they are loading asynchronously and may
  /// finish loading in arbitrary order.
  final Queue<Component> _children = Queue();

  /// Queue for removing children from a component.
  ///
  /// Components that were placed into this queue will be removed from [owner]
  /// when the pending events are resolved.
  final Queue<Component> _removals = Queue();

  /// Queue for moving components from another parent to this one.
  final Queue<Component> _adoption = Queue();

  bool get hasPendingEvents {
    return !(_children.isEmpty && _removals.isEmpty && _adoption.isEmpty);
  }

  void processQueues() {
    _processChildrenQueue();
    _processRemovalQueue();
    _processAdoptionQueue();
  }

  /// Attempt to resolve pending events in all lifecycle event queues.
  ///
  /// This method must be periodically invoked by the game engine, in order to
  /// ensure that the components get properly added/removed from the component
  /// tree.
  void _processChildrenQueue() {
    while (_children.isNotEmpty) {
      final child = _children.first;
      assert(child.parent!.isMounted);
      if (child.isLoaded) {
        child._mount();
        _children.removeFirst();
      } else if (child._state == LifecycleState.loading) {
        break;
      } else {
        child._load();
      }
    }
  }

  void _processRemovalQueue() {
    while (_removals.isNotEmpty) {
      final component = _removals.removeFirst();
      if (component.isMounted) {
        component._remove();
      }
      assert(component._state == LifecycleState.removed);
    }
  }

  void _processAdoptionQueue() {
    while (_adoption.isNotEmpty) {
      final child = _adoption.removeFirst();
      child._remove();
      child._parent = owner;
      child._mount();
    }
  }
}
