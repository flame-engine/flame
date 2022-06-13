import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flame/src/cache/value_cache.dart';
import 'package:flame/src/components/component_set.dart';
import 'package:flame/src/components/mixins/coordinate_transform.dart';
import 'package:flame/src/components/position_type.dart';
import 'package:flame/src/game/flame_game.dart';
import 'package:flame/src/game/mixins/game.dart';
import 'package:flame/src/gestures/events.dart';
import 'package:flame/src/text/text_paint.dart';
import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';

/// [Component]s are the basic building blocks for a [FlameGame].
///
/// Components are quite similar to widgets in Flutter, or to GameObjects in
/// Unity. Any entity within the game can be represented as a Component,
/// especially if that entity has some visual appearance, or if it changes over
/// time. For example, the player, the enemies, flying bullets, clouds in the
/// sky, buildings, rocks, etc -- all can be represented as components. Some
/// components may also represent more abstract entities: effects, behaviors,
/// data stores, groups.
///
/// Components are designed to be organized into a component tree, where every
/// component belongs to a single parent and owns any number of children
/// components. A [Component] must be added to the component tree in order for
/// it to become fully operational. Typically, the [FlameGame] is the root of
/// the component tree.
///
/// The components are added into the component tree using the [add] method, or
/// [addToParent]; and then later can be removed using [remove] or
/// [removeFromParent]. Note that neither adding nor removing are immediate,
/// typically these operations complete by the next game tick.
///
/// Each component goes through several lifecycle stages during its lifetime,
/// at each stage invoking certain user-defined "lifecycle methods":
///  - [onGameResize] when the component is first added into the tree;
///  - [onLoad] immediately after;
///  - [onMount] when done loading;
///  - [onRemove] if the component is later removed from the component tree.
///
/// The [onLoad] is only invoked once during the lifetime of the component,
/// which means you can treat it as "async constructor". When [onLoad] is
/// invoked, we guarantee that the game instance can be found via [findGame],
/// and that this game instance already has layout (i.e. knows the size of the
/// canvas).
///
/// The [onMount] is invoked when the component is done loading, and when its
/// parent is properly mounted. If a component is removed from the tree and
/// later added to another component, the [onMount] will be called again. For
/// every call to [onMount] there will be a corresponding call to [onRemove].
///
/// While the component is mounted, the following user-overridable methods are
/// invoked:
///  - [update] on every game tick;
///  - [render] after all components are done updating;
///  - [updateTree] and [renderTree] are more advanced versions of the update
///    and render callbacks, but they rarely need to be overridden by the user;
///  - [onGameResize] every time the size game's Flutter widget changes.
///
/// The [update] and [render] are two most important methods of the component's
/// lifecycle. On every game tick, first the entire component tree will be
/// [update]d, and then all the components will be [render]ed.
///
/// You may also need to override [containsLocalPoint] if the component needs to
/// respond to tap events or similar; the [componentsAtPoint] may also need to
/// be overridden if you have reimplemented [renderTree].
class Component {
  Component({Iterable<Component>? children, int? priority})
      : _priority = priority ?? 0 {
    if (children != null) {
      addAll(children);
    }
  }

  //#region Lifecycle state

