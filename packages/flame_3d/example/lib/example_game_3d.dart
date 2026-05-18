import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d_example/components/player.dart';
import 'package:flame_3d_example/components/room_bounds.dart';
import 'package:flame_3d_example/example_camera_3d.dart';

/// A common base for examples that use the standard player + camera + room
/// setup. Subclasses override [onSetup] to populate the world.
abstract class ExampleGame3D extends FlameGame3D<World3D, PlayerCamera>
    with DragCallbacks, ScrollDetector, HasKeyboardHandlerComponents {
  ExampleGame3D({Player? player})
    : player = player ?? Player(position: Vector3(0, 1, 0)),
      super(world: World3D(), camera: _placeholderCamera);

  final Player player;

  // FlameGame3D requires a camera at construction. We replace it in onLoad
  // once the player is available.
  static final _placeholderPlayer = Player(position: Vector3.zero());
  static InteractiveCamera get _placeholderCamera =>
      InteractiveCamera(player: _placeholderPlayer);

  @override
  FutureOr<void> onLoad() async {
    super.camera = InteractiveCamera(player: player);

    world.addAll([
      RoomBounds(),
      LightComponent.ambient(intensity: 1.0),
      player,
    ]);
    onSetup();
  }

  void onSetup();

  @override
  void onScroll(PointerScrollInfo info) => camera.onScroll(info);

  @override
  void onDragUpdate(DragUpdateEvent event) {
    camera.onDragUpdate(event);
    super.onDragUpdate(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    camera.onDragEnd(event);
    super.onDragEnd(event);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    camera.onDragCancel(event);
    super.onDragCancel(event);
  }
}
