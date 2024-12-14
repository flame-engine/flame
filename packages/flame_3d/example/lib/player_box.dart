import 'dart:ui';

import 'package:example/main.dart';
import 'package:flame/components.dart' show HasGameReference;
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter/material.dart' show Colors;

class PlayerBox extends MeshComponent with HasGameReference<ExampleGame3D> {
  PlayerBox()
      : super(
          mesh: CuboidMesh(
            size: Vector3.all(0.5),
            material:
                SpatialMaterial(albedoTexture: ColorTexture(Colors.purple)),
          ),
        );

  @override
  void renderTree(Canvas canvas) {
    game.camera.target = position + Vector3(0, 2, 0);
  }
}
