import 'dart:math' as math;

import '../../components.dart';
import '../../game.dart';

class Camera {
  static const DEFAULT_CAMERA_SPEED = 50.0; // in pixels/s
  static const DEFAULT_SHAKE_INTENSITY = 75.0; // in pixels
  static const DEFAULT_SHAKE_DURATION = 0.3; // in seconds

  /// This must be set by the Game as soon as the Camera is created.
  ///
  /// Do not change this reference.
  BaseGame gameRef;

  Vector2 _currentCameraDelta = Vector2.zero();
  Vector2 _targetCameraDelta = Vector2.zero();

  bool onTop = false;
  double _shakeTimer = 0.0;

  double cameraSpeed = DEFAULT_CAMERA_SPEED;
  double shakeIntensity = DEFAULT_SHAKE_INTENSITY;

  /// This is the current position of the camera.
  ///
  /// Zero means no translation is applied.
  /// You should probably not change this yourself, but use the provided
  /// methods for smooth transitions.
  final Vector2 position = Vector2.zero();

  /// If set, the camera will "follow" this component, making sure that this
  /// component is always rendered in a fixed position in the screen, by
  /// immediately moving the camera to "focus" on the object.
  ///
  /// You probably want to set it to the player component.
  /// Note that this is not smooth because the movement of the follow object
  /// is assumed to be smooth.
  PositionComponent follow;

  Camera();

  void handle(double dt) {
    if (_currentCameraDelta != _targetCameraDelta) {
      final ds = cameraSpeed * dt;
      final diff = _targetCameraDelta - _currentCameraDelta;
      if (diff.length < ds) {
        _currentCameraDelta = _targetCameraDelta.clone();
      } else {
        _currentCameraDelta = _currentCameraDelta + diff
          ..scaleTo(ds);
      }
    }

    final shake = Vector2(_shakeDelta(), _shakeDelta());
    position.setFrom(_getTarget() + _currentCameraDelta + shake);

    if (shaking) {
      _shakeTimer -= dt;
      if (_shakeTimer < 0.0) {
        _shakeTimer = 0.0;
      }
    }
  }

  Vector2 _getTarget() {
    if (follow == null) {
      return Vector2.zero();
    }
    return follow.position + (gameRef.size + follow.size) / 2;
  }

  bool get shaking => _shakeTimer > 0.0;

  double _shakeDelta() {
    if (shaking) {
      return math.Random.secure().nextDouble() * shakeIntensity;
    }
    return 0.0;
  }

  void top() {
    onTop = true;
    _targetCameraDelta = Vector2(0, -gameRef.size.y / 4);
  }

  void reset() {
    onTop = false;
    _targetCameraDelta = Vector2.zero();
  }

  void softReset() {
    if (onTop) {
      top();
    } else {
      reset();
    }
  }

  void moveTo(Vector2 p) {
    _targetCameraDelta.x = p.x;
    _targetCameraDelta.y = p.y;
  }

  void shake({double amount = DEFAULT_SHAKE_DURATION}) {
    _shakeTimer += amount;
  }
}
