import 'package:flame_3d/components.dart';
import 'package:flame_3d/graphics.dart';

abstract class Light extends Component3D {
  @override
  void bind(GraphicsDevice device) {
    device.bindLight(this);
  }
}
