import 'package:flame_3d/src/graphics/backend/gpu_enums.dart';
import 'package:meta/meta.dart';

/// {@template render_state}
/// The fixed-function state a material draws with: blending, the depth test
/// and depth writes, face culling, and whether it is translucent.
///
/// Translucent draws are drawn after every opaque draw, sorted back to front,
/// and are never batched into instanced draws. Opaque draws are grouped to
/// batch and to limit state changes, then ordered roughly front to back.
///
/// The front-face winding is not part of the state: it is counter-clockwise
/// on screen, and flips automatically when the camera or the object's model
/// matrix mirrors the scene, so that [CullMode.backFace] keeps culling the
/// faces that point away from the camera.
/// {@endtemplate}
@immutable
class const RenderState({
  /// How the output color is blended with the render target.
  final BlendState blend = BlendState.opaque,

  /// Whether fragments are tested against the depth buffer with
  /// [depthCompare]. When `false` every fragment passes; it still writes its
  /// depth if [depthWrite] is `true`.
  final bool depthTest = true,

  /// The comparison a fragment's depth must pass against the stored depth.
  final CompareFunction depthCompare = CompareFunction.less,

  /// Whether fragments that pass the depth test write their depth.
  final bool depthWrite = true,

  /// Which faces are culled.
  final CullMode cullMode = CullMode.none,

  /// Whether draws are translucent, defaults to `true` for every [blend]
  /// other than [BlendState.opaque].
  bool? translucent,

  /// Whether translucent draws automatically record an internal
  /// [BlendState.depthOnly] prepass right before shading with
  /// [CompareFunction.lessEqual], so overlapping multi-part meshes and skinned
  /// models fade out as a single seamless piece without internal bleed.
  final bool depthPrepass = false,
}) {
  /// {@macro render_state}
  // Initialized here rather than in the declaration: the analyzer fails to
  // evaluate a const field initializer that reads a constructor parameter of
  // the same name.
  // ignore: initialize_in_field_declaration
  this : translucent = translucent ?? blend != BlendState.opaque;

  /// Whether draws with this state are translucent: drawn after the opaque
  /// ones, back to front, and never batched.
  final bool translucent;

  /// Opaque geometry: no blending, depth test and depth writes on.
  static const RenderState opaque = RenderState();

  /// Translucent geometry with straight (non-premultiplied) alpha: blended,
  /// depth tested, without depth writes.
  static const RenderState alphaBlend = RenderState(
    blend: BlendState.alpha,
    depthWrite: false,
  );

  /// Translucent geometry with premultiplied alpha: blended, depth tested,
  /// without depth writes.
  static const RenderState premultipliedAlphaBlend = RenderState(
    blend: BlendState.premultipliedAlpha,
    depthWrite: false,
  );

  /// Seamless single-piece straight-alpha translucency: automatically writes
  /// depth in an internal prepass before shading with
  /// [CompareFunction.lessEqual].
  static const RenderState singlePieceAlphaBlend = RenderState(
    blend: BlendState.alpha,
    depthCompare: CompareFunction.lessEqual,
    depthWrite: false,
    depthPrepass: true,
  );

  /// Seamless single-piece premultiplied-alpha translucency: automatically
  /// writes depth in an internal prepass before shading with
  /// [CompareFunction.lessEqual].
  static const RenderState singlePiecePremultipliedAlphaBlend = RenderState(
    blend: BlendState.premultipliedAlpha,
    depthCompare: CompareFunction.lessEqual,
    depthWrite: false,
    depthPrepass: true,
  );

  /// Additive effects (glows, particles): added to the target, depth tested,
  /// without depth writes. The target keeps its alpha (see
  /// [BlendState.additive]), so over a transparent target they are added to
  /// what is drawn behind it.
  static const RenderState additive = RenderState(
    blend: BlendState.additive,
    depthWrite: false,
  );

  /// A depth prepass: no color written ([BlendState.depthOnly]), depth
  /// tested and written, drawn with the translucent draws. Draw an object
  /// with it right before drawing it with a translucent material whose
  /// depth compare is [CompareFunction.lessEqual]: only the object's nearest
  /// surfaces then blend, and it fades as one piece.
  static const RenderState depthOnly = RenderState(
    blend: BlendState.depthOnly,
  );

  /// The depth comparison applied, taking [depthTest] into account.
  CompareFunction get effectiveDepthCompare =>
      depthTest ? depthCompare : CompareFunction.always;

  /// Returns a copy of this state with the given fields replaced.
  RenderState copyWith({
    BlendState? blend,
    bool? depthTest,
    CompareFunction? depthCompare,
    bool? depthWrite,
    CullMode? cullMode,
    bool? translucent,
    bool? depthPrepass,
  }) {
    return RenderState(
      blend: blend ?? this.blend,
      depthTest: depthTest ?? this.depthTest,
      depthCompare: depthCompare ?? this.depthCompare,
      depthWrite: depthWrite ?? this.depthWrite,
      cullMode: cullMode ?? this.cullMode,
      translucent: translucent ?? this.translucent,
      depthPrepass: depthPrepass ?? this.depthPrepass,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RenderState &&
        other.blend == blend &&
        other.depthTest == depthTest &&
        other.depthCompare == depthCompare &&
        other.depthWrite == depthWrite &&
        other.cullMode == cullMode &&
        other.translucent == translucent &&
        other.depthPrepass == depthPrepass;
  }

  @override
  int get hashCode => Object.hash(
    blend,
    depthTest,
    depthCompare,
    depthWrite,
    cullMode,
    translucent,
    depthPrepass,
  );

  @override
  String toString() {
    return 'RenderState(blend: ${blend.name}, depthTest: $depthTest, '
        'depthCompare: ${depthCompare.name}, depthWrite: $depthWrite, '
        'cullMode: ${cullMode.name}, translucent: $translucent, '
        'depthPrepass: $depthPrepass)';
  }
}
