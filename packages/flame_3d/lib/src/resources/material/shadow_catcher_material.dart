import 'dart:ui' hide FragmentShader;

import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// {@template shadow_catcher_material}
/// A material for invisible surfaces that show only the shadows falling on
/// them.
///
/// Where a surface drawn with it is in the shadow of the light that casts
/// shadows (see [ShadowSettings]), it draws [color] (times the per-instance
/// color) with an opacity of `color.alpha * strength`, the shadow's strength,
/// blended over what is behind it; elsewhere it is fully transparent, and it
/// draws nothing when the scene has no shadows.
///
/// It lets 3D objects cast shadows onto content that is not part of the 3D
/// scene: in a `Scene3DComponent`, whose image is drawn over the 2D
/// components below it, a ground of this material under the 3D objects
/// darkens the 2D art there, with soft edges, and leaves it untouched
/// elsewhere:
///
/// ```dart
/// layer.world.addAll([
///   LightComponent.directional(
///     direction: Vector3(-0.3, -0.5, -1),
///     shadows: ShadowSettings(),
///   ),
///   MeshComponent(
///     mesh: PlaneMesh(
///       size: Vector2(12, 12),
///       material: ShadowCatcherMaterial(color: const Color(0x8C1B2440)),
///     ),
///     // The PlaneMesh faces +y: turned to face +z, the up of this scene.
///     rotation: Quaternion.axisAngle(Vector3(1, 0, 0), pi / 2),
///   ),
///   ...houses,
/// ]);
/// ```
///
/// Its surfaces need a position and a normal (`vertexPosition` and
/// `vertexNormal`), which the standard layout and `StylizedMaterial`'s have.
/// It is translucent (blended with premultiplied alpha, depth tested, without
/// depth writes, drawn after the opaque draws) and casts no shadows.
///
/// Not available on the web yet: creating one there throws an
/// [UnsupportedError].
/// {@endtemplate}
class ShadowCatcherMaterial({
  /// The color of the shadows, and their opacity at full strength.
  var Color color = const Color(0x80000000),
}) extends Material {
  /// {@macro shadow_catcher_material}
  this
    : super(
        vertexShader: VertexShader.fromAsset(
          _bundle,
          slots: [RenderContext3D.cameraMatricesBlock],
        ),
        fragmentShader: FragmentShader.fromAsset(
          _bundle,
          slots: [
            'Material',
            RenderContext3D.shadowsBlock,
            RenderContext3D.shadowMapSampler,
          ],
        ),
      ) {
    if (kIsWeb) {
      throw UnsupportedError(
        'ShadowCatcherMaterial is not available on the web yet: shadows have '
        'no WebGPU shaders.',
      );
    }
    renderState = RenderState.premultipliedAlphaBlend;
  }

  static const _bundle =
      'packages/flame_3d/assets/shaders/shadow_catcher.shaderbundle';

  @override
  void apply(RenderContext context) {
    fragmentShader.setColor('Material.color', color);
  }
}
