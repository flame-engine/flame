import 'dart:ui';

import 'package:meta/meta.dart';

import '../components/component.dart';
import '../extensions/vector2.dart';
import 'camera/camera.dart';
import 'camera/camera_wrapper.dart';
import 'mixins/component_tree_root.dart';
import 'mixins/game.dart';
import 'projector.dart';

/// This is a more complete and opinionated implementation of [Game].
///
/// [FlameGame] can be extended to add your game logic, or you can keep the
/// logic in child [Component]s.
///
/// This is the recommended base class to use for most games made with Flame.
/// It is based on the Flame Component System (also known as FCS).
class FlameGame extends Component with Game, ComponentTreeRoot {
  FlameGame({Camera? camera}) {
    _cameraWrapper = CameraWrapper(camera ?? Camera(), children);
    Component.root = this;
  }

  late final CameraWrapper _cameraWrapper;

  /// The camera translates the coordinate space after the viewport is applied.
  Camera get camera => _cameraWrapper.camera;

  /// This is overwritten to consider the viewport transformation.
  ///
  /// Which means that this is the logical size of the game screen area as
  /// exposed to the canvas after viewport transformations and camera zooming.
  ///
  /// This does not match the Flutter widget size; for that see [canvasSize].
  @override
  Vector2 get size => camera.gameSize;

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
    _cameraWrapper.update(dt);
    if (parent == null) {
      updateTree(dt);
    }
  }

  @override
  void updateTree(double dt) {
    processComponentQueues();
    children.updateComponentList();
    if (parent != null) {
      update(dt);
    }
    children.forEach((c) => c.updateTree(dt));
  }

  /// This passes the new size along to every component in the tree via their
  /// [Component.onGameResize] method, enabling each one to make their decision
  /// of how to handle the resize event.
  ///
  /// It also updates the [size] field of the class to be used by later added
  /// components and other methods.
  /// You can override it further to add more custom behavior, but you should
  /// seriously consider calling the super implementation as well.
  /// This implementation also uses the current [camera] in order to transform
  /// the coordinate system appropriately.
  @override
  @mustCallSuper
  void onGameResize(Vector2 canvasSize) {
    if (!isMounted) {
      // TODO(st-pasha): remove this hack, which is for test purposes only
      setMounted();
    }
    camera.handleResize(canvasSize);
    super.onGameResize(canvasSize); // Game.onGameResize
    // [onGameResize] is declared both in [Component] and in [Game]. Since
    // there is no way to explicitly call the [Component]'s implementation,
    // we propagate the event to [FlameGame]'s children manually.
    children.forEach((child) => child.onGameResize(canvasSize));
  }

  /// Whether a point is within the boundaries of the visible part of the game.
  @override
  bool containsPoint(Vector2 p) {
    return p.x > 0 && p.y > 0 && p.x < size.x && p.y < size.y;
  }

  /// Returns the current time in seconds with microseconds precision.
  ///
  /// This is compatible with the `dt` value used in the [update] method.
  double currentTime() {
    return DateTime.now().microsecondsSinceEpoch.toDouble() /
        Duration.microsecondsPerSecond;
  }

  @override
  Projector get viewportProjector => camera.viewport;

  @override
  Projector get projector => camera.combinedProjector;
}
