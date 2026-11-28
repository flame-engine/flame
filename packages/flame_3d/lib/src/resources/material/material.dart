import 'dart:ui';

import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

/// {@template material}
/// Base material [Resource], it holds the shader library that should be used
/// for the material.
/// {@endtemplate}
abstract class Material({
  required var Shader _vertexShader,
  required var Shader _fragmentShader,

  /// How the renderer uses the alpha channel of the material.
  var Transparency transparency = Transparency.disabled,

  /// Alpha threshold used when [transparency] = [Transparency.alphaScissor]
  /// (or in the depth pre-pass for [Transparency.alphaDepthPrePass]).
  /// Fragments whose alpha is below this value are discarded.
  var double alphaScissorThreshold = 0.5,

  /// Dither cell size for [Transparency.alphaHash]. Larger values give a
  /// coarser pattern.
  var double alphaHashScale = 1.0,

  /// Draw order within the opaque or blended group. Higher values draw
  /// later, before distance is compared.
  var int renderPriority = 0,
}) extends Resource<GpuPipeline> {
  static Material defaultMaterial = SpatialMaterial()
    ..albedoColor = const Color(0xFFFF00FF);

  @override
  GpuPipeline createResource() {
    return GpuBackend.instance.createPipeline(
      vertexShader: _vertexShader.resource,
      fragmentShader: _fragmentShader.resource,
    );
  }

  Shader get vertexShader => _vertexShader;
  set vertexShader(Shader shader) {
    _vertexShader = shader;
    recreateResource = true;
  }

  Shader get fragmentShader => _fragmentShader;
  set fragmentShader(Shader shader) {
    _fragmentShader = shader;
    recreateResource = true;
  }

  /// Face culling mode for this material. Defaults to [CullMode.none].
  CullMode cullMode = CullMode.none;

  /// The scissor threshold for the shader in [passKind], or `0` for none.
  double activeAlphaScissorThreshold(PassKind passKind) {
    return switch (transparency) {
      Transparency.alphaScissor => alphaScissorThreshold,
      Transparency.alphaDepthPrePass when passKind == PassKind.depthPrePass =>
        alphaScissorThreshold,
      _ => 0,
    };
  }

  /// Whether this material draws with alpha blending.
  bool get isBlended =>
      transparency == Transparency.alpha ||
      transparency == Transparency.alphaDepthPrePass;

  /// The hash scale for the shader, or `0` for none.
  double get activeAlphaHashScale =>
      transparency == Transparency.alphaHash ? alphaHashScale : 0;

  void apply(RenderContext context) {}
}

/// How a [Material]'s alpha channel is interpreted by the renderer.
enum Transparency() {
  /// Alpha is ignored, output is fully opaque. Rendered in the opaque
  /// bucket with depth-write on, sorted front-to-back for early-Z.
  disabled,

  /// Standard alpha blending. Rendered in the transparent bucket with
  /// depth-read-only, sorted back-to-front so blending composites
  /// correctly.
  alpha,

  /// Hard-edged transparency via alpha clipping: fragments whose alpha is
  /// below [Material.alphaScissorThreshold] are discarded. Rendered in
  /// the opaque bucket (no blending), sorted front-to-back.
  alphaScissor,

  /// Stochastic/dithered transparency: fragments are discarded based on a
  /// per-pixel hashed threshold compared to alpha. Rendered in the opaque
  /// bucket, sorted front-to-back. Controlled by [Material.alphaHashScale].
  alphaHash,

  /// Alpha blending with an extra depth pre-pass: the material is first
  /// rendered with alpha-scissor (using [Material.alphaScissorThreshold])
  /// to write depth for its mostly-opaque parts, then rendered again with
  /// normal alpha blending. This makes blended geometry self-sort
  /// correctly in cases where simple back-to-front breaks down (hair,
  /// dense foliage).
  alphaDepthPrePass,
}
