import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flame/devtools.dart';

/// Updates the children of [parent] in place so that they match [children].
///
/// Nodes for components that are still in the game are kept, so that their
/// expansion state is kept, and only their data is updated. Nodes for removed
/// components are removed, and nodes for new components are added.
///
/// Returns the number of components in [children], including all of their
/// descendants.
int syncTreeChildren(
  TreeNode<ComponentTreeNode> parent,
  List<ComponentTreeNode> children,
) {
  final existing = {
    for (final child in parent.childrenAsList)
      child.key: child as TreeNode<ComponentTreeNode>,
  };
  final keys = {for (final child in children) child.id.toString()};

  for (final entry in existing.entries) {
    if (!keys.contains(entry.key)) {
      parent.remove(entry.value);
    }
  }

  var count = 0;
  for (final child in children) {
    final key = child.id.toString();
    var node = existing[key];
    if (node == null) {
      node = TreeNode(key: key, parent: parent, data: child);
      parent.add(node);
    } else {
      node.data = child;
    }
    count += 1 + syncTreeChildren(node, child.children);
  }
  return count;
}
