import 'package:flame_3d/resources.dart';

/// {@template fragment_shader}
/// A [Shader] that runs per-fragment (pixel) during rasterization.
///
/// Typically used to compute the final color of each pixel based on material
/// properties, lighting, and textures.
/// {@endtemplate}
class FragmentShader extends Shader {
  /// {@macro fragment_shader}
  FragmentShader.fromAsset(
    super.assetName, {
    super.entryPoint = 'TextureFragment',
    super.slots = const [],
  }) : super.fromAsset();
}
