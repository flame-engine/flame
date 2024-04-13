import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:devtools_app_shared/ui.dart';
import 'package:flame_devtools/widgets/component_tree_model.dart';
import 'package:flame_devtools/widgets/debug_mode_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComponentTree extends StatelessWidget {
  const ComponentTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Split(
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
    final model = ref.watch(componentTreeModelProvider);
    final selectedTreeNode = ref.watch(selectedTreeNodeProvider);
    final componentCount = model.value?.componentCount ?? 0;

    return RoundedOutlinedBorder(
      child: Column(
        children: [
          AreaPaneHeader(
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
                  onPressed: () => ref.refresh(componentTreeModelProvider),
                ),
              ],
            ),
          ),
          model.when(
            data: (data) {
              return Expanded(
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
                    tree: data.treeRoot,
                  ),
                ),
              );
            },
            loading: () => const CircularProgressIndicator(strokeWidth: 20),
            error: (_, __) => const Text('Error loading the component tree'),
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

    return RoundedOutlinedBorder(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AreaPaneHeader(
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: node == null
                ? Text(
                    'Select a component in the tree',
                    style: textStyle,
                  )
                : Column(
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
                    ].withSpacing(),
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
