import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart' as v64 show Vector2;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d_example/components/player.dart';
import 'package:flame_3d_example/components/simple_hud.dart';
import 'package:flutter/services.dart';

/// A camera that smoothly follows a [Player].
///
/// This is the base camera for most examples. It handles third-person
/// follow logic.
class PlayerCamera extends CameraComponent3D {
  PlayerCamera({
    required this.player,
    this.distance = 5.0,
    Viewport? viewport,
    super.world,
  }) : super(
         position: Vector3(0, 2, 4),
         projection: CameraProjection.perspective,
         viewport:
             viewport ??
             FixedResolutionViewport(resolution: v64.Vector2(800, 600)),
         hudComponents: [SimpleHud()],
       );

  final Player player;

  double distance;

  void reset() {
    position = player.position + _positionOffset(player.rotation);
    target = player.position + player.lookAt;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final targetOffset = player.position + _positionOffset(player.rotation);
    final targetLookAt = player.position + player.lookAt;

    position += (targetOffset - position) * _linearSpeed * dt;
    target += (targetLookAt - target) * _rotationSpeed * dt;
  }

  void onScroll(PointerScrollInfo info) {}

  void onDragUpdate(DragUpdateEvent event) {}

  void onDragEnd(DragEndEvent event) {}

  void onDragCancel(DragCancelEvent event) {}

  Vector3 _positionOffset(Quaternion rotation) {
    final forward = Vector3(0, -1, 1)..applyQuaternion(rotation);
    return forward.normalized() * -distance;
  }

  static const double _rotationSpeed = 6.0;
  static const double _linearSpeed = 12.0;
}

/// Extends [PlayerCamera] with drag-look mode and scroll zoom.
///
/// Used by examples that need free camera control (M to toggle).
class InteractiveCamera extends PlayerCamera with KeyboardHandler {
  InteractiveCamera({
    required super.player,
    super.distance,
    super.viewport,
    super.world,
  });

  CameraMode _mode = CameraMode.player;
  Vector2 delta = Vector2.zero();

  CameraMode get mode => _mode;

  set mode(CameraMode mode) {
    _mode = mode;
    reset();
  }

  @override
  void reset() {
    if (_mode == CameraMode.drag) {
      position.setFrom(Vector3(0, 2, 4));
      target.setFrom(Vector3(-1, 0, 0));
    } else {
      super.reset();
    }
    delta.setZero();
  }

  @override
  void update(double dt) {
    if (_mode == CameraMode.drag) {
      _dragUpdate(dt);
    } else {
      super.update(dt);
    }
  }

  void _dragUpdate(double dt) {
    rotate(delta.x * dt, delta.y * dt);
    target.setFrom(position + _positionOffset(rotation));
  }

  @override
  bool onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyR) {
        reset();
        player.reset();
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.keyM) {
        mode = mode == CameraMode.drag ? CameraMode.player : CameraMode.drag;
        return true;
      }
    }
    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onScroll(PointerScrollInfo info) {
    const scrollSensitivity = 0.01;
    final delta = info.scrollDelta.global.y.clamp(-10, 10) * scrollSensitivity;
    distance += delta;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    delta.setValues(event.deviceDelta.x, event.deviceDelta.y);

    super.onDragUpdate(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    delta.setZero();

    super.onDragEnd(event);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    delta.setZero();
    super.onDragCancel(event);
  }
}

enum CameraMode { drag, player }
