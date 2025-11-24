import 'dart:math';

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
      'make sure ScaleDragCallback components can be added to a FlameGame',
      (game) async {
        await game.add(_ScaleDragCallbacksComponent());
        await game.ready();
        expect(game.children.toList()[2], isA<MultiDragScaleDispatcher>());
      },
    );
  });
  testWithFlameGame('scale drag event start', (game) async {
    final component = _ScaleDragCallbacksComponent()
      ..x = 10
      ..y = 10
      ..width = 10
      ..height = 10;
    game.add(component);
    await game.ready();

    expect(game.children.whereType<MultiDragScaleDispatcher>().length, 1);
    game.firstChild<MultiDragScaleDispatcher>()!.onScaleStart(
      createScaleStartEvents(
        game: game,
        localFocalPoint: const Offset(12, 12),
        focalPoint: const Offset(12, 12),
      ),
    );
    expect(component.containsLocalPoint(Vector2(10, 10)), false);
  });

  testWithFlameGame('scale event start, update and end', (game) async {
    final component = _ScaleDragCallbacksComponent()
      ..x = 10
      ..y = 10
      ..width = 10
      ..height = 10;
    await game.ensureAdd(component);
    final dispatcher = game.firstChild<ScaleDragCallbacks>()!;

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
      final component = _ScaleDragCallbacksComponent()
        ..x = 10
        ..y = 10
        ..width = 10
        ..height = 10;
      await game.ensureAdd(component);
      final dispatcher = game.firstChild<MultiDragScaleDispatcher>()!;
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
    final component = _ScaleDragCallbacksComponent()
      ..x = 100
      ..y = 100
      ..width = 150
      ..height = 150;
    final game = FlameGame(children: [component]);

    await tester.pumpWidget(GameWidget(game: game));
    await tester.pump();

    await _zoomFrom(
      tester,
      startLocation1: const Offset(180, 150),
      offset1: const Offset(15, 2),
      startLocation2: const Offset(120, 150),
      offset2: const Offset(-15, -2),
    );
    await tester.pump();
    await tester.pump();

    expect(game.children.length, equals(4));
    expect(component.isMounted, isTrue);

    expect(component.scaleStartEvent, equals(1));
    expect(component.scaleUpdateEvent, greaterThan(0));
    expect(component.scaleEndEvent, equals(1));
  });

  testWidgets(
    'scale outside of component is not registered as handled',
    (tester) async {
      final component = _ScaleDragCallbacksComponent()..size = Vector2.all(100);
      final game = FlameGame(children: [component]);
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();
      expect(component.isMounted, isTrue);

      await _zoomFrom(
        tester,
        startLocation1: const Offset(250, 200),
        offset1: const Offset(15, 2),
        startLocation2: const Offset(150, 200),
        offset2: const Offset(-15, -2),
      );

      expect(component.scaleStartEvent, equals(0));
      expect(component.scaleUpdateEvent, equals(0));
      expect(component.scaleEndEvent, equals(0));
    },
  );

  testWithGame(
    'make sure the FlameGame can registers Scale Callbacks on itself',
    _ScaleDragCallbacksGame.new,
    (game) async {
      await game.ready();
      expect(game.children.length, equals(3));
      expect(game.children.elementAt(1), isA<MultiDragScaleDispatcher>());
    },
  );

  testWidgets(
    'scale correctly registered handled event directly on FlameGame',
    (tester) async {
      final game = _ScaleDragCallbacksGame()..onGameResize(Vector2.all(300));
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();
      expect(game.children.length, equals(3));
      expect(game.isMounted, isTrue);

      await _zoomFrom(
        tester,
        startLocation1: const Offset(50, 100),
        offset1: const Offset(15, 2),
        startLocation2: const Offset(150, 100),
        offset2: const Offset(-15, -2),
      );

      expect(game.scaleStartEvent, equals(1));
      expect(game.scaleUpdateEvent, greaterThan(0));
      expect(game.scaleEndEvent, equals(1));
    },
  );

  testWidgets(
    'isScaled is changed',
    (tester) async {
      final component = _ScaleDragCallbacksComponent()
        ..size = Vector2.all(100)
        ..x = 100
        ..y = 100;

      final game = FlameGame(children: [component]);
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();

      // Inside component
      await _zoomFrom(
        tester,
        startLocation1: const Offset(180, 100),
        offset1: const Offset(15, 2),
        startLocation2: const Offset(120, 100),
        offset2: const Offset(-15, -2),
      );

      expect(component.isScaledStateChange, equals(2));

      // Outside component
      await _zoomFrom(
        tester,
        startLocation1: const Offset(330, 300),
        offset1: const Offset(15, 2),
        startLocation2: const Offset(270, 300),
        offset2: const Offset(-15, -2),
      );

      expect(component.isScaledStateChange, equals(2));
    },
  );
  group('HasScalableComponents', () {
    testWidgets(
      'scale event does not affect more than one component',
      (tester) async {
        var nEvents = 0;
        final game = FlameGame(
          children: [
            _ScaleDragWithCallbacksComponent(
              size: Vector2.all(100),
              onScaleStart: (e) => nEvents++,
              onScaleUpdate: (e) => nEvents++,
              onScaleEnd: (e) => nEvents++,
            ),
            _SimpleScaleDragCallbacksComponent(size: Vector2.all(200))
              ..priority = 10,
          ],
        );
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();
        await tester.pump();
        await _zoomFrom(
          tester,
          startLocation1: const Offset(80, 50),
          offset1: const Offset(15, 2),
          startLocation2: const Offset(20, 50),
          offset2: const Offset(-15, -2),
        );
        expect(nEvents, 0);
      },
    );

    testWidgets(
      'scale event can move outside the component bounds and still fire',
      (tester) async {
        var nEvents = 0;
        const intervals = 50;
        final component = _ScaleDragWithCallbacksComponent(
          size: Vector2.all(30),
          position: Vector2.all(100),
          onScaleUpdate: (e) => nEvents++,
        );
        final game = FlameGame(
          children: [component],
        );
        await tester.pumpWidget(GameWidget(game: game));
        await tester.pump();

        const center = Offset(115, 115);
        await tester._timedZoomFrom(
          center.translate(-10, 0),
          const Offset(-30, 0),
          center.translate(10, 0),
          const Offset(30, 0),
          const Duration(milliseconds: 300),
          intervals: intervals,
        );
        expect(nEvents, intervals * 2 + 2);
      },
    );
  });

  testWidgets(
    'scale event scale respects camera & zoom',
    (tester) async {
      final resolution = Vector2(80, 60);
      final game = FlameGame(
        camera: CameraComponent.withFixedResolution(
          width: resolution.x,
          height: resolution.y,
        ),
      );
      final scales = [];

      game.camera.viewfinder.zoom = 3;

      await game.world.add(
        _ScaleDragWithCallbacksComponent(
          position: Vector2.all(-5),
          size: Vector2.all(10),
          onScaleUpdate: (event) {
            scales.add(event.scale);
          },
        ),
      );
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();

      final canvasSize = game.canvasSize;

      final center = (canvasSize / 2).toOffset();
      await tester._timedZoomFrom(
        center.translate(-1, 0),
        const Offset(-20, 0),
        center.translate(1, 0),
        const Offset(20, 0),
        const Duration(milliseconds: 300),
        intervals: 10,
      );

      expect(scales.skip(1), List.generate(21, (i) => i + 1));
    },
  );

  testWidgets(
    'scale event triggers both scale and drag',
    (tester) async {
      final resolution = Vector2(80, 60);
      final game = FlameGame(
        camera: CameraComponent.withFixedResolution(
          width: resolution.x,
          height: resolution.y,
        ),
      );

      final component = _ScaleDragWithCallbacksComponent(
        position: Vector2.all(-5),
        size: Vector2.all(10),
      );
      await game.world.add(component);
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();

      final canvasSize = game.canvasSize;

      final center = (canvasSize / 2).toOffset();
      await tester._timedZoomFrom(
        center.translate(-1, 0),
        const Offset(0, 20),
        center.translate(1, 0),
        const Offset(0, -20),
        const Duration(milliseconds: 300),
        intervals: 10,
      );

      await tester.pump();
      await tester.pump();

      expect(component.scaleStartEvent, equals(1));
      expect(component.scaleUpdateEvent, greaterThan(0));
      expect(component.scaleEndEvent, equals(1));
      expect(component.dragStartEvent, equals(2));
      expect(component.dragUpdateEvent, greaterThan(0));
      expect(component.dragEndEvent, equals(2));
    },
  );
}

