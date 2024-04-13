import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flame/devtools.dart';
import 'package:flame_devtools/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _treeRootProvider = Provider<TreeNode<ComponentTreeNode>>(
  (_) => TreeNode.root(),
);
final selectedTreeNodeProvider =
    StateProvider<TreeNode<ComponentTreeNode>?>((_) => null);
final componentTreeModelProvider = FutureProvider<ComponentTreeModel>((ref) {
  final root = ref.watch(_treeRootProvider);
  return ComponentTreeModel.refreshComponentTree(root);
});

@immutable
class ComponentTreeModel {
  final TreeNode<ComponentTreeNode> treeRoot;
  final ComponentTreeNode? componentTree;
  final int componentCount;

  ComponentTreeModel({
    required this.componentTree,
    this.componentCount = 0,
    TreeNode<ComponentTreeNode>? treeRoot,
  }) : treeRoot = treeRoot ?? TreeNode<ComponentTreeNode>.root();

  static Future<ComponentTreeModel> refreshComponentTree(
    TreeNode<ComponentTreeNode> treeRoot,
  ) {
    treeRoot.clear();
    final updatedComponentTree = Repository.getComponentTree();
    return updatedComponentTree.then((value) {
      final componentCount = _buildTree(value, treeRoot);
      return ComponentTreeModel(
        treeRoot: treeRoot,
        componentTree: value,
        componentCount: componentCount,
      );
    });
  }

  static int _buildTree(
    ComponentTreeNode node,
    TreeNode<ComponentTreeNode> parent,
  ) {
    final current = TreeNode(
      key: node.id.toString(),
      parent: parent,
      data: node,
    );
    parent.add(current);
    var componentCount = 1;
    for (final child in node.children) {
      componentCount += _buildTree(child, current);
    }
    return componentCount;
  }
}
