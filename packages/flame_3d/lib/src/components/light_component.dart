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

  LightComponent.spot({
    Vector3? position,
  }) : this(
          source: SpotLight(),
          position: position,
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
