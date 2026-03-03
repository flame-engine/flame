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

extension ZoomTesting on WidgetTester {
  /// Simulates a timed two-finger pinch/zoom gesture by generating pointer
  /// event records with accurate timestamps for both pointers.
  Future<void> timedZoomFrom(
    Offset start1,
    Offset offset1,
    Offset start2,
    Offset offset2,
    Duration duration, {
    int? pointer,
    int buttons = kPrimaryButton,
    int intervals = 30,
  }) {
    assert(intervals > 1);
    final p1 = pointer ?? nextPointer;
    final p2 = p1 + 1;

    final records = <PointerEventRecord>[
      // Both pointers land simultaneously at t=0.
      PointerEventRecord(Duration.zero, [
        PointerAddedEvent(position: start1),
        PointerAddedEvent(position: start2),
        PointerDownEvent(position: start1, pointer: p1, buttons: buttons),
        PointerDownEvent(position: start2, pointer: p2, buttons: buttons),
      ]),
    ];

    // Generate interleaved move events for both pointers at each step.
    var prev1 = start1;
    var prev2 = start2;
    for (var step = 0; step <= intervals; step++) {
      final t = step / intervals;
      final ts = duration * step ~/ intervals;
      final pos1 = start1 + offset1 * t;
      final pos2 = start2 + offset2 * t;
      records.add(
        PointerEventRecord(ts, [
          PointerMoveEvent(
            timeStamp: ts,
            position: pos1,
            delta: pos1 - prev1,
            pointer: p1,
            buttons: buttons,
          ),
          PointerMoveEvent(
            timeStamp: ts,
            position: pos2,
            delta: pos2 - prev2,
            pointer: p2,
            buttons: buttons,
          ),
        ]),
      );
      prev1 = pos1;
      prev2 = pos2;
    }

    // Both pointers lift at the end.
    records.add(
      PointerEventRecord(duration, [
        PointerUpEvent(timeStamp: duration, position: prev1, pointer: p1),
        PointerUpEvent(timeStamp: duration, position: prev2, pointer: p2),
      ]),
    );

    return TestAsyncUtils.guard<void>(() async {
      await handlePointerEventRecord(records);
    });
  }

  Future<void> zoomFrom({
    required Offset startLocation1,
    required Offset offset1,
    required Offset startLocation2,
    required Offset offset2,
  }) async {
    // Start two gestures on opposite sides of that center
    final gesture1 = await startGesture(startLocation1);
    final gesture2 = await startGesture(startLocation2);

    await pump();

    await gesture1.moveBy(offset1);
    await gesture2.moveBy(offset2);
    await pump();

    // release fingers
    await gesture1.up();
    await gesture2.up();

    await pump();
  }

  Future<void> dragWithInjection(
    Offset start,
    Offset delta,
    Duration duration,
    Future<void> Function() onHalfway, {
    int steps = 20,
  }) async {
    final gesture = await startGesture(start);
    final dt = duration ~/ steps;

    for (var i = 0; i < steps; i++) {
      if (i == steps ~/ 2) {
        await onHalfway();
      }

      final t = (i + 1) / steps;
      await gesture.moveTo(start + delta * t);
      await pump(dt);
    }

    await gesture.up();
    await pump();
  }

  Future<void> zoomFromWithInjection({
    required Offset startLocation1,
    required Offset offset1,
    required Offset startLocation2,
    required Offset offset2,
    required Duration duration,
    required Future<void> Function() onHalfway,
    int steps = 20,
  }) async {
    // Start both fingers
    final gesture1 = await startGesture(startLocation1);
    final gesture2 = await startGesture(startLocation2);

    await pump();

    final dt = duration ~/ steps;

    for (var i = 0; i < steps; i++) {
      // Inject custom logic at halfway
      if (i == steps ~/ 2) {
        await onHalfway();
        await pump();
      }

      final t = (i + 1) / steps;

      await gesture1.moveTo(startLocation1 + offset1 * t);
      await gesture2.moveTo(startLocation2 + offset2 * t);

      await pump(dt);
    }

    // Release both gestures
    await gesture1.up();
    await gesture2.up();

    await pump();
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
