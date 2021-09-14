import 'dart:math' as math;
import 'dart:ui' show Rect, Canvas;

import '../../../components.dart';
import '../../../extensions.dart';
import '../../../game.dart';
import '../projector.dart';

/// A camera translates your game coordinate system; this is useful when your
/// world is not 1:1 with your screen size.
///
/// A camera always has a current [position], however you cannot set it
/// directly. You must use some methods to ensure that the camera moves smoothly
/// as the game runs. Smoothly here means that sudden snaps should be avoided,
/// as they feel jarring to the player.
///
/// There are three major factors that determine the camera position:
///
/// * Follow
/// If you want, you can call [followComponent] at the beginning of your
/// stage/world/level, and provided a [PositionComponent].
/// The camera will follow this component making sure its position is fixed
/// on the screen.
/// You can set the relative position of the screen you want the follow
/// object to stay in (normally the center), and you can even change that
/// and get a smooth transition.
///
/// * Move
/// You can alternatively move the camera to a specific world coordinate.
/// This will set the top left of the camera and will ignore any existing follow
/// rules and move the camera smoothly until it reaches the desired destination.
///
/// * Shake
/// Regardless of the the previous rules, you can additionally add a shake
/// effect for a brief period of time on top of the current coordinate.
/// The shake adds a random immediate delta to each tick to simulate the shake
/// effect.
///
/// Note: in the context of the FlameGame, the camera effectively translates
/// the position where components are rendered with relation to the Viewport.
/// Components marked as `isHud = true` are always rendered in screen
/// coordinates, bypassing the camera altogether.
class Camera extends Projector {
  Camera() : _viewport = DefaultViewport() {
    _combinedProjector = Projector.compose([this, _viewport]);
  }

  Viewport get viewport => _viewport;
  Viewport _viewport;
  set viewport(Viewport value) {
    _viewport = value;
    if (_canvasSize != null) {
      _viewport.resize(canvasSize);
    }
    _combinedProjector = Projector.compose([this, _viewport]);
  }

  // camera movement speed, in pixels/s
  static const defaultSpeed = 50.0;

  /// If set, this bypasses follow and moves the camera to a specific point
  /// in the world.
  ///
  /// You can use this if you are not using follow but have a few different
  /// camera positions or if you are using follow but you want to highlight a
  /// spot in the world during an animation.
  Vector2? _currentCameraDelta;
  Vector2? _targetCameraDelta;

  /// Remaining time in seconds for the camera shake.
  double _shakeTimer = 0.0;

  /// The intensity of the current shake action.
  double _shakeIntensity = 0.0;

  /// The matrix used for scaling and translating the canvas
  final Matrix4 _transform = Matrix4.identity();

  // Configurable parameters

  double speed = defaultSpeed;
  double defaultShakeIntensity = 75.0; // in pixels
  double defaultShakeDuration = 0.3; // in seconds

  /// This is the current position of the camera, ie the world coordinate that
  /// is rendered on the top left of the screen (origin of the screen space).
  ///
  /// Zero means no translation is applied.
  /// You can't change this directly; the camera will handle all ongoing
  /// movements so they smoothly transition.
  /// If you want to immediately snap the camera to a new place, you can do:
  /// ```
  ///   camera.snapTo(newPosition);
  /// ```
  Vector2 get position => _internalPosition.clone();

  /// Do not change this directly since it bypasses [onPositionUpdate]
  final Vector2 _internalPosition = Vector2.zero();

  Vector2 get _position => _internalPosition;
  set _position(Vector2 position) {
    _internalPosition.setFrom(position);
    onPositionUpdate(_internalPosition);
  }

  /// If set, the camera will "follow" this vector, making sure that this
  /// vector is always rendered in a fixed position in the screen, by
  /// immediately moving the camera to "focus" on the where the vector is.
  ///
  /// You might want to set it to the player component by using the
  /// [followComponent] method.
  /// Note that this is not smooth because the movement of the followed vector
  /// is assumed to be smooth.
  Vector2? follow;

  /// Where in the screen the follow object should be.
  ///
  /// This is a fractional value relating to the screen size.
  /// Changing this will smoothly move the camera to the new position
  /// (unless you use the followObject method that immediately sets
  /// up the camera for the new parameters).
  Vector2 get relativeOffset => _currentRelativeOffset;

  final Vector2 _currentRelativeOffset = Vector2.zero();
  final Vector2 _targetRelativeOffset = Vector2.zero();

  /// If set, this determines boundaries for the camera movement.
  ///
  /// The camera will never move such that a region outside the world boundaries
  /// is shown, meaning it will stop following when the object gets close to the
  /// edges.
  ///
  /// Changing this value can immediately snap the camera if it is a wrong
  /// position, but other than that it's just prevent movement so should not
  /// add any non-smooth movement.
  Rect? worldBounds;

