import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

class PlaneMesh extends Mesh {
  PlaneMesh({
    required Vector2 size,
    super.material,
  }) : super(geometry: PlaneGeometry(size: size));
}
