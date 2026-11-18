import 'package:flame_3d/core.dart';
import 'package:flame_3d/resources.dart' as flame_3d;
import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';
import 'package:flame_3d/src/parser/gltf/primitive.dart';

/// A set of primitives to be rendered.
class Mesh({
  required super.root,
  required final List<Primitive> primitives,
  required final List<double>? weights,
}) extends GltfNode {
  Mesh.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
        root: root,
        primitives:
            Parser.objectList(root, map, 'primitives', Primitive.parse) ?? [],
        weights: Parser.floatList(map, 'weights'),
      );

  flame_3d.Mesh toFlameMesh([Matrix4? transform]) {
    final mesh = flame_3d.Mesh();
    final initialWeights = weights;
    for (final primitive in primitives) {
      for (final surface in primitive.toFlameSurfaces(transform)) {
        if (initialWeights != null && initialWeights.isNotEmpty) {
          surface.applyMorphWeights(initialWeights);
        }
        mesh.addSurface(surface);
      }
    }
    return mesh;
  }
}
