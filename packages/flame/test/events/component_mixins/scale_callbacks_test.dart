import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart' hide PointerMoveEvent;
import 'package:flame/game.dart';
import 'package:flame/src/events/flame_game_mixins/scale_dispatcher.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart' show PointerAddedEvent, kPrimaryButton;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScaleCallbacks', () {
    testWithFlameGame(
      'make sure ScaleCallback components can be added to a FlameGame',
      (game) async {
        await game.add(_ScaleCallbacksComponent());
        await game.ready();
        expect(game.children.toList()[2], isA<ScaleDispatcher>());
      },
    );
  });
  testWithFlameGame('scale event start', (game) async {
      final component = _ScaleCallbacksComponent()
        ..x = 10
        ..y = 10
        ..width = 10
        ..height = 10;
      game.add(component);
      await game.ready();

      expect(game.children.whereType<ScaleDispatcher>().length, 1);
      game.firstChild<ScaleDispatcher>()!.onScaleStart(
        createScaleStartEvents(
          game: game,
          localFocalPoint: const Offset(12, 12),
          focalPoint: const Offset(12, 12),
        ),
      );
      expect(component.containsLocalPoint(Vector2(10, 10)), false);
    });

    testWithFlameGame('scale event start, update and end', (game) async {
      final component = _ScaleCallbacksComponent()
        ..x = 10
        ..y = 10
        ..width = 10
        ..height = 10;
      await game.ensureAdd(component);
      final dispatcher = game.firstChild<ScaleDispatcher>()!;

      dispatcher.onScaleStart(
        createScaleStartEvents(
          game: game,
          localFocalPoint: const Offset(12, 12),
          focalPoint: const Offset(12, 12),
        ),
      );
      expect(component.scaleStartEvent, 1);
      expect(component.scaleUpdateEvent, 0);
      expect(component.scaleEndEvent, 0);

      dispatcher.onScaleUpdate(
        createScaleUpdateEvents(
          game: game,
          localFocalPoint: const Offset(15, 15),
          focalPoint: const Offset(15, 15),
        ),
      );

      expect(game.containsLocalPoint(Vector2(9, 9)), isTrue);
      expect(component.scaleUpdateEvent, equals(1));

      dispatcher.onScaleEnd(ScaleEndEvent(1, ScaleEndDetails()));
      expect(component.scaleEndEvent, equals(1));
    });

    testWithFlameGame(
      'scale event update not called without onScaleStart',
      (game) async {
        final component = _ScaleCallbacksComponent()
          ..x = 10
          ..y = 10
          ..width = 10
          ..height = 10;
        await game.ensureAdd(component);
        final dispatcher = game.firstChild<ScaleDispatcher>()!;
        expect(component.scaleStartEvent, equals(0));
        expect(component.scaleUpdateEvent, equals(0));

        dispatcher.onScaleUpdate(
          createScaleUpdateEvents(
            game: game,
            localFocalPoint: const Offset(15, 15),
            focalPoint: const Offset(15, 15),
          ),
        );
        expect(component.scaleUpdateEvent, equals(0));
      },
    );

testWidgets('scale correctly registered handled event', (tester) async {
  final component = _ScaleCallbacksComponent()
    ..x = 100
    ..y = 100
    ..width = 150
    ..height = 150;
  final game = FlameGame(children: [component]);

  await tester.pumpWidget(GameWidget(game: game));
  await tester.pump();

  await performPinchGesture(tester, 
  center: Offset(150, 150), 
  startSeparation: Offset(30, 0),
  moveDelta: Offset(15, 2)
  );

  expect(game.children.length, equals(4));
  expect(component.isMounted, isTrue);

  expect(component.scaleStartEvent, equals(2));
  expect(component.scaleUpdateEvent, greaterThan(0));
  expect(component.scaleEndEvent, equals(2));
});

