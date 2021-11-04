import 'dart:ui';

import 'package:meta/meta.dart';

import '../components/component.dart';
import '../extensions/vector2.dart';
import 'camera/camera.dart';
import 'camera/camera_wrapper.dart';
import 'mixins/game.dart';
import 'projector.dart';

/// This is a more complete and opinionated implementation of [Game].
///
/// [FlameGame] can be extended to add your game logic, or you can keep the
/// logic in child [Component]s.
///
/// This is the recommended base class to use for most games made with Flame.
/// It is based on the Flame Component System (also known as FCS).
class FlameGame extends Component with Game {
  FlameGame({Camera? camera}) {
    _cameraWrapper = CameraWrapper(camera ?? Camera(), children);
  }

  /// The camera translates the coordinate space after the viewport is applied.
  Camera get camera => _cameraWrapper.camera;

  // When the Game becomes a Component (#906), this could be added directly
  // into the component tree.
  late final CameraWrapper _cameraWrapper;

  /// This is overwritten to consider the viewport transformation.
  ///
  /// Which means that this is the logical size of the game screen area as
  /// exposed to the canvas after viewport transformations and camera zooming.
  ///
  /// This does not match the Flutter widget size; for that see [canvasSize].
  @override
  Vector2 get size => camera.gameSize;

  /// This is the original Flutter widget size, without any transformation.
  Vector2 get canvasSize => camera.canvasSize;

  /// This method is called for every component before it is added to the
  /// component tree.
  /// It does preparation on a component before any update or render method is
  /// called on it.
  ///
  /// You can use this to set up your mixins or pre-calculate things for
  /// example.
  /// By default, this calls the first [onGameResize] for every component, so
  /// don't forget to call `super.prepareComponent` when overriding.
  @mustCallSuper
  void prepareComponent(Component c) {
    // First time resize
    c.onGameResize(size);
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
    super.render(canvas);
    _cameraWrapper.render(canvas);
  }

  /// This updates every component in the tree.
  ///
  /// It also adds the components added via [add] since the previous tick, and
  /// removes those that are marked for removal via the [remove] and
  /// [Component.removeFromParent] methods.
  /// You can override it to add more custom behavior.
  @override
  @mustCallSuper
  void update(double dt) {
    super.update(dt);
    _cameraWrapper.update(dt);
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
    camera.handleResize(canvasSize);
    super.onGameResize(canvasSize);
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
