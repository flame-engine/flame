import 'dart:typed_data';
import 'dart:ui' hide FragmentShader;

import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// {@template stylized_material}
/// A material for stylized, vertex-colored art without textures: low-poly
/// meshes whose vertices carry a color, a baked ambient occlusion and a few
/// masks that pick per-vertex effects.
///
/// ## Vertex data
///
/// It reads its own [vertexLayout] (build surfaces in it with [buildSurface]):
///
/// | Attribute         | Floats | Meaning                                    |
/// | ----------------- | ------ | ------------------------------------------ |
/// | `vertexPosition`  | 3      | position                                   |
/// | `vertexNormal`    | 3      | normal                                     |
/// | `vertexColor`     | 4      | color (rgb) and alpha                      |
/// | `vertexMasks`     | 4      | tint, accent, emissive masks and gloss     |
/// | `vertexOcclusion` | 1      | ambient occlusion, 1 unoccluded            |
/// | `vertexWind`      | 3      | sway weight, phase (turns), flutter weight |
///
/// That is 18 floats per vertex. The masks blend from `0` (none) to `1`
/// (fully). Gloss is the specular strength of the vertex and may exceed `1`
/// for extra bright highlights. The wind of a vertex is how much it sways,
/// the phase of its sway and flutter in turns (`0` to `1` is a full turn) and
/// how much it flutters, see "Wind".
///
/// It also draws surfaces in the standard layout ([VertexLayout.standard],
/// including the built-in meshes and skinned models): their vertex color is
/// used, they are unoccluded, tinted by the instance color everywhere, and
/// have no accent, emission, gloss nor wind.
///
/// ## Skinning
///
/// Surfaces in [skinnedVertexLayout], [vertexLayout] followed by
/// `vertexJoints` and `vertexWeights` (4 floats each: up to four joint
/// indices per vertex and their weights, 26 floats per vertex in all), are
/// skinned: each vertex is moved by the weighted sum of the joint matrices of
/// its draw, then drawn as above, its wind added in model space after the
/// skinning. Build them
/// with [buildSurface] and its `joints` and `weights`, and give the joint
/// matrices with every draw (`RenderContext3D.drawSurface(jointTransforms:)`,
/// or `MeshComponent.jointTransforms`); at most 16 joints per draw. A vertex
/// whose weights are all `0` keeps its position. Skinned draws are never
/// batched: each is one draw call.
///
/// ## Per-instance data
///
/// Besides the per-instance color, which tints the vertices of the tint mask,
/// each object can vary through its per-instance data
/// (`MeshComponent.instanceData`, zero by default):
///
/// - `x`, the emissive boost: added to [emissiveStrength] on the vertices of
///   the emissive mask; from `0` to `1` it also moves their glow color from
///   [emissiveColor] towards [emissiveBoostColor];
/// - `y`, the highlight: [highlightColor] times it is added to every vertex;
/// - `z`, the wind strength, added to `1`: `-1` stills the sway of the object
///   and `1` doubles it;
/// - `w`, the fade: the opacity of the object is `1 - w`, which shows when
///   the material is translucent (see below).
///
/// Objects that differ only in their color and instance data are still drawn
/// with one instanced draw call per surface.
///
/// ## Shading
///
/// With `n` the normal, `v` the direction to the viewer, `up` the hemisphere
/// light's up axis, `hemi = 0.5 + 0.5 * n·up`, `bounce = max(0, -n·up)` and
/// `boost`, `highlight` and `fade` from the instance data:
///
/// ```text
/// base = albedoColor * vertexColor * mix(1, instance color, tint mask)
///        * mix(1, accentColor, accent mask)
/// lit  = occlusion * (ambient light
///          + hemisphere intensity * (ambientBase
///                                    + skyFill * skyFillWeight * sky * hemi
///                                    + groundBounce * ground * bounce))
///        + Σ directional: max(0, n·l) * intensity * color
///        + Σ point: intensity * color * falloff * max(pointLightWrap, n·l)
/// spec = (only where gloss > specularThreshold)
///        Σ directional: (n·h)^specularPower * light.specular
///          * gloss * specularStrength
/// rim  = (1 - n·v)^rimPower * rimStrength * (sky + rimColor)
/// cap  = where gloss > gemThreshold:
///          gemMatCapTexture(view-space normal) * gemMatCapStrength
///        elsewhere, where gloss > matCapThreshold:
///          matCapTexture(view-space normal) * matCapStrength
///          * mix(1, gloss, matCapGlossWeight)
/// surface = base * lit + rim
/// shaded  = mix(surface + cap, min(surface, 1) * reflected, matCapMetallic)
///           + spec + highlight * highlightColor
/// glow = clamp(emissive mask * (emissiveStrength + boost), 0, 1)
/// out  = mix(shaded,
///            mix(emissiveColor, emissiveBoostColor, clamp(boost, 0, 1)),
///            glow)
/// alpha = albedoColor.a * vertex alpha * (1 - fade)
/// ```
///
/// Last comes the color grade of the material, which leaves the color as it
/// is by default: the color, clamped to `[0, 1]`, is desaturated towards its
/// luminosity `0.3 r + 0.59 g + 0.11 b` as [saturation] goes from `1` to
/// `0`, then covered by [overlayColor] as far as its alpha goes. One material
/// per grade greys out or tints whole objects (a disabled or stunned look,
/// a shield's glint) whatever their vertex colors.
///
/// `falloff` is the point light's: `(1 - d / range)²` with a range, `1 / d²`
/// without. MatCap textures are sampled at `(0.5 + 0.5 x, 0.5 - 0.5 y)` of
/// the view-space normal, `x` pointing right and `y` up in the picture, also
/// when the projection mirrors it. `reflected` is `cap` on the vertices that
/// get a MatCap texture and `1` on the others. Highlights are white and
/// follow the direction of the directional lights, not their intensity. The
/// result is clamped to `[0, 1]`, with no tone mapping, graded, and output
/// premultiplied by its alpha.
///
/// ## Metals
///
/// By default a MatCap texture is a sheen added over the surface: a clear
/// coat, the glint of a gem. With [matCapMetallic] at `1` it is the
/// surface's own reflection instead, tinted by it: the lit surface, at most
/// `1` per channel, multiplies the texture, so that a gold MatCap on a gold
/// tint gives a deep, saturated gold where an added sheen would wash it out
/// towards white. A fully lit white vertex then shows the texture as painted;
/// vertices without a MatCap keep their lit color.
///
/// ## Wind
///
/// A vertex moves along [windDirection] by
///
/// ```text
/// offset  = (sway + flutter) * gust * (1 + instanceData.z)
/// sway    = windAmplitude * sin(windTime * windFrequency
///             + dot(origin, windPhase) + phase) * sway weight
/// flutter = windFlutterAmplitude * sin(windTime * windFlutterFrequency
///             + dot(origin, windPhase) + phase) * flutter weight
/// gust    = 1 + windGustAmplitude * sin(windTime * windGustFrequency
///             - dot(origin, windGustDirection) * windGustPhaseScale)
/// ```
///
/// where `origin` is the world position of its object, `phase` the phase of
/// the vertex in radians (its phase in turns times `2π`) and
/// `instanceData.z` the wind strength of its instance. The flutter is a
/// fast, small sway of the vertices with a flutter weight (leaves, flags);
/// the gust a slow wave that crosses the scene along [windGustDirection]
/// (normalized), strengthening and weakening the wind of the objects it
/// reaches. Both are off by default (their amplitudes are `0`), and so is the
/// phase of vertices built without one.
///
/// [windSpace] is the space of the direction and of the amplitudes:
///
/// - [WindSpace.world] (the default): world space, every object sways the
///   same way by the same distance;
/// - [WindSpace.model]: the model space of each object, so that the sway
///   turns and scales with the object, as if it were part of its mesh;
/// - [WindSpace.worldScaled]: the direction in world space, the amplitudes
///   scaled by the scale of each object along its up axis ([windUpAxis], in
///   model space): objects of every orientation and size sway the same world
///   way, each in proportion to its height.
///
/// The wind does not move the shadows: shadows are cast from the rest
/// positions.
///
/// The defaults give a soft, toy-like look under a [HemisphereLight] and a
/// [DirectionalLight].
///
/// It is drawn instanced and batches like any opaque material: vary objects
/// with the per-instance color and data, or with distinct materials (one per
/// accent color, for instance).
///
/// ## Translucency
///
/// With `translucent: true` the material blends its premultiplied output over
/// what is behind it, without writing depth, and its draws are sorted back to
/// front after the opaque ones, like every translucent draw: objects can then
/// fade out with the `w` of their instance data, a see-through preview for
/// instance. Translucent draws of one surface that are consecutive in that
/// order are still batched.
///
/// ## Shadows
///
/// It receives the shadows of the directional light that casts them (see
/// [ShadowSettings]): where a surface is in shadow, that light's direct light
/// (and its highlights) is multiplied by `mix(white, color, strength)` of the
/// settings, so that colored shadows tint the surface rather than darken it;
/// ambient, hemisphere and the other lights stay. Opaque stylized materials
/// cast shadows and translucent ones do not (see [Material.castsShadows]);
/// the wind (sway, flutter and gusts) does not move the shadows.
///
/// Not available on the web yet: creating one there throws an
/// [UnsupportedError].
/// {@endtemplate}
class StylizedMaterial({
  /// Multiplies the vertex color.
  var Color albedoColor = const Color(0xFFFFFFFF),

  /// Multiplies the color of the vertices of the accent mask.
  var Color accentColor = const Color(0xFFFFFFFF),

  /// Optional palette of up to [maxAccentPaletteSize] (`16`) accent colors that
  /// individual instances can select through [packAccentAndFade] in
  /// `instanceData.w` without breaking instanced batching.
  List<Color> accentPalette = const [],

  /// The color the vertices of the emissive mask glow with.
  var Color emissiveColor = const Color(0xFFFFFFFF),

  /// How strongly the vertices of the emissive mask glow, from `0` (lit like
  /// the others) to `1` (the [emissiveColor] alone).
  var double emissiveStrength = 1.0,

  /// The color the vertices of the emissive mask glow with in objects whose
  /// emissive boost (the `x` of their instance data) is `1`; the color moves
  /// from [emissiveColor] towards it as the boost goes from `0` to `1`.
  /// `null` (the default) keeps [emissiveColor].
  var Color? emissiveBoostColor,

  /// The color added to objects in proportion to their highlight (the `y` of
  /// their instance data).
  var Color highlightColor = const Color(0xFFFFFFFF),

  /// The ambient light a hemisphere light gives every surface, whatever its
  /// orientation, per unit of the hemisphere light's intensity.
  var Color ambientBase = const Color.from(
    alpha: 1,
    red: 0.65,
    green: 0.65,
    blue: 0.65,
  ),

  /// How much of the hemisphere light's sky color surfaces facing up get,
  /// times [skyFillWeight].
  var double skyFill = 0.35,

  /// The weight of each channel (red, green, blue) of the sky fill, `(1, 1,
  /// 1)` by default: a surface facing up gets `skyFill * skyFillWeight`
  /// times the hemisphere light's sky color.
  Vector3? skyFillWeight,

  /// How much of the hemisphere light's ground color surfaces facing down
  /// get.
  var double groundBounce = 0.1,

  /// The least a point light lights a surface, even facing away from it, as
  /// a fraction of its light.
  var double pointLightWrap = 0.18,

  /// The strength of the highlights of a vertex of gloss `1`.
  var double specularStrength = 0.28,

  /// The exponent of the highlights: higher is tighter.
  var double specularPower = 8,

  /// Vertices with no more gloss than this have no highlights.
  var double specularThreshold = 0.12,

  /// The strength of the rim light, on the edges facing away from the
  /// viewer.
  var double rimStrength = 0.14,

  /// The exponent of the rim light: higher is thinner.
  var double rimPower = 3,

  /// Added to the hemisphere light's sky color for the rim light.
  var Color rimColor = const Color(0xFF000000),

  /// An optional MatCap texture, a sheen added where vertices have more gloss
  /// than [matCapThreshold] (and no more than [gemThreshold] when there is a
  /// [gemMatCapTexture]).
  var Texture? matCapTexture,

  /// The strength of the [matCapTexture] (for a vertex of gloss `1` when
  /// [matCapGlossWeight] is `1`).
  var double matCapStrength = 1.0,

  /// Vertices with no more gloss than this get no [matCapTexture].
  var double matCapThreshold = 0,

  /// How much the gloss of a vertex scales its [matCapTexture]: `1` (the
  /// default) in proportion to the gloss, `0` at [matCapStrength] whatever
  /// the gloss.
  var double matCapGlossWeight = 1,

  /// An optional second MatCap texture, for the glossiest vertices (gems, for
  /// instance): those with more gloss than [gemThreshold] get it at
  /// [gemMatCapStrength] instead of the [matCapTexture].
  var Texture? gemMatCapTexture,

  /// The strength of the [gemMatCapTexture].
  var double gemMatCapStrength = 1.0,

  /// Vertices with more gloss than this get the [gemMatCapTexture], when
  /// there is one.
  var double gemThreshold = 1.0,

  /// How the MatCap textures combine with the lit surface: `0` (the
  /// default) adds them, as a sheen; `1` multiplies the lit surface (at most
  /// `1`) by them, as the reflection of a metal; values in between blend the
  /// two. See the "Metals" section of [StylizedMaterial].
  var double matCapMetallic = 0,

  /// How saturated the final color stays: `1` (the default) leaves it as it
  /// is, `0` turns it into its luminosity, a grey (see "Shading").
  var double saturation = 1,

  /// A color laid over the final color as far as its alpha goes: transparent
  /// (the default) leaves the color as it is (see "Shading").
  var Color overlayColor = const Color(0x00000000),

  /// The direction vertices sway in, in [windSpace].
  Vector3? windDirection,

  /// How far vertices of sway weight `1` sway, in [windSpace] units.
  var double windAmplitude = 0.032,

  /// The space of [windDirection] and of the amplitudes of the wind: the
  /// world (the default), the model space of each object, or the world
  /// scaled by the size of each object (see [WindSpace]).
  var WindSpace windSpace = WindSpace.world,

  /// The up axis of the objects, in their model space, along which
  /// [WindSpace.worldScaled] measures their scale: `(0, 1, 0)` by default.
  /// It is normalized.
  Vector3? windUpAxis,

  /// The angular frequency of the sway, in radians per unit of [windTime].
  var double windFrequency = 2.3,

  /// How the phase of the sway (and of the flutter) changes with the world
  /// position of objects, in radians per unit along each axis, so that they
  /// do not sway in unison.
  Vector3? windPhase,

  /// How far vertices of flutter weight `1` flutter, in [windSpace] units:
  /// `0` (the default) turns the flutter off.
  var double windFlutterAmplitude = 0,

  /// The angular frequency of the flutter, in radians per unit of
  /// [windTime]: a fast sway, faster than [windFrequency].
  var double windFlutterFrequency = 12,

  /// How much gusts strengthen and weaken the wind, as a fraction of it:
  /// the wind of an object goes from `1 - windGustAmplitude` to
  /// `1 + windGustAmplitude` times its strength as gusts cross it. `0` (the
  /// default) turns the gusts off.
  var double windGustAmplitude = 0,

  /// The angular frequency of the gusts, in radians per unit of [windTime]:
  /// a slow wave, slower than [windFrequency].
  var double windGustFrequency = 0.8,

  /// The direction the gusts travel in, in world space: `(1, 0, 0)` by
  /// default. It is normalized.
  Vector3? windGustDirection,

  /// How fast the phase of the gusts changes along [windGustDirection], in
  /// radians per world unit: gusts travel at
  /// `windGustFrequency / windGustPhaseScale` world units per unit of
  /// [windTime], and `0` gusts the whole scene in unison.
  var double windGustPhaseScale = 0.5,

  /// The time of the wind, to advance every frame (in seconds).
  var double windTime = 0,

  /// Whether the material is drawn translucent: blended with premultiplied
  /// alpha, without depth writes, sorted back to front (see [renderState]).
  bool translucent = false,

  /// When `translucent` is `true`, whether to automatically record an internal
  /// depth prepass ([RenderState.singlePiecePremultipliedAlphaBlend]) so
  /// overlapping multi-part meshes and skinned models fade as one seamless
  /// piece.
  bool singlePieceTranslucent = false,

  /// Whether opaque draws dissolve via a `4x4` screen-space Bayer dither
  /// pattern driven by `albedoColor.a * instanceColor.a * (1 - fade)`, writing
  /// full depth on kept fragments with zero translucent overdraw.
  var bool ditherFade = false,
}) extends Material {
  /// {@macro stylized_material}
  this
    : super(
        vertexShader: VertexShader.fromAsset(
          _bundle,
          slots: [RenderContext3D.cameraMatricesBlock, 'Wind'],
        ),
        fragmentShader: FragmentShader.fromAsset(
          _bundle,
          slots: [
            'matCapTexture',
            'gemMatCapTexture',
            'Material',
            // The camera, the lights and the shadows of the pass.
            RenderContext3D.stylizedPassBlock,
            RenderContext3D.shadowMapSampler,
          ],
        ),
      ) {
    if (kIsWeb) {
      throw UnsupportedError(
        'StylizedMaterial is not available on the web yet: it has no WebGPU '
        'shaders.',
      );
    }
    if (translucent) {
      renderState = singlePieceTranslucent
          ? RenderState.singlePiecePremultipliedAlphaBlend
          : translucentRenderState;
    }
  }

  /// The render state of translucent stylized materials: blended with
  /// premultiplied alpha, depth tested, without depth writes.
  static const RenderState translucentRenderState =
      RenderState.premultipliedAlphaBlend;

  /// Maximum number of entries supported in [accentPalette].
  static const int maxAccentPaletteSize = 16;

  /// Optional per-instance accent palette (up to [maxAccentPaletteSize]
  /// colors).
  final List<Color> accentPalette = List.of(accentPalette);

  /// Encodes an [accentIndex] (`0` to `maxAccentPaletteSize - 1`) into
  /// [accentPalette] together with a [fade] in `[0, 1]` as a single float for
  /// `instanceData.w`.
  ///
  /// Plain `instanceData.w` values below `2.0` keep their ordinary `[0, 1]`
  /// fade meaning and use [accentColor].
  static double packAccentAndFade(int accentIndex, {double fade = 0.0}) {
    RangeError.checkValueInInterval(
      accentIndex,
      0,
      maxAccentPaletteSize - 1,
      'accentIndex',
    );
    return (accentIndex + 1) * 4.0 + fade.clamp(0.0, 1.0);
  }

  /// The weight of each channel of the sky fill, see [skyFill].
  Vector3 skyFillWeight = skyFillWeight ?? Vector3.all(1);

  /// The direction vertices sway in, in [windSpace].
  Vector3 windDirection = windDirection ?? Vector3(1, 0, 0);

  /// How the phase of the sway changes with the world position of objects.
  Vector3 windPhase = windPhase ?? Vector3(0.7, 0, 0.5);

  /// The up axis of the objects, in their model space, see [windSpace].
  Vector3 windUpAxis = windUpAxis ?? Vector3(0, 1, 0);

  /// The direction the gusts travel in, in world space.
  Vector3 windGustDirection = windGustDirection ?? Vector3(1, 0, 0);

  static const _bundle =
      'packages/flame_3d/assets/shaders/stylized_material.shaderbundle';

  /// The layout of the vertices [StylizedMaterial] reads, 18 floats per
  /// vertex: see [StylizedMaterial].
  static final VertexLayout vertexLayout = VertexLayout(const [
    VertexAttribute(VertexLayout.positionAttribute, 3),
    VertexAttribute('vertexNormal', 3),
    VertexAttribute('vertexColor', 4),
    VertexAttribute(masksAttribute, 4),
    VertexAttribute('vertexOcclusion', 1),
    VertexAttribute(windAttribute, 3),
  ]);

  /// The name of the masks attribute: surfaces whose layout has it are drawn
  /// as laid out in [vertexLayout], the others as in the standard layout.
  static const String masksAttribute = 'vertexMasks';

  /// The name of the wind attribute of [vertexLayout], 3 floats per vertex:
  /// the sway weight, the phase in turns and the flutter weight.
  static const String windAttribute = 'vertexWind';

  /// The name of the joint indices attribute of [skinnedVertexLayout].
  static const String jointsAttribute = 'vertexJoints';

  /// The name of the joint weights attribute of [skinnedVertexLayout].
  static const String weightsAttribute = 'vertexWeights';

  /// The layout of skinned vertices, 26 floats per vertex: [vertexLayout]
  /// followed by four joint indices (`vertexJoints`) and their four weights
  /// (`vertexWeights`). See the "Skinning" section of [StylizedMaterial].
  static final VertexLayout skinnedVertexLayout = VertexLayout([
    ...vertexLayout.attributes,
    const VertexAttribute(jointsAttribute, 4),
    const VertexAttribute(weightsAttribute, 4),
  ]);

  /// The number of joint matrices a skinned draw may have.
  static const int maxJoints = 64;

  // The variant for skinned surfaces in the stylized layout.
  final Shader _skinnedVertexShader = VertexShader.fromAsset(
    'packages/flame_3d/assets/shaders/stylized_material_skinned.shaderbundle',
    slots: [
      RenderContext3D.cameraMatricesBlock,
      'Wind',
      RenderContext3D.jointMatricesBlock,
    ],
  );

  // Whether the skinned variant drew: only then are its values written.
  bool _skinnedInUse = false;

  // The variant for surfaces without the masks (the standard layout).
  final Shader _standardVertexShader = VertexShader.fromAsset(
    'packages/flame_3d/assets/shaders/stylized_material_standard.shaderbundle',
    slots: [
      RenderContext3D.cameraMatricesBlock,
      RenderContext3D.jointMatricesBlock,
    ],
  );

  VertexLayout? _lastLayout;
  Shader? _lastShader;

  @override
  Shader vertexShaderFor(VertexLayout layout) {
    if (!identical(layout, _lastLayout)) {
      _lastLayout = layout;
      if (layout.offsetOf(masksAttribute) == null) {
        _lastShader = _standardVertexShader;
      } else if (layout.offsetOf(jointsAttribute) != null &&
          layout.offsetOf(weightsAttribute) != null) {
        _lastShader = _skinnedVertexShader;
        _skinnedInUse = true;
      } else {
        _lastShader = vertexShader;
      }
    }
    return _lastShader!;
  }

  @override
  void apply(RenderContext context) {
    final space = windSpace;
    _unitOrZero(
      _upAxis,
      space == WindSpace.worldScaled ? windUpAxis : _zero,
      1,
    );
    _unitOrZero(_gustWave, windGustDirection, windGustPhaseScale);
    _applyWind(vertexShader, space);
    if (_skinnedInUse) {
      _applyWind(_skinnedVertexShader, space);
    }
    final matCap = matCapTexture;
    final gemMatCap = gemMatCapTexture;
    final weight = skyFillWeight;
    final paletteCount = accentPalette.length < maxAccentPaletteSize
        ? accentPalette.length
        : maxAccentPaletteSize;
    final matBlock = fragmentShader.block('Material')
      ..setFloat('accentPaletteCount', paletteCount.toDouble());
    for (var i = 0; i < paletteCount; i++) {
      matBlock.setColor('accentPalette', accentPalette[i], index: i);
    }
    fragmentShader
      ..setTexture('matCapTexture', matCap ?? Texture.empty)
      ..setTexture('gemMatCapTexture', gemMatCap ?? Texture.empty)
      ..setColor('Material.albedoColor', albedoColor)
      ..setColor('Material.accentColor', accentColor)
      ..setColor('Material.emissiveColor', emissiveColor)
      ..setColor(
        'Material.emissiveBoostColor',
        emissiveBoostColor ?? emissiveColor,
      )
      ..setColor('Material.ambientBase', ambientBase)
      ..setVector4(
        'Material.skyFill',
        _skyFill..setValues(
          skyFill * weight.x,
          skyFill * weight.y,
          skyFill * weight.z,
          0,
        ),
      )
      ..setColor('Material.rimColor', rimColor)
      ..setColor('Material.highlightColor', highlightColor)
      ..setFloat('Material.emissiveStrength', emissiveStrength)
      ..setFloat('Material.groundBounce', groundBounce)
      ..setFloat('Material.pointLightWrap', pointLightWrap)
      ..setFloat('Material.specularStrength', specularStrength)
      ..setFloat('Material.specularPower', specularPower)
      ..setFloat('Material.specularThreshold', specularThreshold)
      ..setFloat('Material.rimStrength', rimStrength)
      ..setFloat('Material.rimPower', rimPower)
      ..setFloat(
        'Material.matCapStrength',
        matCap == null ? 0 : matCapStrength,
      )
      // Without a MatCap texture no vertex gets one: a metallic material
      // then keeps the lit color instead of reflecting nothing.
      ..setFloat(
        'Material.matCapThreshold',
        matCap == null ? _never : matCapThreshold,
      )
      ..setFloat('Material.matCapGlossWeight', matCapGlossWeight)
      ..setFloat(
        'Material.gemMatCapStrength',
        gemMatCap == null ? 0 : gemMatCapStrength,
      )
      // Without a gem texture no vertex is a gem: every glossy vertex gets
      // the first MatCap texture.
      ..setFloat(
        'Material.gemThreshold',
        gemMatCap == null ? _never : gemThreshold,
      )
      ..setFloat('Material.matCapMetallic', matCapMetallic)
      ..setFloat('Material.saturation', saturation)
      ..setColor('Material.overlayColor', overlayColor);
    if (fragmentShader.slot('Material').getMemberOffsetInBytes('ditherFade') !=
        null) {
      fragmentShader.setFloat('Material.ditherFade', ditherFade ? 1.0 : 0.0);
    }
  }

  void _applyWind(Shader shader, WindSpace space) {
    final inModelSpace = space == WindSpace.model;
    shader
      ..setVector3('Wind.direction', inModelSpace ? _zero : windDirection)
      ..setVector3('Wind.modelDirection', inModelSpace ? windDirection : _zero)
      ..setFloat('Wind.amplitude', windAmplitude)
      ..setVector3('Wind.phaseScale', windPhase)
      ..setFloat('Wind.frequency', windFrequency)
      ..setFloat('Wind.time', windTime)
      // Zero, unless in WindSpace.worldScaled.
      ..setVector3('Wind.upAxis', _upAxis)
      ..setFloat('Wind.flutterAmplitude', windFlutterAmplitude)
      ..setFloat('Wind.flutterFrequency', windFlutterFrequency)
      ..setVector3('Wind.gustWave', _gustWave)
      ..setFloat('Wind.gustAmplitude', windGustAmplitude)
      ..setFloat('Wind.gustFrequency', windGustFrequency);
  }

  /// Sets [target] to [direction] normalized, times [scale], or to zero when
  /// [direction] is zero.
  static void _unitOrZero(Vector3 target, Vector3 direction, double scale) {
    final length = direction.length;
    if (length == 0) {
      target.setZero();
    } else {
      target
        ..setFrom(direction)
        ..scale(scale / length);
    }
  }

  final Vector4 _skyFill = Vector4.zero();
  final Vector3 _upAxis = Vector3.zero();
  final Vector3 _gustWave = Vector3.zero();

  static final Vector3 _zero = Vector3.zero();

  /// A gloss no vertex reaches.
  static const double _never = 1e30;

  /// Builds a surface in [vertexLayout] from per-vertex arrays, drawn with
  /// [material].
  ///
  /// [positions] and [normals] hold 3 floats per vertex, [colors] 4 (RGBA,
  /// white by default) and the others one: [occlusion] (`1` by default), and
  /// [tint], [accent], [emissive], [gloss], [sway] (the sway weight),
  /// [windPhase] (the phase of the vertex's sway and flutter, in turns: `0`
  /// to `1` is a full turn) and [windFlutter] (the flutter weight), `0` by
  /// default. See the "Wind" section of [StylizedMaterial].
  /// [indices] are the triangles' vertex indices; they are stored as 16-bit
  /// integers when possible, and used as given when they are a [Uint16List]
  /// or a [Uint32List].
  ///
  /// With [joints] and [weights], 4 floats per vertex each (joint indices,
  /// below [maxJoints], and their weights), the surface is skinned and laid
  /// out in [skinnedVertexLayout] instead; both must be given together.
  ///
  /// The bounds of the surface, which culling uses, are those of [positions]
  /// unless [aabb] is given: give bounds wide enough for every pose when the
  /// joints of a skinned surface move it outside of them.
  static Surface buildSurface({
    required List<double> positions,
    required List<double> normals,
    required List<int> indices,
    required Material material,
    List<double>? colors,
    List<double>? occlusion,
    List<double>? tint,
    List<double>? accent,
    List<double>? emissive,
    List<double>? gloss,
    List<double>? sway,
    List<double>? windPhase,
    List<double>? windFlutter,
    List<double>? joints,
    List<double>? weights,
    Aabb3? aabb,
  }) {
    final count = positions.length ~/ 3;
    void check(List<double>? values, String name, int perVertex) {
      if (values != null && values.length != count * perVertex) {
        throw ArgumentError.value(
          values.length,
          name,
          'Must hold $perVertex float(s) for each of the $count vertices',
        );
      }
    }

    check(positions, 'positions', 3);
    check(normals, 'normals', 3);
    check(colors, 'colors', 4);
    check(occlusion, 'occlusion', 1);
    check(tint, 'tint', 1);
    check(accent, 'accent', 1);
    check(emissive, 'emissive', 1);
    check(gloss, 'gloss', 1);
    check(sway, 'sway', 1);
    check(windPhase, 'windPhase', 1);
    check(windFlutter, 'windFlutter', 1);
    check(joints, 'joints', 4);
    check(weights, 'weights', 4);
    if ((joints == null) != (weights == null)) {
      throw ArgumentError(
        'joints and weights must be given together: '
        'a skinned surface needs both',
      );
    }
    if (joints != null) {
      for (var i = 0; i < joints.length; i++) {
        final joint = joints[i];
        if (joint < 0 || joint >= maxJoints || joint != joint.roundToDouble()) {
          throw ArgumentError.value(
            joint,
            'joints',
            'Joint indices must be whole numbers from 0 to ${maxJoints - 1}',
          );
        }
      }
    }

    final skinned = joints != null;
    final layout = skinned ? skinnedVertexLayout : vertexLayout;
    final stride = layout.strideInFloats;
    final data = Float32List(count * stride);
    for (var i = 0; i < count; i++) {
      final o = i * stride;
      data
        ..[o] = positions[i * 3]
        ..[o + 1] = positions[i * 3 + 1]
        ..[o + 2] = positions[i * 3 + 2]
        ..[o + 3] = normals[i * 3]
        ..[o + 4] = normals[i * 3 + 1]
        ..[o + 5] = normals[i * 3 + 2]
        ..[o + 6] = colors == null ? 1 : colors[i * 4]
        ..[o + 7] = colors == null ? 1 : colors[i * 4 + 1]
        ..[o + 8] = colors == null ? 1 : colors[i * 4 + 2]
        ..[o + 9] = colors == null ? 1 : colors[i * 4 + 3]
        ..[o + 10] = tint?[i] ?? 0
        ..[o + 11] = accent?[i] ?? 0
        ..[o + 12] = emissive?[i] ?? 0
        ..[o + 13] = gloss?[i] ?? 0
        ..[o + 14] = occlusion?[i] ?? 1
        ..[o + 15] = sway?[i] ?? 0
        ..[o + 16] = windPhase?[i] ?? 0
        ..[o + 17] = windFlutter?[i] ?? 0;
      if (skinned) {
        for (var k = 0; k < 4; k++) {
          data
            ..[o + 18 + k] = joints[i * 4 + k]
            ..[o + 22 + k] = weights![i * 4 + k];
        }
      }
    }
    return Surface.fromBuffers(
      vertices: data,
      indices: _indexList(indices, count),
      layout: layout,
      material: material,
      aabb: aabb,
    );
  }

  static List<int> _indexList(List<int> indices, int vertexCount) {
    if (indices is Uint16List || indices is Uint32List) {
      return indices;
    }
    // Index 65535 is kept free, as some APIs reserve it to restart primitives.
    var wide = vertexCount > 0xFFFF;
    for (var i = 0; !wide && i < indices.length; i++) {
      wide = indices[i] >= 0xFFFF;
    }
    return wide ? Uint32List.fromList(indices) : Uint16List.fromList(indices);
  }
}

/// The space a [StylizedMaterial]'s wind direction and amplitudes are given
/// in.
enum WindSpace() {
  /// World space: every object sways along the same direction, by the same
  /// distance.
  world,

  /// The model space of each object: the sway turns and scales with the
  /// object, as if it were part of its mesh.
  model,

  /// The direction in world space and the amplitudes scaled by the size of
  /// each object along its up axis ([StylizedMaterial.windUpAxis], in model
  /// space): whatever their orientation, objects sway the same world way,
  /// each in proportion to its height. An object scaled twice along its up
  /// axis sways twice as far.
  worldScaled,
}
