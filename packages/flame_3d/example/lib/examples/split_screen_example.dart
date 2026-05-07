import 'package:flame/palette.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d_example/components/crate.dart';
import 'package:flame_3d_example/components/player.dart';
import 'package:flame_3d_example/components/rendered_point_light.dart';
import 'package:flame_3d_example/components/split_viewport.dart';
import 'package:flame_3d_example/example_camera_3d.dart';
import 'package:flame_3d_example/example_game_3d.dart';
import 'package:flutter/services.dart';

class SplitScreenExample extends ExampleGame3D {
  final Player player2 = Player(
    position: Vector3(2, 1, 0),
    upKey: LogicalKeyboardKey.arrowUp,
    downKey: LogicalKeyboardKey.arrowDown,
    leftKey: LogicalKeyboardKey.arrowLeft,
    rightKey: LogicalKeyboardKey.arrowRight,
    jumpKey: LogicalKeyboardKey.enter,
    runKeys: {LogicalKeyboardKey.controlRight},
    color: BasicPalette.red.color,
  );

  static final _resolution = Vector2(800, 600);

  @override
  void onSetup() {
    camera.removeFromParent();

    addAll([
      PlayerCamera(
        player: player,
        world: world,
        viewport: SplitViewport(
          resolution: _resolution,
          side: SplitSide.left,
        ),
      ),
      PlayerCamera(
        player: player2,
        world: world,
        viewport: SplitViewport(
          resolution: _resolution,
          side: SplitSide.right,
        ),
      ),
    ]);

    world.addAll([
      player2,
      RenderedPointLight(
        position: Vector3(0, 5, 0),
        color: const Color(0xFFFFFFFF),
      ),
      Crate(position: Vector3(0, 3, 0), size: Vector3.all(2)),
      Crate(position: Vector3(4, 1, -3), size: Vector3.all(1.5)),
      Crate(position: Vector3(-3, 1, 2), size: Vector3.all(1)),
      MeshComponent(
        position: Vector3(0, 0.5, -5),
        mesh: SphereMesh(
          radius: 0.5,
          material: SpatialMaterial(
            albedoTexture: ColorTexture(BasicPalette.green.color),
          ),
        ),
      ),
    ]);
  }
}
