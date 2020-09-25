import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' hide WidgetBuilder;
import 'package:ordered_set/comparing.dart';
import 'package:ordered_set/ordered_set.dart';

import '../components/component.dart';
import '../components/composed_component.dart';
import '../components/mixins/has_game_ref.dart';
import '../components/mixins/tapable.dart';
import '../fps_counter.dart';
import '../position.dart';
import 'game.dart';

/// This is a more complete and opinionated implementation of Game.
///
/// It still needs to be subclasses to add your game logic, but the [update], [render] and [resize] methods have default implementations.
/// This is the recommended structure to use for most games.
/// It is based on the Component system.
class BaseGame extends Game with FPSCounter {
  /// The list of components to be updated and rendered by the base game.
  OrderedSet<Component> components =
      OrderedSet(Comparing.on((c) => c.priority()));

  /// Components added by the [addLater] method
  final List<Component> _addLater = [];

  /// Components to be removed on the next update
  final List<Component> _removeLater = [];

  /// Current screen size, updated every resize via the [resize] method hook
  Size size;

  /// Camera position; every non-HUD component is translated so that the camera position is the top-left corner of the screen.
  Position camera = Position.empty();

  /// This method is called for every component added, both via [add] and [addLater] methods.
  ///
  /// You can use this to setup your mixins, pre-calculate stuff on every component, or anything you desire.
  /// By default, this calls the first time resize for every component, so don't forget to call super.preAdd when overriding.
  @mustCallSuper
  void preAdd(Component c) {
    if (c is Tapable) {
      assert(
        this is HasTapableComponents,
        'Tapable Components can only be added to a BaseGame with HasTapableComponents',
      );
    }

    if (debugMode() && c is PositionComponent) {
      c.debugMode = true;
    }

    if (c is HasGameRef) {
      (c as HasGameRef).gameRef = this;
    }

    // first time resize
    if (size != null) {
      c.resize(size);
    }

    if (c is ComposedComponent) {
      c.components.forEach(preAdd);
    }

    c.onMount();
  }

  /// Adds a new component to the components list.
  ///
  /// Also calls [preAdd], witch in turn sets the current size on the component (because the resize hook won't be called until a new resize happens).
  void add(Component c) {
    preAdd(c);
    components.add(c);
  }

  /// Registers a component to be added on the components on the next tick.
  ///
  /// Use this to add components in places where a concurrent issue with the update method might happen.
  /// Also calls [preAdd] for the component added, immediately.
  void addLater(Component c) {
    preAdd(c);
    _addLater.add(c);
  }

  /// Marks a component to be removed from the components list on the next game loop cycle
  void markToRemove(Component c) {
    _removeLater.add(c);
  }

  /// This implementation of render basically calls [renderComponent] for every component, making sure the canvas is reset for each one.
  ///
  /// You can override it further to add more custom behaviour.
  /// Beware of however you are rendering components if not using this; you must be careful to save and restore the canvas to avoid components messing up with each other.
  @override
  @mustCallSuper
  void render(Canvas canvas) {
    canvas.save();
    components.forEach((comp) => renderComponent(canvas, comp));
    canvas.restore();
  }

  /// This renders a single component obeying BaseGame rules.
  ///
  /// It translates the camera unless hud, call the render method and restore the canvas.
  /// This makes sure the canvas is not messed up by one component and all components render independently.
  void renderComponent(Canvas canvas, Component c) {
    if (!c.loaded()) {
      return;
    }
    if (!c.isHud()) {
      canvas.translate(-camera.x, -camera.y);
    }
    c.render(canvas);
    canvas.restore();
    canvas.save();
  }

  /// This implementation of update updates every component in the list.
  ///
  /// It also actually adds the components that were added by the [addLater] method, and remove those that are marked for destruction via the [Component.destroy] method.
  /// You can override it further to add more custom behaviour.
  @override
  @mustCallSuper
  void update(double t) {
    _removeLater.forEach((c) => components.remove(c));
    _removeLater.clear();

    components.addAll(_addLater);
    _addLater.clear();

    components.forEach((c) => c.update(t));
    components.removeWhere((c) => c.destroy()).forEach((c) => c.onDestroy());
  }

  /// This implementation of resize passes the resize call along to every component in the list, enabling each one to make their decisions as how to handle the resize.
  ///
  /// It also updates the [size] field of the class to be used by later added components and other methods.
  /// You can override it further to add more custom behaviour, but you should seriously consider calling the super implementation as well.
  @override
  @mustCallSuper
  void resize(Size size) {
    this.size = size;
    components.forEach((c) => c.resize(size));
  }

  /// Returns whether this [Game] is in debug mode or not.
  ///
  /// Returns `false` by default. Override to use the debug mode.
  /// You can use this value to enable debug behaviors for your game, many components show extra information on screen when on debug mode
  bool debugMode() => false;

  @override
  bool recordFps() => false;

  /// Returns the current time in seconds with microseconds precision.
  ///
  /// This is compatible with the `dt` value used in the [update] method.
  double currentTime() {
    return DateTime.now().microsecondsSinceEpoch.toDouble() /
        Duration.microsecondsPerSecond;
  }
}
