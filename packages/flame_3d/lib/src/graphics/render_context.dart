import 'package:flame_3d/graphics.dart';

abstract class RenderContext {
  const RenderContext(this.device);

  final GraphicsDevice device;
}
