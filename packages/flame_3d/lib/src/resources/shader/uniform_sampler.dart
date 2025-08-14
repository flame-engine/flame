import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

/// {@template uniform_sampler}
/// Instance of a uniform sampler. Represented by a [Texture].
/// {@endtemplate}
class UniformSampler extends UniformInstance<void, Texture> {
  Texture? texture;

  /// {@macro uniform_sampler}
  UniformSampler(super.slot);

  @override
  void bind(GraphicsDevice device) {
    device.bindTexture(slot.resource!, resource!);
  }

  @override
  void set(void key, Texture value) {
    texture = value;
    recreateResource = true;
  }

  @override
  Texture createResource() => texture!;

  @override
  void makeKey(int? index, String? field) {}
}
