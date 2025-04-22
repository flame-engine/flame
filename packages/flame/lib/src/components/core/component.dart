import 'dart:async';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/cache/value_cache.dart';
import 'package:flame/src/camera/viewport.dart';
import 'package:flame/src/components/core/component_render_context.dart';
import 'package:flame/src/components/core/component_tree_root.dart';
import 'package:flame/src/effects/provider_interfaces.dart';
import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';
import 'package:ordered_set/ordered_set.dart';
import 'package:ordered_set/queryable_ordered_set.dart';

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
///  - [onLoad] when the component is first added into the tree;
///  - [onGameResize] + [onMount] when done loading, or when the component is
///    re-added to the component tree after having been removed;
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
/// respond to tap events or similar; the [componentsAtLocation] may also need
/// to be overridden if you have reimplemented [renderTree].
class Component {
  Component({
    Iterable<Component>? children,
    int? priority,
    this.key,
  }) : _priority = priority ?? 0 {
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
  ///     method, and can be checked via [isLoading] getter. This bit is turned
  ///     on when the component starts loading, and then off when it has
  ///     finished loading.
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
  ///    and then [onLoad] immediately
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
  ///      - first we run [onGameResize];
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
  static const int _mounting = 32;
  static const int _mounted = 4;
  static const int _removing = 8;
  static const int _removed = 16;

  /// Whether the component is currently executing its [onLoad] step.
  bool get isLoading => (_state & _loading) != 0;
  void _setLoadingBit() => _state |= _loading;
  void _clearLoadingBit() => _state &= ~_loading;

  /// Whether this component has completed its [onLoad] step.
  bool get isLoaded => (_state & _loaded) != 0;
  void _setLoadedBit() => _state |= _loaded;

  @internal
  bool get isMounting => (_state & _mounting) != 0;
  void _setMountingBit() => _state |= _mounting;
  void _clearMountingBit() => _state &= ~_mounting;

  /// Whether this component is currently added to a component tree.
  bool get isMounted => (_state & _mounted) != 0;
  void _setMountedBit() => _state |= _mounted;
  void _clearMountedBit() => _state &= ~_mounted;

  /// Whether the component is scheduled to be removed.
  bool get isRemoving => (_state & _removing) != 0;
  void _setRemovingBit() => _state |= _removing;
  void _clearRemovingBit() => _state &= ~_removing;

  /// Whether the component has been removed. Originally this flag is `false`,
  /// but it becomes `true` after the component was mounted and then removed
  /// from its parent. The flag becomes `false` again when the component is
  /// mounted to a new parent.
  bool get isRemoved => (_state & _removed) != 0;
  void _setRemovedBit() => _state |= _removed;
  void _clearRemovedBit() => _state &= ~_removed;

  Completer<void>? _loadCompleter;
  Completer<void>? _mountCompleter;
  Completer<void>? _removeCompleter;

  /// A future that completes when this component finishes loading.
  ///
  /// If the component is already loaded (see [isLoaded]), this returns an
  /// already completed future.
  Future<void> get loaded {
    return isLoaded
        ? Future.value()
        : (_loadCompleter ??= Completer<void>()).future;
  }

  /// A future that will complete once the component is mounted on its parent.
  ///
  /// If the component is already mounted (see [isMounted]), this returns an
  /// already completed future.
  Future<void> get mounted {
    return isMounted
        ? Future.value()
        : (_mountCompleter ??= Completer<void>()).future;
  }

  /// A future that completes when this component is removed from its parent.
  ///
  /// If the component is already removed (see [isRemoved]), this returns an
  /// already completed future.
  Future<void> get removed {
    return isRemoved
        ? Future.value()
        : (_removeCompleter ??= Completer<void>()).future;
  }

  //#endregion

  //#region Component tree

  /// Who owns this component in the component tree.
  ///
  /// This can be null if the component hasn't been added to the component tree
  /// yet, or if it is the root of component tree.
  ///
  /// Setting this property to `null` is equivalent to [removeFromParent].
  /// Setting it to a new parent component is equivalent to calling
  /// [addToParent] and will properly remove this component from its current
  /// parent, if any.
  ///
  /// Note that the [parent] setter, like [add] and similar methods,
  /// merely enqueues the move from one parent to another. For example:
  ///
  /// ```dart
  /// coin.parent = inventory;
  /// // The inventory.children set does not include coin yet.
  /// await game.lifecycleEventsProcessed;
  /// // The inventory.children set now includes coin.
  /// ```
  Component? get parent => _parent;
  Component? _parent;
  set parent(Component? newParent) {
    if (newParent == null) {
      removeFromParent();
    } else {
      addToParent(newParent);
    }
  }

  QueryableOrderedSet<Component>? _children;

  /// The children components of this component.
  ///
  /// This getter will automatically create the [OrderedSet] container within
  /// the current object if it didn't exist before. Check the [hasChildren]
  /// property in order to avoid instantiating the children container.
  QueryableOrderedSet<Component> get children =>
      _children ??= createComponentSet();

  /// Whether this component has any children.
  /// Avoids the creation of the children container if not necessary.
  bool get hasChildren => _children?.isNotEmpty ?? false;

  /// `Component.childrenFactory` is the default method for creating children
  /// containers within all components. Replace this method if you want to have
  /// customized (non-default) [OrderedSet] instances in your project.
  static ComponentSetFactory childrenFactory = () {
    return OrderedSet.queryable(
      OrderedSet.mapping<num, Component>(_componentPriorityMapper),
      strictMode: false,
    );
  };

  static int _componentPriorityMapper(Component component) {
    return component.priority;
  }

  /// This method creates the children container for the current component.
  /// Override this method if you need to have a custom [OrderedSet] within
  /// a particular class.
  QueryableOrderedSet<Component> createComponentSet() => childrenFactory();

  /// Returns the closest parent further up the hierarchy that satisfies type=T,
  /// or null if no such parent can be found.
  ///
  /// If [includeSelf] is set to true (default is false) then the component
  /// which the call is made for is also included in the search.
  T? findParent<T extends Component>({bool includeSelf = false}) {
    return ancestors(includeSelf: includeSelf).whereType<T>().firstOrNull;
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

  /// Fetches the nearest [FlameGame] ancestor to the component.
  FlameGame? findGame() {
    assert(
      staticGameInstance is FlameGame || staticGameInstance == null,
      'A component needs to have a FlameGame as the root.',
    );
    final gameInstance = staticGameInstance is FlameGame
        ? staticGameInstance! as FlameGame
        : null;
    return gameInstance ??
        ((this is FlameGame) ? (this as FlameGame) : _parent?.findGame());
  }

  /// Fetches the root [FlameGame] ancestor to the component.
  FlameGame? findRootGame() {
    var game = findGame();
    while (game?.parent != null) {
      game = game!.parent!.findGame();
    }
    return game;
  }

  /// Whether the children list contains the given component.
  ///
  /// This method uses reference equality.
  bool contains(Component c) => _children?.contains(c) ?? false;

  //#endregion

  //#region Component lifecycle methods

  /// Called whenever the size of the top-level Canvas changes.
  ///
  /// In addition, this method will be invoked before each [onMount].
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
  /// add [HasGameReference] mixin and then query `game.size` or
  /// `game.canvasSize`.
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
  /// you can declare it as a regular method returning `void`:
  /// ```dart
  /// @override
  /// void onLoad() {
  ///   // your code here
  /// }
  /// ```
  ///
  /// The engine ensures that this method will be called exactly once during
  /// the lifetime of the [Component] object. Do not call this method manually.
  FutureOr<void> onLoad() => null;

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

  /// Called right before the component is removed from its parent
  /// and also before it changes parents (and is thus temporarily removed
  /// from the component tree).
  ///
  /// This method will only run for a component that was previously mounted into
  /// a component tree. If a component was never mounted (for example, when it
  /// is removed before it had a chance to mount), then this callback will not
  /// trigger. Thus, [onRemove] runs if and only if there was a corresponding
  /// [onMount] call before.
  void onRemove() {}

  /// Called whenever the parent of this component changes size; and also once
  /// before [onMount].
  ///
  /// The component may change its own size or perform layout in response to
  /// this call. If the component changes size, then it should call
  /// [onParentResize] for all its children.
  void onParentResize(Vector2 maxSize) {}

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
    update(dt);
    final children = _children;
    if (children != null) {
      for (final child in children) {
        child.updateTree(dt);
      }
    }
  }

  /// This method will be invoked from lifecycle if [child] has been added
  /// to or removed from its parent children list.
  void onChildrenChanged(Component child, ChildrenChangeType type) {}

  void render(Canvas canvas) {}

  void renderTree(Canvas canvas) {
    final context = renderContext;
    if (context != null) {
      _renderContexts.add(context);
    }

    render(canvas);
    final children = _children;
    if (children != null) {
      for (final child in children) {
        final hasContext = _renderContexts.isNotEmpty;
        if (hasContext) {
          child._renderContexts.addAll(_renderContexts);
        }
        child.renderTree(canvas);
        if (hasContext) {
          child._renderContexts.removeRange(
            _renderContexts.length,
            child._renderContexts.length,
          );
        }
      }
    }

    // Any debug rendering should be rendered on top of everything
    if (debugMode) {
      renderDebugMode(canvas);
    }

    if (context != null) {
      _renderContexts.removeLast();
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
  /// You can await [FlameGame.lifecycleEventsProcessed] like so:
  ///
  /// ```dart
  /// world.add(coin);
  /// await game.lifecycleEventsProcessed;
  /// // The coin is now guaranteed to be added.
  /// ```
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
  /// [parent] setter.
  FutureOr<void> add(Component component) => _addChild(component);

  /// Adds this component as a child of [parent] (see [add] for details).
  FutureOr<void> addToParent(Component parent) => parent._addChild(this);

  /// A convenience method to [add] multiple children at once.
  Future<void> addAll(Iterable<Component> components) {
    final futures = <Future<void>>[];
    for (final component in components) {
      final future = add(component);
      if (future is Future) {
        futures.add(future);
      }
    }
    return Future.wait(futures);
  }

  FutureOr<void> _addChild(Component child) {
    final game = findGame() ?? child.findGame();
    if ((!isMounted && !child.isMounted) || game == null) {
      child._parent?.children.remove(child);
      child._parent = this;
      children.add(child);
    } else if (child._parent != null) {
      if (child.isRemoving) {
        game.dequeueRemove(child);
        _clearRemovingBit();
      }
      game.enqueueMove(child, this);
    } else if (isMounted && !child.isMounted) {
      child._parent = this;
      game.enqueueAdd(child, this);
    } else {
      child._parent = this;
      // This will be reconciled during the mounting stage
      children.add(child);
    }
    if (!child.isLoaded && !child.isLoading && (game?.hasLayout ?? false)) {
      return child._startLoading();
    }
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
  void remove(Component component) => _removeChild(component);

  /// Remove the component from its parent in the next tick.
  void removeFromParent() => _parent?.remove(this);

  /// Removes all the children in the list and calls [onRemove] for all of them
  /// and their children.
  void removeAll(Iterable<Component> components) {
    components.toList(growable: false).forEach(_removeChild);
  }

  /// Removes all the children for which the [test] function returns true.
  void removeWhere(bool Function(Component component) test) {
    children.where(test).toList(growable: false).forEach(_removeChild);
  }

  void _removeChild(Component child) {
    assert(
      child._parent != null,
      "Trying to remove a component that doesn't belong to any parent",
    );
    assert(
      child._parent == this,
      'Trying to remove a component that belongs to a different parent: this = '
      "$this, component's parent = ${child._parent}",
    );
    if (isMounted) {
      final root = findGame()!;
      if (child.isMounted || child.isMounting) {
        if (!child.isRemoving) {
          root.enqueueRemove(child, this);
          child._setRemovingBit();
        }
      } else {
        root.dequeueAdd(child, this);
        child._parent = null;
      }
    } else {
      _children?.remove(child);
      child._parent = null;
    }
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
  ]) {
    return componentsAtLocation<Vector2>(
      point,
      nestedPoints,
      (transform, point) => transform.parentToLocal(point),
      (component, point) => component.containsLocalPoint(point),
    );
  }

  /// This is a generic implementation of [componentsAtPoint]; refer to those
  /// docs for context.
  ///
  /// This will find components intersecting a given location context [T]. The
  /// context can be a single point or a more complicated structure. How to
  /// interpret the structure T is determined by the provided lambdas,
  /// [transformContext] and [checkContains].
  ///
  /// A simple choice of T would be a simple point (i.e. Vector2). In that case
  /// transformContext needs to be able to transform a Vector2 on the parent
  /// coordinate space into the coordinate space of a provided
  /// [CoordinateTransform]; and [checkContains] must be able to determine if
  /// a given [Component] "contains" the Vector2 (the definition of "contains"
  /// will vary and shall be determined by the nature of the chosen location
  /// context [T]).
  Iterable<Component> componentsAtLocation<T>(
    T locationContext,
    List<T>? nestedContexts,
    T? Function(CoordinateTransform, T) transformContext,
    bool Function(Component, T) checkContains,
  ) sync* {
    nestedContexts?.add(locationContext);
    if (_children != null) {
      for (final child in _children!.reversed()) {
        if (child is IgnoreEvents && child.ignoreEvents) {
          continue;
        }
        T? childPoint = locationContext;
        if (child is CoordinateTransform) {
          childPoint = transformContext(
            child as CoordinateTransform,
            locationContext,
          );
        }
        if (childPoint != null) {
          yield* child.componentsAtLocation(
            childPoint,
            nestedContexts,
            transformContext,
            checkContains,
          );
        }
      }
    }
    final shouldIgnoreEvents =
        this is IgnoreEvents && (this as IgnoreEvents).ignoreEvents;
    if (checkContains(this, locationContext) && !shouldIgnoreEvents) {
      yield this;
    }
    nestedContexts?.removeLast();
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
  /// If two components share the same priority, they will be updated and
  /// rendered in the order they were added.
  ///
  /// Note that setting the priority is relatively expensive if the component is
  /// already added to a component tree since all siblings have to be re-added
  /// to the parent.
  int get priority => _priority;
  int _priority;
  set priority(int newPriority) {
    if (_priority != newPriority) {
      _priority = newPriority;
      final parent = _parent;
      final game = findGame();
      if (game != null && parent != null) {
        game.enqueuePriorityChange(parent, this);
      }
    }
  }

  //#endregion

  //#region Internal lifecycle management

  @internal
  LifecycleEventStatus handleLifecycleEventAdd(Component parent) {
    assert(!isMounted);
    if (parent.isMounted && isLoaded) {
      _parent ??= parent;
      _mount();
      return LifecycleEventStatus.done;
    } else {
      if (parent.isMounted && !isLoading) {
        _startLoading();
      } else if (parent.isRemoved) {
        // This case happens when the child is added to a parent that is being
        // removed in the same tick.
        _parent = parent;
        parent.children.add(this);
        return LifecycleEventStatus.done;
      }
      return LifecycleEventStatus.block;
    }
  }

  @internal
  LifecycleEventStatus handleLifecycleEventRemove(Component parent) {
    if (_parent == null) {
      parent._children?.remove(this);
    } else {
      _remove();
      assert(_parent == null);
    }
    return LifecycleEventStatus.done;
  }

  @internal
  LifecycleEventStatus handleLifecycleEventMove(Component newParent) {
    if (_parent != null) {
      _remove();
    }
    if (newParent.isMounted) {
      _parent = newParent;
      _mount();
    } else {
      newParent.add(this);
    }
    return LifecycleEventStatus.done;
  }

  @mustCallSuper
  @internal
  void handleResize(Vector2 size) {
    final children = _children;
    if (children != null) {
      for (final child in children) {
        if (child.isLoading || child.isLoaded) {
          child.onGameResize(size);
        }
      }
    }
  }

  FutureOr<void> _startLoading() {
    assert(_state == _initial);
    assert(_parent != null);
    assert(_parent!.findGame() != null);
    assert(_parent!.findGame()!.hasLayout);
    _setLoadingBit();
    final onLoadFuture = onLoad();
    if (onLoadFuture is Future) {
      return onLoadFuture.then((dynamic _) => _finishLoading());
    } else {
      _finishLoading();
    }
  }

  void _finishLoading() {
    _clearLoadingBit();
    _setLoadedBit();
    _loadCompleter?.complete();
    _loadCompleter = null;
  }

  /// Mount the component that is already loaded and has a mounted parent.
  void _mount() {
    assert(_parent != null && _parent!.isMounted);
    assert(isLoaded && !isLoading);
    _setMountingBit();
    onGameResize(_parent!.findGame()!.canvasSize);
    if (_parent is ReadOnlySizeProvider) {
      if (_parent is Viewport) {
        onParentResize((_parent! as Viewport).virtualSize);
      } else {
        onParentResize((_parent! as ReadOnlySizeProvider).size);
      }
    }
    if (isRemoved) {
      _clearRemovedBit();
    } else if (isRemoving) {
      _parent = null;
      _clearRemovingBit();
      _setRemovedBit();
      return;
    }
    debugMode |= _parent!.debugMode;
    onMount();
    _setMountedBit();
    _mountCompleter?.complete();
    _mountCompleter = null;
    _parent!.children.add(this);
    _reAddChildren();
    _parent!.onChildrenChanged(this, ChildrenChangeType.added);
    _clearMountingBit();

    if (key != null) {
      final currentGame = findGame();
      if (currentGame is FlameGame) {
        currentGame.registerKey(key!, this);
      }
    }
  }

  /// Used by [_reAddChildren].
  static final List<Component> _tmpChildren = [];

  /// At the end of mounting, we remove all children components and then re-add
  /// them one-by-one. The reason for this is that before the current component
  /// was mounted, its [children] may have contained components in arbitrary
  /// state -- initial, loading, unmounted, etc. However, we don't want to
  /// have such components in a component tree. By removing and then re-adding
  /// them, we ensure that they are placed in a queue, and will only be placed
  /// into [children] once they are fully mounted.
  void _reAddChildren() {
    if (_children != null && _children!.isNotEmpty) {
      assert(_tmpChildren.isEmpty);
      _tmpChildren.addAll(_children!);
      _children!.clear();
      for (final child in _tmpChildren) {
        child._parent = null;
        _addChild(child);
      }
      _tmpChildren.clear();
    }
  }

  /// Used by the [FlameGame] to set the loaded state of the component, since
  /// the game isn't going through the whole normal component life cycle.
  @internal
  void setLoaded() {
    _setLoadedBit();
    _loadCompleter?.complete();
    _loadCompleter = null;
  }

  /// Used by the [FlameGame] to set the mounted state of the component, since
  /// the game isn't going through the whole normal component life cycle.
  @internal
  void setMounted() {
    _setMountedBit();
    _mountCompleter?.complete();
    _mountCompleter = null;
    _reAddChildren();
  }

  /// Used by the [FlameGame] to set the removed state of the component, since
  /// the game isn't going through the whole normal component life cycle.
  @internal
  void setRemoved() {
    _setRemovedBit();
    _removeCompleter?.complete();
    _removeCompleter = null;
  }

  void _remove() {
    assert(_parent != null, 'Trying to remove a component with no parent');

    _parent!.children.remove(this);
    propagateToChildren(
      (Component component) {
        component
          ..onRemove()
          .._unregisterKey()
          .._clearMountedBit()
          .._clearRemovingBit()
          .._setRemovedBit()
          .._removeCompleter?.complete()
          .._removeCompleter = null
          .._parent!.onChildrenChanged(component, ChildrenChangeType.removed)
          .._parent = null;
        return true;
      },
      includeSelf: true,
    );
  }

  void _unregisterKey() {
    if (key != null) {
      final game = findGame();
      if (game is FlameGame) {
        game.unregisterKey(key!);
      }
    }
  }

  //#endregion

  //#region Context

  final QueueList<ComponentRenderContext> _renderContexts = QueueList();

  /// Override this method if you want your component to provide a custom
  /// render context to all its children (recursively).
  ComponentRenderContext? get renderContext => null;

  T? findRenderContext<T extends ComponentRenderContext>() {
    return _renderContexts.whereType<T>().lastOrNull;
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
  int? debugCoordinatesPrecision = 0;

  /// A key that can be used to identify this component in the tree.
  ///
  /// It can be used to retrieve this component from anywhere in the tree.
  final ComponentKey? key;

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
    final viewfinder = CameraComponent.currentCamera?.viewfinder;
    final viewport = CameraComponent.currentCamera?.viewport;
    final zoom = viewfinder?.zoom ?? 1.0;

    final viewportScale = math.max(
      viewport?.transform.scale.x ?? 1,
      viewport?.transform.scale.y ?? 1,
    );

    if (!_debugTextPaintCache.isCacheValid([debugColor])) {
      final textPaint = TextPaint(
        style: TextStyle(
          color: debugColor,
          fontSize: 12 / zoom / viewportScale,
        ),
      );
      _debugTextPaintCache.updateCache(textPaint, [debugColor]);
    }
    return _debugTextPaintCache.value!;
  }

  void renderDebugMode(Canvas canvas) {}

  //#endregion
}

typedef ComponentSetFactory = QueryableOrderedSet<Component> Function();

enum ChildrenChangeType { added, removed }
