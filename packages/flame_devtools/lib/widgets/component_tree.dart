import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:devtools_app_shared/ui.dart';
import 'package:flame/devtools.dart';
import 'package:flame_devtools/repository.dart';
import 'package:flame_devtools/widgets/debug_mode_button.dart';
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
  int _componentCount = 0;

  @override
  void initState() {
    _refreshComponentTree();
    super.initState();
  }

  void _refreshComponentTree() {
    _tree.clear();
    _componentCount = 0;
    _componentTree = Repository.getComponentTree();
    _componentTree?.then((value) => setState(() => _buildTree(value, _tree)));
  }

  void _buildTree(ComponentTreeNode node, TreeNode<ComponentTreeNode> parent) {
    _componentCount++;
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
    final theme = Theme.of(context);
    return Column(
      children: [
        FutureBuilder(
          future: _componentTree,
          builder: (context, value) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: RoundedOutlinedBorder(
                    child: Column(
                      children: [
                        AreaPaneHeader(
                          title: Row(
                            children: [
                              Text(
                                'Component Tree ($_componentCount components)',
                                style: theme.textTheme.titleSmall,
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                alignment: Alignment.topCenter,
                                onPressed: () =>
                                    setState(_refreshComponentTree),
                              ),
                            ],
                          ),
                        ),
                        if (value.hasData)
                          SingleChildScrollView(
                            child: ValueListenableBuilder(
                              valueListenable: _tree,
                              builder: (context, _, __) => TreeView.simple(
                                showRootNode: false,
                                shrinkWrap: true,
                                indentation: const Indentation(
                                  color: Colors.blue,
                                  style: IndentStyle.roundJoint,
                                ),
                                padding: const EdgeInsets.only(left: 20),
                                expansionIndicatorBuilder: (context, node) =>
                                    node.isLeaf
                                        ? NoExpansionIndicator(tree: node)
                                        : ChevronIndicator.rightDown(
                                            tree: node,
                                            alignment: Alignment.centerLeft,
                                          ),
                                builder: (context, node) {
                                  return Padding(
                                    padding: node.isLeaf
                                        ? EdgeInsets.zero
                                        : const EdgeInsets.only(left: 20),
                                    child: ListTile(
                                      //key: Key(
                                      //  node.data?.id.toString() ?? node.key,
                                      //),
                                      title: Text(node.data!.name),
                                      subtitle: Text(node.data!.id.toString()),
                                      onTap: () {
                                        return setState(
                                          () => _selectedTreeNode = node,
                                        );
                                      },
                                    ),
                                  );
                                },
                                tree: _tree,
                              ),
                            ),
                          )
                        else
                          const CircularProgressIndicator(strokeWidth: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: RoundedOutlinedBorder(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AreaPaneHeader(
                          title: Row(
                            children: [
                              Text(
                                'Selected Component',
                                style: theme.textTheme.titleSmall,
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                alignment: Alignment.topCenter,
                                onPressed: () => setState(
                                  () {
                                    // TODO(Lukas): Update the selected component
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        ComponentView(_selectedTreeNode?.data),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class ComponentView extends StatelessWidget {
  const ComponentView(this.componentNode, {super.key});

  final ComponentTreeNode? componentNode;

  @override
  Widget build(BuildContext context) {
    final node = componentNode;
    const textStyle = TextStyle(fontSize: 18);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: node == null
          ? const Text(
              'Select a component in the tree',
              style: textStyle,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type: ${node.name}', style: textStyle),
                Text('Id: ${node.id}', style: textStyle),
                Text('Children: ${node.children.length}', style: textStyle),
                DebugModeButton(id: node.id),
              ].withSpacing(),
            ),
    );
  }
}

extension on List<Widget> {
  List<Widget> withSpacing() {
    return expand((item) sync* {
      yield const SizedBox(width: 10, height: 10);
      yield item;
    }).skip(1).toList();
  }
}