Future<void> _zoomFrom(
  WidgetTester tester, {
  required Offset startLocation1,
  required Offset offset1,
  required Offset startLocation2,
  required Offset offset2,
}) async {
  // Start two gestures on opposite sides of that center
  final gesture1 = await tester.startGesture(startLocation1);
  final gesture2 = await tester.startGesture(startLocation2);

  await tester.pump();

  await gesture1.moveBy(offset1);
  await gesture2.moveBy(offset2);
  await tester.pump();

  // release fingers
  await gesture1.up();
  await gesture2.up();

  await tester.pump();
}

mixin _ScaleDragCounter on ScaleDragCallbacks {
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
    if (_wasScaled != isScaling) {
      ++isScaledStateChange;
      _wasScaled = isScaling;
    }
  }

  @override
  void onScaleUpdate(ScaleUpdateEvent event) {
    super.onScaleUpdate(event);
    expect(event.raw, isNotNull);
    event.handled = true;
    scaleUpdateEvent++;
  }

  @override
  void onScaleEnd(ScaleEndEvent event) {
    super.onScaleEnd(event);
    debugPrint("scale end counter");
    event.handled = true;
    scaleEndEvent++;
    if (_wasScaled != isScaling) {
      ++isScaledStateChange;
      _wasScaled = isScaling;
    }
  }

  bool _wasDragged = false;
  int dragStartEvent = 0;
  int dragUpdateEvent = 0;
  int dragEndEvent = 0;
  int dragCancelEvent = 0;
  int isDraggedStateChange = 0;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    event.handled = true;
    dragStartEvent++;
    if (_wasDragged != isDragged) {
      ++isDraggedStateChange;
      _wasDragged = isDragged;
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    event.handled = true;
    dragUpdateEvent++;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    event.handled = true;
    dragEndEvent++;
    if (_wasDragged != isDragged) {
      ++isDraggedStateChange;
      _wasDragged = isDragged;
    }
  }
}

