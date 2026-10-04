import 'package:flame_devtools/behavior_tree_snapshot.dart';
import 'package:flutter/material.dart';

/// Shows a [BehaviorTreeSnapshot]: the nodes of the tree and what each of them
/// is doing, and the contents of the blackboard.
///
/// A node that is running is bold, and the color of the other nodes is the
/// status that they returned last. Nodes that have not been ticked, or that
/// were aborted, are grey.
class const BehaviorTreeView({required this.snapshot, super.key})
    extends StatelessWidget {
  final BehaviorTreeSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tickInterval = snapshot.tickInterval;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tickInterval > 0
              ? 'Ticked every ${tickInterval}s'
              : 'Ticked on every update',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        _NodeRow(node: snapshot.root, depth: 0),
        if (snapshot.blackboard.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Blackboard', style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          for (final entry in snapshot.blackboard)
            Text(
              '${entry.key}: ${entry.value}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
        ],
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
    final color = _stateColor(context, node.state);
    final name = node.name;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: depth * 16.0, top: 2, bottom: 2),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
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
                ),
              ),
              const SizedBox(width: 8),
              Text(
                node.state ?? 'idle',
                style: theme.textTheme.bodySmall?.copyWith(color: color),
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
