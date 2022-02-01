import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';

import '../../components.dart';
import '../../game.dart';
import '../../input.dart';
import '../game/mixins/component_tree_root.dart';
import 'cache/value_cache.dart';

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

  /// Whether this component has completed its [onLoad] step.
  bool get isLoaded => _loaded;
  bool _loaded = false;

  /// Whether this component is currently added to a component tree.
  bool get isMounted => _mounted;
  bool _mounted = false;

  /// The current parent of the component, or null if there is none.
  Component? get parent => _parent;
  Component? _parent;

  /// If the component should be added to another parent once it has been
  /// removed from its current parent.
  Component? nextParent;

  /// The children of the current component.
  ///
  /// This getter will automatically create the [ComponentSet] container within
  /// the current object if it didn't exist before. Check the [hasChildren]
  /// property in order to avoid instantiating the children container.
  ComponentSet get children => _children ??= createComponentSet();
  bool get hasChildren => _children?.isNotEmpty ?? false;
  ComponentSet? _children;

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
  int get priority => _priority;
  int _priority;

  /// Whether this component should be removed or not.
  ///
  /// It will be checked once per component per tick, and if it is true,
  /// FlameGame will remove it.
  bool shouldRemove = false;

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
        ..strokeWidth = 1
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
  void onGameResize(Vector2 gameSize) {
    _children?.forEach((child) => child.onGameResize(gameSize));
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
  void removeFromParent() => shouldRemove = true;

  /// Changes the current parent for another parent and prepares the tree under
  /// the new root.
  void changeParent(Component component) {
    parent?.remove(this);
    nextParent = component;
  }

  /// An iterator producing this component's parent, then its parent's parent,
  /// then the great-grand-parent, and so on, until it reaches a component
  /// without a parent.
  Iterable<Component> ancestors() sync* {
    var current = parent;
    while (current != null) {
      yield current;
      current = current.parent;
    }
  }

  /// Called right before the component is removed from the game.
  @mustCallSuper
  void onRemove() {
    _children?.forEach((child) => child.onRemove());
    _mounted = false;
    _parent = null;
    nextParent?.add(this);
    nextParent = null;
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
  Future<void> add(Component component) => component.addToParent(this);

  /// A convenience method to [add] multiple children at once.
  Future<void> addAll(Iterable<Component> components) {
    return Future.wait(components.map(add));
  }

  /// Adds this component to the provided [parent] (see [add] for details).
  Future<void> addToParent(Component parent) async {
    assert(
      _parent == null,
      '$this cannot be added to $parent because it already has a parent: '
      '$_parent',
    );
    assert(root != null, 'The root of the component tree was not initialized');
    assert(
      root!.hasLayout,
      'add() called before the game has a layout. Did you try to add '
      'components from the constructor? Use the onLoad() method instead.',
    );

    _parent = parent;
    debugMode |= parent.debugMode;
    onGameResize(root!.canvasSize);
    root!.enqueueChild(parent: parent, child: this);

    if (!isLoaded) {
      final onLoadFuture = onLoad();
      if (onLoadFuture != null) {
        await onLoadFuture;
      }
      _loaded = true;
    }
  }

  /// Removes a component from the component tree, calling [onRemove] for it and
  /// its children.
  void remove(Component c) {
    _children?.remove(c);
  }

  /// Removes all the children in the list and calls [onRemove] for all of them
  /// and their children.
  void removeAll(Iterable<Component> cs) {
    _children?.removeAll(cs);
  }

  /// Attempt to mount the component, and return true if successful. This will
  /// return false only if mounting not possible right now, for example because
  /// the component hasn't loaded yet, or if its parent is not mounted yet.
  @internal
  bool tryMounting() {
    assert(!_mounted && _parent != null);
    if (!_loaded || !_parent!._mounted) {
      return false;
    }
    onMount();
    _parent!.children.addChild(this);
    _mounted = true;
    if (_children != null) {
      _children!.forEach((child) => child.remount());
    }
    return true;
  }

  /// Used to mount components that are already in the [children] list of a
  /// component that was just mounted. The difference from regular mounting is
  /// that since the component is already in [children], it can be marked as
  /// [isMounted] immediately. Also, we need to trigger [onGameResize], since
  /// this mounting is not caused by [add].
  @internal
  void remount() {
    assert(_loaded && !_mounted);
    assert(_parent!.isMounted);
    onGameResize(root!.canvasSize);
    onMount();
    _mounted = true;
    if (_children != null) {
      _children!.forEach((child) => child.remount());
    }
  }

  @internal
  void setMounted() => _mounted = true;

  //#endregion

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
    bool Function(T) handler,
  ) {
    var shouldContinue = true;
    if (_children != null) {
      for (final child in _children!.reversed()) {
        shouldContinue = child.propagateToChildren(handler);
        if (shouldContinue && child is T) {
          shouldContinue = handler(child);
        } else if (shouldContinue && child is FlameGame) {
          shouldContinue = child.propagateToChildren<T>(handler);
        }
        if (!shouldContinue) {
          break;
        }
      }
    }
    return shouldContinue;
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

  /// Component at the root of the component tree. This node serves as the
  /// central place for resolving lifecycle event queues, and also facilitates
  /// `onGameResize` events. This variable MUST be initialized before components
  /// may be combined into a tree.
  ///
  /// Usually, [FlameGame] is the root of the component tree, and it declares
  /// itself as such automatically.
  static ComponentTreeRoot? root;

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
