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
    final isExpanded = expandedComponents.contains(node.component);
    return Row(
      children: [
        if (node.hasChildren)
          GestureDetector(
            onTap: () => _toggle(node.component),
            child: _ExpanderIcon(true, isExpanded),
          )
        else
          _ExpanderIcon(false, isExpanded),
        if (depth > 0)
          Container(width: 15.0 * depth),
        GestureDetector(
          onTap: () => _toggle(node.component),
          child: Text(
            node.name,
            style: const TextStyle(
              color: Color(0xffffffff),
            ),
          ),
        )
      ],
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

class _ExpanderIcon extends StatelessWidget {
  const _ExpanderIcon(this.hasChildren, this.isExpanded);
  final bool hasChildren;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 20),
      painter: _ExpanderIconPainter(this),
    );
  }
}

class _ExpanderIconPainter extends CustomPainter {
  _ExpanderIconPainter(this.icon);

  final _ExpanderIcon icon;
  static final _paint = Paint()
    ..color = const Color(0xFFFFFFFF)
    ..style = PaintingStyle.stroke;

  @override
  bool shouldRepaint(_ExpanderIconPainter old) =>
      (icon.hasChildren != old.icon.hasChildren) ||
      (icon.isExpanded != old.icon.isExpanded);

  @override
  void paint(Canvas canvas, Size size) {
    const iconSize = 10.0;
    const halfSize = iconSize / 2;
    final xExtent = size.width / 2;
    final yExtent = size.height / 2;
    canvas.save();
    canvas.translate(xExtent, yExtent);
    if (icon.hasChildren) {
      canvas.drawLine(
        Offset(0, -yExtent),
        const Offset(0, -halfSize),
        _paint,
      );
      canvas.drawRect(
        const Rect.fromLTWH(-halfSize, -halfSize, iconSize, iconSize),
        _paint,
      );
      canvas.drawLine(
        const Offset(-iconSize / 4, 0),
        const Offset(iconSize / 4, 0),
        _paint,
      );
      if (!icon.isExpanded) {
        canvas.drawLine(
          const Offset(0, -iconSize / 4),
          const Offset(0, iconSize / 4),
          _paint,
        );
      }
      canvas.drawLine(
        const Offset(0, halfSize),
        Offset(0, yExtent),
        _paint,
      );
    } else {
      canvas.drawLine(Offset(0, -yExtent), Offset(0, yExtent), _paint);
    }
    canvas.restore();
  }
}