  /// Bitfield which keeps track of the current state of the component: which
  /// lifecycle events it has already executed, and which are currently being
  /// executed.
  ///
  /// [_initial]: the original state of the component as it was just created. In
  ///     this state no events has occurred so far.
  ///
  /// [_loading]: this flag is set while the component is running its [onLoad]
  ///     method, and can be checked via [isLoading] getter. More specifically,
  ///     this bit is set before invoking [onGameResize], it is on for the
  ///     duration of [onLoad], and then it is turned off when the component is
  ///     about to be mounted. After that, the bit is never turned on again.
  ///
  /// [_loaded]: this flag is set after the component finishes running its
  ///     [onLoad] method, and can be checked via the [isLoaded] getter. Once
  ///     set, this bit is never turned off.
  ///
  /// [_mounted]: this flag is set when the component becomes properly mounted
  ///     to the component tree, and then turned off when the component is
  ///     removed from the tree.
  ///
  /// [_removing]: this bit indicates that the component is scheduled for
  ///     removal at the earliest possible opportunity, and then cleared when
  ///     the component is actually removed.
  ///
  /// The lifecycle process of a component is quite complicated. This happens
  /// for several reasons: partly because it consists of several stages, between
  /// which there are asynchronous or even physical execution gaps. In addition,
  /// the lifecycle invokes a number of user-provided callbacks, and those
  /// callbacks may attempt to modify the component.
  ///
  /// This is how a typical component's lifecycle progresses:
  ///  - First, the component is created with the [_state] variable = 0. At this
  ///    point the only operations that can be done are: to [add] it to another
  ///    component, or to add other components to it.
  ///  - When the component is [add]ed to another component (the parent), we do
  ///    the following:
  ///    - set the [_parent] variable;
  ///    - add the component to the parent's queue of pending children;
  ///    - if the component has been [_loaded] before, then do nothing else and
  ///      wait until its parent will do the mounting.
  ///    - otherwise, if the [Game] instance is accessible via [findGame], then
  ///      we start loading the component;
  ///    - otherwise we will start loading when the parent becomes mounted. This
  ///      means we're entering into an execution gap here. During this gap the
  ///      component is still in the [_initial] state, and it can be [remove]d
  ///      by the user. When the user removes the component in this state, we
  ///      simply set the [_parent] to null and remove it from the parent's
  ///      queue of pending children.
  ///  - When we [_startLoading] the component, we set the [_loading] bit,
  ///    invoke the [onGameResize] callback, and then [onLoad] immediately
  ///    afterwards. The onLoad will be either sync or async, in both cases we
  ///    arrange to turn on the [_loaded] bit at the end of [onLoad]'s run.
  ///  - At this point we're in an execution gap: either the async [onLoad] is
  ///    waiting to be run, or it already completed, or it was sync to begin
  ///    with -- in either case we're waiting until the component can be
  ///    mounted, and in that time the [_loading] bit is still on.
  ///    During this time the user may request to [remove] the component. If at
  ///    that moment the component is already loaded, then we remove it by
  ///    setting parent to null and deleting it from the parent's pending
  ///    children queue. If, on the other hand, the component is not loaded yet,
  ///    then we turn on the [_removing] flag only -- this is because we don't
  ///    want to set [_parent] to null while the [onLoad] may still try to
  ///    access it.
  ///  - The next step in the component's lifecycle comes when its parent
  ///    processes own pending events queue, which only happens after the parent
  ///    gets mounted. For each component in its queue of pending children, the
  ///    following checks are performed:
  ///      - if the component is already [_loaded], then it will now be
  ///        [_mount]ed;
  ///      - otherwise, if the component is not even [_loading], then it will
  ///        now [_startLoading];
  ///      - otherwise do nothing: need to wait until the component finishes
  ///        loading.
  ///  - During [_mount]ing, we perform the following sequence:
  ///      - first check whether we need to run [onGameResize] -- this could
  ///        happen if mounting a component that was  added to the game earlier
  ///        and then removed;
  ///      - check if the component was scheduled for removal while waiting in
  ///        the queue -- if so, remove it immediately without mounting;
  ///      - clear the [_loading] flag and start the [onMount] callback;
  ///      - set the [_mounted] bit;
  ///      - add the component to parent's list of [children];
  ///      - if the component has its own list of existing children, then mount
  ///        those;
  ///      - if the component has a list of pending children, then process the
  ///        lifecycle events queue, which would attempt to load and/or mount
  ///        these pending children.
  ///
  /// At this point the component would be at its normal, mounted state. When
  /// [remove] is invoked in this state, we (1) turn on the [_removing] bit, and
  /// (2) add the component to the "removals" lifecycle queue of its parent. The
  /// next time the parent processes its lifecycle event queue, it would take
  /// all the components from the "removals", and for each one call the
  /// [onRemove] method, clear the [_mounted] and [_removing] flags, and lastly
  /// remove the component from the official list of children.
  ///
  /// After a component was removed, it will be [_loaded], but not [_mounted],
  /// and its [_parent] will be null. Such component can be re-added into the
  /// component tree if needed.
  int _state = _initial;

  static const int _initial = 0;
  static const int _loading = 1;
  static const int _loaded = 2;
  static const int _mounted = 4;
  static const int _removing = 8;

