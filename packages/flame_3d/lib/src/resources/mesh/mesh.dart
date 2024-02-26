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

  /// Add a new surface represented by [vertices], [indices] and a material.
  void addSurface(
    List<Vertex> vertices,
    List<int> indices, {
    Material? material,
  }) {
    _surfaces.add(Surface(vertices, indices, material));
  }

  /// Add a material to the surface at [index].
  void addMaterialToSurface(int index, Material material) {
    _surfaces[index].material = material;
  }

  /// Get a material from the surface at [index].
  Material? getMaterialToSurface(int index) {
    return _surfaces[index].material;
  }
}
