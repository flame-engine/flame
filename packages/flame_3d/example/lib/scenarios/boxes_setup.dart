import 'dart:math';

import 'package:example/components/crate.dart';
import 'package:example/components/rendered_point_light.dart';
import 'package:example/components/rotating_light.dart';
import 'package:example/example_game_3d.dart';
import 'package:example/scenarios/game_setup.dart';
import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/resources.dart';

class BoxesScenario implements GameScenario {
  static final BoxesScenario instance = BoxesScenario._();

  BoxesScenario._();

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

      // Add the player

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
      final height = rnd.range(1, 12);

      game.world.add(
        MeshComponent(
          position: Vector3(rnd.range(-15, 15), height / 2, rnd.range(-15, 15)),
          mesh: CuboidMesh(
            size: Vector3(1, height, 1),
            material: SpatialMaterial(
              albedoTexture: ColorTexture(
                Color.fromRGBO(rnd.iRange(20, 255), rnd.iRange(10, 55), 30, 1),
              ),
            ),
          ),
        ),
      );
    }
  }
}

extension on Random {
  double range(num min, num max) => nextDouble() * (max - min) + min;

  int iRange(int min, int max) => range(min, max).toInt();
}
