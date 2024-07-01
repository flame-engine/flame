import 'package:flame_3d/components.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/src/resources/light/light.dart';

class LightComponent extends Component3D {
  final Light light;

  LightComponent({required this.light});

  @override
  void bind(GraphicsDevice device) {
    world.device
      ..model.setFrom(transformMatrix)
      ..bindLight(light);
  }
}
