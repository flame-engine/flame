import 'dart:async';

import 'package:example/components/player.dart';
import 'package:example/components/room_bounds.dart';
import 'package:example/example_camera_3d.dart';
import 'package:example/scenarios/game_scenario.dart';
import 'package:flame/events.dart';
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class ExampleGame3D extends FlameGame3D<World3D, ExampleCamera3D>
    with DragCallbacks, ScrollDetector, HasKeyboardHandlerComponents {
  late final Player player;

  ExampleGame3D()
    : super(
        world: World3D(clearColor: const Color(0xFFFFFFFF)),
        camera: ExampleCamera3D(),
      );

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (overlays.isActive('console')) {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.backquote) {
        overlays.remove('console');
      }
    } else {
      if (event is KeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.backquote) {
          overlays.add('console');
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.keyR) {
          camera.reset();
          player.reset();
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.keyM) {
          camera.mode = camera.mode == CameraMode.drag
              ? CameraMode.player
              : CameraMode.drag;
          return KeyEventResult.handled;
        }
      }
    }

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  FutureOr<void> onLoad() async {
    await GameScenario.loadAll();

    world.addAll([
      RoomBounds(),
      LightComponent.ambient(
        intensity: 1.0,
      ),
      player = Player(
        position: Vector3(0, 1, 0),
      ),
    ]);

    GameScenario.defaultSetup(this);
  }

  @override
  void onScroll(PointerScrollInfo info) {
    const scrollSensitivity = 0.01;
    final delta = info.scrollDelta.global.y.clamp(-10, 10) * scrollSensitivity;

    camera.distance += delta;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (camera.mode == CameraMode.drag) {
      camera.delta.setValues(event.deviceDelta.x, event.deviceDelta.y);
    }
    super.onDragUpdate(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    camera.delta.setZero();
    super.onDragEnd(event);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    camera.delta.setZero();
    super.onDragCancel(event);
  }
}
