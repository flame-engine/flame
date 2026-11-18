import 'dart:ui' hide FragmentShader;

import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// {@template outline_material}
/// An instanced inverted-hull silhouette contour material.
///
/// Extrudes vertices outward along their normals and culls front faces
/// ([CullMode.frontFace]), leaving a clean silhouette rim around any closed 3D
/// mesh (both static and skinned).
///
/// When [screenSpace] is `false` (the default), [thickness] is measured in
/// world units. When [screenSpace] is `true`, [thickness] is expressed as a
/// fraction of viewport height in clip space (`0.01` = 0.5 % of viewport height
/// on each side), keeping the stroke width invariant to camera distance and 2D
/// zoom.
///
/// Instances drawn with one [OutlineMaterial] still batch into a single draw
/// call while varying through:
/// - `MeshComponent.color` (`instanceColor`), multiplied into [color];
/// - `MeshComponent.instanceData.x`, added to `1.0` to scale [thickness]
///   (`-1` hides the outline, `1` doubles it);
/// - `MeshComponent.instanceData.y`, added to [depthBias].
/// {@endtemplate}
class OutlineMaterial({
  /// Base contour color and opacity.
  var Color color = const Color(0xFF1A1614),

  /// Contour width (in world units when [screenSpace] is `false`, or in
  /// clip-height fraction when [screenSpace] is `true`).
  var double thickness = 0.03,

  /// Whether [thickness] is evaluated in screen/clip space rather than world
  /// units.
  var bool screenSpace = false,

  /// Clip-space depth bias (`>= 0`) nudging the extruded back faces slightly
  /// away from the camera so interior creases do not poke through front faces.
  var double depthBias = 0.0005,
}) extends Material {
  /// {@macro outline_material}
  this
    : super(
        vertexShader: VertexShader.fromAsset(
          _bundle,
          slots: const [RenderContext3D.cameraMatricesBlock, 'Outline'],
        ),
        fragmentShader: FragmentShader.fromAsset(_bundle),
      ) {
    if (kIsWeb) {
      throw UnsupportedError('OutlineMaterial is not supported on the web yet');
    }
    renderState = const RenderState(cullMode: CullMode.frontFace);
    castsShadows = false;
  }

  static const String _bundle =
      'packages/flame_3d/assets/shaders/outline_material.shaderbundle';
  static const String _skinnedBundle =
      'packages/flame_3d/assets/shaders/outline_material_skinned.shaderbundle';

  final Shader _skinnedVertexShader = VertexShader.fromAsset(
    _skinnedBundle,
    slots: const [
      RenderContext3D.cameraMatricesBlock,
      RenderContext3D.jointMatricesBlock,
      'Outline',
    ],
  );

  bool _skinnedInUse = false;
  VertexLayout? _lastLayout;
  Shader? _lastShader;

  @override
  Shader vertexShaderFor(VertexLayout layout) {
    if (!identical(layout, _lastLayout)) {
      _lastLayout = layout;
      final skinned =
          layout.offsetOf('vertexJoints') != null &&
          layout.offsetOf('vertexWeights') != null;
      if (skinned) {
        _skinnedInUse = true;
        _lastShader = _skinnedVertexShader;
      } else {
        _lastShader = vertexShader;
      }
    }
    return _lastShader!;
  }

  final Vector4 _params = Vector4.zero();

  @override
  void apply(RenderContext context) {
    var aspect = 1.0;
    if (context is RenderContext3D) {
      final p = context.projection.storage;
      if (p[0].abs() > 1e-6 && p[5].abs() > 1e-6) {
        aspect = (p[0] / p[5]).abs();
      }
    }
    _params.setValues(
      thickness,
      depthBias,
      screenSpace ? 1.0 : 0.0,
      aspect,
    );
    vertexShader
      ..setColor('Outline.color', color)
      ..setVector4('Outline.params', _params);
    if (_skinnedInUse) {
      _skinnedVertexShader
        ..setColor('Outline.color', color)
        ..setVector4('Outline.params', _params);
    }
  }
}
