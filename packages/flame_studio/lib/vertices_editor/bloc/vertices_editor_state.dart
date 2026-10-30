part of 'vertices_editor_cubit.dart';

/// The state of the [VerticesEditorCubit].
final class VerticesEditorState extends Equatable {
  /// Creates a [VerticesEditorState] editing [initial].
  // ignore: use_primary_constructors, can't be const, which a primary one asks.
  new({
    required this.initial,
    List<ComponentVertex>? vertices,
    this.selectedIndex,
    this.zoom = 1,
  }) : vertices = vertices ?? initial.vertices;

  /// The vertices the editor opened with.
  final ComponentVertices initial;

  /// The edited vertices, in order.
  final List<ComponentVertex> vertices;

  /// The index of the selected vertex in [vertices], if any.
  final int? selectedIndex;

  /// The zoom of the canvas, relative to the scale that fits the polygon
  /// in it (see `VerticesViewTransform.fit`), around its center.
  final double zoom;

  /// Whether the canvas can zoom in further.
  bool get canZoomIn => ZoomLevels.next(zoom) != null;

  /// Whether the canvas can zoom out further.
  bool get canZoomOut => ZoomLevels.previous(zoom) != null;

  /// Whether a vertex can be deleted: a polygon needs at least
  /// [ComponentVertices.minLength] vertices.
  bool get canDelete => vertices.length > ComponentVertices.minLength;

  /// Whether the vertices were edited.
  bool get hasChanges => result != initial.normalized();

  /// The edited vertices, placed like Flame places them (see
  /// [ComponentVertices.normalized]).
  ComponentVertices get result => ComponentVertices(vertices).normalized();

  /// Returns a copy of this state with the given fields replaced.
  VerticesEditorState copyWith({
    List<ComponentVertex>? vertices,
    int? Function()? selectedIndex,
    double? zoom,
  }) {
    return VerticesEditorState(
      initial: initial,
      vertices: vertices ?? this.vertices,
      selectedIndex: selectedIndex != null
          ? selectedIndex()
          : this.selectedIndex,
      zoom: zoom ?? this.zoom,
    );
  }

  @override
  List<Object?> get props => [initial, vertices, selectedIndex, zoom];
}
