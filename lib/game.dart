import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components/composed_component.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:ordered_set/comparing.dart';
import 'package:ordered_set/ordered_set.dart';

import 'components/component.dart';
import 'components/mixins/has_game_ref.dart';
import 'components/mixins/tapable.dart';
import 'position.dart';

/// Represents a generic game.
///
/// Subclass this to implement the [update] and [render] methods.
/// Flame will deal with calling these methods properly when the game's widget is rendered.
abstract class Game {

  void onTap() {}
  void onTapCancel() {}
  void onTapDown(TapDownDetails details) {}
  void onTapUp(TapUpDetails details) {}

  // Widget Builder for this Game
  final builder = WidgetBuilder();

  /// Implement this method to update the game state, given that a time [t] has passed.
  ///
  /// Keep the updates as short as possible. [t] is in seconds, with microseconds precision.
  void update(double t);

  /// Implement this method to render the current game state in the [canvas].
  void render(Canvas canvas);

  /// This is the resize hook; every time the game widget is resized, this hook is called.
  ///
  /// The default implementation does nothing; override to use the hook.
  void resize(Size size) {}

  /// This is the lifecycle state change hook; every time the game is resumed, paused or suspended, this is called.
  ///
  /// The default implementation does nothing; override to use the hook.
  /// Check [AppLifecycleState] for details about the events received.
  void lifecycleStateChange(AppLifecycleState state) {}

  /// Used for debugging
  void _recordDt(double dt) {}

  /// Returns the game widget. Put this in your structure to start rendering and updating the game.
  /// You can add it directly to the runApp method or inside your widget structure (if you use vanilla screens and widgets).
  Widget get widget => builder.build(this);

  // Called when the Game widget is attached
  void onAttach() { }

  // Called when the Game widget is detached
  void onDetach() { }
}

class WidgetBuilder {
  Offset offset = Offset.zero;

  Widget build(Game game) {
    return GestureDetector(
        onTap: () => game.onTap(),
        onTapCancel: () => game.onTapCancel(),
        onTapDown: (TapDownDetails d) => game.onTapDown(d),
        onTapUp: (TapUpDetails d) => game.onTapUp(d),
        child: Container(
            color: const Color(0xFF000000),
            child: Directionality(
                textDirection: TextDirection.ltr, child: EmbeddedGameWidget(game)
            )
        ),
    );
  }
}

/// This is a more complete and opinionated implementation of Game.
///
/// It still needs to be subclasses to add your game logic, but the [update], [render] and [resize] methods have default implementations.
/// This is the recommended structure to use for most games.
/// It is based on the Component system.
abstract class BaseGame extends Game {
  /// The list of components to be updated and rendered by the base game.
  OrderedSet<Component> components =
      OrderedSet(Comparing.on((c) => c.priority()));

  /// Components added by the [addLater] method
  final List<Component> _addLater = [];

  /// Current screen size, updated every resize via the [resize] method hook
  Size size;

  /// Camera position; every non-HUD component is translated so that the camera position is the top-left corner of the screen.
  Position camera = Position.empty();

  /// List of deltas used in debug mode to calculate FPS
  final List<double> _dts = [];

  Iterable<Tapable> get _tapableComponents =>
      components.where((c) => c is Tapable).cast();

  @override
  void onTapCancel() {
    _tapableComponents.forEach((c) => c.handleTapCancel());
  }

  @override
  void onTapDown(TapDownDetails details) {
    _tapableComponents.forEach((c) => c.handleTapDown(details));
  }

  @override
  void onTapUp(TapUpDetails details) {
    _tapableComponents.forEach((c) => c.handleTapUp(details));
  }

