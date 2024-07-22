import 'dart:async';

import 'package:flame/flame.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

class Crate extends MeshComponent {
  Crate({
    required Vector3 size,
    super.position,
  }) : super(mesh: CuboidMesh(size: size));

  @override
  FutureOr<void> onLoad() async {
    final crateTexture = await Flame.images.loadTexture('crate.jpg');
    mesh.updateSurfaces((surfaces) {
      surfaces[0].material = SpatialMaterial(
        albedoTexture: crateTexture,
      );
    });
  }

  double direction = 0.1;

  @override
  void update(double dt) {
    if (scale.x >= 1.19 || scale.x <= 0.99) {
      direction *= -1;
    }
    scale.add(Vector3.all(direction * dt));
  }
}
