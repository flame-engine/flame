import 'dart:math';

import 'package:example/components/crate.dart';
import 'package:example/components/rendered_point_light.dart';
import 'package:example/components/rotating_light.dart';
import 'package:example/example_game_3d.dart';
import 'package:example/scenarios/game_scenario.dart';
import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/resources.dart';

class BoxesScenario implements GameScenario {
  @override
  Future<void> onLoad() async {}

  @override
  void setup(ExampleGame3D game) {
    game.world.addAll([
      RotatingLight(),

      RenderedPointLight(
        position: Vector3(0, 0.1, 0),
        color: const Color(0xFFFF00FF),
      ),
      RenderedPointLight(
        position: Vector3(-2, 3, 2),
        color: const Color(0xFFFF2255),
      ),

      // Floating crate
      Crate(
        position: Vector3(0, 5, 0),
        size: Vector3.all(1),
      ),

      // Floating sphere
      MeshComponent(
        position: Vector3(5, 5, 5),
        mesh: SphereMesh(
          radius: 1,
          material: SpatialMaterial(
            albedoTexture: ColorTexture(
              BasicPalette.green.color,
            ),
          ),
        ),
      ),
    ]);

    final rnd = Random();
    for (var i = 0; i < 20; i++) {
      final height = rnd.nextDoubleBetween(1, 12);

      game.world.add(
        MeshComponent(
          position: Vector3(
            rnd.nextDoubleBetween(-15, 15),
            height / 2,
            rnd.nextDoubleBetween(-15, 15),
          ),
          mesh: CuboidMesh(
            size: Vector3(1, height, 1),
            material: SpatialMaterial(
              albedoTexture: ColorTexture(
                Color.fromRGBO(
                  rnd.nextIntBetween(20, 255),
                  rnd.nextIntBetween(10, 55),
                  30,
                  1,
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}
