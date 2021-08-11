import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';

import '../../components.dart';
import '../../game.dart';
import '../extensions/vector2.dart';

/// This represents a Component for your game.
///
/// Components can be bullets flying on the screen, a spaceship or your player's
/// fighter. Anything that either renders or updates can be added to the list on
/// BaseGame. It will deal with calling those methods for you.
/// Components also have other methods that can help you out if you want to
/// override them.
abstract class Component {
  /// Whether this component is HUD object or not.
  ///
  /// HUD objects ignore the BaseGame.camera when rendered (so their position
  /// coordinates are considered relative to the device screen).
  bool isHud = false;

  bool _isMounted = false;

  /// Whether this component is currently mounted on a game or not
  bool get isMounted => _isMounted;

  /// Whether this component has been prepared and is ready to be added to the
  /// game loop
  bool isPrepared = false;

  /// If the component has a parent it will be set here
  Component? parent;

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
  /// BaseGame will remove it.
  bool shouldRemove = false;

  Component({int? priority}) : _priority = priority ?? 0;

  /// This method is called periodically by the game engine to request that your
  /// component updates itself.
  ///
  /// The time [dt] in seconds (with microseconds precision provided by Flutter)
  /// since the last update cycle.
  /// This time can vary according to hardware capacity, so make sure to update
  /// your state considering this.
  /// All components on BaseGame are always updated by the same amount. The time
  /// each one takes to update adds up to the next update cycle.
  void update(double dt) {}

  /// Renders this component on the provided Canvas [c].
  void render(Canvas c) {}

  /// This is used to render this component and potential children on subclasses
  /// of [Component] on the provided Canvas [c].
  void renderTree(Canvas c) => render(c);

  /// Remove the component from the game it is added to in the next tick
  void removeFromParent() => shouldRemove = true;

  /// Changes the current parent for another parent and prepares the tree under
  /// the new root.
  void changeParent(Component component) {
    removeFromParent();
    component.add(this);
  }

  /// It receives the new game size.
  /// Executed right after the component is attached to a game and right before
  /// [onMount] is called
  @mustCallSuper
  void onGameResize(Vector2 gameSize) {
    children.forEach((child) => child.onGameResize(gameSize));
  }

  /// Called when the component has been added and prepared by the game
  /// instance.
  ///
  /// This can be used to make initializations on your component as, when this
  /// method is called,
  /// things like [onGameResize] are already set and usable.
  @mustCallSuper
  void onMount() {
    _isMounted = true;
    children.forEach((child) => child.onMount());
  }

  /// Called right before the component is removed from the game
  @mustCallSuper
  void onRemove() {
    if (parent != this) {
      return;
    }
    _isMounted = false;
    children.forEach((child) {
      child.onRemove();
    });
    parent = null;
  }

  /// Prepares and registers a component to be added on the next game tick
  ///
  /// This methods is an async operation since it await the `onLoad` method of
  /// the component. Nevertheless, this method only need to be waited to finish
  /// if by some reason, your logic needs to be sure that the component has
  /// finished loading, otherwise, this method can be called without waiting
  /// for it to finish as the BaseGame already handle the loading of the
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

  /// Removes a component from the component list, calling onRemove for it and
  /// its children.
  void remove(Component c) {
    children.remove(c);
  }

  /// Removes all the children in the list and calls onRemove for all of them
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
  /// This will call `rebalanceAll` on the [children] ordered set.
  void reorderChildren() => children.rebalanceAll();

  /// This method first calls the passed handler on the leaves in the tree,
  /// the children without any children of their own.
  /// Then it continues through all other children. The propagation continues
  /// until the handler returns false, which means "do not continue", or when
  /// the handler has been called with all children
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
      if (child is BaseComponent) {
        shouldContinue = child.propagateToChildren(handler);
      }
      if (shouldContinue && child is T) {
        shouldContinue = handler(child);
      } else if (shouldContinue && child is BaseGame) {
        shouldContinue = child.propagateToChildren<T>(handler);
      }
      if (!shouldContinue) {
        break;
      }
    }
    return shouldContinue;
  }

  T? findParent<T extends Component>() {
    return (parent is T ? parent : parent?.findParent<T>()) as T?;
  }

  /// Called before the component is added to the BaseGame by the add method.
  /// Whenever this returns something, BaseGame will wait for the [Future] to be
  /// resolved before adding the component on the list.
  /// If `null` is returned, the component is added right away.
  ///
  /// Has a default implementation which just returns null.
  ///
  /// This can be overwritten this to add custom logic to the component loading.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Future<void> onLoad() async {
  ///   myImage = await gameRef.load('my_image.png');
  /// }
  /// ```
  Future<void>? onLoad() => null;

  /// Called to check whether the point is to be counted as within the component
  /// It needs to be overridden to have any effect, like it is in
  /// PositionComponent.
  bool containsPoint(Vector2 point) => false;

  /// Usually this is not something that the user would want to call since the
  /// component list isn't re-ordered when it is called.
  /// See BaseGame.changePriority instead.
  void changePriorityWithoutResorting(int priority) => _priority = priority;

  /// Prepares the [Component] child to be added to a [Game].
  /// If there are no parents that are a [Game] this will run again once a
  /// parent is added to a [Game] and false will be returned.
  @mustCallSuper
  void prepare(Component component) {
    component.parent = this;
    final parentGame = component.findParent<Game>();
    if (parentGame == null) {
      component.isPrepared = false;
    } else {
      if (parentGame is BaseGame) {
        parentGame.prepareComponent(component);
      }

      if (component is BaseComponent && this is BaseComponent) {
        component.debugMode = (this as BaseComponent).debugMode;
      }

      component.isPrepared = true;
    }
  }

  @mustCallSuper
  ComponentSet createComponentSet() {
    final components = ComponentSet.createDefault(prepare);
    if (this is HasGameRef) {
      components.register<HasGameRef>();
    }
    return components;
  }
}