  /// Whether the component is currently executing its [onLoad] step.
  bool get isLoading => (_state & _loading) != 0;
  void _setLoadingBit() => _state |= _loading;
  void _clearLoadingBit() => _state &= ~_loading;

  /// Whether this component has completed its [onLoad] step.
  bool get isLoaded => (_state & _loaded) != 0;
  void _setLoadedBit() => _state |= _loaded;

  /// Whether this component is currently added to a component tree.
  bool get isMounted => (_state & _mounted) != 0;
  void _setMountedBit() => _state |= _mounted;
  void _clearMountedBit() => _state &= ~_mounted;

  /// Whether the component is scheduled to be removed.
  bool get isRemoving => (_state & _removing) != 0;
  void _setRemovingBit() => _state |= _removing;
  void _clearRemovingBit() => _state &= ~_removing;

  /// A future that completes when this component finishes loading.
  ///
  /// If the component is already loaded (see [isLoaded]), this returns an
  /// already completed future.
  Future<void> get loaded => isLoaded ? Future.value() : lifecycle.loadFuture;

  /// A future that will complete once the component is mounted on its parent.
  ///
  /// If the component is already mounted (see [isMounted]), this returns an
  /// already completed future.
  Future<void> get mounted =>
      isMounted ? Future.value() : lifecycle.mountFuture;

  //#endregion

  //#region Component tree

  /// Who owns this component in the component tree.
  ///
  /// This can be null if the component hasn't been added to the component tree
  /// yet, or if it is the root of component tree.
  ///
  /// Setting this property is equivalent to the [changeParent] method, or to
  /// [removeFromParent] if setting to null.
  Component? get parent => _parent;
  Component? _parent;
  set parent(Component? newParent) {
    if (newParent == null) {
      removeFromParent();
    } else if (_parent == null) {
      addToParent(newParent);
    } else {
      newParent.lifecycle._adoption.add(this);
    }
  }

  /// The children components of this component.
  ///
  /// This getter will automatically create the [ComponentSet] container within
  /// the current object if it didn't exist before. Check the [hasChildren]
  /// property in order to avoid instantiating the children container.
  ComponentSet get children => _children ??= createComponentSet();
  bool get hasChildren => _children?.isNotEmpty ?? false;
  ComponentSet? _children;

  /// `Component.childrenFactory` is the default method for creating children
  /// containers within all components. Replace this method if you want to have
  /// customized (non-default) [ComponentSet] instances in your project.
  static ComponentSetFactory childrenFactory = ComponentSet.new;

  /// This method creates the children container for the current component.
  /// Override this method if you need to have a custom [ComponentSet] within
  /// a particular class.
  ComponentSet createComponentSet() => childrenFactory();

  /// Returns the closest parent further up the hierarchy that satisfies type=T,
  /// or null if no such parent can be found.
  T? findParent<T extends Component>() {
    return ancestors().whereType<T>().firstOrNull;
  }

  /// Returns the first child that matches the given type [T], or null if there
  /// are no such children.
  T? firstChild<T extends Component>() {
    return children.whereType<T>().firstOrNull;
  }

