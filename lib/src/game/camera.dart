import 'dart:math' as math;
import 'dart:ui' show Rect;

import '../../components.dart';
import '../../game.dart';

/// Utility method to smoothly transition vectors.
void _moveToTarget(
  Vector2 current,
  Vector2 target,
  double ds,
) {
  if (current != target) {
    final diff = target - current;
    if (diff.length < ds) {
      current.setFrom(target);
    } else {
      diff.scaleTo(ds);
      current.setFrom(current + diff);
    }
  }
}

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
/// If you want, you can call [followObject] at the beginning of your
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
  static const DEFAULT_CAMERA_SPEED = 50.0; // in pixels/s
  static const DEFAULT_SHAKE_INTENSITY = 75.0; // in pixels
  static const DEFAULT_SHAKE_DURATION = 0.3; // in seconds

  /// This must be set by the Game as soon as the Camera is created.
  ///
  /// Do not change this reference.
  BaseGame gameRef;

  /// If set, this bypasses follow and moves the camera to a specific point
  /// in the world.
  ///
  /// You can use this if you are not using follow but have a few different
  /// camera positions or if you are using follow but you want to highlight a
  /// spot in the world during an animation.
  Vector2 _currentCameraDelta;
  Vector2 _targetCameraDelta;

  /// Remaining time in seconds for the camera shake.
  double _shakeTimer = 0.0;

  // Configurable parameters

  double cameraSpeed = DEFAULT_CAMERA_SPEED;
  double shakeIntensity = DEFAULT_SHAKE_INTENSITY;

  /// This is the current position of the camera, ie the world coordinate that is
  /// rendered on the top left of the screen (origin of the screen space).
  ///
  /// Zero means no translation is applied.
  /// You can't change this directly; the camera will handle all ongoing
  /// movements so they smoothly transition.
  /// If you want to immediately snap the camera to a new place, you can do:
  /// ```
  ///   camera.moveTo(newPosition);
  ///   camera.snap();
  /// ```
  Vector2 get position => _position.clone();

  final Vector2 _position = Vector2.zero();

  /// If set, the camera will "follow" this component, making sure that this
  /// component is always rendered in a fixed position in the screen, by
  /// immediately moving the camera to "focus" on the object.
  ///
  /// You probably want to set it to the player component.
  /// Note that this is not smooth because the movement of the follow object
  /// is assumed to be smooth.
  PositionComponent follow;

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
  /// Changing this value can immediately snap the camera if it is an wrong
  /// position, but other than that it's just prevent movement so should not
  /// add any non-smooth movement.
  Rect worldBounds;

  Camera();

  /// This smoothly updates the camera for an amount of time [dt].
  ///
  /// This should be called by the Game class during the update cycle.
  void handle(double dt) {
    final ds = cameraSpeed * dt;
    final shake = Vector2(_shakeDelta(), _shakeDelta());

    if (_targetCameraDelta != null) {
      _moveToTarget(_currentCameraDelta, _targetCameraDelta, ds);
      position.setFrom(_currentCameraDelta + shake);
    } else {
      _moveToTarget(_currentRelativeOffset, _targetRelativeOffset, ds);
      position.setFrom(_getTarget() + shake);
    }

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
    if (_targetCameraDelta != null) {
      _targetCameraDelta.setFrom(_currentCameraDelta);
    }
    _targetRelativeOffset.setFrom(_currentRelativeOffset);
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

  /// Immediately snaps the camera to start following the object [follow].
  ///
  /// This means that the camera will move so that the [follow] object is
  /// in a fixed position on the screen.
  /// That position is determined by a fraction of screen size defined by
  /// [relativeOffset] (default to the center).
  /// [worldBounds] can be optionally set to add boundaries to how far the
  /// camera is allowed to move.
  void followObject(
    PositionComponent follow, {
    Vector2 relativeOffset,
    Rect worldBounds,
  }) {
    this.follow = follow;
    this.worldBounds = worldBounds;
    _targetRelativeOffset.setFrom(relativeOffset ?? Anchor.center.toVector2);
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

  Vector2 _getTarget() {
    if (follow == null) {
      return Vector2.zero();
    }
    final screenDelta = gameRef.size.clone()..multiply(_currentRelativeOffset);
    final attemptedTarget = follow.position + follow.size / 2 + screenDelta;

    if (worldBounds != null) {
      if (worldBounds.width > gameRef.size.x) {
        final cameraLeftEdge = attemptedTarget.x;
        final cameraRightEdge = attemptedTarget.x + gameRef.size.x;
        if (cameraLeftEdge < worldBounds.left) {
          attemptedTarget.x = worldBounds.left;
        } else if (cameraRightEdge > worldBounds.right) {
          attemptedTarget.x = worldBounds.right - gameRef.size.x;
        }
      } else {
        attemptedTarget.x = (gameRef.size.x - worldBounds.width) / 2;
      }

      if (worldBounds.height > gameRef.size.y) {
        final cameraTopEdge = attemptedTarget.y;
        final cameraBottomEdge = attemptedTarget.y + gameRef.size.y;
        if (cameraTopEdge < worldBounds.top) {
          attemptedTarget.y = worldBounds.top;
        } else if (cameraBottomEdge > worldBounds.bottom) {
          attemptedTarget.y = worldBounds.bottom - gameRef.size.y;
        }
      } else {
        attemptedTarget.y = (gameRef.size.y - worldBounds.height) / 2;
      }
    }

    return attemptedTarget;
  }

  // Movement

  /// Applies an ad-hoc movement to the camera towards the target, bypassing
  /// follow. Once it arrives the camera will not move until resetMovement
  /// is called.
  ///
  /// The camera will be smoothly transitioned to this position.
  /// This will replace any previous targets.
  void moveTo(Vector2 p) {
    _currentCameraDelta = position;
    _targetCameraDelta = p.clone();
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
  void shake({double amount = DEFAULT_SHAKE_DURATION}) {
    _shakeTimer += amount;
  }

  /// Wether the camera is currently shaking or not.
  bool get shaking => _shakeTimer > 0.0;

  /// Generates a random amount of displacement applied to the camera.
  /// This will be a random number every tick causing a shakiness effect.
  double _shakeDelta() {
    if (shaking) {
      return math.Random.secure().nextDouble() * shakeIntensity;
    }
    return 0.0;
  }
}
