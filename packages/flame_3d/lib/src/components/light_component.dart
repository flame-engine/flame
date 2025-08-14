import 'dart:ui';

import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

/// A [Component3D] that represents a light source in the 3D world.
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
    transform: transform,
    source: source,
  );

  Light get light => _light;

  @override
  void onMount() {
    assert(
      parent is World3D,
      'Lights must be added to the root of the World3D',
    );
  }
}
