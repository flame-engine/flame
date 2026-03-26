import 'dart:async';
import 'dart:ui';

import 'package:flame_3d/components.dart';
import 'package:flame_3d/resources.dart';

class RenderedPointLight extends Component3D {
  final Color color;

  RenderedPointLight({
    required super.position,
    required this.color,
  });

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
