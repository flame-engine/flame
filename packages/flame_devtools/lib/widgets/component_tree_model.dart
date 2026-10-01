import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flame/devtools.dart';
import 'package:flame_devtools/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final selectedTreeNodeProvider = StateProvider<TreeNode<ComponentTreeNode>?>(
  (_) => null,
);

// This is in a separate provider due to the fact that the tree can't keep
// track of whether it has been changed or not since the nodes don't implement
// the == operator and hashCode properly.
final loadedTreeModelProvider = StateProvider<ComponentTreeModel>(
  (_) => ComponentTreeModel(),
);

final componentTreeLoaderProvider = FutureProvider<void>((ref) async {
  final previousTreeModel = ref.read(loadedTreeModelProvider);
  final updatedModel = await ComponentTreeModel.refreshComponentTree(
    previousTreeModel,
  );
  if (updatedModel == null) {
    return;
  }
  ref.read(loadedTreeModelProvider.notifier).state = updatedModel;

  // The tree nodes have been rebuilt, so the selection has to point to the
  // new node for the same component, or be cleared if the component is gone.
  final selectedKey = ref.read(selectedTreeNodeProvider)?.key;
  if (selectedKey != null) {
    ref.read(selectedTreeNodeProvider.notifier).state = updatedModel.findNode(
      selectedKey,
    );
  }
});

@immutable
// ignore: prefer_const_constructors_in_immutables
class ComponentTreeModel({
  final int nodeHash = 0,
  final int componentCount = 0,
  TreeNode<ComponentTreeNode>? treeRoot,
}) {
  final TreeNode<ComponentTreeNode> treeRoot =
      treeRoot ?? TreeNode<ComponentTreeNode>.root();
  static Future<ComponentTreeModel?> refreshComponentTree(
    ComponentTreeModel previousModel,
  ) async {
    final node = await Repository.getComponentTree();
    final treeRoot = previousModel.treeRoot;
    final componentRoot = TreeNode(key: node.id.toString(), data: node);
    final (:count, :nodeHash) = _buildTree(node, componentRoot, isRoot: true);
    if (previousModel.nodeHash == nodeHash) {
      return null;
    }
    treeRoot.clear();
    treeRoot.add(componentRoot);
    return previousModel.copyWith(
      componentCount: count,
      nodeHash: nodeHash,
    );
  }

  static ({int count, int nodeHash}) _buildTree(
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
    var computedHash = node.id;
    for (final child in node.children) {
      final (:count, :nodeHash) = _buildTree(child, current);
      componentCount += count;
      computedHash = Object.hash(computedHash, nodeHash);
    }
    return (count: componentCount, nodeHash: computedHash);
  }

  /// Finds the node with the given [key], which is the id of the component,
  /// or returns null if there is no such node in the tree.
  TreeNode<ComponentTreeNode>? findNode(String key) {
    return _findNode(treeRoot, key);
  }

  static TreeNode<ComponentTreeNode>? _findNode(
    TreeNode<ComponentTreeNode> node,
    String key,
  ) {
    if (node.key == key) {
      return node;
    }
    for (final child in node.childrenAsList) {
      final found = _findNode(child as TreeNode<ComponentTreeNode>, key);
      if (found != null) {
        return found;
      }
    }
    return null;
  }

  ComponentTreeModel copyWith({
    int? componentCount,
    int? nodeHash,
  }) {
    return ComponentTreeModel(
      treeRoot: treeRoot,
      componentCount: componentCount ?? this.componentCount,
      nodeHash: nodeHash ?? this.nodeHash,
    );
  }
}
