import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

class _TappableComponent extends PositionComponent with TapCallbacks {
  int tapUpCount = 0;

  @override
  void onTapUp(TapUpEvent event) {
    tapUpCount++;
  }
}

class _SnapshotComponent extends PositionComponent with Snapshot {}

class _CameraGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    camera.viewfinder.zoom = 2;
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2(50, 50);
  }
}

class _ClippedCameraGame extends FlameGame {
  _ClippedCameraGame()
    : super(
        camera: CameraComponent.withFixedResolution(width: 400, height: 400),
      );

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
  }
}

const _red = Color(0xFFFF0000);

Finder _redBox() {
  return find.byWidgetPredicate(
    (widget) => widget is ColoredBox && widget.color == _red,
  );
}

Future<void> _pumpGame(WidgetTester tester, FlameGame game) async {
  await tester.pumpWidget(MaterialApp(home: GameWidget(game: game)));
  await tester.pump();
  await tester.pump();
  await game.ready();
  await tester.pump();
  await tester.pump();
}

Widget _button(String label, VoidCallback onPressed) {
  return Material(
    child: ElevatedButton(onPressed: onPressed, child: Text(label)),
  );
}

void main() {
  group('WidgetComponent', () {
    testWidgets('renders its widget inside the game', (tester) async {
      final game = FlameGame();
      final component = WidgetComponent(
        widget: const Text('hello'),
        size: Vector2(100, 40),
      );
      game.add(component);
      await _pumpGame(tester, game);

      expect(find.text('hello'), findsOneWidget);
      expect(game.renderBox.paintedWidgetComponents, [component]);
    });

    testWidgets('lays the widget out with the component size', (
      tester,
    ) async {
      final game = FlameGame();
      final component = WidgetComponent(
        widget: const ColoredBox(color: _red),
        size: Vector2(120, 40),
      );
      game.add(component);
      await _pumpGame(tester, game);

      expect(tester.getSize(_redBox()), const Size(120, 40));

      component.size = Vector2(60, 20);
      await tester.pump();
      await tester.pump();
      expect(tester.getSize(_redBox()), const Size(60, 20));
    });

    testWidgets('adopts the size of the widget when no size is given', (
      tester,
    ) async {
      final game = FlameGame();
      final component = WidgetComponent(
        widget: const SizedBox(width: 70, height: 30),
      );
      game.add(component);
      await _pumpGame(tester, game);

      expect(component.adoptsWidgetSize, isTrue);
      expect(component.size, Vector2(70, 30));

      component.widget = const SizedBox(width: 50, height: 10);
      await tester.pump();
      await tester.pump();
      expect(component.size, Vector2(50, 10));
    });

    testWidgets('positions the widget on screen', (tester) async {
      final game = FlameGame();
      game.add(
        WidgetComponent(
          widget: const ColoredBox(color: _red),
          size: Vector2(100, 50),
          position: Vector2(200, 100),
          anchor: Anchor.center,
        ),
      );
      await _pumpGame(tester, game);

      expect(
        tester.getRect(_redBox()),
        const Rect.fromLTWH(150, 75, 100, 50),
      );
    });

    testWidgets('follows the camera transform', (tester) async {
      final game = _CameraGame();
      game.world.add(
        WidgetComponent(
          widget: const ColoredBox(color: _red),
          size: Vector2(100, 50),
          position: Vector2(100, 100),
        ),
      );
      await _pumpGame(tester, game);

      expect(
        tester.getRect(_redBox()),
        const Rect.fromLTWH(100, 100, 200, 100),
      );
    });

    testWidgets('receives taps', (tester) async {
      var pressed = 0;
      final game = FlameGame();
      game.add(
        WidgetComponent(
          widget: _button('Press', () => pressed++),
          size: Vector2(120, 40),
          position: Vector2(300, 200),
        ),
      );
      await _pumpGame(tester, game);

      await tester.tapAt(const Offset(360, 220));
      await tester.pump();
      expect(pressed, 1);

      await tester.tapAt(const Offset(100, 100));
      await tester.pump();
      expect(pressed, 1);
    });

    testWidgets('receives taps when rotated and scaled', (tester) async {
      var pressed = 0;
      final game = FlameGame();
      final component = WidgetComponent(
        widget: _button('Press', () => pressed++),
        size: Vector2(120, 40),
        position: Vector2(300, 200),
        anchor: Anchor.center,
        angle: pi / 2,
        scale: Vector2.all(2),
      );
      game.add(component);
      await _pumpGame(tester, game);

      final inside = component.absolutePositionOf(Vector2(110, 10));
      await tester.tapAt(Offset(inside.x, inside.y));
      await tester.pump();
      expect(pressed, 1);

      final outside = component.absolutePositionOf(Vector2(130, 10));
      await tester.tapAt(Offset(outside.x, outside.y));
      await tester.pump();
      expect(pressed, 1);
    });

    testWidgets('takes priority over Flame tap callbacks below it', (
      tester,
    ) async {
      var pressed = 0;
      final game = FlameGame();
      final tappable = _TappableComponent()..size = Vector2(800, 600);
      game.add(tappable);
      game.add(
        WidgetComponent(
          widget: _button('Press', () => pressed++),
          size: Vector2(120, 40),
          position: Vector2(300, 200),
          priority: 1,
        ),
      );
      await _pumpGame(tester, game);

      await tester.tapAt(const Offset(360, 220));
      await tester.pump(const Duration(milliseconds: 100));
      expect(pressed, 1);
      expect(tappable.tapUpCount, 0);

      await tester.tapAt(const Offset(100, 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(pressed, 1);
      expect(tappable.tapUpCount, 1);
    });

    testWidgets('hit tests the topmost of overlapping widgets', (
      tester,
    ) async {
      var bottomPressed = 0;
      var topPressed = 0;
      final game = FlameGame();
      final bottom = WidgetComponent(
        widget: _button('Bottom', () => bottomPressed++),
        size: Vector2(120, 40),
        position: Vector2(300, 200),
        priority: 2,
      );
      final top = WidgetComponent(
        widget: _button('Top', () => topPressed++),
        size: Vector2(120, 40),
        position: Vector2(300, 200),
        priority: 1,
      );
      game.addAll([top, bottom]);
      await _pumpGame(tester, game);

      expect(game.renderBox.paintedWidgetComponents, [top, bottom]);

      await tester.tapAt(const Offset(360, 220));
      await tester.pump();
      expect(bottomPressed, 1);
      expect(topPressed, 0);

      bottom.priority = 0;
      await tester.pump();
      await tester.pump();
      expect(game.renderBox.paintedWidgetComponents, [bottom, top]);

      await tester.tapAt(const Offset(360, 220));
      await tester.pump();
      expect(bottomPressed, 1);
      expect(topPressed, 1);
    });

    testWidgets('renders and hit tests a composited widget', (tester) async {
      var pressed = 0;
      final game = FlameGame();
      game.add(RectangleComponent(size: Vector2(800, 600)));
      game.add(
        WidgetComponent(
          widget: RepaintBoundary(
            child: _button('Press', () => pressed++),
          ),
          size: Vector2(120, 40),
          position: Vector2(300, 200),
          priority: 1,
        ),
      );
      game.add(
        RectangleComponent(size: Vector2(10, 10), priority: 2),
      );
      await _pumpGame(tester, game);

      expect(find.text('Press'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tapAt(const Offset(360, 220));
      await tester.pump();
      expect(pressed, 1);
    });

    testWidgets('splits the game picture around a composited widget', (
      tester,
    ) async {
      final game = FlameGame();
      game.add(RectangleComponent(size: Vector2(800, 600)));
      game.add(
        WidgetComponent(
          widget: const RepaintBoundary(child: ColoredBox(color: _red)),
          size: Vector2(120, 40),
          position: Vector2(300, 200),
          priority: 1,
        ),
      );
      game.add(RectangleComponent(size: Vector2(10, 10), priority: 2));
      await _pumpGame(tester, game);

      final gameLayer = game.renderBox.debugLayer!;
      final children = <Layer>[];
      var layer = gameLayer.firstChild;
      while (layer != null) {
        children.add(layer);
        layer = layer.nextSibling;
      }
      expect(children.map((layer) => layer.runtimeType).toList(), [
        PictureLayer,
        TransformLayer,
        PictureLayer,
      ]);
      final transformLayer = children[1] as TransformLayer;
      expect(transformLayer.transform!.getTranslation().x, 300);
      expect(transformLayer.transform!.getTranslation().y, 200);
    });

    testWidgets('is clipped and hit tested by the camera viewport', (
      tester,
    ) async {
      var pressed = 0;
      final game = _ClippedCameraGame();
      game.world.add(
        WidgetComponent(
          widget: RepaintBoundary(
            child: _button('Press', () => pressed++),
          ),
          size: Vector2(120, 40),
          position: Vector2(380, 100),
        ),
      );
      await _pumpGame(tester, game);
      expect(tester.takeException(), isNull);

      // On the 800x600 test screen the viewport is scaled by 1.5 and covers
      // the horizontal range 100 to 700, so the widget spans 670 to 850 on
      // screen but is clipped at 700.
      await tester.tapAt(const Offset(690, 180));
      await tester.pump();
      expect(pressed, 1);

      await tester.tapAt(const Offset(720, 180));
      await tester.pump();
      expect(pressed, 1);
    });

    testWidgets('removes the widget when the component is removed', (
      tester,
    ) async {
      final game = FlameGame();
      final component = WidgetComponent(
        widget: const Text('hello'),
        size: Vector2(100, 40),
      );
      game.add(component);
      await _pumpGame(tester, game);
      expect(find.text('hello'), findsOneWidget);

      component.removeFromParent();
      await tester.pump();
      await tester.pump();
      expect(find.text('hello'), findsNothing);
      expect(game.widgetComponents, isEmpty);
    });

    testWidgets('rebuilds when the widget is replaced', (tester) async {
      final game = FlameGame();
      final component = WidgetComponent(
        widget: const Text('one'),
        size: Vector2(100, 40),
      );
      game.add(component);
      await _pumpGame(tester, game);
      expect(find.text('one'), findsOneWidget);

      component.widget = const Text('two');
      await tester.pump();
      await tester.pump();
      expect(find.text('one'), findsNothing);
      expect(find.text('two'), findsOneWidget);
    });

    testWidgets('keeps widget state across game frames', (tester) async {
      final game = FlameGame();
      game.add(
        WidgetComponent(
          widget: const Material(child: TextField()),
          size: Vector2(200, 60),
          position: Vector2(100, 100),
        ),
      );
      await _pumpGame(tester, game);

      await tester.enterText(find.byType(TextField), 'typed');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('typed'), findsOneWidget);
    });

    testWidgets('is skipped when rendered into a snapshot', (tester) async {
      final game = FlameGame();
      final snapshot = _SnapshotComponent()..size = Vector2(200, 200);
      snapshot.add(
        WidgetComponent(
          widget: const Text('hello'),
          size: Vector2(100, 40),
        ),
      );
      game.add(snapshot);
      await _pumpGame(tester, game);

      expect(tester.takeException(), isNull);
      expect(game.renderBox.paintedWidgetComponents, isEmpty);
    });

    testWithFlameGame('mounts without a GameWidget', (game) async {
      final component = WidgetComponent(
        widget: const Text('hello'),
        size: Vector2(100, 40),
      );
      game.add(component);
      await game.ready();

      expect(component.isMounted, isTrue);
      expect(game.widgetComponents, [component]);
      game.update(0);
      final recorder = PictureRecorder();
      game.render(Canvas(recorder));
      recorder.endRecording().dispose();

      component.removeFromParent();
      await game.ready();
      expect(game.widgetComponents, isEmpty);
    });
  });
}
