import 'dart:ui';

import 'package:example/main.dart';
import 'package:flame/components.dart' show HasGameReference;
import 'package:flame_3d/camera.dart';
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
                StandardMaterial(albedoTexture: ColorTexture(Colors.purple)),
          ),
        );

  @override
  void renderTree(Canvas canvas) {
    // Only show the box if we are in third person mode.
    if (game.camera.mode == CameraMode.thirdPerson) {
      position.setFrom(game.camera.target);
      super.renderTree(canvas);
    }
  }
}
