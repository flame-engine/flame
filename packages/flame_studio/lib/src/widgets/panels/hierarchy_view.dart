import 'package:flame/components.dart';
import 'package:flame_studio/src/core/component_tree.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HierarchyView extends ConsumerStatefulWidget {
  const HierarchyView({super.key});

  @override
  HierarchyViewState createState() => HierarchyViewState();
}

class HierarchyViewState extends ConsumerState<ConsumerStatefulWidget> {
  Component? selectedComponent;
  Set<Component> expandedComponents = {};

  @override
  Widget build(BuildContext context) {
    final componentTree = ref.watch(componentTreeProvider).root;
    if (componentTree == null) {
      return Container();
    }

    final listItems = <Widget>[];
    _buildList(componentTree, 0, listItems);

    return ListView(
      padding: const EdgeInsets.all(8),
      children: listItems,
    );
  }

  void _buildList(ComponentTreeNode node, int depth, List<Widget> out) {
    out.add(_buildItem(node, depth));
    if (expandedComponents.contains(node.component) && node.children != null) {
      for (final childNode in node.children!) {
        _buildList(childNode, depth + 1, out);
      }
    }
  }

  Widget _buildItem(ComponentTreeNode node, int depth) {
    final pre = '[-]';
    return GestureDetector(
      onTap: () => _toggle(node.component),
      child: Text(
        '$pre ${'..' * depth}${node.name}',
        style: const TextStyle(
          color: Color(0xffffffff),
        ),
      ),
    );
  }

  void _toggle(Component component) {
    setState(() {
      if (expandedComponents.contains(component)) {
        expandedComponents.remove(component);
      } else {
        expandedComponents.add(component);
      }
    });
  }
}