testWidgets(
  'scale outside of component is not registered as handled',
  (tester) async {
    final component = _ScaleCallbacksComponent()..size = Vector2.all(100);
    final game = FlameGame(children: [component]);
    await tester.pumpWidget(GameWidget(game: game));
    await tester.pump();
    await tester.pump();
    expect(component.isMounted, isTrue);

    await performPinchGesture(tester, 
    center: Offset(200, 200), 
    startSeparation: Offset(50, 0),
    moveDelta: Offset(15, 2)
    );

    expect(component.scaleStartEvent, equals(0));
    expect(component.scaleUpdateEvent, equals(0));
    expect(component.scaleEndEvent, equals(0));
  },
);

testWithGame(
  'make sure the FlameGame can registers Scale Callbacks on itself',
  _ScaleCallbacksGame.new,
  (game) async {
    await game.ready();
    expect(game.children.length, equals(3));
    expect(game.children.elementAt(1), isA<ScaleDispatcher>());
  },
);

testWidgets(
  'scale correctly registered handled event directly on FlameGame',
  (tester) async {
    final game = _ScaleCallbacksGame()..onGameResize(Vector2.all(300));
    await tester.pumpWidget(GameWidget(game: game));
    await tester.pump();
    await tester.pump();
    expect(game.children.length, equals(3));
    expect(game.isMounted, isTrue);

    await performPinchGesture(tester, 
      center: Offset(100, 100), 
      startSeparation: Offset(50, 0),
      moveDelta: Offset(15, 2)
      );

    expect(game.scaleStartEvent, equals(2));
    expect(game.scaleUpdateEvent, greaterThan(0));
    expect(game.scaleEndEvent, equals(2));
  },
);

testWidgets(
      'isDragged is changed',
      (tester) async {
        final component = _ScaleCallbacksComponent()..size = Vector2.all(100)
            ..x = 100
            ..y = 100;

        final game = FlameGame(children: [component]);
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump();

        // Inside component
        await performPinchGesture(tester, 
        center: Offset(150, 150), 
        startSeparation: Offset(30, 0),
        moveDelta: Offset(15, 2)
        );

        expect(component.isScaledStateChange, equals(4));

        // Outside component
        await performPinchGesture(tester, 
        center: Offset(300, 300), 
        startSeparation: Offset(30, 0),
        moveDelta: Offset(15, 2)
        );
        expect(component.isScaledStateChange, equals(4));
      },
    );
 group('HasDraggableComponents', () {

    testWidgets(
      'drag event does not affect more than one component',
      (tester) async {
        var nEvents = 0;
        final game = FlameGame(
          children: [
            _ScaleWithCallbacksComponent(
              size: Vector2.all(100),
              onScaleStart: (e) => nEvents++,
              onScaleUpdate: (e) => nEvents++,
              onScaleEnd: (e) => nEvents++,
            ),
            _SimpleScaleCallbacksComponent(size: Vector2.all(200))..priority = 10,
          ],
        );
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump();
        await performPinchGesture(tester, 
        center: Offset(50, 50), 
        startSeparation: Offset(30, 0),
        moveDelta: Offset(15, 2)
        );

        expect(nEvents, 0);
      },
    );

    testWidgets(
      'drag event can move outside the component bounds and still fire',
      (tester) async {
        final points = <Vector2>[];
        final game = FlameGame(
          children: [
            _ScaleWithCallbacksComponent(
              size: Vector2.all(500),
              position: Vector2.all(5),
              onScaleUpdate: (e) => points.add(Vector2.all(e.scale)),
            ),
          ],
        );
        // TODO isn't the issue actually localStartPosition ???
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump();
        
        final center = Offset(150, 150);
        await tester.timedZoomFrom(
        center.translate(-10, 0), const Offset(-10, 0),
        center.translate(10, 0), const Offset(10, 0),
        const Duration(seconds: 1),
        frequency: 10);

        /*await performScaleGestureTimed(
          tester,
          pinch: false,
          center: Offset(150, 150),
          duration: Duration(milliseconds: 300),
          steps: 15,
          startSeparation: Offset(100, 0),
          moveDelta: Offset(45, 2),
        );*/
        //expect(points.length, 80);
        debugPrint('${points.length}');
        expect(points.first, Vector2(75, 75));
        expect(
          points.skip(1),
          List.generate(41, (i) => Vector2(75.0, 75.0 + i)),
        );
      },
    );
  });
  
}


