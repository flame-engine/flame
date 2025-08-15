import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/src/components/core/component_tree_root.dart';
import 'package:flame/src/devtools/dev_tools_service.dart';
import 'package:flame/src/effects/provider_interfaces.dart';
import 'package:flame/src/game/game.dart';
import 'package:flutter/foundation.dart';
// TODO(spydon): Remove this import when flutter version is updated to 3.35.0
// ignore: unnecessary_import
import 'package:meta/meta.dart';

/// This is a more complete and opinionated implementation of [Game].
///
/// [FlameGame] can be extended to add your game logic, or you can keep the
/// logic in child [Component]s.
///
/// This is the recommended base class to use for most games made with Flame.
/// It is based on the Flame Component System (also known as FCS).
class FlameGame<W extends World> extends ComponentTreeRoot
    with Game
    implements ReadOnlySizeProvider {
  FlameGame({
    super.children,
    W? world,
    CameraComponent? camera,
  }) : assert(
         world != null || W == World,
         'The generics type $W does not conform to the type of '
         '${world?.runtimeType ?? 'World'}.',
       ),
       _world = world ?? World() as W,
       _camera = camera ?? CameraComponent() {
    assert(
      Component.staticGameInstance == null,
      '$this instantiated, while another game ${Component.staticGameInstance} '
      'declares itself to be a singleton',
    );

    if (kDebugMode) {
      DevToolsService.initWithGame(this);
    }

    _camera.world = _world;
    add(_camera);
    add(_world);
  }

  /// The [World] that the [camera] is rendering.
  /// Inside of this world is where most of your components should be added.
  ///
  /// You don't have to add the world to the tree after setting it here, it is
  /// done automatically.
  W get world => _world;
  set world(W newWorld) {
    if (newWorld == _world) {
      return;
    }
    _world.removeFromParent();
    camera.world = newWorld;
    _world = newWorld;
    if (_world.parent == null) {
      add(_world);
    }
  }

  W _world;

  /// The component that is responsible for rendering your [world].
  ///
  /// In this component you can set different viewports, viewfinders, follow
  /// components, set bounds for where the camera can move etc.
  ///
  /// You don't have to add the CameraComponent to the tree after setting it
  /// here, it is done automatically.
  ///
  /// When setting the camera, if it doesn't already have a world it will be
  /// set to match the game's world.
  CameraComponent get camera => _camera;
  set camera(CameraComponent newCameraComponent) {
    _camera.removeFromParent();
    _camera = newCameraComponent;
    if (_camera.parent == null) {
      add(_camera);
    }
    _camera.world ??= world;
  }

  CameraComponent _camera;

  @internal
  late final List<ComponentsNotifier> notifiers = [];

  /// This is overwritten to consider the viewport transformation.
  ///
  /// Which means that this is the logical size of the game screen area as
  /// exposed to the canvas after viewport transformations.
  ///
  /// This does not match the Flutter widget size; for that see [canvasSize].
  @override
  Vector2 get size => camera.viewport.virtualSize;

  @override
  @internal
  FutureOr<void> load() async {
    await super.load();
    setLoaded();
  }

  @override
  @internal
  void mount() {
    super.mount();
    if (_pausedBecauseBackgrounded) {
      resumeEngine();
    }
    setMounted();
  }

  @override
  @internal
  void finalizeRemoval() {
    super.finalizeRemoval();
    setRemoved();
  }

  /// This implementation of render renders each component, making sure the
  /// canvas is reset for each one.
  ///
  /// You can override it further to add more custom behavior.
  /// Beware of that if you are rendering components without using this method;
  /// you must be careful to save and restore the canvas to avoid components
  /// interfering with each others rendering.
  @override
  @mustCallSuper
  void render(Canvas canvas) {
    if (parent == null) {
      renderTree(canvas);
    }
  }

  @override
  void renderTree(Canvas canvas) {
    if (parent != null) {
      render(canvas);
    }
    for (final component in children) {
      component.renderTree(canvas);
    }
  }

  @override
  @mustCallSuper
  void update(double dt) {
    if (parent == null) {
      updateTree(dt);
    }
  }

  @override
  void updateTree(double dt) {
    processLifecycleEvents();
    if (parent != null) {
      update(dt);
    }
    for (final component in children) {
      component.updateTree(dt);
    }
  }

  /// This passes the new size along to every component in the tree via their
  /// [Component.onGameResize] method, enabling each one to make their decision
  /// of how to handle the resize event.
  ///
  /// It also updates the [size] field of the class to be used by later added
  /// components and other methods.
  /// You can override it further to add more custom behavior, but you should
  /// seriously consider calling the super implementation as well.
  @override
  @mustCallSuper
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // This work-around is needed since the camera has the highest priority and
    // [size] uses [viewport.virtualSize], so the viewport needs to be updated
    // first since users will be using `game.size` in their [onGameResize]
    // methods.
    camera.viewport.onGameResize(size);
    // [onGameResize] is declared both in [Component] and in [Game]. Since
    // there is no way to explicitly call the [Component]'s implementation,
    // we propagate the event to [FlameGame]'s children manually.
    handleResize(size);
    for (final child in children) {
      child.onParentResize(size);
    }
  }

  /// Ensure that all pending tree operations finish.
  ///
  /// This is mainly intended for testing purposes: awaiting on this future
  /// ensures that the game is fully loaded, and that all pending operations
  /// of adding the components into the tree are fully materialized.
  ///
  /// Warning: awaiting on a game that was not fully connected will result in an
  /// infinite loop. For example, this could occur if you run `x.add(y)` but
  /// then forget to mount `x` into the game.
  Future<void> ready() async {
    var repeat = true;
    while (repeat) {
      // Give chance to other futures to execute first
      await Future<void>.delayed(Duration.zero);
      repeat = false;
      processLifecycleEvents();
      repeat |= hasLifecycleEvents;
    }
  }

  /// Whether a point is within the boundaries of the visible part of the game.
  @override
  bool containsLocalPoint(Vector2 point) {
    return point.x >= 0 &&
        point.y >= 0 &&
        point.x < canvasSize.x &&
        point.y < canvasSize.y;
  }

  /// Returns the current time in seconds with microseconds precision.
  ///
  /// This is compatible with the `dt` value used in the [update] method.
  double currentTime() {
    return DateTime.now().microsecondsSinceEpoch.toDouble() /
        Duration.microsecondsPerSecond;
  }

  /// Returns a [ComponentsNotifier] for the given type [W].
  ///
  /// This method handles duplications, so there will never be
  /// more than one [ComponentsNotifier] for a given type, meaning
  /// that this method can be called as many times as needed for a type.
  ComponentsNotifier<T> componentsNotifier<T extends Component>() {
    for (final notifier in notifiers) {
      if (notifier is ComponentsNotifier<T>) {
        return notifier;
      }
    }
    final notifier = ComponentsNotifier<T>(
      descendants().whereType<T>().toList(),
    );
    notifiers.add(notifier);
    return notifier;
  }

  @internal
  void propagateToApplicableNotifiers(
    Component component,
    void Function(ComponentsNotifier) callback,
  ) {
    for (final notifier in notifiers) {
      if (notifier.applicable(component)) {
        callback(notifier);
      }
    }
  }

  /// Whether the game should pause when the app is backgrounded.
  ///
  /// On the latest Flutter stable at the time of writing (3.13),
  /// this is only working on Android and iOS.
  ///
  /// Defaults to true.
  bool pauseWhenBackgrounded = true;
  bool _pausedBecauseBackgrounded = false;

  @visibleForTesting
  bool get isPausedOnBackground => _pausedBecauseBackgrounded;

  @override
  @mustCallSuper
  void lifecycleStateChange(AppLifecycleState state) {
    super.lifecycleStateChange(state);
    switch (state) {
      case AppLifecycleState.resumed:
      case AppLifecycleState.inactive:
        if (_pausedBecauseBackgrounded) {
          resumeEngine();
        }
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        if (pauseWhenBackgrounded && !paused) {
          pauseEngine();
          _pausedBecauseBackgrounded = true;
        }
    }
  }

  @override
  void pauseEngine() {
    _pausedBecauseBackgrounded = false;
    super.pauseEngine();
  }

  @override
  void resumeEngine() {
    _pausedBecauseBackgrounded = false;
    super.resumeEngine();
  }
}