  /// Returns the last child that matches the given type [T], or null if there
  /// are no such children.
  T? lastChild<T extends Component>() {
    return children.reversed().whereType<T>().firstOrNull;
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

  //#endregion

  //#region Component lifecycle methods

  /// Called whenever the size of the top-level Canvas changes.
  ///
  /// In addition, this method will be invoked once after the component is
  /// attached to the game tree, and before [onLoad] is called.
  @mustCallSuper
  void onGameResize(Vector2 size) => handleResize(size);

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
  ///
  /// See also:
  /// - [onRemove] that is called every time the component is removed from the
  /// game tree
  void onMount() {}

  /// Called right before the component is removed from the game.
  ///
  /// This method will only run for a component that was previously mounted into
  /// a component tree. If a component was never mounted (for example, when it
  /// is removed before it had a chance to mount), then this callback will not
  /// trigger. Thus, [onRemove] runs if and only if there was a corresponding
  /// [onMount] call before.
  void onRemove() {}

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

  /// Adds this component as a child of [parent] (see [add] for details).
  Future<void>? addToParent(Component parent) {
    assert(
      _parent == null,
      '$this cannot be added to $parent because it already has a parent: '
      '$_parent',
    );
    _parent = parent;
    parent.lifecycle._children.add(this);
    if (!isLoaded && (parent.findGame()?.hasLayout ?? false)) {
      return _startLoading();
    }
    return null;
  }

  /// Removes a component from the component tree.
  ///
  /// This will call [onRemove] for the component and its children, but only if
  /// there was an [onMount] call previously, i.e. when removing a component
  /// that was properly mounted.
  ///
  /// A component can be removed even before it finishes mounting, however such
  /// component cannot be added back into the tree until it at least finishes
  /// loading.
  void remove(Component component) {
    assert(
      component._parent != null,
      "Trying to remove a component that doesn't belong to any parent",
    );
    assert(
      component._parent == this,
      'Trying to remove a component that belongs to a different parent: this = '
      "$this, component's parent = ${component._parent}",
    );
    if (component._state == _initial) {
      lifecycle._children.remove(component);
      component._parent = null;
    } else if (component.isLoading) {
      if (component.isLoaded) {
        component._parent = null;
        lifecycle._children.remove(component);
        component._clearLoadingBit();
      } else {
        component._setRemovingBit();
      }
    } else if (!component.isRemoving) {
      lifecycle._removals.add(component);
      component._setRemovingBit();
    }
  }

  /// Removes all the children in the list and calls [onRemove] for all of them
  /// and their children.
  void removeAll(Iterable<Component> components) {
    components.forEach(remove);
  }

  /// Remove the component from its parent in the next tick.
  void removeFromParent() {
    _parent?.remove(this);
  }

  /// Changes the current parent for another parent and prepares the tree under
  /// the new root.
  void changeParent(Component newParent) {
    parent = newParent;
  }

  //#endregion

  //#region Hit Testing

  /// Checks whether the [point] is within this component's bounds.
  ///
  /// This method should be implemented for any component that has a visual
  /// representation and non-zero size. The [point] is in the local coordinate
  /// space.
  bool containsLocalPoint(Vector2 point) => false;

  /// Same as [containsLocalPoint], but for a "global" [point].
  ///
  /// This will be deprecated in the future, due to the notion of "global" point
  /// not being well-defined.
  bool containsPoint(Vector2 point) => containsLocalPoint(point);

  /// An iterable of descendant components intersecting the given point. The
  /// [point] is in the local coordinate space.
  ///
  /// More precisely, imagine a ray originating at a certain point (x, y) on
  /// the screen, and extending perpendicularly to the screen's surface into
  /// your game's world. The purpose of this method is to find all components
  /// that intersect with this ray, in the order from those that are closest to
  /// the user to those that are farthest.
  ///
  /// The return value is an [Iterable] of components. If the [nestedPoints]
  /// parameter is given, then it will also report the points of intersection
  /// for each component in its local coordinate space. Specifically, the last
  /// element in the list is the point in the coordinate space of the returned
  /// component, the element before the last is in that component's parent's
  /// coordinate space, and so on. The [nestedPoints] list must be growable and
  /// modifiable.
  ///
  /// The default implementation relies on the [CoordinateTransform] interface
  /// to translate from the parent's coordinate system into the local one. Make
  /// sure that your component implements this interface if it alters the
  /// coordinate system when rendering.
  ///
  /// If your component overrides [renderTree], then it almost certainly needs
  /// to override this method as well, so that this method can find all rendered
  /// components wherever they are.
  Iterable<Component> componentsAtPoint(
    Vector2 point, [
    List<Vector2>? nestedPoints,
  ]) sync* {
    nestedPoints?.add(point);
    if (_children != null) {
      for (final child in _children!.reversed()) {
        Vector2? childPoint = point;
        if (child is CoordinateTransform) {
          childPoint = (child as CoordinateTransform).parentToLocal(point);
        }
        if (childPoint != null) {
          yield* child.componentsAtPoint(childPoint, nestedPoints);
        }
      }
    }
    if (containsLocalPoint(point)) {
      yield this;
    }
    nestedPoints?.removeLast();
  }

  //#endregion

  //#region Priority

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
  int _priority;
  set priority(int newPriority) {
    if (parent == null) {
      _priority = newPriority;
    } else {
      parent!.children.changePriority(this, newPriority);
    }
  }

  /// Usually this is not something that the user would want to call since the
  /// component list isn't re-ordered when it is called.
  /// See FlameGame.changePriority instead.
  void changePriorityWithoutResorting(int priority) => _priority = priority;

  /// Call this if any of this component's children priorities have changed
  /// at runtime.
  ///
  /// This will call [ComponentSet.rebalanceAll] on the [children] ordered set.
  void reorderChildren() => _children?.rebalanceAll();

  //#endregion

  //#region Internal lifecycle management

  @protected
  _LifecycleManager get lifecycle {
    return _lifecycleManager ??= _LifecycleManager(this);
  }

  _LifecycleManager? _lifecycleManager;

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
  void handleResize(Vector2 size) {
    _children?.forEach((child) => child.onGameResize(size));
    _lifecycleManager?._children.forEach((child) {
      if (child.isLoading || child.isLoaded) {
        child.onGameResize(size);
      }
    });
  }

  Future<void>? _startLoading() {
    assert(_state == _initial);
    assert(_parent != null);
    assert(_parent!.findGame() != null);
    assert(_parent!.findGame()!.hasLayout);
    _setLoadingBit();
    onGameResize(_parent!.findGame()!.canvasSize);
    final onLoadFuture = onLoad();
    if (onLoadFuture == null) {
      _finishLoading();
      return null;
    } else {
      return onLoadFuture.then((_) => _finishLoading());
    }
  }

  void _finishLoading() {
    _setLoadedBit();
    _lifecycleManager?.finishLoading();
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
    assert(isLoaded);
    if (existingChild || !isLoading) {
      onGameResize(findGame()!.canvasSize);
    }
    _clearLoadingBit();
    if (isRemoving) {
      _parent = null;
      _clearRemovingBit();
      return;
    }
    debugMode |= _parent!.debugMode;
    onMount();
    _setMountedBit();
    _lifecycleManager?.finishMounting();
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
  void setMounted() {
    _setLoadedBit();
    _setMountedBit();
  }

  void _remove() {
    _parent!.children.remove(this);
    propagateToChildren(
      (Component component) {
        component.onRemove();
        component._clearMountedBit();
        component._clearRemovingBit();
        component._parent = null;
        return true;
      },
      includeSelf: true,
    );
  }

  //#endregion

  //#region Debugging assistance

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

  void renderDebugMode(Canvas canvas) {}

  //#endregion

  //#region Legacy component placement overrides

  /// What coordinate system this component should respect (i.e. should it
  /// observe camera, viewport, or use the raw canvas).
  ///
  /// Do note that this currently only works if the component is added directly
  /// to the root `FlameGame`.
  PositionType positionType = PositionType.game;

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

  //#endregion
}

typedef ComponentSetFactory = ComponentSet Function();

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

  Completer<void>? _mountCompleter;
  Completer<void>? _loadCompleter;

  Future<void> get loadFuture {
    _loadCompleter ??= Completer<void>();
    return _loadCompleter!.future;
  }

  Future<void> get mountFuture {
    _mountCompleter ??= Completer<void>();
    return _mountCompleter!.future;
  }

  void finishLoading() {
    _loadCompleter?.complete();
    _loadCompleter = null;
  }

  void finishMounting() {
    _mountCompleter?.complete();
    _mountCompleter = null;
  }

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
    return _children.isNotEmpty ||
        _removals.isNotEmpty ||
        _adoption.isNotEmpty ||
        _mountCompleter != null ||
        _loadCompleter != null;
  }

  /// Attempt to resolve pending events in all lifecycle event queues.
  ///
  /// This method must be periodically invoked by the game engine, in order to
  /// ensure that the components get properly added/removed from the component
  /// tree.
  void processQueues() {
    _processChildrenQueue();
    _processRemovalQueue();
    _processAdoptionQueue();
  }

  void _processChildrenQueue() {
    while (_children.isNotEmpty) {
      final child = _children.first;
      assert(child._parent!.isMounted);
      if (child.isLoaded) {
        child._mount();
        _children.removeFirst();
      } else if (child.isLoading) {
        break;
      } else {
        child._startLoading();
      }
    }
  }

  void _processRemovalQueue() {
    while (_removals.isNotEmpty) {
      final component = _removals.removeFirst();
      if (component.isMounted) {
        component._remove();
      }
      assert(!component.isMounted);
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
