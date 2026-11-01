import 'package:flame_studio/component_editor/widgets/widgets.dart';
import 'package:flame_studio/repositories/repositories.dart';
import 'package:flame_studio/vertices_editor/vertices_editor.dart';
import 'package:flame_studio/vertices_editor/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(VerticesEditor, () {
    Future<List<ComponentVertices>> pumpEditor(WidgetTester tester) async {
      final changes = <ComponentVertices>[];
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VerticesEditor(
              value: const ComponentVertices(),
              onChanged: changes.add,
            ),
          ),
        ),
      );
      return changes;
    }

    testWidgets('shows the number of vertices and the size', (tester) async {
      await pumpEditor(tester);

      expect(find.text('3 vertices, 50 × 50'), findsOneWidget);
    });

    testWidgets('edits the vertices in the dialog', (tester) async {
      final changes = await pumpEditor(tester);

      await tester.tap(find.text('Edit vertices'));
      await tester.pumpAndSettle();
      expect(find.byType(VerticesEditorDialog), findsOneWidget);

      // Adds a vertex in the middle of the first edge, then applies.
      tester
          .element(find.byType(VerticesCanvas))
          .read<VerticesEditorCubit>()
          .vertexInserted(0, 40, 20);
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(changes, hasLength(1));
      expect(changes.single.vertices, hasLength(4));
    });

    testWidgets('keeps the vertices when the dialog is cancelled', (
      tester,
    ) async {
      final changes = await pumpEditor(tester);

      await tester.tap(find.text('Edit vertices'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(VerticesEditorDialog), findsNothing);
      expect(changes, isEmpty);
    });

    testWidgets('does not report unchanged vertices', (tester) async {
      final changes = await pumpEditor(tester);

      await tester.tap(find.text('Edit vertices'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(changes, isEmpty);
    });
  });
}
