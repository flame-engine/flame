import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:devtools_app_shared/ui.dart' as devtools_ui;
import 'package:flame_devtools/widgets/component_snapshot.dart';
import 'package:flame_devtools/widgets/component_tree_model.dart';
import 'package:flame_devtools/widgets/debug_mode_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComponentTree extends StatelessWidget {
  const ComponentTree({super.key});

  @override
  Widget build(BuildContext context) {
    return devtools_ui.SplitPane(
      axis: MediaQuery.of(context).size.width > 1000
          ? Axis.horizontal
          : Axis.vertical,
      initialFractions: const [0.5, 0.5],
      minSizes: const [300, 350],
      children: const [
        ComponentTreeSection(),
        ComponentSection(),
      ],
    );
  }
}

class ComponentTreeSection extends ConsumerWidget {
  const ComponentTreeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final loader = ref.read(componentTreeLoaderProvider);
    final loadedModel = ref.watch(loadedTreeModelProvider);
    final selectedTreeNode = ref.watch(selectedTreeNodeProvider);
    final componentCount = loadedModel.componentCount;

    return devtools_ui.RoundedOutlinedBorder(
      child: Column(
        children: [
          devtools_ui.AreaPaneHeader(
            title: Row(
              children: [
                Text(
                  'Component Tree ($componentCount components)',
                  style: theme.textTheme.titleSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  iconSize: 18,
                  alignment: Alignment.center,
                  onPressed: loader.isLoading
                      ? null
                      : () => ref.refresh(componentTreeLoaderProvider),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: TreeView.simple(
                showRootNode: false,
                shrinkWrap: true,
                indentation: const Indentation(
                  color: Colors.blue,
                  style: IndentStyle.roundJoint,
                ),
                onTreeReady: (controller) =>
                    controller.expandAllChildren(controller.tree),
                padding: const EdgeInsets.only(left: 20),
                expansionIndicatorBuilder: (context, node) => node.isLeaf
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
                      key: Key(
                        node.data?.id.toString() ?? node.key,
                      ),
                      selected: node == selectedTreeNode,
                      selectedColor: theme.colorScheme.primary,
                      title: Text(node.data!.name),
                      subtitle: Text(node.data!.id.toString()),
                      onTap: () {
                        ref.read(selectedTreeNodeProvider.notifier).state =
                            node;
                      },
                    ),
                  );
                },
                tree: loadedModel.treeRoot,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ComponentSection extends ConsumerWidget {
  const ComponentSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final node = ref.watch(selectedTreeNodeProvider)?.data;
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyLarge;

    return devtools_ui.RoundedOutlinedBorder(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          devtools_ui.AreaPaneHeader(
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Component',
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: node == null
                  ? Text(
                      'Select a component in the tree',
                      style: textStyle,
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Id: ${node.id}', style: textStyle),
                              DebugModeButton(id: node.id),
                            ].withSpacing(),
                          ),
                          Text('Type: ${node.name}', style: textStyle),
                          Text(
                            'Children: ${node.children.length}',
                            style: textStyle,
                          ),
                          Text(
                            'toString:\n${node.toStringText}',
                            style: textStyle,
                          ),
                          ComponentSnapshot(id: node.id.toString()),
                        ].withSpacing(),
                      ),
                    ),
            ),
          ),
        ],
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
