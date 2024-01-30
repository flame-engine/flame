import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

class BoxMesh extends Mesh {
  BoxMesh({
    required Vector3 size,
    super.material,
  }) : super(geometry: CuboidGeometry(size: size));
}
