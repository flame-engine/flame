// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/src/components/core/component_tree_root.dart';
import 'package:flame/src/effects/provider_interfaces.dart';
import 'package:flame/src/game/camera/camera.dart';
import 'package:flame/src/game/camera/camera_wrapper.dart';
import 'package:flame/src/game/game.dart';
import 'package:flame/src/game/projector.dart';
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
    Camera? oldCamera,
  })  : assert(
          world is W || (world == null && W is World),
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
    _cameraWrapper = CameraWrapper(oldCamera ?? Camera(), children);
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
  CameraComponent get camera => _camera;
  set camera(CameraComponent newCameraComponent) {
    _camera.removeFromParent();
    _camera = newCameraComponent;
    if (_camera.parent == null) {
      add(_camera);
    }
  }

  CameraComponent _camera;

  late final CameraWrapper _cameraWrapper;

  @internal
  late final List<ComponentsNotifier> notifiers = [];

  /// The camera translates the coordinate space after the viewport is applied.
  @Deprecated('''
    In the future (maybe as early as v1.10.0) this camera will be removed,
    please use the CameraComponent instead, which has a default camera at 
    `FlameGame.camera`.
    
    This is the simplest way of using the CameraComponent:
    1. Instead of adding the root components directly to your game with `add`,
       add them to the world.
       
       world.add(yourComponent);
    
    2. (Optional) If you want to add a HUD component, instead of using
       PositionType, add the component as a child of the viewport.
       
       camera.viewport.add(yourHudComponent);
    ''')
  Camera get oldCamera => _cameraWrapper.camera;

  /// This is overwritten to consider the viewport transformation.
  ///
  /// Which means that this is the logical size of the game screen area as
  /// exposed to the canvas after viewport transformations and camera zooming.
  ///
  /// This does not match the Flutter widget size; for that see [canvasSize].
  @override
  Vector2 get size => oldCamera.gameSize;

  @override
  @internal
  void mount() {
    super.mount();
    setMounted();
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
    // Don't call super.renderTree, since the tree is rendered by the camera
    _cameraWrapper.render(canvas);
  }

  @override
  @mustCallSuper
  void update(double dt) {
    if (parent == null) {
      updateTree(dt);
    }
    _cameraWrapper.update(dt);
  }

  @override
  void updateTree(double dt) {
    processLifecycleEvents();
    if (parent != null) {
      update(dt);
    }
    children.forEach((c) => c.updateTree(dt));
    processRebalanceEvents();
  }

  /// This passes the new size along to every component in the tree via their
  /// [Component.onGameResize] method, enabling each one to make their decision
  /// of how to handle the resize event.
  ///
  /// It also updates the [size] field of the class to be used by later added
  /// components and other methods.
  /// You can override it further to add more custom behavior, but you should
  /// seriously consider calling the super implementation as well.
  /// This implementation also uses the current [oldCamera] in order to
  /// transform the coordinate system appropriately for those using the old
  /// camera.
  @override
  @mustCallSuper
  void onGameResize(Vector2 size) {
    oldCamera.handleResize(size);
    super.onGameResize(size);
    // [onGameResize] is declared both in [Component] and in [Game]. Since
    // there is no way to explicitly call the [Component]'s implementation,
    // we propagate the event to [FlameGame]'s children manually.
    handleResize(size);
    children.forEach((child) => child.onParentResize(size));
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
  bool containsLocalPoint(Vector2 p) {
    return p.x >= 0 && p.y >= 0 && p.x < size.x && p.y < size.y;
  }

  /// Returns the current time in seconds with microseconds precision.
  ///
  /// This is compatible with the `dt` value used in the [update] method.
  double currentTime() {
    return DateTime.now().microsecondsSinceEpoch.toDouble() /
        Duration.microsecondsPerSecond;
  }

  @override
  Projector get viewportProjector => oldCamera.viewport;

  @override
  Projector get projector => oldCamera.combinedProjector;

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
}
