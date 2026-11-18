import 'dart:ui';

import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d/src/graphics/material_pipeline_cache.dart';
import 'package:meta/meta.dart';

/// {@template material}
/// Base material: the shaders a surface is drawn with, the values it binds to
/// them, and the [renderState] it is drawn with.
///
/// The [RenderContext3D] links the shaders into a pipeline for the vertex
/// layout of each surface the material draws, and caches it.
///
/// ## Instancing
///
/// When the vertex shader declares the per-instance inputs of
/// `shaders/flame_3d/instancing.glsl` (the model matrix columns, and
/// optionally `instanceColor`), the draws of one surface with the same
/// material are batched into instanced draws, and [apply] runs once each time
/// the material is bound. Otherwise every object is drawn on its own and
/// [apply] runs before each draw, with [RenderContext3D.model] set to its
/// model matrix.
/// {@endtemplate}
abstract class Material({
  required var Shader _vertexShader,
  required var Shader _fragmentShader,
}) {
  static Material defaultMaterial = SpatialMaterial()
    ..albedoColor = const Color(0xFFFF00FF);

  static int _nextId = 0;

  /// A number identifying this material, used to group draws by material.
  final int id = _nextId++;

  Shader get vertexShader => _vertexShader;
  set vertexShader(Shader shader) {
    _vertexShader = shader;
    pipelineCache = null;
  }

  Shader get fragmentShader => _fragmentShader;
  set fragmentShader(Shader shader) {
    _fragmentShader = shader;
    pipelineCache = null;
  }

  /// The blending, depth and culling state this material draws with, and
  /// whether it is translucent. Defaults to [RenderState.opaque].
  ///
  /// For example, a material for glows that are added to what is behind them:
  ///
  /// ```dart
  /// material.renderState = RenderState.additive;
  /// ```
  ///
  /// or an opaque material that culls back faces:
  ///
  /// ```dart
  /// material.renderState = const RenderState(cullMode: CullMode.backFace);
  /// ```
  RenderState renderState = RenderState.opaque;

  /// Whether the surfaces drawn with this material cast shadows (see
  /// [ShadowSettings]).
  ///
  /// By default opaque materials do and translucent ones (see
  /// [RenderState.translucent]: glass, glows, additive effects) do not. Set
  /// it to override that, for instance to `false` for an opaque glow, and to
  /// `null` to go back to the default.
  ///
  /// A caster's shadow is rendered from its positions alone (skinned when
  /// its vertices have joints and joint weights): vertices that a material's
  /// own vertex shader moves (`StylizedMaterial`'s wind, for instance)
  /// cast the shadow of their rest position.
  bool get castsShadows => _castsShadows ?? !renderState.translucent;
  set castsShadows(bool? value) => _castsShadows = value;
  bool? _castsShadows;

  /// The pipeline this material drew with last, managed by the
  /// [RenderContext3D].
  @internal
  MaterialPipelineCache? pipelineCache;

  /// The vertex shader that draws surfaces whose vertices are laid out as
  /// [layout]: [vertexShader] unless overridden.
  ///
  /// A material can draw several vertex layouts by overriding it to return a
  /// vertex shader variant per layout. Every variant must feed the
  /// [fragmentShader] the same outputs; [apply] writes the values of all of
  /// them, as it does not know which one is bound.
  Shader vertexShaderFor(VertexLayout layout) => vertexShader;

  /// Writes this material's values into its shaders, see [Material].
  ///
  /// Uniform blocks filled by the [RenderContext3D] (see
  /// [RenderContext3D.registerPassUniform]) and the joint matrices of skinned
  /// draws need not be written.
  void apply(RenderContext context) {}
}
