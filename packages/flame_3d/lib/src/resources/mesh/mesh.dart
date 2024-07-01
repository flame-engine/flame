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
  Mesh()
      : _surfaces = [],
        super(null);

  /// The AABB of the mesh.
  ///
  /// This is the sum of all the AABB's of the surfaces it contains.
  Aabb3 get aabb {
    if (_aabb == null) {
      var aabb = Aabb3();
      for (var i = 0; i < _surfaces.length; i++) {
        if (i == 0) {
          aabb = _surfaces[i].aabb;
        } else {
          aabb.hull(_surfaces[i].aabb);
        }
      }
      _aabb = aabb;
    }
    return _aabb!;
  }

  Aabb3? _aabb;

  final List<Surface> _surfaces;

  /// The total surface count of the mesh.
  int get surfaceCount => _surfaces.length;

  void bind(GraphicsDevice device) {
    for (final surface in _surfaces) {
      device.bindSurface(surface);
    }
  }

  /// Add a new surface represented by [vertices], [indices] and a [material].
  void addSurface(
    List<Vertex> vertices,
    List<int> indices, {
    Material? material,
  }) {
    add(Surface(vertices, indices, material));
  }

  /// Must be called when the mesh has been modified.
  void updateBounds() {
    _aabb = null;
  }

  /// Add a new [surface] to the mesh.
  void add(Surface surface) {
    _surfaces.add(surface);
    updateBounds();
  }

  /// An unmodifiable view over the list of the surfaces.
  /// 
  /// Note: if you modify the geometry of any [Surface] within this list,
  /// you will need to call [updateBounds] to update the mesh's bounds.
  List<Surface> get surfaces {
    return List.unmodifiable(_surfaces);
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
}
