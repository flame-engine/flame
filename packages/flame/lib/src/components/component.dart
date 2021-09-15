import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';

import '../../components.dart';
import '../../game.dart';
import '../../input.dart';
import '../extensions/vector2.dart';
import '../game/mixins/loadable.dart';
import 'cache/value_cache.dart';

/// This represents a Component for your game.
///
/// Components can be for example bullets flying on the screen, a spaceship, a
/// timer or an enemy. Anything that either needs to be rendered and/or updated
/// is a good idea to have as a [Component], since [update] and [render] will be
/// called automatically once the component is added to the component tree in
/// your game (with `game.add`).
class Component with Loadable {
  /// Whether this component is a HUD (Heads-up display) object or not.
  ///
  /// HUD objects ignore the FlameGame.camera when rendered (so their position
  /// coordinates are considered relative to the device screen).
  bool isHud = false;

  /// Whether this component has been prepared and is ready to be added to the
  /// game loop.
  bool isPrepared = false;

  /// Whether this component is done loading through [onLoad].
  bool isLoaded = false;

  /// Whether this component is currently added to a component tree.
  bool isMounted = false;

  /// If the component has a parent it will be set here.
  Component? _parent;

  /// Get the current parent of the component, if there is one, otherwise null.
  Component? get parent => _parent;

  /// If the component should be added to another parent once it has been
  /// removed from its current parent.
  Component? nextParent;

  late final ComponentSet children = createComponentSet();

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
        config: TextPaintConfig(
          color: debugColor,
          fontSize: 12,
        ),
      );
      _debugTextPaintCache.updateCache(textPaint, [debugColor]);
    }
    return _debugTextPaintCache.value!;
  }

  Component({int? priority}) : _priority = priority ?? 0;

  /// This method is called periodically by the game engine to request that your
  /// component updates itself.
  ///
  /// The time [dt] in seconds (with microseconds precision provided by Flutter)
  /// since the last update cycle.
  /// This time can vary according to hardware capacity, so make sure to update
  /// your state considering this.
  /// All components in the tree are always updated by the same amount. The time
  /// each one takes to update adds up to the next update cycle.
  @mustCallSuper
  void update(double dt) {
    children.updateComponentList();
    children.forEach((c) => c.update(dt));
  }

  void render(Canvas canvas) {
    preRender(canvas);
  }

  @mustCallSuper
  void renderTree(Canvas canvas) {
    render(canvas);
    postRender(canvas);
    children.forEach((c) {
      canvas.save();
      c.renderTree(canvas);
      canvas.restore();
    });

    // Any debug rendering should be rendered on top of everything
    if (debugMode) {
      renderDebugMode(canvas);
    }
  }

  /// A render cycle callback that runs before the component and its children
  /// has been rendered.
  @protected
  void preRender(Canvas canvas) {}

  /// A render cycle callback that runs after the component has been
  /// rendered, but before any children has been rendered.
  void postRender(Canvas canvas) {}

  void renderDebugMode(Canvas canvas) {}

  @protected
  Vector2 eventPosition(PositionInfo info) {
    return isHud ? info.eventPosition.widget : info.eventPosition.game;
  }

  /// Remove the component from its parent in the next tick.
  void removeFromParent() => shouldRemove = true;

  /// Changes the current parent for another parent and prepares the tree under
  /// the new root.
  void changeParent(Component component) {
    parent?.remove(this);
    nextParent = component;
  }

  /// It receives the new game size.
  /// Executed right after the component is attached to a game and right before
  /// [onLoad] is called.
  @override
  @mustCallSuper
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    children.forEach((child) => child.onGameResize(gameSize));
  }

  /// Called right before the component is removed from the game
  @override
  @mustCallSuper
  void onRemove() {
    children.forEach((child) {
      child.onRemove();
    });
    isPrepared = false;
    isMounted = false;
    _parent = null;
    nextParent?.add(this);
    nextParent = null;
  }

  /// Prepares and registers a component to be added on the next game tick
  ///
  /// This method is an async operation since it await the [onLoad] method of
  /// the component. Nevertheless, this method only need to be waited to finish
  /// if by some reason, your logic needs to be sure that the component has
  /// finished loading, otherwise, this method can be called without waiting
  /// for it to finish as the FlameGame already handle the loading of the
  /// component.
  ///
  /// *Note:* Do not add components on the game constructor. This method can
  /// only be called after the game already has its layout set, this can be
  /// verified by the [Game.hasLayout] property, to add components upon game
  /// initialization, the [onLoad] method can be used instead.
  Future<void> add(Component component) {
    return children.addChild(component);
  }

  /// Adds multiple children.
  ///
  /// See [add] for details.
  Future<void> addAll(List<Component> components) {
    return children.addChildren(components);
  }

  /// The children are added again to the component set so that [prepare],
  /// [onLoad] and [onMount] runs again. Used when a parent is changed
  /// further up the tree.
  Future<void> reAddChildren() async {
    await Future.wait(children.map(add));
    await Future.wait(children.addLater.map(add));
  }

  /// Removes a component from the component tree, calling [onRemove] for it and
  /// its children.
  void remove(Component c) {
    children.remove(c);
  }

  /// Removes all the children in the list and calls [onRemove] for all of them
  /// and their children.
  void removeAll(Iterable<Component> cs) {
    children.removeAll(cs);
  }

  /// Whether the children list contains the given component.
  ///
  /// This method uses reference equality.
  bool contains(Component c) => children.contains(c);

  /// Call this if any of this component's children priorities have changed
  /// at runtime.
  ///
  /// This will call [ComponentSet.rebalanceAll] on the [children] ordered set.
  void reorderChildren() => children.rebalanceAll();

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
    for (final child in children) {
      if (child is Component) {
        shouldContinue = child.propagateToChildren(handler);
      }
      if (shouldContinue && child is T) {
        shouldContinue = handler(child);
      } else if (shouldContinue && child is FlameGame) {
        shouldContinue = child.propagateToChildren<T>(handler);
      }
      if (!shouldContinue) {
        break;
      }
    }
    return shouldContinue;
  }

  /// Finds the closest parent further up the hierarchy that satisfies type=T,
  /// or null if none is found.
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

  /// Prepares the [Component] to be added to a [parent], and if there is an
  /// ancestor that is a [FlameGame] that game will do necessary preparations for
  /// this component.
  /// If there are no parents that are a [Game] false will be returned and this
  /// will run again once an ancestor or the component itself is added to a
  /// [Game].
  @mustCallSuper
  void prepare(Component parent) {
    _parent = parent;
    final parentGame = findParent<FlameGame>();
    if (parentGame == null) {
      isPrepared = false;
    } else {
      if (parentGame is FlameGame) {
        parentGame.prepareComponent(this);
      }

      debugMode |= parent.debugMode;
      isPrepared = true;
    }
  }

  /// This method sets up the `OrderedSet` instance used by this component to
  /// handle its children,
  /// This is set up before any lifecycle methods happen.
  ///
  /// You can return a specific sub-class of OrderedSet, like
  /// `QueryableOrderedSet` for example.
  @mustCallSuper
  ComponentSet createComponentSet() {
    return ComponentSet.createDefault(this);
  }
}
