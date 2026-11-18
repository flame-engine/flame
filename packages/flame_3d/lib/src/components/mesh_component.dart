import 'dart:ui';

import 'package:flame_3d/camera.dart' show Ray, RayHit3D;
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

/// {@template mesh_component}
/// An [Object3D] that renders a [Mesh] at the [position] with the [rotation]
/// and [scale] applied.
///
/// This is a commonly used subclass of [Object3D]. Components sharing one
/// [Mesh] (and so its surfaces and materials) are drawn with a single
/// instanced draw per surface, whatever their [color] and [instanceData].
/// {@endtemplate}
class MeshComponent({
  required final Mesh _mesh,
  super.position,
  super.scale,
  super.rotation,
  super.children,
  super.castsShadows,
  super.cameraMask,

  /// The per-instance color of this component, available to the material's
  /// shaders (the built-in materials multiply their base color by it).
  var Color color = const Color(0xFFFFFFFF),

  /// The initial value of [instanceData], zero when `null`.
  Vector4? instanceData,

  /// The joint matrices of the mesh's skinned surfaces, by surface index: a
  /// [StylizedMaterial] surface built with joints and weights, or a skinned
  /// surface of a model. `null` (the default) draws every surface unskinned.
  ///
  /// The matrices are read when the component is drawn, so they can be
  /// updated in place every frame to animate the mesh. The component's bounds
  /// are the mesh's: give the surfaces bounds that hold every pose (see
  /// [StylizedMaterial.buildSurface]) for culling to stay right.
  var Map<int, List<Matrix4>>? jointTransforms,
}) extends Object3D {
  /// The mesh resource.
  Mesh get mesh => _mesh;

  /// Four floats of per-instance data, zero by default, that reach the
  /// material's vertex shader as `instanceData` (see
  /// `shaders/flame_3d/instancing.glsl`).
  ///
  /// What they mean is up to the material: see [StylizedMaterial] for the
  /// built-in material that reads them. They may be changed at any time; the
  /// values at the time the component is drawn are used.
  final Vector4 instanceData = instanceData?.clone() ?? Vector4.zero();

  @override
  Aabb3? computeLocalAabb() => mesh.aabb;

  @override
  void draw(covariant RenderContext3D context) {
    context.drawMesh(
      mesh,
      transform: worldTransformMatrix,
      color: color,
      instanceData: instanceData,
      jointTransforms: jointTransforms,
    );
  }

  @override
  RayHit3D? raycast(
    Ray worldRay, {
    double maxDistance = double.infinity,
    CullMode? cullMode,
  }) {
    return RayHit3D.intersectMesh(
      owner: this,
      mesh: mesh,
      modelMatrix: worldTransformMatrix,
      worldRay: worldRay,
      maxDistance: maxDistance,
      cullMode: cullMode,
    );
  }
}
