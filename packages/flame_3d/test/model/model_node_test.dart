import 'package:flame_3d/core.dart';
import 'package:flame_3d/model.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ModelNode', () {
    test('orders the joint transforms of a surface by local index', () {
      final surface = Surface(
        vertices: [
          Vertex(position: Vector3.zero(), texCoord: Vector2.zero()),
          Vertex(position: Vector3(1, 0, 0), texCoord: Vector2.zero()),
          Vertex(position: Vector3(0, 1, 0), texCoord: Vector2.zero()),
        ],
        indices: [0, 1, 2],
        jointMap: {5: 1, 3: 0},
      );
      final node = ModelNode(
        name: null,
        nodeIndex: 0,
        parentNodeIndex: null,
        transform: Matrix4.identity(),
        mesh: Mesh()..addSurface(surface),
        joints: {
          3: ModelJoint(nodeIndex: 30, inverseBindMatrix: Matrix4.identity()),
          5: ModelJoint(nodeIndex: 50, inverseBindMatrix: Matrix4.identity()),
        },
      );
      ProcessedNode jointNode(double x) => ProcessedNode(
        node: node,
        combinedTransform: Matrix4.translationValues(x, 0, 0),
        jointTransforms: {},
      );

      final joints = node.computeJointsPerSurface({
        30: jointNode(3),
        50: jointNode(5),
      })[0]!;

      expect(joints.map((joint) => joint.getTranslation().x), [3, 5]);
    });
  });
}
