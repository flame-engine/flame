import 'package:flame_3d/resources.dart';

/// {@template vertex_shader}
/// A [Shader] that runs per-vertex to transform geometry from model space
/// to screen space.
///
/// Typically used to apply model, view, and projection transforms, as well
/// as skeletal animation via joint matrices.
/// {@endtemplate}
class VertexShader extends Shader {
  /// {@macro vertex_shader}
  VertexShader.fromAsset(
    super.assetName, {
    super.entryPoint = 'TextureVertex',
    super.slots = const [],
  }) : super.fromAsset();
}
