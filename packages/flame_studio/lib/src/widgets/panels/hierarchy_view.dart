import 'package:flame/components.dart' show Component;
import 'package:flame_studio/src/core/component_tree.dart';
import 'package:flame_studio/src/core/hierarchy_expansion.dart';
import 'package:flame_studio/src/core/selection.dart';
import 'package:flame_studio/src/core/theme.dart';
import 'package:flame_studio/src/widgets/common/disclosure_triangle.dart';
import 'package:flame_studio/src/widgets/common/studio_text_field.dart';
import 'package:flame_studio/src/widgets/common/studio_tooltip.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows the component tree of the game, and allows to select a component.
///
/// When the filter is not empty, only the components whose type name contains
/// the filter are shown, together with their ancestors.
class const HierarchyView({super.key}) extends ConsumerStatefulWidget {
  static const double indentWidth = 14.0;

  @override
  ConsumerState<HierarchyView> createState() => _HierarchyViewState();
}

class _HierarchyViewState() extends ConsumerState<HierarchyView> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final root = ref.watch(componentTreeProvider).root;
    final expanded = ref.watch(hierarchyExpansionProvider);
    final selected = ref.watch(selectedComponentProvider);
    ref.listen(selectedComponentProvider, (_, component) {
      if (component != null) {
        ref.read(hierarchyExpansionProvider.notifier).reveal(component);
      }
    });

    final rows = <_RowData>[];
    if (root != null) {
      final query = _filter.trim().toLowerCase();
      if (query.isEmpty) {
        _flatten(root, 0, expanded, rows);
      } else {
        _flattenFiltered(root, 0, query, rows);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(6),
          child: StudioTooltip(
            message:
                'Only show the components whose type contains this text, '
                'together with their ancestors',
            child: StudioTextField(
              value: _filter,
              placeholder: 'Filter',
              onChanged: (value) => setState(() => _filter = value),
            ),
          ),
        ),
        Expanded(
          child: root == null
              ? Center(
                  child: Text(
                    'Waiting for a game…',
                    style: TextStyle(color: theme.dimTextColor),
                  ),
                )
              : ListView.builder(
                  itemCount: rows.length,
                  itemExtent: theme.rowHeight,
                  itemBuilder: (context, index) {
                    final row = rows[index];
                    return _HierarchyRow(
                      row,
                      isSelected: row.node.component == selected,
                      canToggle: _filter.trim().isEmpty,
                      key: ObjectKey(row.node.component),
                    );
                  },
                ),
        ),
      ],
    );
  }

  static void _flatten(
    ComponentTreeNode node,
    int depth,
    Set<Component> expanded,
    List<_RowData> out,
  ) {
    final isExpanded = expanded.contains(node.component);
    out.add(_RowData(node, depth, isExpanded: isExpanded));
    if (isExpanded && node.hasChildren) {
      for (final child in node.children!) {
        _flatten(child, depth + 1, expanded, out);
      }
    }
  }

  /// Adds [node] to [out] if it or any of its descendants matches the [query],
  /// and returns whether it was added.
  static bool _flattenFiltered(
    ComponentTreeNode node,
    int depth,
    String query,
    List<_RowData> out,
  ) {
    final index = out.length;
    var hasMatchingChild = false;
    out.add(_RowData(node, depth, isExpanded: false));
    for (final child in node.children ?? const <ComponentTreeNode>[]) {
      hasMatchingChild |= _flattenFiltered(child, depth + 1, query, out);
    }
    if (!hasMatchingChild && !node.name.toLowerCase().contains(query)) {
      out.removeRange(index, out.length);
      return false;
    }
    out[index] = _RowData(node, depth, isExpanded: hasMatchingChild);
    return true;
  }
}

class const _RowData(
  final ComponentTreeNode node,
  final int depth, {
  required final bool isExpanded,
});

class const _HierarchyRow(
  final _RowData row, {
  required final bool isSelected,
  required final bool canToggle,
  super.key,
}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<_HierarchyRow> createState() => _HierarchyRowState();
}

class _HierarchyRowState() extends ConsumerState<_HierarchyRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final row = widget.row;
    final node = row.node;

    Widget expander = const SizedBox(width: 16);
    if (node.hasChildren) {
      expander = DisclosureTriangle(
        isExpanded: row.isExpanded,
        color: widget.isSelected ? theme.textColor : theme.dimTextColor,
      );
      if (widget.canToggle) {
        expander = GestureDetector(
          onTap: () => ref
              .read(hierarchyExpansionProvider.notifier)
              .toggle(node.component),
          child: expander,
        );
      }
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () =>
            ref.read(selectedComponentProvider.notifier).select(node.component),
        child: Container(
          color: widget.isSelected
              ? theme.accentColor
              : (_isHovered ? theme.hoverColor : null),
          padding: EdgeInsets.only(
            left: 4 + row.depth * HierarchyView.indentWidth,
            right: 8,
          ),
          child: Row(
            children: [
              expander,
              Expanded(
                child: Text(
                  node.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (node.hasChildren && !row.isExpanded)
                Text(
                  '${node.children!.length}',
                  style: TextStyle(
                    color: widget.isSelected
                        ? theme.textColor
                        : theme.dimTextColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
