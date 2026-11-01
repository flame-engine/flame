import 'package:flame_studio/repositories/repositories.dart';
import 'package:flame_studio/vertices_editor/vertices_editor.dart';
import 'package:flame_studio/vertices_editor/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(VerticesEditorDialog, () {
    const square = ComponentVertices(ComponentVertices.square);

    late ComponentVertices? result;

    Future<void> openDialog(
      WidgetTester tester, {
      ComponentVertices vertices = square,
    }) async {
      result = null;
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await VerticesEditorDialog.show(
                  context,
                  vertices: vertices,
                  paint: const ComponentPaint(style: PaintStyle.stroke),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    Finder canvas() => find.descendant(
      of: find.byType(VerticesCanvas),
      matching: find.byType(CustomPaint),
    );

    /// Where the local [vertex] is on the screen.
    Offset onScreen(
      WidgetTester tester,
      ComponentVertex vertex, {
      List<ComponentVertex> initial = ComponentVertices.square,
    }) {
      final transform = VerticesViewTransform.fit(
        initial,
        tester.getSize(canvas()),
      );
      return tester.getTopLeft(canvas()) + transform.toCanvas(vertex);
    }

    Future<void> apply(WidgetTester tester) async {
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows the number of vertices', (tester) async {
      await openDialog(tester);

      expect(find.text('Edit vertices'), findsOneWidget);
      expect(find.text('4 vertices'), findsOneWidget);
    });

    testWidgets('returns null when cancelled', (tester) async {
      await openDialog(tester);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(VerticesEditorDialog), findsNothing);
      expect(result, isNull);
    });

    group('zoom', () {
      VerticesViewTransform transform(WidgetTester tester) =>
          (tester.widget<CustomPaint>(canvas()).painter! as VerticesPainter)
              .transform;

      testWidgets('zooms the canvas with the buttons', (tester) async {
        await openDialog(tester);
        final fitted = transform(tester);
        expect(find.text('100%'), findsOneWidget);

        await tester.tap(find.byTooltip('Zoom in'));
        await tester.pump();
        expect(find.text('150%'), findsOneWidget);
        expect(transform(tester).scale, equals(fitted.scale * 1.5));

        await tester.tap(find.byTooltip('Zoom out'));
        await tester.tap(find.byTooltip('Zoom out'));
        await tester.pump();
        expect(find.text('75%'), findsOneWidget);

        await tester.tap(find.text('75%'));
        await tester.pump();
        expect(transform(tester), equals(fitted));
      });

      testWidgets('zooms the canvas with the keyboard', (tester) async {
        await openDialog(tester);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.equal);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
        await tester.pump();
        expect(find.text('150%'), findsOneWidget);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.minus);
        await tester.sendKeyEvent(LogicalKeyboardKey.minus);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await tester.pump();
        expect(find.text('75%'), findsOneWidget);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.digit0);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
        await tester.pump();
        expect(find.text('100%'), findsOneWidget);
      });

      testWidgets('drags vertices on the zoomed canvas', (tester) async {
        await openDialog(tester);
        await tester.tap(find.byTooltip('Zoom in'));
        await tester.tap(find.byTooltip('Zoom in'));
        await tester.pump();
        final zoomed = transform(tester);

        // 2x zoom: 60 pixels are 30 local units.
        await tester.dragFrom(
          tester.getTopLeft(canvas()) +
              zoomed.toCanvas(const ComponentVertex(50, 50)),
          const Offset(60, 20),
        );
        await tester.pump();
        await apply(tester);

        expect(result!.vertices[2], equals(const ComponentVertex(80, 60)));
      });
    });

    testWidgets('selects a vertex when it is tapped', (tester) async {
      await openDialog(tester);

      await tester.tapAt(onScreen(tester, const ComponentVertex(50, 0)));
      await tester.pump();
      expect(find.text('Vertex 2: (50, 0)'), findsOneWidget);

      await tester.tapAt(onScreen(tester, const ComponentVertex(25, 25)));
      await tester.pump();
      expect(find.text('4 vertices'), findsOneWidget);
    });

    testWidgets('moves a vertex when it is dragged', (tester) async {
      await openDialog(tester);

      await tester.dragFrom(
        onScreen(tester, const ComponentVertex(50, 50)),
        const Offset(30, 10),
      );
      await tester.pump();
      await apply(tester);

      expect(
        result,
        equals(
          const ComponentVertices([
            ComponentVertex(0, 0),
            ComponentVertex(50, 0),
            ComponentVertex(80, 60),
            ComponentVertex(0, 50),
          ]),
        ),
      );
    });

    testWidgets('adds a vertex when the middle of an edge is tapped', (
      tester,
    ) async {
      await openDialog(tester);

      await tester.tapAt(onScreen(tester, const ComponentVertex(25, 0)));
      await tester.pump();
      expect(find.text('Vertex 2: (25, 0)'), findsOneWidget);
      await apply(tester);

      expect(result!.vertices, hasLength(5));
      expect(result!.vertices[1], equals(const ComponentVertex(25, 0)));
    });

    testWidgets('adds and moves a vertex dragged from the middle of an '
        'edge', (tester) async {
      await openDialog(tester);

      await tester.dragFrom(
        onScreen(tester, const ComponentVertex(25, 0)),
        const Offset(0, -20),
      );
      await tester.pump();
      await apply(tester);

      expect(result!.vertices, hasLength(5));
      expect(result!.vertices[1], equals(const ComponentVertex(25, 0)));
      expect(result!.vertices[0], equals(const ComponentVertex(0, 20)));
    });

    testWidgets('shows the add handle of hovered edges', (tester) async {
      await openDialog(tester);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(gesture.removePointer);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(onScreen(tester, const ComponentVertex(10, 0)));
      await tester.pump();

      final painter = tester.widget<CustomPaint>(canvas()).painter!;
      expect((painter as VerticesPainter).hoveredEdge, equals(0));

      await gesture.moveTo(onScreen(tester, const ComponentVertex(0, 0)));
      await tester.pump();
      await gesture.moveTo(Offset.zero);
      await tester.pump();
    });

    testWidgets('deletes the selected vertex with the keyboard', (
      tester,
    ) async {
      await openDialog(tester);

      await tester.tapAt(onScreen(tester, const ComponentVertex(50, 0)));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      await tester.pump();
      expect(find.text('3 vertices'), findsOneWidget);

      // A triangle can't lose a vertex.
      await tester.tapAt(onScreen(tester, const ComponentVertex(0, 0)));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();
      final delete = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.delete_outline),
      );
      expect(delete.onPressed, isNull);
      await apply(tester);

      expect(
        result,
        equals(
          const ComponentVertices([
            ComponentVertex(0, 0),
            ComponentVertex(50, 50),
            ComponentVertex(0, 50),
          ]),
        ),
      );
    });

    testWidgets('deletes the selected vertex with the button', (tester) async {
      await openDialog(tester);

      await tester.tapAt(onScreen(tester, const ComponentVertex(0, 0)));
      await tester.pump();
      await tester.tap(find.byTooltip('Delete vertex'));
      await tester.pump();

      expect(find.text('3 vertices'), findsOneWidget);
    });

    group('side bar', () {
      Finder field(int index, String label) => find.descendant(
        of: find.byKey(ValueKey('4-$index')),
        matching: find.widgetWithText(TextField, label),
      );

      testWidgets('lists the coordinates of every vertex', (tester) async {
        await openDialog(tester);

        expect(find.byType(VerticesList), findsOneWidget);
        expect(find.widgetWithText(TextField, 'X'), findsNWidgets(4));
        expect(
          tester.widget<TextField>(field(1, 'X')).controller!.text,
          equals('50'),
        );
      });

      testWidgets('moves a vertex to the typed coordinates', (tester) async {
        await openDialog(tester);

        await tester.enterText(field(2, 'X'), '62.5');
        await tester.enterText(field(2, 'Y'), '-10');
        await tester.pump();
        expect(find.text('Vertex 3: (62.5, -10)'), findsOneWidget);
        await apply(tester);

        expect(
          result,
          equals(
            const ComponentVertices([
              ComponentVertex(0, 10),
              ComponentVertex(50, 10),
              ComponentVertex(62.5, 0),
              ComponentVertex(0, 60),
            ]),
          ),
        );
      });

      testWidgets('selects the vertex of the tapped row', (tester) async {
        await openDialog(tester);

        await tester.tap(find.text('4'));
        await tester.pump();

        expect(find.text('Vertex 4: (0, 50)'), findsOneWidget);
      });

      testWidgets('follows the vertices dragged on the canvas', (tester) async {
        await openDialog(tester);

        await tester.dragFrom(
          onScreen(tester, const ComponentVertex(50, 50)),
          const Offset(30, 10),
        );
        await tester.pump();

        expect(
          tester.widget<TextField>(field(2, 'X')).controller!.text,
          equals('80'),
        );
      });

      testWidgets('deletes a vertex from its row', (tester) async {
        await openDialog(tester);

        await tester.tap(find.byTooltip('Delete vertex 1'));
        await tester.pump();

        expect(find.text('3 vertices'), findsOneWidget);
        final delete = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.remove_circle_outline).first,
        );
        expect(delete.onPressed, isNull);
      });
    });

    testWidgets('deletes a vertex from its context menu', (tester) async {
      await openDialog(tester);

      await tester.tapAt(
        onScreen(tester, const ComponentVertex(0, 50)),
        buttons: kSecondaryButton,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete vertex').last);
      await tester.pumpAndSettle();

      expect(find.text('3 vertices'), findsOneWidget);
    });
  });
}
