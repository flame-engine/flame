import 'dart:async';
import 'dart:ui';

import 'package:flame_3d/components.dart';
import 'package:flame_3d/resources.dart';

class RenderedPointLight({
  required super.position,
  required final Color color,
}) extends Component3D {
  @override
  FutureOr<void> onLoad() async {
    addAll([
      LightComponent.point(color: color),
      MeshComponent(
        mesh: SphereMesh(
          radius: 0.05,
          material: SpatialMaterial(
            albedoTexture: ColorTexture(color),
          ),
        ),
      ),
    ]);
  }
}