  /// This method is called for every component added, both via [add] and [addLater] methods.
  ///
  /// You can use this to setup your mixins, pre-calculate stuff on every component, or anything you desire.
  /// By default, this calls the first time resize for every component, so don't forget to call super.preAdd when overriding.
  @mustCallSuper
  void preAdd(Component c) {
    if (debugMode() && c is PositionComponent) {
      c.debugMode = true;
    }

    // first time resize
    if (size != null) {
      c.resize(size);
    }

    if (c is HasGameRef) {
      (c as HasGameRef).gameRef = this;
    }

    if (c is ComposedComponent) {
      c.components.forEach(preAdd);
    }
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

  /// This implementation of render basically calls [renderComponent] for every component, making sure the canvas is reset for each one.
  ///
  /// You can override it further to add more custom behaviour.
  /// Beware of however you are rendering components if not using this; you must be careful to save and restore the canvas to avoid components messing up with each other.
  @override
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
  void update(double t) {
    components.addAll(_addLater);
    _addLater.clear();

    components.forEach((c) => c.update(t));
    components.removeWhere((c) => c.destroy());
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
  /// In debug mode, the [_recordDt] method actually records every `dt` for statistics.
  /// Then, you can use the [fps] method to check the game FPS.
  /// You can also use this value to enable other debug behaviors for your game, like bounding box rendering, for instance.
  bool debugMode() => false;

  /// This is a hook that comes from the RenderBox to allow recording of render times and statistics.
  @override
  void _recordDt(double dt) {
    if (debugMode()) {
      _dts.add(dt);
    }
  }

  /// Returns the average FPS for the last [average] measures.
  ///
  /// The values are only saved if in debug mode (override [debugMode] to use this).
  /// Selects the last [average] dts, averages then, and returns the inverse value.
  /// So it's technically updates per second, but the relation between updates and renders is 1:1.
  /// Returns 0 if empty.
  double fps([int average = 1]) {
    final List<double> dts = _dts.sublist(math.max(0, _dts.length - average));
    if (dts.isEmpty) {
      return 0.0;
    }
    final double dtSum = dts.reduce((s, t) => s + t);
    final double averageDt = dtSum / average;
    return 1 / averageDt;
  }

  /// Returns the current time in seconds with microseconds precision.
  ///
  /// This is compatible with the `dt` value used in the [update] method.
  double currentTime() {
    return DateTime.now().microsecondsSinceEpoch.toDouble() /
        Duration.microsecondsPerSecond;
  }
}

/// This is a helper implementation of a [BaseGame] designed to allow to easily create a game with a single component.
///
/// This is useful to add sprites, animations and other Flame components "directly" to your non-game Flutter widget tree, when combined with [EmbeddedGameWidget].
class SimpleGame extends BaseGame {
  SimpleGame(Component c) {
    add(c);
  }
}

/// This a widget to embed a game inside the Widget tree. You can use it in pair with [SimpleGame] or any other more complex [Game], as desired.
///
/// It handles for you positioning, size constraints and other factors that arise when your game is embedded within the component tree.
/// Provided it with a [Game] instance for your game and the optional size of the widget.
/// Creating this without a fixed size might mess up how other components are rendered with relation to this one in the tree.
/// You can bind Gesture Recognizers immediately around this to add controls to your widgets, with easy coordinate conversions.
class EmbeddedGameWidget extends LeafRenderObjectWidget {
  final Game game;
  final Position size;
  EmbeddedGameWidget(this.game, {this.size});

  @override
  RenderBox createRenderObject(BuildContext context) {
    return RenderConstrainedBox(
        child: GameRenderBox(context, game),
        additionalConstraints:
            BoxConstraints.expand(width: size?.x, height: size?.y));
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderConstrainedBox renderBox) {
    renderBox
      ..child = GameRenderBox(context, game)
      ..additionalConstraints =
          BoxConstraints.expand(width: size?.x, height: size?.y);
  }
}

class GameRenderBox extends RenderBox with WidgetsBindingObserver {
  BuildContext context;

  Game game;

  int _frameCallbackId;

  Duration previous = Duration.zero;

  GameRenderBox(this.context, this.game);

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    super.performResize();
    game.resize(constraints.biggest);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    game.onAttach();

    _scheduleTick();
    _bindLifecycleListener();
  }

  @override
  void detach() {
    super.detach();
    game.onDetach();
    _unscheduleTick();
    _unbindLifecycleListener();
  }

  void _scheduleTick() {
    _frameCallbackId = SchedulerBinding.instance.scheduleFrameCallback(_tick);
  }

  void _unscheduleTick() {
    SchedulerBinding.instance.cancelFrameCallbackWithId(_frameCallbackId);
  }

  void _tick(Duration timestamp) {
    if (!attached) {
      return;
    }
    _scheduleTick();
    _update(timestamp);
    markNeedsPaint();
  }

  void _update(Duration now) {
    final double dt = _computeDeltaT(now);
    game._recordDt(dt);
    game.update(dt);
  }

  double _computeDeltaT(Duration now) {
    Duration delta = now - previous;
    if (previous == Duration.zero) {
      delta = Duration.zero;
    }
    previous = now;
    return delta.inMicroseconds / Duration.microsecondsPerSecond;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.save();
    context.canvas.translate(
        game.builder.offset.dx + offset.dx, game.builder.offset.dy + offset.dy);
    game.render(context.canvas);
    context.canvas.restore();
  }

  void _bindLifecycleListener() {
    WidgetsBinding.instance.addObserver(this);
  }

  void _unbindLifecycleListener() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    game.lifecycleStateChange(state);
  }
}
