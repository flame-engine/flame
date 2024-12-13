import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame_3d/camera.dart';

class FlameGame3D<W extends World3D> extends FlameGame<W> {
  FlameGame3D({
    super.children,
    W? world,
    CameraComponent3D? camera,
  }) : super(
          world: world ?? World3D(clearColor: const Color(0xFFFFFFFF)) as W,
          camera: camera ?? CameraComponent3D(),
        );

  @override
  CameraComponent3D get camera => super.camera as CameraComponent3D;
}
