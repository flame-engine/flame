import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:devtools_app_shared/ui.dart' as devtools_ui;
import 'package:flame/devtools.dart';
import 'package:flame_devtools/poller.dart';
import 'package:flame_devtools/providers/component_priority_provider.dart';
import 'package:flame_devtools/providers/position_component_attributes_provider.dart';
import 'package:flame_devtools/repository.dart';
import 'package:flame_devtools/widgets/behavior_tree_section.dart';
import 'package:flame_devtools/widgets/component_priority_form.dart';
import 'package:flame_devtools/widgets/component_snapshot.dart';
import 'package:flame_devtools/widgets/component_tree_model.dart';
import 'package:flame_devtools/widgets/debug_mode_button.dart';
import 'package:flame_devtools/widgets/position_component_attributes_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How often the selected component is refreshed while live updates are on.
///
/// This is cheap since it is a single component.
const _selectedComponentInterval = Duration(milliseconds: 100);

/// How often the component tree is refreshed while live updates are on.
///
/// The game builds the whole tree, with the `toString` and attributes of every
/// component, on every call, so this is less frequent.
const _componentTreeInterval = Duration(seconds: 1);

class const ComponentTree({super.key}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<ComponentTree> createState() => _ComponentTreeState();
}

class _ComponentTreeState() extends ConsumerState<ComponentTree> {
  late final _treePoller = Poller(
    interval: _componentTreeInterval,
    isActive: () => _isLive && !ref.read(componentTreeLoaderProvider).isLoading,
    poll: () => ref.refresh(componentTreeLoaderProvider.future),
  );

  late final _selectedComponentPoller = Poller(
    interval: _selectedComponentInterval,
    isActive: () => _isLive && ref.read(selectedTreeNodeProvider) != null,
    poll: _refreshSelectedComponent,
  );

  bool get _isLive => ref.read(liveUpdatesProvider) && Repository.isConnected;

  Future<void> _refreshSelectedComponent() async {
    final node = ref.read(selectedTreeNodeProvider)?.data;
    if (node == null) {
      return;
    }
    await Future.wait([
      ref.refresh(componentPriorityProvider(node.id).future),
      if (node.isPositionComponent)
        ref.refresh(positionComponentAttributesProvider(node.id).future),
    ]);
  }

  @override
  void initState() {
    super.initState();
    _treePoller.start();
    _selectedComponentPoller.start();
  }

  @override
  void dispose() {
    _treePoller.stop();
    _selectedComponentPoller.stop();
    super.dispose();
  }

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

class const ComponentTreeSection({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final loader = ref.watch(componentTreeLoaderProvider);
    final loadedModel = ref.watch(loadedTreeModelProvider);
    final selectedTreeNode = ref.watch(selectedTreeNodeProvider);
    final componentCount = loadedModel.componentCount;

    return devtools_ui.RoundedOutlinedBorder(
      child: Column(
        children: [
          devtools_ui.AreaPaneHeader(
            title: Row(
              children: [
                Flexible(
                  child: Text(
                    'Component Tree ($componentCount components)',
                    style: theme.textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  iconSize: 18,
                  alignment: Alignment.center,
                  tooltip: 'Refresh',
                  onPressed: loader.isLoading
                      ? null
                      : () => ref.refresh(componentTreeLoaderProvider),
                ),
                const SizedBox(width: 8),
                Text('Live', style: theme.textTheme.bodyMedium),
                // Scaled down to fit in the height of the pane header.
                Transform.scale(
                  scale: 0.7,
                  child: Switch(
                    key: const Key('live_updates_switch'),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: ref.watch(liveUpdatesProvider),
                    onChanged: (value) =>
                        ref.read(liveUpdatesProvider.notifier).state = value,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TreeView.simple(
              showRootNode: false,
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
                      ref.read(selectedTreeNodeProvider.notifier).state = node;
                    },
                  ),
                );
              },
              tree: loadedModel.treeRoot,
            ),
          ),
        ],
      ),
    );
  }
}

class const ComponentSection({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treeNode = ref.watch(selectedTreeNodeProvider);
    if (treeNode == null) {
      return _buildSection(context, null);
    }
    // The tree node is updated in place when the tree is refreshed, so its
    // data is listened to directly.
    return ValueListenableBuilder(
      valueListenable: treeNode.listenableData,
      builder: (context, node, _) => _buildSection(context, node),
    );
  }

  Widget _buildSection(BuildContext context, ComponentTreeNode? node) {
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
                        spacing: 10,
                        children: [
                          Row(
                            spacing: 10,
                            children: [
                              Text('Id: ${node.id}', style: textStyle),
                              DebugModeButton(id: node.id),
                            ],
                          ),
                          Text('Type: ${node.name}', style: textStyle),
                          Text(
                            'Children: ${node.children.length}',
                            style: textStyle,
                          ),
                          ComponentPriorityForm(componentId: node.id),
                          if (node.isPositionComponent)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: PositionComponentAttributesForm(
                                componentId: node.id,
                              ),
                            ),
                          BehaviorTreeSection(
                            id: node.id,
                            fetch: (id) => Repository.getBehaviorTree(id: id),
                          ),
                          Text(
                            'toString:\n${node.toStringText}',
                            style: textStyle,
                          ),
                          ComponentSnapshot(id: node.id),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
