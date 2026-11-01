import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flame_studio/repositories/repositories.dart';

part 'vertices_editor_state.dart';

/// {@template vertices_editor_cubit}
/// Edits a working copy of the vertices of a polygon, which the vertices
/// editor dialog returns when the user applies the changes.
///
/// Also holds the zoom of the canvas, which is not remembered: the dialog
/// opens fitting the polygon again every time.
/// {@endtemplate}
class VerticesEditorCubit(ComponentVertices vertices)
    extends Cubit<VerticesEditorState> {
  /// {@macro vertices_editor_cubit}
  this : super(VerticesEditorState(initial: vertices));

  /// Selects the vertex at [index], or nothing if it is `null`.
  void vertexSelected(int? index) {
    emit(state.copyWith(selectedIndex: () => index));
  }

  /// Moves the vertex at [index] to [x], [y].
  void vertexMoved(int index, double x, double y) {
    emit(
      state.copyWith(
        vertices: [...state.vertices]..[index] = ComponentVertex(x, y),
      ),
    );
  }

  /// Adds a vertex at [x], [y] on the edge that starts at the vertex at
  /// [edgeIndex], and selects it.
  void vertexInserted(int edgeIndex, double x, double y) {
    final index = edgeIndex + 1;
    emit(
      state.copyWith(
        vertices: [...state.vertices]..insert(index, ComponentVertex(x, y)),
        selectedIndex: () => index,
      ),
    );
  }

  /// Removes the selected vertex, unless the polygon would have fewer than
  /// [ComponentVertices.minLength] vertices.
  void selectedVertexDeleted() {
    final index = state.selectedIndex;
    if (index != null) {
      vertexDeleted(index);
    }
  }

  /// Removes the vertex at [index], unless the polygon would have fewer
  /// than [ComponentVertices.minLength] vertices. The selection stays on
  /// the same vertex, or is cleared if it was the removed one.
  void vertexDeleted(int index) {
    if (!state.canDelete) {
      return;
    }
    final selected = state.selectedIndex;
    emit(
      state.copyWith(
        vertices: [...state.vertices]..removeAt(index),
        selectedIndex: () => switch (selected) {
          null => null,
          _ when selected == index => null,
          _ when selected > index => selected - 1,
          _ => selected,
        },
      ),
    );
  }

  /// Zooms the canvas in to the next of the [ZoomLevels], if any.
  void zoomedIn() {
    final zoom = ZoomLevels.next(state.zoom);
    if (zoom != null) {
      emit(state.copyWith(zoom: zoom));
    }
  }

  /// Zooms the canvas out to the previous of the [ZoomLevels], if any.
  void zoomedOut() {
    final zoom = ZoomLevels.previous(state.zoom);
    if (zoom != null) {
      emit(state.copyWith(zoom: zoom));
    }
  }

  /// Resets the zoom of the canvas, showing the polygon as it was fitted
  /// when the dialog opened.
  void zoomReset() => emit(state.copyWith(zoom: 1));
}
