import 'package:animated_tree_view/tree_view/tree_node.dart';
import 'package:animated_tree_view/tree_view/tree_view.dart';
import 'package:flame/devtools.dart';
import 'package:flame_devtools/repository.dart';
import 'package:flutter/material.dart';

class ComponentTree extends StatefulWidget {
  const ComponentTree({super.key});

  @override
  State<ComponentTree> createState() => _ComponentTreeState();
}

class _ComponentTreeState extends State<ComponentTree> {
  Future<ComponentTreeNode>? _componentTree;
  final TreeNode<ComponentTreeNode> _tree = TreeNode.root();
  TreeNode<ComponentTreeNode>? _selectedTreeNode;

  @override
  void initState() {
    _refreshComponentTree();
    super.initState();
  }

  void _refreshComponentTree() {
    _tree.clear();
    _componentTree = Repository.getComponentTree();
    _componentTree?.then((value) => _buildTree(value, _tree));
  }

  void _buildTree(ComponentTreeNode node, TreeNode<ComponentTreeNode> parent) {
    final current = TreeNode(
      key: node.id.toString(),
      parent: parent,
      data: node,
    );
    parent.add(current);
    for (final child in node.children) {
      _buildTree(child, current);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _componentTree,
      builder: (context, value) {
        return Row(
          children: [
            Expanded(
              child: value.hasData
                  ? ValueListenableBuilder(
                      valueListenable: _tree,
                      builder: (context, _, __) => TreeView.simple(
                        showRootNode: false,
                        shrinkWrap: true,
                        builder: (context, node) {
                          return ListTile(
                            title: Text(node.data?.name ?? 'something'),
                            subtitle: Text(node.data?.id.toString() ?? 'else'),
                            onTap: () {
                              return setState(() => _selectedTreeNode = node);
                            },
                          );
                        },
                        tree: _tree,
                      ),
                    )
                  : const CircularProgressIndicator(strokeWidth: 20),
            ),
            Expanded(
              child: Text(
                _selectedTreeNode?.data?.name ?? 'Select a node',
                style: const TextStyle(fontSize: 24),
              ),
            )
          ],
        );
      },
    );
  }
}