Future<void> performScaleGestureTimed(
  WidgetTester tester, {
  required Offset center,
  required bool pinch,
  required Offset startSeparation,
  required Offset moveDelta,
  int steps = 10,
  Duration duration = const Duration(milliseconds: 300),
}) async {
  final binding = tester.binding;
  final p1 = TestPointer(1, PointerDeviceKind.touch);
  final p2 = TestPointer(2, PointerDeviceKind.touch);

  Offset pos1 = center - startSeparation;
  Offset pos2 = center + startSeparation;

  // Pointer down
  binding.handlePointerEvent(p1.down(pos1));
  binding.handlePointerEvent(p2.down(pos2));

  final perStep = moveDelta / steps.toDouble();
  final stepDuration =
      Duration(microseconds: duration.inMicroseconds ~/ steps);


  for (int i = 0; i < steps; i++) {
    pos1 += pinch ? perStep : -perStep;
    pos2 += pinch ? -perStep : perStep;

    binding.handlePointerEvent(p1.move(pos1));
    binding.handlePointerEvent(p2.move(pos2));

    await tester.pump(stepDuration);
  }

  // Pointer up
  binding.handlePointerEvent(p1.up());
  binding.handlePointerEvent(p2.up());

  await tester.pump();
}


Future<void> performPinchGesture(
  WidgetTester tester,
  {
  Offset center = Offset.zero, 
  Offset startSeparation = const Offset(50, 0),
  Offset moveDelta = const Offset(15, 2),
}) async {
    // Start two gestures on opposite sides of that center
  final gesture1 = await tester.startGesture(center - startSeparation);
  final gesture2 = await tester.startGesture(center + startSeparation);

  await tester.pump();

  await gesture1.moveBy(moveDelta); 
  await gesture2.moveBy(-moveDelta);
  await tester.pump();

  // release fingers
  await gesture1.up();
  await gesture2.up();

  await tester.pump();
}

mixin _ScaleCounter on ScaleCallbacks {
  int scaleStartEvent = 0;
  int scaleUpdateEvent = 0;
  int scaleEndEvent = 0;

  int isScaledStateChange = 0;

  bool _wasScaled = false;

  @override
  void onScaleStart(ScaleStartEvent event) {
    super.onScaleStart(event);
    expect(event.raw, isNotNull);
    event.handled = true;
    scaleStartEvent++;
    if (_wasScaled != isScaled) {
      ++isScaledStateChange;
      _wasScaled = isScaled;
    }
  }

  @override
  void onScaleUpdate(ScaleUpdateEvent event) {
    expect(event.raw, isNotNull);
    event.handled = true;
    scaleUpdateEvent++;
  }

  @override
  void onScaleEnd(ScaleEndEvent event) {
    super.onScaleEnd(event);
    expect(event.raw, isNotNull);
    event.handled = true;
    scaleEndEvent++;
    if (_wasScaled != isScaled) {
      ++isScaledStateChange;
      _wasScaled = isScaled;
    }
  }
}

// Source - https://stackoverflow.com/a
// Posted by Alexander Marochko
// Retrieved 2025-11-19, License - CC BY-SA 4.0

