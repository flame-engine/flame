import 'dart:math' as math;

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

extension on Aabb3 {
  void merge(Aabb3 aabb) {
    min.setValues(
      math.min(min.x, aabb.min.x),
      math.min(min.y, aabb.min.y),
      math.min(min.z, aabb.min.z),
    );
    max.setValues(
      math.max(max.x, aabb.max.x),
      math.max(max.y, aabb.max.y),
      math.max(max.z, aabb.max.z),
    );
  }
}