class _ScaleDragCallbacksComponent extends PositionComponent
    with ScaleDragCallbacks, _ScaleDragCounter {}

class _ScaleDragCallbacksGame extends FlameGame
    with ScaleDragCallbacks, _ScaleDragCounter {}

class _SimpleScaleDragCallbacksComponent extends PositionComponent
    with ScaleDragCallbacks {
  _SimpleScaleDragCallbacksComponent({super.size});
}

class _ScaleDragWithCallbacksComponent extends PositionComponent
    with ScaleDragCallbacks, _ScaleDragCounter {
  _ScaleDragWithCallbacksComponent({
    void Function(ScaleStartEvent)? onScaleStart,
    void Function(ScaleUpdateEvent)? onScaleUpdate,
    void Function(ScaleEndEvent)? onScaleEnd,
    void Function(DragStartEvent)? onDragStart,
    void Function(DragUpdateEvent)? onDragUpdate,
    void Function(DragEndEvent)? onDragEnd,
    super.position,
    super.size,
  }) : _onScaleStart = onScaleStart,
       _onScaleUpdate = onScaleUpdate,
       _onScaleEnd = onScaleEnd,
       _onDragStart = onDragStart,
       _onDragUpdate = onDragUpdate,
       _onDragEnd = onDragEnd;

  final void Function(ScaleStartEvent)? _onScaleStart;
  final void Function(ScaleUpdateEvent)? _onScaleUpdate;
  final void Function(ScaleEndEvent)? _onScaleEnd;
  final void Function(DragStartEvent)? _onDragStart;
  final void Function(DragUpdateEvent)? _onDragUpdate;
  final void Function(DragEndEvent)? _onDragEnd;

  @override
  void onScaleStart(ScaleStartEvent event) {
    super.onScaleStart(event);
    return _onScaleStart?.call(event);
  }

  @override
  void onScaleUpdate(ScaleUpdateEvent event) {
    super.onScaleUpdate(event);
    return _onScaleUpdate?.call(event);
  }

  @override
  void onScaleEnd(ScaleEndEvent event) {
    super.onScaleEnd(event);
    return _onScaleEnd?.call(event);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    return _onDragStart?.call(event);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    return _onDragUpdate?.call(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    return _onDragEnd?.call(event);
  }
}

// Source - https://stackoverflow.com/a/75171528
// Posted by Alexander
// Retrieved 2025-11-19, License - CC BY-SA 4.0

extension _ZoomTesting on WidgetTester {
  Future<void> _timedZoomFrom(
    Offset startLocation1,
    Offset offset1,
    Offset startLocation2,
    Offset offset2,
    Duration duration, {
    int? pointer,
    int buttons = kPrimaryButton,
    int intervals = 30,
  }) {
    assert(intervals > 1);
    pointer ??= nextPointer;
    final pointer2 = pointer + 1;
    final timeStamps = <Duration>[
      for (int t = 0; t <= intervals; t += 1) duration * t ~/ intervals,
    ];
    final offsets1 = <Offset>[
      startLocation1,
      for (int t = 0; t <= intervals; t += 1)
        startLocation1 + offset1 * (t / intervals),
    ];
    final offsets2 = <Offset>[
      startLocation2,
      for (int t = 0; t <= intervals; t += 1)
        startLocation2 + offset2 * (t / intervals),
    ];
    final records = <PointerEventRecord>[
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
        for (int t = 0; t <= intervals; t += 1)
          PointerEventRecord(timeStamps[t], <PointerEvent>[
            PointerMoveEvent(
              timeStamp: timeStamps[t],
              position: offsets1[t + 1],
              delta: offsets1[t + 1] - offsets1[t],
              pointer: pointer,
              buttons: buttons,
            ),
            PointerMoveEvent(
              timeStamp: timeStamps[t],
              position: offsets2[t + 1],
              delta: offsets2[t + 1] - offsets2[t],
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
