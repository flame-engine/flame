import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

/// Drives a whole trackpad pinch through the Flutter binding, the way the
/// engine reports one on desktop and web.
Future<_Gesture> _startPinch(WidgetTester tester, Offset at) async {
  final pointer = TestPointer(1, PointerDeviceKind.trackpad);
  await tester.sendEventToBinding(pointer.panZoomStart(at));
  return _Gesture(tester, pointer, at);
}

class _Gesture(
  final WidgetTester tester,
  final TestPointer pointer,
  final Offset at,
) {
  Future<void> update({
    Offset pan = Offset.zero,
    double scale = 1,
    double rotation = 0,
  }) {
    return tester.sendEventToBinding(
      pointer.panZoomUpdate(
        at,
        pan: pan,
        scale: scale,
        rotation: rotation,
      ),
    );
  }

  Future<void> end() => tester.sendEventToBinding(pointer.panZoomEnd());
}

void main() {
  group('trackpad pinch', () {
    testWidgets('reaches ScaleCallbacks on the game', (tester) async {
      final game = _ScaleGame();
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();

      final pinch = await _startPinch(tester, const Offset(400, 300));
      // A trackpad reports scale directly, so the 5% default threshold is
      // crossed by the scale factor alone with no movement.
      await pinch.update(scale: 1.5);

      expect(game.starts, equals(1));
      expect(game.updates, greaterThan(0));
      expect(game.lastScale, closeTo(1.5, 1e-9));

      await pinch.end();
      expect(game.ends, equals(1));
    });

    testWidgets('reports at least two pointers', (tester) async {
      final game = _ScaleGame();
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();

      final pinch = await _startPinch(tester, const Offset(400, 300));
      await pinch.update(scale: 1.5);

      // The protocol never says how many fingers are involved, only that a
      // gesture is happening, so it counts as the minimum of two.
      expect(game.lastPointerCount, equals(2));

      await pinch.end();
    });

    testWidgets('a two-finger pan moves the focal point', (tester) async {
      final game = _ScaleGame();
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();

      final pinch = await _startPinch(tester, const Offset(400, 300));
      // Panning without pinching: the scale stays at 1 and the focal point
      // travels, which is what pans a camera.
      await pinch.update(pan: const Offset(60, 0));

      expect(game.starts, equals(1));
      expect(game.lastScale, closeTo(1.0, 1e-9));
      expect(game.lastFocalPoint.x, greaterThan(400));

      await pinch.end();
    });

    testWidgets('rotation is reported', (tester) async {
      final game = _ScaleGame();
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();

      final pinch = await _startPinch(tester, const Offset(400, 300));
      await pinch.update(scale: 1.5, rotation: 0.5);

      expect(game.lastRotation, closeTo(0.5, 1e-9));

      await pinch.end();
    });

    testWidgets('below the threshold nothing fires', (tester) async {
      final game = _ScaleGame();
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();

      final pinch = await _startPinch(tester, const Offset(400, 300));
      // 1% is under the 5% default, and the focal point has not moved.
      await pinch.update(scale: 1.01);

      expect(game.starts, equals(0));
      expect(game.updates, equals(0));

      await pinch.end();
      expect(game.ends, equals(0));
    });

    testWidgets('is ignored when only DragCallbacks are present', (
      tester,
    ) async {
      final game = _DragOnlyGame();
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();

      final pinch = await _startPinch(tester, const Offset(400, 300));
      await pinch.update(scale: 1.5, pan: const Offset(60, 0));
      await pinch.end();

      // A trackpad gesture has no per-finger pointers, so it is not turned
      // into drags.
      expect(game.dragStarts, equals(0));
      expect(game.dragUpdates, equals(0));
    });
  });

  group('MultiDragScaleGestureRecognizer with a trackpad', () {
    testWidgets('respects supportedDevices', (tester) async {
      var started = false;
      final recognizer =
          MultiDragScaleGestureRecognizer(
              supportedDevices: {PointerDeviceKind.touch},
            )
            ..hasScale = true
            ..onScaleStart = (_) => started = true;
      addTearDown(recognizer.dispose);

      final pointer = TestPointer(1, PointerDeviceKind.trackpad);
      final start = pointer.panZoomStart(const Offset(400, 300));
      recognizer.addPointerPanZoom(start);
      await tester.sendEventToBinding(start);
      await tester.sendEventToBinding(
        pointer.panZoomUpdate(const Offset(400, 300), scale: 1.5),
      );
      await tester.sendEventToBinding(pointer.panZoomEnd());

      expect(started, isFalse);
    });

    testWidgets(
      'gives up a gesture it never accepted, so a competitor can win it',
      (tester) async {
        final recognizer = MultiDragScaleGestureRecognizer()..hasScale = true;
        addTearDown(recognizer.dispose);
        final competitor = _ArenaProbe();
        addTearDown(competitor.dispose);

        final pointer = TestPointer(1, PointerDeviceKind.trackpad);
        final start = pointer.panZoomStart(const Offset(400, 300));
        // Flame joins the arena first, so an unresolved entry would win the
        // sweep at the end of the gesture.
        recognizer.addPointerPanZoom(start);
        competitor.addPointerPanZoom(start);
        await tester.sendEventToBinding(start);
        // Below the threshold: Flame never wants this gesture.
        await tester.sendEventToBinding(
          pointer.panZoomUpdate(const Offset(400, 300), scale: 1.01),
        );
        await tester.sendEventToBinding(pointer.panZoomEnd());

        expect(competitor.won, isTrue);
      },
    );

    testWidgets(
      'stays silent for a gesture over which a competitor has won',
      (tester) async {
        final events = <String>[];
        final recognizer = MultiDragScaleGestureRecognizer()
          ..hasScale = true
          ..onScaleStart = ((_) => events.add('start'))
          ..onScaleUpdate = ((_) => events.add('update'))
          ..onScaleEnd = ((_) => events.add('end'));
        addTearDown(recognizer.dispose);
        final competitor = _ArenaProbe(eager: true);
        addTearDown(competitor.dispose);

        final pointer = TestPointer(1, PointerDeviceKind.trackpad);
        final start = pointer.panZoomStart(const Offset(400, 300));
        recognizer.addPointerPanZoom(start);
        competitor.addPointerPanZoom(start);
        // Closing the arena hands the gesture to the eager competitor
        await tester.sendEventToBinding(start);
        await tester.sendEventToBinding(
          pointer.panZoomUpdate(const Offset(400, 300), scale: 1.5),
        );
        await tester.sendEventToBinding(pointer.panZoomEnd());

        expect(competitor.won, isTrue);
        expect(events, isEmpty);
      },
    );
  });
}

