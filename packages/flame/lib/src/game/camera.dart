import 'dart:math' as math;
import 'dart:ui' show Rect;

import '../../components.dart';
import '../../game.dart';

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
/// Note: in the context of the BaseGame, the camera effectively translates
/// the position where components are rendered with relation to the Viewport.
/// Components marked as `isHud = true` are always rendered in screen
/// coordinates, bypassing the camera altogether.
///
/// Note: right now this only applies to rendering. No transformation is
/// done on event handling (for gestures). You have to transform it yourself
/// using [screenToWorld].
class Camera {
  static const defaultCameraSpeed = 50.0; // in pixels/s
  static const defaultShakeIntensity = 75.0; // in pixels
  static const defaultShakeDuration = 0.3; // in seconds

  /// This must be set by the Game as soon as the Camera is created.
  ///
  /// Do not change this reference.
  late BaseGame gameRef;

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

  // Configurable parameters

  double cameraSpeed = defaultCameraSpeed;
  double shakeIntensity = defaultShakeIntensity;

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

  Camera();

  /// This smoothly updates the camera for an amount of time [dt].
  ///
  /// This should be called by the Game class during the update cycle.
  void update(double dt) {
    final ds = cameraSpeed * dt;
    final shake = Vector2(_shakeDelta(), _shakeDelta());

    _currentRelativeOffset.moveToTarget(_targetRelativeOffset, ds);
    if (_targetCameraDelta != null && _currentCameraDelta != null) {
      _currentCameraDelta?.moveToTarget(_targetCameraDelta!, ds);
    }
    _position = _target() + shake;

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

  /// Converts a vector in the screen space to the world space.
  Vector2 screenToWorld(Vector2 screenCoordinates) {
    return screenCoordinates + _position;
  }

  /// Converts a vector in the world space to the screen space.
  Vector2 worldToScreen(Vector2 worldCoordinates) {
    return worldCoordinates - _position;
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
    Vector2? relativeOffset,
    Rect? worldBounds,
  }) {
    follow = component.position;
    this.worldBounds = worldBounds;
    _targetRelativeOffset.setFrom(relativeOffset ?? Anchor.center.toVector2());
    _currentRelativeOffset.setFrom(_targetRelativeOffset);
  }

  /// This will trigger a smooth transition to a new relative offset.
  ///
  /// You can use this for example to change camera modes in your game, maybe
  /// you have two different options for the player to choose or your have a
  /// "dialog" camera that puts the player in a better place to show the
  /// dialog UI.
  void setRelativeOffset(Vector2 newRelativeOffset) {
    _targetRelativeOffset.setFrom(newRelativeOffset);
  }

  Vector2 _screenDelta() {
    return gameRef.size.clone()..multiply(_currentRelativeOffset);
  }

  Vector2 _target() {
    final target = _currentCameraDelta ?? follow ?? Vector2.zero();
    final attemptedTarget = target - _screenDelta();

    final bounds = worldBounds;
    if (bounds != null) {
      if (bounds.width > gameRef.size.x) {
        final cameraLeftEdge = attemptedTarget.x;
        final cameraRightEdge = attemptedTarget.x + gameRef.size.x;
        if (cameraLeftEdge < bounds.left) {
          attemptedTarget.x = bounds.left;
        } else if (cameraRightEdge > bounds.right) {
          attemptedTarget.x = bounds.right - gameRef.size.x;
        }
      } else {
        attemptedTarget.x = (gameRef.size.x - bounds.width) / 2;
      }

      if (bounds.height > gameRef.size.y) {
        final cameraTopEdge = attemptedTarget.y;
        final cameraBottomEdge = attemptedTarget.y + gameRef.size.y;
        if (cameraTopEdge < bounds.top) {
          attemptedTarget.y = bounds.top;
        } else if (cameraBottomEdge > bounds.bottom) {
          attemptedTarget.y = bounds.bottom - gameRef.size.y;
        }
      } else {
        attemptedTarget.y = (gameRef.size.y - bounds.height) / 2;
      }
    }

    return attemptedTarget;
  }

  // Movement

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

  /// Applies a shaking effect to the camera for [amount] seconds.
  ///
  /// The intensity can be controlled via the [shakeIntensity] property.
  void shake({double amount = defaultShakeDuration}) {
    _shakeTimer += amount;
  }

  /// Whether the camera is currently shaking or not.
  bool get shaking => _shakeTimer > 0.0;

  /// Generates a random amount of displacement applied to the camera.
  /// This will be a random number every tick causing a shakiness effect.
  double _shakeDelta() {
    if (shaking) {
      return math.Random.secure().nextDouble() * shakeIntensity;
    }
    return 0.0;
  }

  /// If you need updated on when the position of the camera is updated you
  /// can override this.
  void onPositionUpdate(Vector2 position) {}
}