  /// If set, the camera will zoom by this ratio. This can be greater than 1
  /// (zoom in) or smaller (zoom out), but should always be greater than zero.
  ///
  /// Note: do not confuse this with the zoom applied by the viewport. The
  /// viewport applies a (normally) fixed zoom to adapt multiple screens into
  /// one aspect ratio. The zoom might be different per dimension depending
  /// on the Viewport implementation. Also, if used with the default
  /// FlameGame implementation, it will apply to all components.
  /// The zoom from the camera is only for components that respect camera,
  /// and is applied after the viewport is set. It exists to be used if there
  /// is any kind of user configurable camera on your game.
  double zoom = 1.0;

  Vector2 get gameSize => _viewport.effectiveSize / zoom;

  /// Use this method to transform the canvas using the current rules provided
  /// by this camera object.
  ///
  /// If you are using FlameGame, this will be done for you for all non-HUD
  /// components.
  /// When using this method you are responsible for saving/restoring canvas
  /// state to avoid leakage.
  void apply(Canvas canvas) {
    canvas.transform(_transformMatrix(position, zoom).storage);
  }

  Vector2? _canvasSize;
  Vector2 get canvasSize {
    assert(
      _canvasSize != null,
      'Property `canvasSize` cannot be accessed before the layout stage',
    );
    return _canvasSize!;
  }

  void handleResize(Vector2 canvasSize) {
    _canvasSize = canvasSize.clone();
    _viewport.resize(canvasSize);
  }

  Matrix4 _transformMatrix(Vector2 position, double zoom) {
    final translateX = -_position.x * zoom;
    final translateY = -_position.y * zoom;
    if (_transform.m11 == zoom &&
        _transform.m22 == zoom &&
        _transform.m33 == zoom &&
        _transform.m41 == translateX &&
        _transform.m42 == translateY) {
      return _transform;
    }
    _transform.setIdentity();
    _transform.translate(translateX, translateY);
    _transform.scale(zoom, zoom, 1);
    return _transform;
  }

  // TODO(st-pasha): replace with the transform matrix
  late Projector _combinedProjector;
  Projector get combinedProjector => _combinedProjector;

  /// This smoothly updates the camera for an amount of time [dt].
  ///
  /// This should be called by the Game class during the update cycle.
  void update(double dt) {
    final ds = speed * dt;
    final shake = _shakeDelta();

    _currentRelativeOffset.moveToTarget(_targetRelativeOffset, ds);
    if (_targetCameraDelta != null && _currentCameraDelta != null) {
      _currentCameraDelta?.moveToTarget(_targetCameraDelta!, ds);
    }
    _position = _target()..add(shake);

    if (shaking) {
      _shakeTimer -= dt;
      if (_shakeTimer < 0.0) {
        _shakeTimer = 0.0;
      }
    }
  }

  /// Use this to immediately "snap" the camera to where it should be right
  /// now. This bypasses any currently smooth transitions and might be janky,
  /// but can be used to setup after a new world transition for example.
  void snap() {
    if (_targetCameraDelta != null && _currentCameraDelta != null) {
      _currentCameraDelta!.setFrom(_targetCameraDelta!);
    }
    _currentRelativeOffset.setFrom(_targetRelativeOffset);
    update(0);
  }

  // Coordinates

  @override
  Vector2 unprojectVector(Vector2 screenCoordinates) {
    return _position + (screenCoordinates / zoom);
  }

  @override
  Vector2 projectVector(Vector2 worldCoordinates) {
    return (worldCoordinates - _position) * zoom;
  }

  @override
  Vector2 unscaleVector(Vector2 screenCoordinates) {
    return screenCoordinates / zoom;
  }

  @override
  Vector2 scaleVector(Vector2 worldCoordinates) {
    return worldCoordinates * zoom;
  }

  /// Takes coordinates in the screen space and returns their counter-part in
  /// the world space.
  Vector2 screenToWorld(Vector2 screenCoordinates) {
    return unprojectVector(screenCoordinates);
  }

  /// Takes coordinates in the world space and returns their counter-part in
  /// the screen space.
  Vector2 worldToScreen(Vector2 worldCoordinates) {
    return projectVector(worldCoordinates);
  }

  /// This is the (current) absolute target of the camera, i.e., the
  /// coordinate that should with `relativeOffset` taken into consideration but
  /// regardless of world boundaries or shake.
  Vector2 absoluteTarget() {
    return _currentCameraDelta ?? follow ?? Vector2.zero();
  }

  // Follow

  /// Immediately snaps the camera to start following the [component].
  ///
  /// This means that the camera will move so that the position vector of the
  /// component is in a fixed position on the screen.
  /// That position is determined by a fraction of screen size defined by
  /// [relativeOffset] (default to the center).
  /// [worldBounds] can be optionally set to add boundaries to how far the
  /// camera is allowed to move.
  /// The component is "grabbed" by its anchor (default top left).
  /// So for example if you want the center of the object to be at the fixed
  /// position, set the components anchor to center.
  void followComponent(
    PositionComponent component, {
    Anchor relativeOffset = Anchor.center,
    Rect? worldBounds,
  }) {
    followVector2(
      component.position,
      relativeOffset: relativeOffset,
      worldBounds: worldBounds,
    );
  }

