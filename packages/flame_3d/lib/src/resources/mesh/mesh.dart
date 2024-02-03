import 'package:flame_3d/extensions.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

class Mesh extends Resource<void> {
  Mesh()
      : _surfaces = [],
        super(null);

  Aabb3 get aabb {
    if (_aabb == null) {
      var aabb = Aabb3();
      for (var i = 0; i < _surfaces.length; i++) {
        if (i == 0) {
          aabb = _surfaces[i].aabb;
        } else {
          aabb.merge(_surfaces[i].aabb);
        }
      }
      _aabb = aabb;
    }
    return _aabb!;
  }

  Aabb3? _aabb;

  final List<Surface> _surfaces;

  int get surfaceCount => _surfaces.length;

  void bind(GraphicsDevice device) {
    for (final surface in _surfaces) {
      device.bindSurface(surface);
    }
  }

  void addSurface(
    List<Vertex> vertices,
    List<int> indices, {
    Material? material,
  }) {
    _surfaces.add(Surface(vertices, indices, material));
  }

  void addMaterialToSurface(int index, Material material) {
    _surfaces[index].material = material;
  }
}
