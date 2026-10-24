import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_studio/src/core/inspector/component_inspectors.dart';
import 'package:flame_studio/src/core/viewport_tool.dart';
import 'package:flame_studio/src/widgets/common/studio_tooltip.dart';
import 'package:flame_studio/src/widgets/flame_studio.dart';
import 'package:flame_studio/src/widgets/panels/inspector/property_editors.dart';
import 'package:flame_studio/src/widgets/toolbar/viewport_tool_button.dart';
import 'package:flame_studio/src/widgets/viewport/gizmo_overlay.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlameStudio', () {
    late _Player player;
    late FlameGame game;

    Future<void> pumpStudio(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      player = _Player();
      game = FlameGame(children: [player, _Enemy()]);
      await tester.pumpWidget(FlameStudio(GameWidget(game: game)));
      // Let the game load, the studio find it, and the tree refresh.
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }
    }

    Future<void> disposeStudio(WidgetTester tester) async {
      // Disposes the providers, which cancels their timers.
      await tester.pumpWidget(const SizedBox());
    }

    testWidgets('shows the Hierarchy and Inspector tabs', (tester) async {
      await pumpStudio(tester);

      expect(find.text('Hierarchy'), findsOneWidget);
      expect(find.text('Inspector'), findsOneWidget);
      expect(find.text('FlameGame<World>'), findsOneWidget);
      expect(find.text('_Player'), findsOneWidget);
      expect(find.text('_Enemy'), findsOneWidget);
      expect(
        find.text('Select a component in the Hierarchy to inspect it.'),
        findsOneWidget,
      );

      await disposeStudio(tester);
    });

    testWidgets('selecting a component shows it in the Inspector', (
      tester,
    ) async {
      await pumpStudio(tester);

      await tester.tap(find.text('_Player'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Transform'), findsOneWidget);
      expect(find.text('Position'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);

      await disposeStudio(tester);
    });

    testWidgets('editing a value in the Inspector changes the component', (
      tester,
    ) async {
      await pumpStudio(tester);
      await tester.tap(find.text('_Player'));
      await tester.pump(const Duration(milliseconds: 100));

      // `find.text` also matches the text of an EditableText.
      final xField = find.text('10');
      await tester.tap(xField);
      await tester.pump();
      await tester.enterText(xField, '42');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump(const Duration(milliseconds: 100));

      expect(player.x, 42);
      expect(find.text('42'), findsOneWidget);

      await disposeStudio(tester);
    });

    testWidgets('draws a gizmo for the selected component', (tester) async {
      await pumpStudio(tester);
      final overlay = find.byType(GizmoOverlay);
      expect(tester.renderObject(overlay), paintsNothing);

      await tester.tap(find.text('_Player'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 16));

      expect(tester.renderObject(overlay), paints..path());

      await disposeStudio(tester);
    });

    testWidgets('the select tool selects components in the game view', (
      tester,
    ) async {
      await pumpStudio(tester);
      final playerCenter = game.renderBox.localToGlobal(const Offset(18, 28));

      // With the interact tool, the click goes to the game.
      await tester.tapAt(playerCenter);
      await tester.pump();
      expect(find.text('Transform'), findsNothing);

      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is ViewportToolButton &&
              widget.tool == ViewportTool.select,
        ),
      );
      await tester.pump();
      await tester.tapAt(playerCenter);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Transform'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);

      await disposeStudio(tester);
    });

    testWidgets('the move tool moves components by dragging them', (
      tester,
    ) async {
      await pumpStudio(tester);
      final playerCenter = game.renderBox.localToGlobal(const Offset(18, 28));

      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is ViewportToolButton && widget.tool == ViewportTool.move,
        ),
      );
      await tester.pump();
      await tester.dragFrom(playerCenter, const Offset(30, 10));
      await tester.pump(const Duration(milliseconds: 100));

      expect(player.position, closeToVector(Vector2(40, 30)));
      expect(find.text('Transform'), findsOneWidget);

      await disposeStudio(tester);
    });

    testWidgets('pressing Shift while dragging snaps right away', (
      tester,
    ) async {
      await pumpStudio(tester);
      final playerCenter = game.renderBox.localToGlobal(const Offset(18, 28));
      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is ViewportToolButton && widget.tool == ViewportTool.move,
        ),
      );
      await tester.pump();

      final gesture = await tester.startGesture(playerCenter);
      for (var i = 0; i < 10; i++) {
        await gesture.moveBy(const Offset(3, 1));
        await tester.pump();
      }
      expect(player.position, closeToVector(Vector2(40, 30)));

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      expect(player.position, closeToVector(Vector2(40, 32)));

      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      expect(player.position, closeToVector(Vector2(40, 30)));

      await gesture.up();
      await disposeStudio(tester);
    });

    testWidgets('the rotate tool rotates components with the ring', (
      tester,
    ) async {
      await pumpStudio(tester);
      // The anchor of the player is its top-left corner, at (10, 20).
      final ringPoint = game.renderBox.localToGlobal(const Offset(60, 20));

      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is ViewportToolButton &&
              widget.tool == ViewportTool.rotate,
        ),
      );
      await tester.tap(find.text('_Player'));
      await tester.pump();
      await tester.dragFrom(ringPoint, const Offset(-50, 50));
      await tester.pump(const Duration(milliseconds: 100));

      expect(player.angle, closeTo(pi / 2, 1e-9));
      expect(player.position, closeToVector(Vector2(10, 20)));

      await disposeStudio(tester);
    });

    testWidgets('shows tooltips when hovering over buttons', (tester) async {
      await pumpStudio(tester);
      final moveButton = find.byWidgetPredicate(
        (widget) =>
            widget is ViewportToolButton && widget.tool == ViewportTool.move,
      );
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);

      await mouse.moveTo(tester.getCenter(moveButton));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('Move: drag the arrows'), findsNothing);

      await tester.pump(StudioTooltip.delay);
      expect(find.textContaining('Move: drag the arrows'), findsOneWidget);

      await mouse.moveTo(Offset.zero);
      await tester.pump();
      expect(find.textContaining('Move: drag the arrows'), findsNothing);

      await disposeStudio(tester);
    });

    testWidgets('debug mode is applied to all descendants', (tester) async {
      await pumpStudio(tester);
      await tester.tap(find.text('FlameGame<World>'));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(
        find.descendant(
          of: find.byType(StudioCheckbox),
          matching: find.byType(CustomPaint),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(player.debugMode, isTrue);

      await disposeStudio(tester);
    });

    testWidgets('the Hierarchy filter hides non-matching components', (
      tester,
    ) async {
      await pumpStudio(tester);

      final filter = find.ancestor(
        of: find.text('Filter'),
        matching: find.byType(Stack),
      );
      await tester.enterText(
        find.descendant(of: filter.first, matching: find.byType(EditableText)),
        'enemy',
      );
      await tester.pump();

      expect(find.text('_Enemy'), findsOneWidget);
      expect(find.text('_Player'), findsNothing);
      expect(find.text('FlameGame<World>'), findsOneWidget);

      await disposeStudio(tester);
    });
  });

  group('inspectors', () {
    test('describe all of their properties', () {
      final component = TextComponent();
      for (final inspector in defaultComponentInspectors) {
        for (final property in [...?inspector(component)?.properties]) {
          expect(property.description, isNotNull, reason: property.label);
        }
      }
    });

    test('only PositionComponents have a Transform section', () {
      expect(inspectPositionComponent(Component()), isNull);
      expect(inspectPositionComponent(PositionComponent()), isNotNull);
    });

    test('Rendering section depends on the mixins of the component', () {
      expect(inspectRendering(Component()), isNull);
      final section = inspectRendering(RectangleComponent())!;
      expect(section.properties.map((p) => p.label), ['Opacity']);
    });
  });

  test('formatNumber', () {
    expect(formatNumber(10), '10');
    expect(formatNumber(1.5), '1.5');
    expect(formatNumber(1.23456), '1.235');
    expect(formatNumber(-0.0001), '0');
  });
}

class _Player() extends PositionComponent {
  this : super(position: Vector2(10, 20), size: Vector2.all(16));
}

class _Enemy() extends PositionComponent;