  /// Immediately snaps the camera to start following [vector2].
  ///
  /// This means that the camera will move so that the position vector is in a
  /// fixed position on the screen.
  /// That position is determined by a fraction of screen size defined by
  /// [relativeOffset] (default to the center).
  /// [worldBounds] can be optionally set to add boundaries to how far the
  /// camera is allowed to move.
  void followVector2(
    Vector2 vector2, {
    Anchor relativeOffset = Anchor.center,
    Rect? worldBounds,
  }) {
    follow = vector2;
    if (worldBounds != null) {
      this.worldBounds = worldBounds;
    }
    _targetRelativeOffset.setFrom(relativeOffset.toVector2());
    _currentRelativeOffset.setFrom(_targetRelativeOffset);
  }

  /// This will trigger a smooth transition to a new relative offset.
  ///
  /// You can use this for example to change camera modes in your game, maybe
  /// you have two different options for the player to choose or your have a
  /// "dialog" camera that puts the player in a better place to show the
  /// dialog UI.
  void setRelativeOffset(Anchor newRelativeOffset) {
    _targetRelativeOffset.setFrom(newRelativeOffset.toVector2());
  }

  Vector2 _screenDelta() {
    return gameSize.clone()..multiply(_currentRelativeOffset);
  }

  Vector2 _target() {
    final target = absoluteTarget();
    final attemptedTarget = target - _screenDelta();

    final bounds = worldBounds;
    if (bounds != null) {
      if (bounds.width > gameSize.x * zoom) {
        final cameraLeftEdge = attemptedTarget.x;
        final cameraRightEdge = attemptedTarget.x + gameSize.x;
        if (cameraLeftEdge < bounds.left) {
          attemptedTarget.x = bounds.left;
        } else if (cameraRightEdge > bounds.right) {
          attemptedTarget.x = bounds.right - gameSize.x;
        }
      } else {
        attemptedTarget.x = (gameSize.x - bounds.width) / 2;
      }

      if (bounds.height > gameSize.y * zoom) {
        final cameraTopEdge = attemptedTarget.y;
        final cameraBottomEdge = attemptedTarget.y + gameSize.y;
        if (cameraTopEdge < bounds.top) {
          attemptedTarget.y = bounds.top;
        } else if (cameraBottomEdge > bounds.bottom) {
          attemptedTarget.y = bounds.bottom - gameSize.y;
        }
      } else {
        attemptedTarget.y = (gameSize.y - bounds.height) / 2;
      }
    }

    return attemptedTarget;
  }

  // Movement

  /// Moves the camera by a given [displacement] (delta). This is the same as
  /// [moveTo] but instead of providing an absolute end position, you can
  /// provide a desired translation vector.
  void translateBy(Vector2 displacement) {
    moveTo(absoluteTarget() + displacement);
  }

  /// Applies an ad-hoc movement to the camera towards the target, bypassing
  /// follow. Once it arrives the camera will not move until [resetMovement]
  /// is called.
  ///
  /// The camera will be smoothly transitioned to this position.
  /// This will replace any previous targets.
  void moveTo(Vector2 position) {
    _currentCameraDelta = _position + _screenDelta();
    _targetCameraDelta = position.clone();
  }

  /// Instantly moves the camera to the target, bypassing follow.
  /// This will replace any previous targets.
  void snapTo(Vector2 position) {
    moveTo(position);
    snap();
  }

  /// Smoothly resets any moveTo targets.
  void resetMovement() {
    _currentCameraDelta = null;
    _targetCameraDelta = null;
  }

  // Shake

  /// Applies a shaking effect to the camera for [duration] seconds and with
  /// [intensity] expressed in pixels.
  void shake({double? duration, double? intensity}) {
    _shakeTimer += duration ?? defaultShakeDuration;
    _shakeIntensity = intensity ?? defaultShakeIntensity;
  }

  /// Whether the camera is currently shaking or not.
  bool get shaking => _shakeTimer > 0.0;

  /// Buffer to re-use for the shake delta.
  final _shakeBuffer = Vector2.zero();

  /// The random number generator to use for shaking
  final _shakeRng = math.Random();

  /// Generates one value between [-1, 1] * [_shakeIntensity] used once for each
  /// of the axis in the shake delta.
  double _shakeValue() => (_shakeRng.nextDouble() - 0.5) * 2 * _shakeIntensity;

  /// Generates a random [Vector2] of displacement applied to the camera.
  /// This will be a random [Vector2] every tick causing a shakiness effect.
  Vector2 _shakeDelta() {
    if (shaking) {
      _shakeBuffer.setValues(_shakeValue(), _shakeValue());
    } else if (!_shakeBuffer.isZero()) {
      _shakeBuffer.setZero();
    }
    return _shakeBuffer;
  }

  /// If you need updated on when the position of the camera is updated you
  /// can override this.
  void onPositionUpdate(Vector2 position) {}
}
