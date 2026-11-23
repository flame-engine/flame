import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flame/devtools.dart';
import 'package:flame_devtools/repository.dart';
import 'package:flame_devtools/widgets/component_tree_sync.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final selectedTreeNodeProvider = StateProvider<TreeNode<ComponentTreeNode>?>(
  (_) => null,
);

/// The model of the component tree, which is updated in place by
/// [componentTreeLoaderProvider].
final loadedTreeModelProvider = Provider<ComponentTreeModel>(
  (_) => ComponentTreeModel(),
);

/// Whether the component tree and the selected component are kept up to date
/// by polling the game.
final liveUpdatesProvider = StateProvider<bool>((_) => true);

/// Refreshes the component tree and returns the number of components in it.
final componentTreeLoaderProvider = FutureProvider<int>((ref) async {
  final model = ref.read(loadedTreeModelProvider);
  await model.refresh();

  // The nodes are updated in place, so the selected node is still the same
  // node, unless its component was removed from the game; then the selection
  // is cleared.
  final selectedKey = ref.read(selectedTreeNodeProvider)?.key;
  if (selectedKey != null && model.findNode(selectedKey) == null) {
    ref.read(selectedTreeNodeProvider.notifier).state = null;
  }
  return model.componentCount;
});

class ComponentTreeModel() {
  final treeRoot = TreeNode<ComponentTreeNode>.root();

  /// The number of components in the tree, as of the last [refresh].
  int get componentCount => _componentCount;
  var _componentCount = 0;

  /// Fetches the component tree and updates the nodes in place, so that
  /// expanded nodes stay expanded.
  Future<void> refresh() async {
    final node = await Repository.getComponentTree();
    _componentCount = syncTreeChildren(treeRoot, [node]);
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
}
