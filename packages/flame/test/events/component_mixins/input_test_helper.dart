import 'package:flame/components.dart';
import 'package:flame/events.dart' hide PointerMoveEvent;
import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

mixin DragCounter on DragCallbacks {
  int dragStartEvent = 0;
  int dragUpdateEvent = 0;
  int dragEndEvent = 0;
  int dragCancelEvent = 0;
  int isDraggedStateChange = 0;

  bool _wasDragged = false;

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
    super.onDragUpdate(event);
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

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    event.handled = true;
    dragCancelEvent++;
  }
}

mixin ScaleCounter on ScaleCallbacks {
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
    expect(event.raw, isNotNull);
    event.handled = true;
    scaleEndEvent++;
    if (_wasScaled != isScaling) {
      ++isScaledStateChange;
      _wasScaled = isScaling;
    }
  }
}

class DragWithCallbacksComponent extends PositionComponent with DragCallbacks {
  DragWithCallbacksComponent({
    void Function(DragStartEvent)? onDragStart,
    void Function(DragUpdateEvent)? onDragUpdate,
    void Function(DragEndEvent)? onDragEnd,
    super.position,
    super.size,
  }) : _onDragStart = onDragStart,
       _onDragUpdate = onDragUpdate,
       _onDragEnd = onDragEnd;

  final void Function(DragStartEvent)? _onDragStart;
  final void Function(DragUpdateEvent)? _onDragUpdate;
  final void Function(DragEndEvent)? _onDragEnd;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    return _onDragStart?.call(event);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    return _onDragUpdate?.call(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    return _onDragEnd?.call(event);
  }
}

class ScaleWithCallbacksComponent extends PositionComponent
    with ScaleCallbacks {
  ScaleWithCallbacksComponent({
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

class ScaleDragCallbacksComponent extends PositionComponent
    with ScaleCallbacks, DragCallbacks, ScaleCounter, DragCounter {}

class ScaleDragCallbacksGame extends FlameGame
    with ScaleCallbacks, DragCallbacks, ScaleCounter, DragCounter {}

class SimpleScaleDragCallbacksComponent extends PositionComponent
    with ScaleCallbacks, DragCallbacks {
  SimpleScaleDragCallbacksComponent({super.size});
}

class ScaleDragWithCallbacksComponent extends PositionComponent
    with ScaleCallbacks, DragCallbacks, ScaleCounter, DragCounter {
  ScaleDragWithCallbacksComponent({
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

extension ZoomTesting on WidgetTester {
  Future<void> timedZoomFrom(
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
  Future<void> zoomFrom(
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

Future<void> dragWithInjection(
  WidgetTester tester,
  Offset start,
  Offset delta,
  Duration duration,
  Future<void> Function() onHalfway, {
  int steps = 20,
}) async {
  final gesture = await tester.startGesture(start);
  final dt = duration ~/ steps;

  for (var i = 0; i < steps; i++) {
    if (i == steps ~/ 2) {
      await onHalfway();
    }

    final t = (i + 1) / steps;
    await gesture.moveTo(start + delta * t);
    await tester.pump(dt);
  }

  await gesture.up();
  await tester.pump();
}

Future<void> zoomFromWithInjection(
  WidgetTester tester, {
  required Offset startLocation1,
  required Offset offset1,
  required Offset startLocation2,
  required Offset offset2,
  required Duration duration,
  required Future<void> Function() onHalfway,
  int steps = 20,
}) async {
  // Start both fingers
  final gesture1 = await tester.startGesture(startLocation1);
  final gesture2 = await tester.startGesture(startLocation2);

  await tester.pump();

  final dt = duration ~/ steps;

  for (var i = 0; i < steps; i++) {
    // Inject custom logic at halfway
    if (i == steps ~/ 2) {
      await onHalfway();
      await tester.pump();
    }

    final t = (i + 1) / steps;

    await gesture1.moveTo(startLocation1 + offset1 * t);
    await gesture2.moveTo(startLocation2 + offset2 * t);

    await tester.pump(dt);
  }

  // Release both gestures
  await gesture1.up();
  await gesture2.up();

  await tester.pump();
}

}



class ScaleCallbacksComponent extends PositionComponent
    with ScaleCallbacks, ScaleCounter {}

class ScaleCallbacksGame extends FlameGame with ScaleCallbacks, ScaleCounter {}

class SimpleScaleCallbacksComponent extends PositionComponent
    with ScaleCallbacks {
  SimpleScaleCallbacksComponent({super.size});
}

class SimpleDragCallbacksComponent extends PositionComponent
    with DragCallbacks {
  SimpleDragCallbacksComponent({super.size});
}

class DragCallbacksComponent extends PositionComponent
    with DragCallbacks, DragCounter {}

class DragCallbacksGame extends FlameGame with DragCallbacks, DragCounter {}
