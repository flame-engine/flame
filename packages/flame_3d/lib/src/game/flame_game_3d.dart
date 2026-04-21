import 'package:flame/game.dart';
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/game.dart';

class FlameGame3D<W extends World3D, C extends CameraComponent3D>
    extends FlameGame<W>
    with Game3D {
  FlameGame3D({
    super.children,
    W? world,
    C? camera,
  }) : super(
         world: world ?? World3D() as W,
         camera: camera ?? CameraComponent3D() as C,
       );

  @override
  C get camera => super.camera as C;
}
