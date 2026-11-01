import 'package:flame_studio/repositories/repositories.dart';
import 'package:flame_studio/vertices_editor/bloc/vertices_editor_cubit.dart';
import 'package:flame_studio/vertices_editor/widgets/vertices_painter.dart';
import 'package:flame_studio/vertices_editor/widgets/vertices_view_transform.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template vertices_canvas}
/// The canvas of the vertices editor, where the user drags the vertices of
/// the polygon, adds vertices from the middle of its edges and deletes the
/// selected vertex with Delete or Backspace, or from its context menu.
/// {@endtemplate}
class const VerticesCanvas({
  /// The paint the polygon is drawn with.
  required final ComponentPaint paint,
  super.key,
}) extends StatefulWidget {
  /// {@macro vertices_canvas}
  this;

  /// The background of the canvas, the same as the preview's.
  static const backgroundColor = Color(0xFF000000);

  @override
  State<VerticesCanvas> createState() => _VerticesCanvasState();
}

class _VerticesCanvasState() extends State<VerticesCanvas> {
  final _focusNode = FocusNode(debugLabel: 'VerticesCanvas');

  // Computed once, so the polygon doesn't move while it is edited. The
  // zoom is applied on top of it.
  VerticesViewTransform? _fitted;
  int? _hoveredEdge;
  int? _draggedIndex;
  MouseCursor _cursor = MouseCursor.defer;

  VerticesEditorCubit get _cubit => context.read<VerticesEditorCubit>();

  List<ComponentVertex> get _vertices => _cubit.state.vertices;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onTapUp(TapUpDetails details, VerticesViewTransform transform) {
    _focusNode.requestFocus();
    final point = details.localPosition;
    final vertex = transform.vertexAt(_vertices, point);
    if (vertex != null) {
      _cubit.vertexSelected(vertex);
    } else if (transform.midpointAt(_vertices, point) case final edge?) {
      _insertAtMidpoint(edge, transform);
    } else {
      _cubit.vertexSelected(null);
    }
  }

  void _onPanStart(DragStartDetails details, VerticesViewTransform transform) {
    _focusNode.requestFocus();
    final point = details.localPosition;
    final vertex = transform.vertexAt(_vertices, point);
    if (vertex != null) {
      _cubit.vertexSelected(vertex);
      _draggedIndex = vertex;
    } else if (transform.midpointAt(_vertices, point) case final edge?) {
      _insertAtMidpoint(edge, transform);
      _draggedIndex = edge + 1;
    }
  }

  void _onPanUpdate(
    DragUpdateDetails details,
    VerticesViewTransform transform,
  ) {
    final index = _draggedIndex;
    if (index == null) {
      return;
    }
    final vertex = transform.toLocal(details.localPosition);
    _cubit.vertexMoved(index, vertex.x, vertex.y);
  }

  void _insertAtMidpoint(int edge, VerticesViewTransform transform) {
    final vertex = transform.toLocal(transform.midpointOf(_vertices, edge));
    _cubit.vertexInserted(edge, vertex.x, vertex.y);
    setState(() => _hoveredEdge = null);
  }

  void _onHover(PointerHoverEvent event, VerticesViewTransform transform) {
    final point = event.localPosition;
    final edge = transform.edgeNear(_vertices, point);
    final cursor = transform.vertexAt(_vertices, point) != null
        ? SystemMouseCursors.move
        : transform.midpointAt(_vertices, point) != null
        ? SystemMouseCursors.click
        : MouseCursor.defer;
    if (edge != _hoveredEdge || cursor != _cursor) {
      setState(() {
        _hoveredEdge = edge;
        _cursor = cursor;
      });
    }
  }

  Future<void> _onSecondaryTapUp(
    TapUpDetails details,
    VerticesViewTransform transform,
  ) async {
    final vertex = transform.vertexAt(_vertices, details.localPosition);
    if (vertex == null) {
      return;
    }
    _cubit.vertexSelected(vertex);
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final position = details.globalPosition;
    final delete = await showMenu<bool>(
      context: context,
      position: RelativeRect.fromRect(
        position & Size.zero,
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: true,
          enabled: _cubit.state.canDelete,
          child: const Text('Delete vertex'),
        ),
      ],
    );
    if (delete ?? false) {
      _cubit.selectedVertexDeleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<VerticesEditorCubit>().state;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.delete):
            _cubit.selectedVertexDeleted,
        const SingleActivator(LogicalKeyboardKey.backspace):
            _cubit.selectedVertexDeleted,
      },
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        child: ColoredBox(
          color: VerticesCanvas.backgroundColor,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.biggest;
              final transform = (_fitted ??= VerticesViewTransform.fit(
                state.initial.vertices,
                size,
              )).zoomed(state.zoom, size.center(Offset.zero));
              return MouseRegion(
                cursor: _cursor,
                onHover: (event) => _onHover(event, transform),
                onExit: (_) => setState(() => _hoveredEdge = null),
                child: GestureDetector(
                  // Drags start where the pointer went down, on the handle.
                  dragStartBehavior: DragStartBehavior.down,
                  onTapUp: (details) => _onTapUp(details, transform),
                  onSecondaryTapUp: (details) =>
                      _onSecondaryTapUp(details, transform),
                  onPanStart: (details) => _onPanStart(details, transform),
                  onPanUpdate: (details) => _onPanUpdate(details, transform),
                  onPanEnd: (_) => _draggedIndex = null,
                  onPanCancel: () => _draggedIndex = null,
                  child: CustomPaint(
                    size: constraints.biggest,
                    painter: VerticesPainter(
                      vertices: state.vertices,
                      transform: transform,
                      polygonPaint: widget.paint,
                      selectedIndex: state.selectedIndex,
                      hoveredEdge: _draggedIndex == null ? _hoveredEdge : null,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
