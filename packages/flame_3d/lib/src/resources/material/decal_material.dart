import 'dart:ui' hide FragmentShader;

import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// {@template decal_material}
/// Material for flat 3D surface decals (targeting rings, footprints, scorch
/// marks, puddles, drop shadows) drawn with `DecalBatch3D` or [PlaneMesh].
/// {@endtemplate}
class DecalMaterial({
  /// Optional decal or atlas texture (`null` draws a procedural disc/ring).
  var Texture? texture,

  /// Base color multiplied by each decal's per-instance color.
  var Color albedoColor = const Color(0xFFFFFFFF),

  /// Clip-space depth bias (`>= 0`) preventing coplanar Z-fighting.
  var double depthBias = 0.0005,

  /// Radial edge softness in `[0, 1]` (feathering of the procedural disc/ring,
  /// or circular edge vignette when [texture] is set).
  var double softness = 0.15,

  /// Inner radius in `[0, 1)` when drawing a procedural ring (`0` draws a
  /// filled disc).
  var double innerRadius = 0.0,

  /// Fragments with final alpha below [alphaCutoff] are discarded.
  var double alphaCutoff = 0.001,

  /// Render state (defaults to premultiplied alpha without depth writes).
  RenderState renderState = RenderState.premultipliedAlphaBlend,
}) extends Material {
  /// {@macro decal_material}
  this
    : super(
        vertexShader: VertexShader.fromAsset(
          _bundle,
          slots: const [RenderContext3D.cameraMatricesBlock, 'Decal'],
        ),
        fragmentShader: FragmentShader.fromAsset(
          _bundle,
          slots: const ['Decal', 'albedoTexture'],
        ),
      ) {
    if (kIsWeb) {
      throw UnsupportedError('DecalMaterial is not supported on the web yet');
    }
    this.renderState = renderState;
    castsShadows = false;
  }

  static const String _bundle =
      'packages/flame_3d/assets/shaders/decal_material.shaderbundle';

  final Vector4 _params = Vector4.zero();
  final Vector4 _cutoff = Vector4.zero();

  @override
  void apply(RenderContext context) {
    final tex = texture;
    _params.setValues(
      depthBias,
      softness,
      innerRadius,
      tex == null ? 1.0 : 0.0,
    );
    _cutoff.setValues(alphaCutoff, 0, 0, 0);
    vertexShader
      ..setColor('Decal.albedoColor', albedoColor)
      ..setVector4('Decal.params', _params)
      ..setVector4('Decal.cutoff', _cutoff);
    fragmentShader
      ..setTexture('albedoTexture', tex ?? Texture.standard)
      ..setColor('Decal.albedoColor', albedoColor)
      ..setVector4('Decal.params', _params)
      ..setVector4('Decal.cutoff', _cutoff);
  }
}
