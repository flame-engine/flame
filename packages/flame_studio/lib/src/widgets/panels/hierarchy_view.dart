import 'package:flame/components.dart' hide Matrix4;
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
    out.add(_ListItem(this, node, depth, isFirst: out.isEmpty));
    final isExpanded = expandedComponents.contains(node.component);
    if (isExpanded && node.hasChildren) {
      for (final childNode in node.children!) {
        _buildList(childNode, depth + 1, out);
      }
      out.add(_ClosingBrace(depth));
    }
  }

  /// Used by the expander icons in the gutter: the component expands/collapses
  /// without affecting the selection state.
  void toggle(Component component) {
    setState(() {
      if (expandedComponents.contains(component)) {
        expandedComponents.remove(component);
      } else {
        expandedComponents.add(component);
      }
    });
  }

  void toggleOrSelect(Component component) {
    final isExpanded = expandedComponents.contains(component);
    final isSelected = selectedComponent == component;
    setState(() {
      if (isExpanded && isSelected) {
        expandedComponents.remove(component);
      } else {
        expandedComponents.add(component);
      }
      selectedComponent = component;
    });
  }
}

class _ListItem extends StatelessWidget {
  _ListItem(this.state, this.node, this.indent, {required this.isFirst})
    : super(key: ObjectKey(node.component));

  final HierarchyViewState state;
  final ComponentTreeNode node;
  final int indent;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final isSelected = state.selectedComponent == node.component;
    final isExpanded = state.expandedComponents.contains(node.component);
    final hasChildren = node.hasChildren;

    Widget expanderIcon = _ExpanderIcon(
      hasChildren: hasChildren,
      isExpanded: isExpanded,
      isFirst: isFirst,
      isLast: indent == 0 && !(isExpanded && hasChildren),
    );
    if (hasChildren) {
      expanderIcon = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => state.toggle(node.component),
          child: expanderIcon,
        ),
      );
    }
    final componentName = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => state.toggleOrSelect(node.component),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            color: isSelected ? const Color(0xffc78938) : null,
          ),
          child: Text(
            node.name,
            style: const TextStyle(
              color: Color(0xffffffff),
            ),
          ),
        ),
      ),
    );
    final punctuation = Transform(
      transform: Matrix4.translationValues(-3.0, 0, 0),
      child: Text(
        hasChildren ? (isExpanded ? ' {' : ' {...}') : ',',
        style: const TextStyle(color: Color(0x66f5d49a)),
      ),
    );

    return Row(
      children: [
        expanderIcon,
        SizedBox(width: 15.0 * indent),
        componentName,
        punctuation,
      ],
    );
  }
}

class _ClosingBrace extends StatelessWidget {
  const _ClosingBrace(this.indent);
  final int indent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ExpanderIcon(hasChildren: false, isLast: indent == 0),
        SizedBox(width: 15.0 * indent + 5.0),
        const Text('}', style: TextStyle(color: Color(0x66f5d49a))),
      ],
    );
  }
}

class _ExpanderIcon extends StatelessWidget {
  const _ExpanderIcon({
    required this.hasChildren,
    this.isExpanded = false,
    this.isFirst = false,
    this.isLast = false,
  });

  final bool hasChildren;
  final bool isExpanded;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(15, 20),
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
      if (!icon.isFirst) {
        canvas.drawLine(
          Offset(0, -yExtent),
          const Offset(0, -halfSize),
          _paint,
        );
      }
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
      if (!icon.isLast) {
        canvas.drawLine(
          const Offset(0, halfSize),
          Offset(0, yExtent),
          _paint,
        );
      }
    } else {
      canvas.drawLine(
        Offset(0, icon.isFirst ? 0 : -yExtent),
        Offset(0, icon.isLast ? -2.0 : yExtent),
        _paint,
      );
      if (icon.isLast) {
        canvas.drawCircle(Offset.zero, 2.0, _paint);
      }
    }
    canvas.restore();
  }
}
