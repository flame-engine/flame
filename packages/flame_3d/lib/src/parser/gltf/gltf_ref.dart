import 'package:flame_3d/src/parser/gltf/gltf_node.dart';

class GltfRef<T extends GltfNode> extends GltfNode {
  final int index;

  GltfRef({
    required super.root,
    required this.index,
  });

  T get() {
    return root.resolve<T>(index);
  }
}
