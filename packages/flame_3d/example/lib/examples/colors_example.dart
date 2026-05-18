import 'package:flame/palette.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d_example/components/rendered_point_light.dart';
import 'package:flame_3d_example/example_game_3d.dart';

class ColorsExample extends ExampleGame3D {
  @override
  void onSetup() {
    world.addAll([
      RenderedPointLight(
        position: Vector3(0, 0.2, 0),
        color: const Color(0xFFFF00FF),
      ),
      MeshComponent(
        position: Vector3(5, 2, 5),
        mesh: SphereMesh(
          radius: 1,
          material: SpatialMaterial(albedoColor: BasicPalette.red.color),
        ),
      ),
      MeshComponent(
        position: Vector3(-5, 2, -5),
        mesh: ConeMesh(
          radius: 1,
          height: 2,
          material: SpatialMaterial(albedoColor: BasicPalette.green.color),
        ),
      ),
      MeshComponent(
        position: Vector3(5, 0, -5),
        mesh: CuboidMesh(
          size: Vector3(1, 2, 1),
          material: SpatialMaterial(albedoColor: BasicPalette.blue.color),
        ),
      ),
    ]);
  }
}
