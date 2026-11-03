import 'package:flame_studio/component_editor/widgets/property_editors/number_field.dart';
import 'package:flame_studio/vertices_editor/bloc/vertices_editor_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template vertices_list}
/// The side bar of the vertices editor: a row per vertex, with fields to
/// type its exact coordinates and a button to delete it.
///
/// Selecting a row, or focusing one of its fields, selects its vertex on
/// the canvas, and vice versa.
/// {@endtemplate}
class const VerticesList({super.key}) extends StatelessWidget {
  /// {@macro vertices_list}
  this;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<VerticesEditorCubit>().state;
    final cubit = context.read<VerticesEditorCubit>();
    final theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.vertices.length,
      itemBuilder: (context, index) {
        final vertex = state.vertices[index];
        final isSelected = index == state.selectedIndex;
        // Fresh fields when vertices are added or removed, so no field
        // keeps the text of the vertex that used to be at its index.
        return Material(
          key: ValueKey('${state.vertices.length}-$index'),
          color: isSelected
              ? theme.colorScheme.secondaryContainer
              : Colors.transparent,
          child: InkWell(
            onTap: () => cubit.vertexSelected(index),
            child: Focus(
              canRequestFocus: false,
              skipTraversal: true,
              onFocusChange: (focused) {
                if (focused) {
                  cubit.vertexSelected(index);
                }
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
                child: Row(
                  spacing: 8,
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text(
                        '${index + 1}',
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                    Expanded(
                      child: NumberField(
                        label: 'X',
                        value: vertex.x,
                        min: null,
                        onChanged: (x) => cubit.vertexMoved(index, x, vertex.y),
                      ),
                    ),
                    Expanded(
                      child: NumberField(
                        label: 'Y',
                        value: vertex.y,
                        min: null,
                        onChanged: (y) => cubit.vertexMoved(index, vertex.x, y),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Delete vertex ${index + 1}',
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: state.canDelete
                          ? () => cubit.vertexDeleted(index)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
