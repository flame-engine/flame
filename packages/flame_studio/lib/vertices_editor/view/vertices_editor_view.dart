import 'package:flame_studio/repositories/repositories.dart';
import 'package:flame_studio/vertices_editor/bloc/vertices_editor_cubit.dart';
import 'package:flame_studio/vertices_editor/widgets/widgets.dart';
import 'package:flame_studio/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template vertices_editor_view}
/// The content of the `VerticesEditorDialog`: the canvas, the list of
/// vertices to type their coordinates, the selected vertex, the zoom of
/// the canvas (also Cmd/Ctrl + `=`, `-` and `0`) and the buttons that apply
/// or discard the changes.
/// {@endtemplate}
class const VerticesEditorView({
  /// The paint the polygon is drawn with.
  required final ComponentPaint paint,
  super.key,
}) extends StatelessWidget {
  /// {@macro vertices_editor_view}
  this;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<VerticesEditorCubit>().state;
    final selectedIndex = state.selectedIndex;
    final cubit = context.read<VerticesEditorCubit>();

    return CallbackShortcuts(
      bindings: zoomShortcuts(
        onZoomIn: cubit.zoomedIn,
        onZoomOut: cubit.zoomedOut,
        onReset: cubit.zoomReset,
      ),
      child: Dialog(
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 1080,
          height: 600,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Edit vertices',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    ZoomControls(
                      zoom: state.zoom,
                      onZoomIn: state.canZoomIn ? cubit.zoomedIn : null,
                      onZoomOut: state.canZoomOut ? cubit.zoomedOut : null,
                      onReset: cubit.zoomReset,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRect(child: VerticesCanvas(paint: paint)),
                    ),
                    const VerticalDivider(width: 1),
                    const SizedBox(width: 280, child: VerticesList()),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 16, 16),
                child: Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedIndex == null
                                ? '${state.vertices.length} vertices'
                                : _describe(
                                    selectedIndex,
                                    state.vertices[selectedIndex],
                                  ),
                          ),
                          Text(
                            'Drag to move · click + on an edge to add · '
                            'Delete to remove · type exact values on the right',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Delete vertex',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: selectedIndex != null && state.canDelete
                          ? context
                                .read<VerticesEditorCubit>()
                                .selectedVertexDeleted
                          : null,
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pop(context.read<VerticesEditorCubit>().state.result),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _describe(int index, ComponentVertex vertex) {
    return 'Vertex ${index + 1}: (${_number(vertex.x)}, ${_number(vertex.y)})';
  }

  static String _number(double value) {
    return value == value.truncateToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }
}
