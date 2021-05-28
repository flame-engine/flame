import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';

import '../extensions/vector2.dart';

/// This represents a Component for your game.
///
/// Components can be bullets flying on the screen, a spaceship or your player's fighter.
/// Anything that either renders or updates can be added to the list on BaseGame. It will deal with calling those methods for you.
/// Components also have other methods that can help you out if you want to override them.
abstract class Component {
  /// Whether this component is HUD object or not.
  ///
  /// HUD objects ignore the BaseGame.camera when rendered (so their position coordinates are considered relative to the device screen).
  bool isHud = false;

  bool _isMounted = false;

  /// Whether this component is currently mounted on a game or not
  bool get isMounted => _isMounted;

  /// If the component has a parent it will be set here
  Component? _parent;

  Component? get parent => _parent;

  /// Render priority of this component. This allows you to control the order in which your components are rendered.
  ///
  /// Components are always updated and rendered in the order defined by what this number is when the component is added to the game.
  /// The smaller the priority, the sooner your component will be updated/rendered.
  /// It can be any integer (negative, zero, or positive).
  /// If two components share the same priority, they will probably be drawn in the order they were added.
  int get priority => _priority;
  int _priority;

  /// Whether this component should be removed or not.
  ///
  /// It will be checked once per component per tick, and if it is true, BaseGame will remove it.
  bool shouldRemove = false;

  Component({int? priority}) : _priority = priority ?? 0;

  /// This method is called periodically by the game engine to request that your component updates itself.
  ///
  /// The time [dt] in seconds (with microseconds precision provided by Flutter) since the last update cycle.
  /// This time can vary according to hardware capacity, so make sure to update your state considering this.
  /// All components on BaseGame are always updated by the same amount. The time each one takes to update adds up to the next update cycle.
  void update(double dt) {}

  /// Renders this component on the provided Canvas [c].
  void render(Canvas c) {}

  /// This is used to render this component and potential children on subclasses
  /// of [Component] on the provided Canvas [c].
  void renderTree(Canvas c) => render(c);

  /// It receives the new game size.
  /// Executed right after the component is attached to a game and right before [onMount] is called
  void onGameResize(Vector2 gameSize) {}

  /// Remove the component from the game it is added to in the next tick
  void remove() => shouldRemove = true;

  /// Called when the component has been added and prepared by the game instance.
  ///
  /// This can be used to make initializations on your component as, when this method is called,
  /// things like [onGameResize] are already set and usable.
  @mustCallSuper
  void onMount() {
    _isMounted = true;
  }

  /// Called right before the component is removed from the game
  @mustCallSuper
  void onRemove() {
    _isMounted = false;
  }

  /// Called before the component is added to the BaseGame by the add method.
  /// Whenever this returns something, BaseGame will wait for the [Future] to be resolved before adding the component on the list.
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

  /// Usually this is not something that the user would want to call since the
  /// component list isn't re-ordered when it is called.
  /// See BaseGame.changePriority instead.
  void changePriorityWithoutResorting(int priority) => _priority = priority;
}
