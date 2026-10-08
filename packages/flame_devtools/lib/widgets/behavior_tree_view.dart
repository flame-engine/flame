import 'package:flame_devtools/behavior_tree_snapshot.dart';
import 'package:flutter/material.dart';

/// The width from which the tree and the blackboard are shown next to each
/// other, instead of below each other.
const _sideBySideWidth = 560.0;

/// The height of the row with the headings, which is the same for the tree and
/// the blackboard so that their headings are aligned, also when only one of
/// them has the [BehaviorTreeView.controls] next to it.
const _headerHeight = 40.0;

/// Shows a [BehaviorTreeSnapshot]: the nodes of the tree and what each of them
/// is doing, and the contents of the blackboard.
///
/// A node that is running is bold, and the color of the other nodes is the
/// status that they returned last. Nodes that have not been ticked, or that
/// were aborted, are grey.
///
/// The tree and the blackboard are next to each other when there is enough
/// room, and below each other otherwise. The [controls] are shown at the end of
/// the row with the headings.
class const BehaviorTreeView({required this.snapshot, this.controls, super.key})
    extends StatelessWidget {
  final BehaviorTreeSnapshot snapshot;

  /// Widgets to show at the end of the headings, for example to refresh.
  final Widget? controls;

  @override
  Widget build(BuildContext context) {
    final tree = _TreeColumn(snapshot: snapshot);
    final blackboard = _BlackboardColumn(entries: snapshot.blackboard);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _sideBySideWidth) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(title: 'Behavior tree', trailing: controls),
              tree,
              const _Header(title: 'Blackboard'),
              blackboard,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Header(title: 'Behavior tree'),
                  tree,
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(title: 'Blackboard', trailing: controls),
                  blackboard,
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class const _Header({required this.title, this.trailing})
    extends StatelessWidget {
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _headerHeight,
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          if (trailing != null) ...[const Spacer(), trailing!],
        ],
      ),
    );
  }
}

class const _TreeColumn({required this.snapshot}) extends StatelessWidget {
  final BehaviorTreeSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tickInterval = snapshot.tickInterval;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        // That the tree is ticked on every update is the default, so this
        // only says something when it is not the case.
        if (tickInterval > 0)
          Text(
            'Ticked every ${tickInterval}s',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
        _NodeRow(node: snapshot.root, depth: 0),
      ],
    );
  }
}

class const _BlackboardColumn({required this.entries}) extends StatelessWidget {
  final List<BlackboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyLarge;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        if (entries.isEmpty)
          Text(
            'No values are set',
            style: textStyle?.copyWith(color: theme.hintColor),
          ),
        for (final entry in entries)
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${entry.key}: ',
                  style: TextStyle(color: theme.hintColor),
                ),
                TextSpan(text: entry.value),
              ],
            ),
            style: textStyle,
          ),
      ],
    );
  }
}

class const _NodeRow({required this.node, required this.depth})
    extends StatelessWidget {
  final BehaviorTreeNodeSnapshot node;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyLarge;
    final color = _stateColor(context, node.state);
    final name = node.name;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: depth * 20.0, top: 3, bottom: 3),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: node.type,
                        style: TextStyle(
                          color: color,
                          fontWeight: node.isRunning
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (name != null)
                        TextSpan(
                          text: '  $name',
                          style: TextStyle(color: theme.hintColor),
                        ),
                    ],
                  ),
                  style: textStyle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                node.state ?? 'idle',
                style: theme.textTheme.bodyMedium?.copyWith(color: color),
              ),
            ],
          ),
        ),
        for (final child in node.children)
          _NodeRow(node: child, depth: depth + 1),
      ],
    );
  }
}

/// The color that is used for a node that is in [state].
Color _stateColor(BuildContext context, String? state) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return switch (state) {
    'running' => isDark ? const Color(0xFFFFD60A) : const Color(0xFFB8860B),
    'success' => isDark ? const Color(0xFF30D158) : const Color(0xFF1B8A3A),
    'failure' => isDark ? const Color(0xFFFF453A) : const Color(0xFFC62828),
    _ => Theme.of(context).disabledColor,
  };
}