/// Joins the arena for a trackpad gesture and records whether it won.
///
/// An [eager] probe claims the gesture as soon as it joins.
class _ArenaProbe({final bool eager = false}) extends GestureRecognizer {
  bool? won;

  @override
  void addAllowedPointerPanZoom(PointerPanZoomStartEvent event) {
    final entry = GestureBinding.instance.gestureArena.add(event.pointer, this);
    if (eager) {
      entry.resolve(GestureDisposition.accepted);
    }
  }

  @override
  void acceptGesture(int pointer) => won = true;

  @override
  void rejectGesture(int pointer) => won = false;

  @override
  String get debugDescription => 'arena probe';
}

class _ScaleGame() extends FlameGame with ScaleCallbacks {
  int starts = 0;
  int updates = 0;
  int ends = 0;
  double lastScale = 0;
  double lastRotation = 0;
  int lastPointerCount = 0;
  Vector2 lastFocalPoint = Vector2.zero();

  @override
  void onScaleStart(ScaleStartEvent event) {
    super.onScaleStart(event);
    starts++;
  }

  @override
  void onScaleUpdate(ScaleUpdateEvent event) {
    updates++;
    lastScale = event.scale;
    lastRotation = event.rotation;
    lastPointerCount = event.pointerCount;
    lastFocalPoint = event.canvasEndPosition.clone();
  }

  @override
  void onScaleEnd(ScaleEndEvent event) {
    super.onScaleEnd(event);
    ends++;
  }
}

class _DragOnlyGame() extends FlameGame with DragCallbacks {
  int dragStarts = 0;
  int dragUpdates = 0;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    dragStarts++;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    dragUpdates++;
  }
}
