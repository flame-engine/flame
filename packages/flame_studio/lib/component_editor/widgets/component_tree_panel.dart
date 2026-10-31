import 'package:flame_studio/component_editor/bloc/component_editor_bloc.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template component_tree_panel}
/// Shows the component being edited and the components inside it as a
/// tree.
///
/// Tapping a node selects it, so the properties panel edits it. New
/// components are added inside the selected node, unless it is a hitbox,
/// which can't have children.
/// {@endtemplate}
class const ComponentTreePanel({super.key}) extends StatelessWidget {
  /// {@macro component_tree_panel}
  this;

  @override
  Widget build(BuildContext context) {
    final (component, selectedPath) = context
        .select<ComponentEditorBloc, (Component, List<int>)>(
          (bloc) => (bloc.state.component, bloc.state.selectedPath),
        );
    final bloc = context.read<ComponentEditorBloc>();
    final nodes = _flatten(component, const []).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Components',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              PopupMenuButton<ComponentEditorChildAdded>(
                tooltip: 'Add child',
                icon: const Icon(Icons.add),
                enabled: component.nodeAt(selectedPath) is! HitboxComponent,
                onSelected: bloc.add,
                itemBuilder: (_) => [
                  for (final type in ComponentType.values)
                    if (type.hasVertices)
                      // One entry per shape a new polygon can start with.
                      for (final shape in PolygonShape.values)
                        PopupMenuItem(
                          value: ComponentEditorChildAdded(
                            type,
                            polygonShape: shape,
                          ),
                          child: ListTile(
                            leading: Icon(iconFor(type)),
                            title: Text(
                              '${type.label} (${shape.label.toLowerCase()})',
                            ),
                          ),
                        )
                    else
                      PopupMenuItem(
                        value: ComponentEditorChildAdded(type),
                        child: ListTile(
                          leading: Icon(iconFor(type)),
                          title: Text(type.label),
                        ),
                      ),
                ],
              ),
              IconButton(
                tooltip: 'Remove',
                icon: const Icon(Icons.delete_outline),
                onPressed: selectedPath.isEmpty
                    ? null
                    : () => bloc.add(ComponentEditorNodeRemoved(selectedPath)),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            children: [
              for (final (path, node) in nodes)
                ListTile(
                  key: ValueKey(path.join('.')),
                  dense: true,
                  selected: listEquals(path, selectedPath),
                  contentPadding: EdgeInsetsDirectional.only(
                    start: 16.0 + path.length * 16,
                    end: 16,
                  ),
                  leading: Icon(iconFor(node.type), size: 18),
                  title: Text(node.name),
                  onTap: () => bloc.add(ComponentEditorNodeSelected(path)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// The icon shown for components of [type].
  static IconData iconFor(ComponentType type) {
    return switch (type) {
      ComponentType.rectangle => Icons.crop_square,
      ComponentType.position => Icons.crop_free,
      ComponentType.circle => Icons.circle_outlined,
      ComponentType.polygon => Icons.pentagon_outlined,
      ComponentType.rectangleHitbox => Icons.select_all,
      ComponentType.circleHitbox => Icons.track_changes,
      ComponentType.polygonHitbox => Icons.hexagon_outlined,
    };
  }

  static Iterable<(List<int>, Component)> _flatten(
    Component node,
    List<int> path,
  ) sync* {
    yield (path, node);
    for (final (index, child) in node.children.indexed) {
      yield* _flatten(child, [...path, index]);
    }
  }
}
