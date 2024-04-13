import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flame/devtools.dart';
import 'package:flame_devtools/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedTreeNodeProvider =
    StateProvider<TreeNode<ComponentTreeNode>?>((_) => null);

// This is in a separate provider due to the fact that the tree can't keep
// track of whether it has been changed or not since the nodes don't implement
// the == operator and hashCode properly.
final loadedTreeModelProvider = StateProvider<ComponentTreeModel>(
  (_) => ComponentTreeModel(),
);

final componentTreeLoaderProvider = FutureProvider<void>((ref) async {
  final previousTreeModel = ref.watch(loadedTreeModelProvider);
  final updatedModel =
      await ComponentTreeModel.refreshComponentTree(previousTreeModel);
  if (updatedModel != null) {
    ref.read(loadedTreeModelProvider.notifier).state = updatedModel;
  }
});

@immutable
class ComponentTreeModel {
  ComponentTreeModel({
    this.totalId = 0,
    this.componentCount = 0,
    TreeNode<ComponentTreeNode>? treeRoot,
  }) : treeRoot = treeRoot ?? TreeNode<ComponentTreeNode>.root();

  final TreeNode<ComponentTreeNode> treeRoot;
  final int componentCount;
  final int totalId;

  static Future<ComponentTreeModel?> refreshComponentTree(
    ComponentTreeModel previousModel,
  ) {
    final updatedComponentTree = Repository.getComponentTree();
    return updatedComponentTree.then((node) {
      final treeRoot = previousModel.treeRoot;
      final componentRoot = TreeNode(key: node.id.toString(), data: node);
      final (:count, :totalId) = _buildTree(node, componentRoot, isRoot: true);
      if (previousModel.totalId != totalId) {
        treeRoot.clear();
        treeRoot.add(componentRoot);
        return previousModel.copyWith(
          componentCount: count,
          totalId: totalId,
        );
      }
      return null;
    });
  }

  static ({int count, int totalId}) _buildTree(
    ComponentTreeNode node,
    TreeNode<ComponentTreeNode> parent, {
    bool isRoot = false,
  }) {
    final current = isRoot
        ? parent
        : TreeNode(
            key: node.id.toString(),
            parent: parent,
            data: node,
          );
    if (!isRoot) {
      parent.add(current);
    }
    var componentCount = 1;
    var computedId = node.id;
    for (final child in node.children) {
      final (:count, :totalId) = _buildTree(child, current);
      componentCount += count;
      computedId += totalId ^ (parent.data?.id ?? 0);
    }
    return (count: componentCount, totalId: computedId);
  }

  ComponentTreeModel copyWith({
    int? componentCount,
    int? totalId,
  }) {
    return ComponentTreeModel(
      treeRoot: treeRoot,
      componentCount: componentCount ?? this.componentCount,
      totalId: totalId ?? this.totalId,
    );
  }
}
