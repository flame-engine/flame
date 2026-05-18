import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d_example/example_game_3d.dart';

class BasicExample extends ExampleGame3D {
  @override
  void onSetup() {
    final rnd = Random();
    for (var i = 0; i < 20; i++) {
      final height = rnd.nextDoubleBetween(1, 12);
      world.add(
        MeshComponent(
          position: Vector3(
            rnd.nextDoubleBetween(-15, 15),
            height / 2,
            rnd.nextDoubleBetween(-15, 15),
          ),
          mesh: CuboidMesh(
            size: Vector3(1, height, 1),
            material: UnlitMaterial(
              albedoTexture: ColorTexture(
                Color.fromRGBO(
                  rnd.nextIntBetween(0, 255),
                  rnd.nextIntBetween(0, 255),
                  rnd.nextIntBetween(0, 255),
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
