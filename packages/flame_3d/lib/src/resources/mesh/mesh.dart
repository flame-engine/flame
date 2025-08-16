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
class Mesh extends Resource<void> {
  /// {@macro mesh}
  Mesh() : _surfaces = [];

  final List<Surface> _surfaces;
  Aabb3? _aabb;

  /// The AABB of the mesh.
  ///
  /// This is the sum of all the AABB's of the surfaces it contains.
  Aabb3 get aabb => _aabb ??= _recomputeAabb3();

  int get vertexCount => _surfaces.fold(0, (p, e) => p + e.vertexCount);

  void bind(GraphicsDevice device) {
    for (final (index, surface) in _surfaces.indexed) {
      device.jointsInfo.setSurface(index);
      device.bindSurface(surface);
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
    var aabb = Aabb3();
    for (var i = 0; i < _surfaces.length; i++) {
      if (i == 0) {
        aabb = _surfaces[i].aabb;
      } else {
        aabb.hull(_surfaces[i].aabb);
      }
    }
    return aabb;
  }
}
