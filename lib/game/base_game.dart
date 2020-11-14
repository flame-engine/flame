import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' hide WidgetBuilder;
import 'package:ordered_set/comparing.dart';
import 'package:ordered_set/ordered_set.dart';

import '../components/component.dart';
import '../components/mixins/has_game_ref.dart';
import '../components/mixins/tapable.dart';
import '../components/position_component.dart';
import '../extensions/vector2.dart';
import '../fps_counter.dart';
import 'game.dart';

/// This is a more complete and opinionated implementation of Game.
///
/// BaseGame should be extended to add your game logic.
/// [update], [render] and [onResize] methods have default implementations.
/// This is the recommended structure to use for most games.
/// It is based on the Component system.
class BaseGame extends Game with FPSCounter {
  /// The list of components to be updated and rendered by the base game.
  final OrderedSet<Component> components =
      OrderedSet(Comparing.on((c) => c.priority()));

  /// Components added by the [addLater] method
  final List<Component> _addLater = [];

  /// Components to be removed on the next update
  final List<Component> _removeLater = [];

  /// Current game viewport size, updated every resize via the [resize] method hook
  final Vector2 size = Vector2.zero();
  set size(Vector2 size) => this.size.setFrom(size);

  /// Camera position; every non-HUD component is translated so that the camera position is the top-left corner of the screen.
  Vector2 camera = Vector2.zero();

  /// Does preparation on a component before any update or render method is called on it
  @mustCallSuper
  void prepare(Component c) {
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
      c.onGameResize(size);
    }
  }

  /// Prepares and registers a component to be added on the next game tick
  void add(Component c) {
    prepare(c);
    _addLater.add(c);
  }

  /// Prepares and registers a list of components to be added on the next game tick
  void addAll(Iterable<Component> components) {
    components.forEach(prepare);
    _addLater.addAll(components);
  }

  /// Marks a component to be removed from the components list on the next game loop cycle
  void remove(Component c) {
    _removeLater.add(c);
  }

  /// Marks a list of components to be removed from the components list on the next game loop cycle
  void removeAll(Iterable<Component> components) {
    _removeLater.addAll(components);
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
    _addLater.forEach((component) => component.onMount());
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
  void onResize(Vector2 size) {
    this.size.setFrom(size);
    components.forEach((c) => c.onGameResize(size));
  }

  /// Returns whether this [Game] is in debug mode or not.
  ///
  /// Returns `false` by default. Override to use the debug mode.
  /// You can use this value to enable debug behaviors for your game, many components show extra information on screen when on debug mode
  bool debugMode() => false;

  /// Returns the current time in seconds with microseconds precision.
  ///
  /// This is compatible with the `dt` value used in the [update] method.
  double currentTime() {
    return DateTime.now().microsecondsSinceEpoch.toDouble() /
        Duration.microsecondsPerSecond;
  }
}
