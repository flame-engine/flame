import 'package:flame/components.dart' show KeyboardHandler;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/game.dart';
import 'package:flutter/gestures.dart' show kMiddleMouseButton;
import 'package:flutter/services.dart'
    show KeyEvent, KeyRepeatEvent, LogicalKeyboardKey, PointerEvent;

class KeyboardControlledCamera extends CameraComponent3D with KeyboardHandler {
  KeyboardControlledCamera({
    super.world,
    super.viewport,
    super.viewfinder,
    super.backdrop,
    super.hudComponents,
  }) : super(
          projection: CameraProjection.perspective,
          mode: CameraMode.firstPerson,
          position: Vector3(0, 2, 4),
          target: Vector3(0, 2, 0),
          up: Vector3(0, 1, 0),
          fovY: 60,
        );

  final double moveSpeed = 0.9;
  final double rotationSpeed = 0.3;
  final double panSpeed = 2;
  final double orbitalSpeed = 0.5;

  Set<Key> _keysDown = {};
  PointerEvent? pointerEvent;
  double scrollMove = 0;

  final Matrix4 _orbitalMatrix = Matrix4.identity();

  @override
  bool onKeyEvent(KeyEvent event, Set<Key> keysPressed) {
    _keysDown = keysPressed;

    // Switch camera mode
    if (isKeyDown(Key.digit1)) {
      mode = CameraMode.free;
      up = Vector3(0, 1, 0); // Reset roll
    } else if (isKeyDown(Key.digit2)) {
      mode = CameraMode.firstPerson;
      up = Vector3(0, 1, 0); // Reset roll
    } else if (isKeyDown(Key.digit3)) {
      mode = CameraMode.thirdPerson;
      up = Vector3(0, 1, 0); // Reset roll
    } else if (isKeyDown(Key.digit4)) {
      mode = CameraMode.orbital;
      up = Vector3(0, 1, 0); // Reset roll
    }

    if (isKeyDown(Key.keyP) && event is! KeyRepeatEvent) {
      if (projection == CameraProjection.perspective) {
        // Create an isometric view.
        mode = CameraMode.thirdPerson;
        projection = CameraProjection.orthographic;

        position = Vector3(0, 2, -100);
        target = Vector3(0, 2, 0);
        up = Vector3(0, 1, 0);
        fovY = 20;

        yaw(-135 * degrees2Radians, rotateAroundTarget: true);
        pitch(-45 * degrees2Radians, lockView: true, rotateAroundTarget: true);
      } else if (projection == CameraProjection.orthographic) {
        // Reset to default view.
        mode = CameraMode.thirdPerson;
        projection = CameraProjection.perspective;

        position = Vector3(0, 2, 10);
        target = Vector3(0, 2, 0);
        up = Vector3(0, 1, 0);
        fovY = 60;
      }
    }

    return false;
  }

  @override
  void update(double dt) {
    final moveInWorldPlane = switch (mode) {
      CameraMode.firstPerson || CameraMode.thirdPerson => true,
      _ => false,
    };
    final rotateAroundTarget = switch (mode) {
      CameraMode.thirdPerson || CameraMode.orbital => true,
      _ => false,
    };
    final lockView = switch (mode) {
      CameraMode.free || CameraMode.firstPerson || CameraMode.orbital => true,
      _ => false,
    };

    if (mode == CameraMode.orbital) {
      final rotation = _orbitalMatrix
        ..setIdentity()
        ..rotate(up, orbitalSpeed * dt);
      final view = rotation.transform3(position - target);
      position = target + view;
    } else {
      // Camera rotation
      if (isKeyDown(Key.arrowDown)) {
        pitch(
          -rotationSpeed * dt,
          lockView: lockView,
          rotateAroundTarget: rotateAroundTarget,
        );
      } else if (isKeyDown(Key.arrowUp)) {
        pitch(
          rotationSpeed * dt,
          lockView: lockView,
          rotateAroundTarget: rotateAroundTarget,
        );
      }
      if (isKeyDown(Key.arrowRight)) {
        yaw(-rotationSpeed * dt, rotateAroundTarget: rotateAroundTarget);
      } else if (isKeyDown(Key.arrowLeft)) {
        yaw(rotationSpeed * dt, rotateAroundTarget: rotateAroundTarget);
      }
      if (isKeyDown(Key.keyQ)) {
        roll(-rotationSpeed * dt);
      } else if (isKeyDown(Key.keyE)) {
        roll(rotationSpeed * dt);
      }

      // Camera movement, if mode is free and mouse button is down we pan the
      // camera.
      if (pointerEvent != null) {
        if (mode == CameraMode.free &&
            pointerEvent?.buttons == kMiddleMouseButton) {
          final mouseDelta = pointerEvent!.delta;
          if (mouseDelta.dx > 0) {
            moveRight(panSpeed * dt, moveInWorldPlane: moveInWorldPlane);
          } else if (mouseDelta.dx < 0) {
            moveRight(-panSpeed * dt, moveInWorldPlane: moveInWorldPlane);
          }
          if (mouseDelta.dy > 0) {
            moveUp(-panSpeed * dt);
          } else if (mouseDelta.dy < 0) {
            moveUp(panSpeed * dt);
          }
        } else {
          const mouseMoveSensitivity = 0.003;
          yaw(
            (pointerEvent?.delta.dx ?? 0) * mouseMoveSensitivity,
            rotateAroundTarget: rotateAroundTarget,
          );
          pitch(
            (pointerEvent?.delta.dy ?? 0) * mouseMoveSensitivity,
            lockView: lockView,
            rotateAroundTarget: rotateAroundTarget,
          );
        }
        pointerEvent = null;
      }

      // Keyboard movement
      if (isKeyDown(Key.keyW)) {
        moveForward(moveSpeed * dt);
      } else if (isKeyDown(Key.keyS)) {
        moveForward(-moveSpeed * dt);
      }
      if (isKeyDown(Key.keyA)) {
        moveRight(-moveSpeed * dt);
      } else if (isKeyDown(Key.keyD)) {
        moveRight(moveSpeed * dt);
      }

      if (mode == CameraMode.free) {
        if (isKeyDown(Key.space)) {
          moveUp(moveSpeed * dt);
        } else if (isKeyDown(Key.controlLeft)) {
          moveUp(-moveSpeed * dt);
        }
      }
    }

    // if (mode == CameraMode.thirdPerson ||
    //     mode == CameraMode.orbital ||
    //     mode == CameraMode.free) {
    //   moveToTarget(-scrollMove);
    //   if (isKeyDown(Key.numpadSubtract)) {
    //     moveToTarget(2 * dt);
    //   } else if (isKeyDown(Key.numpadAdd)) {
    //     moveToTarget(-2 * dt);
    //   }
    // }
  }

  bool isKeyDown(Key key) => _keysDown.contains(key);
}

typedef Key = LogicalKeyboardKey;
