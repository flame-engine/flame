import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flame/devtools.dart';
import 'package:flame_devtools/repository.dart';
import 'package:flame_devtools/widgets/component_tree_sync.dart';
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

/// Whether the component tree and the selected component are kept up to date
/// by polling the game.
final liveUpdatesProvider = StateProvider<bool>((_) => true);

final componentTreeLoaderProvider = FutureProvider<void>((ref) async {
  final previousTreeModel = ref.read(loadedTreeModelProvider);
  final updatedModel = await ComponentTreeModel.refreshComponentTree(
    previousTreeModel,
  );
  if (updatedModel != null) {
    ref.read(loadedTreeModelProvider.notifier).state = updatedModel;
  }

  // The nodes are updated in place, so the selected node is still the same
  // node, unless its component was removed from the game; then the selection
  // is cleared.
  final selectedKey = ref.read(selectedTreeNodeProvider)?.key;
  if (selectedKey != null && previousTreeModel.findNode(selectedKey) == null) {
    ref.read(selectedTreeNodeProvider.notifier).state = null;
  }
});

@immutable
// ignore: prefer_const_constructors_in_immutables
class ComponentTreeModel({
  final int componentCount = 0,
  TreeNode<ComponentTreeNode>? treeRoot,
}) {
  final TreeNode<ComponentTreeNode> treeRoot =
      treeRoot ?? TreeNode<ComponentTreeNode>.root();

  /// Fetches the component tree and updates the nodes of [previousModel] in
  /// place, so that expanded nodes stay expanded.
  ///
  /// Returns a new model if the number of components changed, or null if it
  /// didn't. Either way the nodes have been updated.
  static Future<ComponentTreeModel?> refreshComponentTree(
    ComponentTreeModel previousModel,
  ) async {
    final node = await Repository.getComponentTree();
    final count = syncTreeChildren(previousModel.treeRoot, [node]);
    if (previousModel.componentCount == count) {
      return null;
    }
    return previousModel.copyWith(componentCount: count);
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
  }) {
    return ComponentTreeModel(
      treeRoot: treeRoot,
      componentCount: componentCount ?? this.componentCount,
    );
  }
}
