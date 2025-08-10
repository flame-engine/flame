import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame_3d/camera.dart';

class FlameGame3D<W extends World3D, C extends CameraComponent3D>
    extends FlameGame<W> {
  FlameGame3D({
    super.children,
    W? world,
    C? camera,
  }) : super(
         world: world ?? World3D(clearColor: const Color(0xFFFFFFFF)) as W,
         camera: camera ?? CameraComponent3D() as C,
       );

  @override
  C get camera => super.camera as C;
}
