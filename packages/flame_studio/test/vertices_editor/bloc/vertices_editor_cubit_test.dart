import 'package:bloc_test/bloc_test.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flame_studio/vertices_editor/vertices_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(VerticesEditorCubit, () {
    const triangle = ComponentVertices();
    const square = ComponentVertices(ComponentVertices.square);

    test('starts editing the given vertices, with nothing selected', () {
      final state = VerticesEditorCubit(square).state;

      expect(state.vertices, equals(square.vertices));
      expect(state.selectedIndex, isNull);
      expect(state.hasChanges, isFalse);
      expect(state.canDelete, isTrue);
    });

    test('cannot delete vertices of a triangle', () {
      expect(VerticesEditorCubit(triangle).state.canDelete, isFalse);
    });

    blocTest<VerticesEditorCubit, VerticesEditorState>(
      'vertexSelected selects and unselects vertices',
      build: () => VerticesEditorCubit(triangle),
      act: (cubit) => cubit
        ..vertexSelected(1)
        ..vertexSelected(null),
      expect: () => [
        VerticesEditorState(initial: triangle, selectedIndex: 1),
        VerticesEditorState(initial: triangle),
      ],
    );

    blocTest<VerticesEditorCubit, VerticesEditorState>(
      'vertexMoved moves a vertex',
      build: () => VerticesEditorCubit(triangle),
      act: (cubit) => cubit.vertexMoved(1, 60, 70),
      expect: () => [
        VerticesEditorState(
          initial: triangle,
          vertices: const [
            ComponentVertex(25, 0),
            ComponentVertex(60, 70),
            ComponentVertex(0, 50),
          ],
        ),
      ],
      verify: (cubit) => expect(cubit.state.hasChanges, isTrue),
    );

    blocTest<VerticesEditorCubit, VerticesEditorState>(
      'vertexInserted adds a vertex after the start of the edge and '
      'selects it',
      build: () => VerticesEditorCubit(triangle),
      act: (cubit) => cubit.vertexInserted(2, 10, 20),
      expect: () => [
        VerticesEditorState(
          initial: triangle,
          vertices: const [
            ...ComponentVertices.triangle,
            ComponentVertex(10, 20),
          ],
          selectedIndex: 3,
        ),
      ],
    );

    blocTest<VerticesEditorCubit, VerticesEditorState>(
      'selectedVertexDeleted removes the selected vertex',
      build: () => VerticesEditorCubit(square),
      seed: () => VerticesEditorState(initial: square, selectedIndex: 0),
      act: (cubit) => cubit.selectedVertexDeleted(),
      expect: () => [
        VerticesEditorState(
          initial: square,
          vertices: ComponentVertices.square.sublist(1),
        ),
      ],
    );

    blocTest<VerticesEditorCubit, VerticesEditorState>(
      'selectedVertexDeleted keeps at least 3 vertices',
      build: () => VerticesEditorCubit(triangle),
      seed: () => VerticesEditorState(initial: triangle, selectedIndex: 0),
      act: (cubit) => cubit.selectedVertexDeleted(),
      expect: () => const <VerticesEditorState>[],
    );

    blocTest<VerticesEditorCubit, VerticesEditorState>(
      'vertexDeleted keeps the selection on the same vertex',
      build: () => VerticesEditorCubit(square),
      seed: () => VerticesEditorState(initial: square, selectedIndex: 2),
      act: (cubit) => cubit
        ..vertexDeleted(0)
        ..vertexDeleted(2),
      expect: () => [
        VerticesEditorState(
          initial: square,
          vertices: ComponentVertices.square.sublist(1),
          selectedIndex: 1,
        ),
      ],
    );

    blocTest<VerticesEditorCubit, VerticesEditorState>(
      'vertexDeleted keeps vertices after the selected one selected',
      build: () => VerticesEditorCubit(square),
      seed: () => VerticesEditorState(initial: square, selectedIndex: 0),
      act: (cubit) => cubit.vertexDeleted(3),
      expect: () => [
        VerticesEditorState(
          initial: square,
          vertices: ComponentVertices.square.sublist(0, 3),
          selectedIndex: 0,
        ),
      ],
    );

    blocTest<VerticesEditorCubit, VerticesEditorState>(
      'selectedVertexDeleted does nothing without a selection',
      build: () => VerticesEditorCubit(square),
      act: (cubit) => cubit.selectedVertexDeleted(),
      expect: () => const <VerticesEditorState>[],
    );

    test('result places the vertices like Flame does', () {
      final cubit = VerticesEditorCubit(triangle)..vertexMoved(0, -10, -20);

      expect(
        cubit.state.result,
        equals(
          const ComponentVertices([
            ComponentVertex(0, 0),
            ComponentVertex(60, 70),
            ComponentVertex(10, 70),
          ]),
        ),
      );
    });

    test('moving the whole shape is not a change', () {
      final cubit = VerticesEditorCubit(triangle);
      for (final (index, vertex) in triangle.vertices.indexed) {
        cubit.vertexMoved(index, vertex.x + 5, vertex.y + 5);
      }

      expect(cubit.state.hasChanges, isFalse);
    });

    group('zoom', () {
      test('starts at 100%', () {
        final state = VerticesEditorCubit(square).state;

        expect(state.zoom, equals(1));
        expect(state.canZoomIn, isTrue);
        expect(state.canZoomOut, isTrue);
      });

      blocTest<VerticesEditorCubit, VerticesEditorState>(
        'zoomedIn, zoomedOut and zoomReset change the zoom',
        build: () => VerticesEditorCubit(square),
        act: (cubit) => cubit
          ..zoomedIn()
          ..zoomedIn()
          ..zoomReset()
          ..zoomedOut(),
        expect: () => [
          isA<VerticesEditorState>().having((s) => s.zoom, 'zoom', 1.5),
          isA<VerticesEditorState>().having((s) => s.zoom, 'zoom', 2),
          isA<VerticesEditorState>().having((s) => s.zoom, 'zoom', 1),
          isA<VerticesEditorState>().having((s) => s.zoom, 'zoom', 0.75),
        ],
      );

      blocTest<VerticesEditorCubit, VerticesEditorState>(
        'does not zoom past the largest and smallest levels',
        build: () => VerticesEditorCubit(square),
        seed: () => VerticesEditorState(initial: square, zoom: 8),
        act: (cubit) => cubit.zoomedIn(),
        expect: () => const <VerticesEditorState>[],
        verify: (cubit) {
          expect(cubit.state.canZoomIn, isFalse);
          expect(
            VerticesEditorState(initial: square, zoom: 0.1).canZoomOut,
            isFalse,
          );
        },
      );

      blocTest<VerticesEditorCubit, VerticesEditorState>(
        'zooming keeps the edits',
        build: () => VerticesEditorCubit(square),
        act: (cubit) => cubit
          ..vertexMoved(0, 5, 5)
          ..zoomedIn(),
        skip: 1,
        expect: () => [
          isA<VerticesEditorState>()
              .having((s) => s.zoom, 'zoom', 1.5)
              .having(
                (s) => s.vertices.first,
                'vertex',
                const ComponentVertex(5, 5),
              ),
        ],
      );
    });
  });
}
