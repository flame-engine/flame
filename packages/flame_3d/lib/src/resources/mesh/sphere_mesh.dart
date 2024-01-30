import 'package:flame_3d/resources.dart';

class SphereMesh extends Mesh {
  SphereMesh({
    required double radius,
    int segments = 64,
    super.material,
  }) : super(geometry: SphereGeometry(radius: radius, segments: segments));
}
