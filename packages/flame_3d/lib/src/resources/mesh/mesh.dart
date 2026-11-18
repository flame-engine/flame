import 'dart:ui';

import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

/// {@template mesh}
/// A [Resource] that represents a geometric shape that is divided up in one or
/// more [Surface]s.
///
/// This class isn't a true resource, it does not upload it self to the GPU.
/// Instead it uploads [Surface]s, it acts as a proxy.
/// {@endtemplate}
class Mesh() extends Resource<void> {
  /// {@macro mesh}
  this : _surfaces = [];

  final List<Surface> _surfaces;
  Aabb3? _aabb;

  /// The AABB of the mesh.
  ///
  /// This is the sum of all the AABB's of the surfaces it contains.
  Aabb3 get aabb => _aabb ??= _recomputeAabb3();

  int get vertexCount => _surfaces.fold(0, (p, e) => p + e.vertexCount);

  /// Records a draw of every surface with the model matrix [transform]
  /// (defaults to [RenderContext3D.model]), the per-instance [color] and the
  /// per-instance [instanceData] (zero when `null`), see
  /// [RenderContext3D.drawSurface].
  ///
  /// [jointTransforms] holds, by surface index, the joint matrices of skinned
  /// surfaces.
  void draw(
    RenderContext3D context, {
    Matrix4? transform,
    Color color = const Color(0xFFFFFFFF),
    Vector4? instanceData,
    Map<int, List<Matrix4>>? jointTransforms,
  }) {
    for (var index = 0; index < _surfaces.length; index++) {
      context.drawSurface(
        _surfaces[index],
        transform: transform,
        color: color,
        instanceData: instanceData,
        jointTransforms: jointTransforms?[index],
      );
    }
  }

  @override
  void createResource() {}

  /// The total surface count of the mesh.
  int get surfaceCount => _surfaces.length;

  /// An unmodifiable iterable over the list of the surfaces.
  ///
  /// Note: if you modify the geometry of any [Surface] within this list,
  /// you will need to call [updateBounds] to update the mesh's bounds.
  Iterable<Surface> get surfaces => _surfaces;

  /// Add a new [surface] to this mesh.
  /// Return the index of the newly added surface.
  /// Surfaces are always added to the end of the list.
  int addSurface(Surface surface) {
    _surfaces.add(surface);
    updateBounds();
    return _surfaces.length - 1;
  }

  /// Replace the surface at [index] with [surface].
  void updateSurface(int index, Surface surface) {
    _surfaces[index] = surface;
    updateBounds();
  }

  /// Remove the surface at [index].
  void removeSurface(int index) {
    _surfaces.removeAt(index);
    updateBounds();
  }

  /// Update the surfaces of the mesh, making sure to recompute the bounds
  /// after.
  void updateSurfaces(void Function(List<Surface> surfaces) update) {
    update(_surfaces);
    updateBounds();
  }

  /// Must be called when the mesh has been modified.
  void updateBounds() {
    _aabb = null;
  }

  Aabb3 _recomputeAabb3() {
    // Start from a copy: hulling into the first surface's own bounds would
    // grow them.
    final aabb = Aabb3();
    for (var i = 0; i < _surfaces.length; i++) {
      if (i == 0) {
        aabb.copyFrom(_surfaces[i].aabb);
      } else {
        aabb.hull(_surfaces[i].aabb);
      }
    }
    return aabb;
  }
}
