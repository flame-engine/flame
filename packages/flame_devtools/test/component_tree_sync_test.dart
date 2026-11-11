import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flame/devtools.dart';
import 'package:flame_devtools/widgets/component_tree_sync.dart';
import 'package:flutter_test/flutter_test.dart';

ComponentTreeNode _component(
  int id, {
  String toStringText = '',
  List<ComponentTreeNode> children = const [],
}) {
  return ComponentTreeNode(id, 'Component', toStringText, false, children);
}

TreeNode<ComponentTreeNode> _child(TreeNode<ComponentTreeNode> node, int id) {
  return node.children[id.toString()]! as TreeNode<ComponentTreeNode>;
}

List<String> _childKeys(TreeNode<ComponentTreeNode> node) {
  return node.childrenAsList.map((child) => child.key).toList();
}

void main() {
  group('syncTreeChildren', () {
    late TreeNode<ComponentTreeNode> root;

    setUp(() {
      root = TreeNode<ComponentTreeNode>.root();
    });

    test('adds a node for every component and counts them', () {
      final count = syncTreeChildren(root, [
        _component(1, children: [_component(2), _component(3)]),
      ]);

      expect(count, 3);
      expect(_childKeys(root), ['1']);
      expect(_childKeys(_child(root, 1)), ['2', '3']);
    });

    test('keeps the nodes of components that are still in the game', () {
      syncTreeChildren(root, [
        _component(1, children: [_component(2)]),
      ]);
      final game = _child(root, 1);
      final child = _child(game, 2);
      game.expansionNotifier.value = true;

      syncTreeChildren(root, [
        _component(1, children: [_component(2), _component(3)]),
      ]);

      expect(_child(root, 1), same(game));
      expect(_child(game, 2), same(child));
      expect(game.isExpanded, isTrue);
    });

    test('updates the data of the nodes that are kept', () {
      syncTreeChildren(root, [_component(1, toStringText: 'before')]);
      final node = _child(root, 1);

      syncTreeChildren(root, [_component(1, toStringText: 'after')]);

      expect(node.data!.toStringText, 'after');
    });

    test('removes the nodes of removed components', () {
      syncTreeChildren(root, [
        _component(1, children: [_component(2), _component(3)]),
      ]);

      final count = syncTreeChildren(root, [
        _component(1, children: [_component(3)]),
      ]);

      expect(count, 2);
      expect(_childKeys(_child(root, 1)), ['3']);
    });

    test('adds the descendants of new components', () {
      syncTreeChildren(root, [_component(1)]);

      final count = syncTreeChildren(root, [
        _component(
          1,
          children: [
            _component(2, children: [_component(4)]),
          ],
        ),
      ]);

      expect(count, 3);
      expect(_childKeys(_child(_child(root, 1), 2)), ['4']);
    });
  });
}
