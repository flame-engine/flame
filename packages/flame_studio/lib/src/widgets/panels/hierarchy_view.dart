import 'package:flame_studio/src/core/component_tree.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HierarchyView extends ConsumerWidget {
  const HierarchyView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final componentTree = ref.watch(componentTreeProvider);
    if (componentTree == null) {
      return Container();
    }

    final listItems = <Widget>[];
    final controller = ref.read(componentTreeProvider.notifier);
    componentTree.traverse((node, depth, parent, index) {
      listItems.add(_buildItem(node, depth, controller));
      return false;
    });

    return ListView(
      padding: const EdgeInsets.all(8),
      children: listItems,
    );
  }

  Widget _buildItem(Node node, int depth, ComponentTreeNotifier controller) {
    final pre = node.isExpanded
        ? '[-]'
        : node.isCollapsed
            ? '[+]'
            : '[ ]';
    return GestureDetector(
      onTap: () => controller.toggle(node.component),
      child: Text(
        '$pre ${'..' * depth}${node.name}',
        style: const TextStyle(
          color: Color(0xffffffff),
        ),
      ),
    );
  }
}