extension ZoomTesting on WidgetTester{
  Future<void> timedZoomFrom(
      Offset startLocation1,
      Offset offset1,
      Offset startLocation2,
      Offset offset2,
      Duration duration, {
        int? pointer,
        int buttons = kPrimaryButton,
        double frequency = 60.0,
      }) {
    assert(frequency > 0);
    final int intervals = duration.inMicroseconds * frequency ~/ 1E6;
    assert(intervals > 1);
    pointer ??= nextPointer;
    int pointer2 = pointer + 1;
    final List<Duration> timeStamps = <Duration>[
      for (int t = 0; t <= intervals; t += 1)
        duration * t ~/ intervals,
    ];
    final List<Offset> offsets1 = <Offset>[
      startLocation1,
      for (int t = 0; t <= intervals; t += 1)
        startLocation1 + offset1 * (t / intervals),
    ];
    final List<Offset> offsets2 = <Offset>[
      startLocation2,
      for (int t = 0; t <= intervals; t += 1)
        startLocation2 + offset2 * (t / intervals),
    ];
    final List<PointerEventRecord> records = <PointerEventRecord>[
      PointerEventRecord(Duration.zero, <PointerEvent>[
        PointerAddedEvent(
          position: startLocation1,
        ),
        PointerAddedEvent(
          position: startLocation2,
        ),
        PointerDownEvent(
          position: startLocation1,
          pointer: pointer,
          buttons: buttons,
        ),
        PointerDownEvent(
          position: startLocation2,
          pointer: pointer2,
          buttons: buttons,
        ),
      ]),
      ...<PointerEventRecord>[
        for(int t = 0; t <= intervals; t += 1)
          PointerEventRecord(timeStamps[t], <PointerEvent>[
            PointerMoveEvent(
              timeStamp: timeStamps[t],
              position: offsets1[t+1],
              delta: offsets1[t+1] - offsets1[t],
              pointer: pointer,
              buttons: buttons,
            ),
            PointerMoveEvent(
              timeStamp: timeStamps[t],
              position: offsets2[t+1],
              delta: offsets2[t+1] - offsets2[t],
              pointer: pointer2,
              buttons: buttons,
            ),
          ]),
      ],
      PointerEventRecord(duration, <PointerEvent>[
        PointerUpEvent(
          timeStamp: duration,
          position: offsets1.last,
          pointer: pointer,
        ),
        PointerUpEvent(
          timeStamp: duration,
          position: offsets2.last,
          pointer: pointer2,
        ),
      ]),
    ];
    return TestAsyncUtils.guard<void>(() async {
      await handlePointerEventRecord(records);
    });
  }
}


class _ScaleCallbacksComponent extends PositionComponent
    with ScaleCallbacks, _ScaleCounter {}

class _ScaleCallbacksGame extends FlameGame with ScaleCallbacks, _ScaleCounter {}

class _SimpleScaleCallbacksComponent extends PositionComponent
    with ScaleCallbacks {
  _SimpleScaleCallbacksComponent({super.size});
}

class _ScaleWithCallbacksComponent extends PositionComponent with ScaleCallbacks {
  _ScaleWithCallbacksComponent({
    void Function(ScaleStartEvent)? onScaleStart,
    void Function(ScaleUpdateEvent)? onScaleUpdate,
    void Function(ScaleEndEvent)? onScaleEnd,
    super.position,
    super.size,
  }) : _onScaleStart = onScaleStart,
       _onScaleUpdate = onScaleUpdate,
       _onScaleEnd = onScaleEnd;

  final void Function(ScaleStartEvent)? _onScaleStart;
  final void Function(ScaleUpdateEvent)? _onScaleUpdate;
  final void Function(ScaleEndEvent)? _onScaleEnd;

  @override
  void onScaleStart(ScaleStartEvent event) {
    super.onScaleStart(event);
    return _onScaleStart?.call(event);
  }

  @override
  void onScaleUpdate(ScaleUpdateEvent event) {
    return _onScaleUpdate?.call(event);
  }

  @override
  void onScaleEnd(ScaleEndEvent event) {
    super.onScaleEnd(event);
    return _onScaleEnd?.call(event);
  }
}

class _SimpleDragCallbacksComponent extends PositionComponent
    with DragCallbacks {
  _SimpleDragCallbacksComponent({super.size});
}
