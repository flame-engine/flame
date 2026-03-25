import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

/// A [Component3D] that represents a light source in 3D space.
class LightComponent extends Component3D {
  LightComponent({
    required this.source,
    super.position,
  });

  LightComponent.point({
    Vector3? position,
    Color color = const Color(0xFFFFFFFF),
    double intensity = 1.0,
  }) : this(
         source: PointLight(
           color: color,
           intensity: intensity,
         ),
         position: position,
       );

  LightComponent.ambient({
    Color color = const Color(0xFFFFFFFF),
    double intensity = 0.2,
  }) : this(
         source: AmbientLight(
           color: color,
           intensity: intensity,
         ),
       );

  final LightSource source;

  late final Light _light = Light(
    position: Vector3.fromBuffer(
      worldTransformMatrix.storage.buffer,
      12 * Float32List.bytesPerElement,
    ),
    source: source,
  );

  Light get light => _light;

  @override
  void onMount() {
    super.onMount();
    world.addLight(_light);
  }

  @override
  void onRemove() {
    world.removeLight(_light);
    super.onRemove();
  }

  @override
  void update(double dt) {
    // NOTE: this ensures the matrix gets computed if need be, so that
    // the light position moves with it's anecstors.
    worldTransformMatrix;
    super.update(dt);
  }
}
