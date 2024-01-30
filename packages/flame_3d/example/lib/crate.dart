import 'dart:async';

import 'package:example/main.dart';
import 'package:flame/components.dart' show HasGameReference;
import 'package:flame/flame.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

class Crate extends MeshComponent with HasGameReference<ExampleGame3D> {
  Crate({
    required Vector3 size,
    super.position,
  }) : super(mesh: BoxMesh(size: size));

  @override
  FutureOr<void> onLoad() async {
    final crateTexture = await Flame.images.loadTexture('crate.jpg');
    material = DefaultMaterial(texture: crateTexture);
  }

  double direction = 0.1;

  @override
  void update(double dt) {
    if (scale.x > 1.1 || scale.x < 0.9) {
      direction *= -1;
    }
    scale.add(Vector3.all(direction * dt));
  }
}
