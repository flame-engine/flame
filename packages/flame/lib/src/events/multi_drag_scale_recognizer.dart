import 'dart:math' as math;
import 'package:flutter/gestures.dart';

/// A gesture recognizer that can recognize both individual pointer drags
/// and scale gestures simultaneously.
///
/// This recognizer tracks each pointer independently (like Flutter's
/// [ImmediateMultiDragGestureRecognizer]) while also tracking the overall
/// scale gesture (like Flutter's [ScaleGestureRecognizer]). Each pointer
/// fires its own drag callbacks independently. When 2+ pointers are down
/// and movement exceeds [scaleThreshold], scale callbacks also fire.
///
/// Use [hasDrag] and [hasScale] to enable only the features needed. Both
/// default to false; the dispatcher sets them via enableDrag/enableScale.
class MultiDragScaleGestureRecognizer extends GestureRecognizer {
  /// Create a gesture recognizer for tracking multi-drag and scale gestures.
  MultiDragScaleGestureRecognizer({
    super.debugOwner,
    super.supportedDevices,
    AllowedButtonsFilter? allowedButtonsFilter,
    this.scaleThreshold = 1.05,
  }) : super(
         allowedButtonsFilter:
             allowedButtonsFilter ?? _defaultButtonAcceptBehavior,
       );

  // Accept the input if, and only if, [kPrimaryButton] is pressed.
  static bool _defaultButtonAcceptBehavior(int buttons) =>
      buttons == kPrimaryButton;

  /// The threshold for determining when a scale gesture has occurred.
  /// Default is 1.05 (5% change in scale).
  final double scaleThreshold;

  /// Whether drag callbacks should fire. Controlled by the dispatcher.
  bool hasDrag = false;

  /// Whether scale callbacks should fire. Controlled by the dispatcher.
  bool hasScale = false;

  /// Called when a pointer starts dragging. One callback per pointer.
  /// Return a Drag object to receive updates for this specific pointer.
  GestureMultiDragStartCallback? onStart;

  /// Called when a scale gesture starts (when 2+ pointers are active).
  GestureScaleStartCallback? onScaleStart;

  /// Called when a scale gesture is updated.
  GestureScaleUpdateCallback? onScaleUpdate;

  /// Called when a scale gesture ends.
  GestureScaleEndCallback? onScaleEnd;

  final _DragState _drag = _DragState();
  final _ScaleState _scale = _ScaleState();

  int get pointerCount => _drag.count;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (!hasDrag && !hasScale) {
      return;
    }
    assert(
      !_drag.pointers.containsKey(event.pointer),
      'Pointer ${event.pointer} is already tracked by this recognizer.',
    );
    final state = _DragPointerState(recognizer: this, event: event);
    _drag.pointers[event.pointer] = state;
    GestureBinding.instance.pointerRouter.addRoute(event.pointer, _handleEvent);
    state.arenaEntry = GestureBinding.instance.gestureArena.add(
      event.pointer,
      this,
    );

    if (hasScale) {
      if (_drag.count <= 2) {
        // Re-baseline focal point and spans on the first two pointer-down
        // events. For count==1 the span is zero; for count==2 the 2-finger
        // midpoint differs from the single-finger initial position, so we
        // reset both. For 3+ pointers the gesture is already in progress;
        // leave the baseline unchanged.
        _updateScaleFields();
        _scale.initialFocalPoint = _scale.currentFocalPoint;
        _scale.initialSpan = _scale.currentSpan;
        _scale.initialHorizontalSpan = _scale.currentHorizontalSpan;
        _scale.initialVerticalSpan = _scale.currentVerticalSpan;
      }
    }
  }

  void _handleEvent(PointerEvent event) {
    assert(_drag.pointers.containsKey(event.pointer));
    final state = _drag.pointers[event.pointer]!;

    if (event is PointerMoveEvent) {
      state._move(event);
      if (hasScale) {
        _updateScale(event);
      }
    } else if (event is PointerUpEvent) {
      assert(event.delta == Offset.zero);
      state._up(event);
      _removeState(event.pointer);
      if (hasScale) {
        _scale.lastTransform = event.transform;
        _updateScaleFields();
        _updateLines();
        _endScaleIfNeeded();
      }
    } else if (event is PointerCancelEvent) {
      assert(event.delta == Offset.zero);
      state._cancel(event);
      _removeState(event.pointer);
      if (hasScale) {
        _scale.lastTransform = event.transform;
        _updateScaleFields();
        _updateLines();
        _endScaleIfNeeded();
        // No need to reset initialSpan/initialLine here: addAllowedPointer
        // re-initializes them whenever a new two-finger gesture begins.
      }
    } else if (event is! PointerDownEvent) {
      assert(false);
    }
  }

  void _updateScale(PointerMoveEvent event) {
    _scale.lastTransform = event.transform;
    _updateScaleFields();
    _updateLines();
    final focalPoint = _scale.currentFocalPoint!;

    if (_drag.count >= 2 && !_scale.active && _checkScaleGestureThreshold()) {
      _scale.active = true;
      _scale.initialEventTimestamp = event.timeStamp;
      _scale.velocityTracker = VelocityTracker.withKind(event.kind);

      if (onScaleStart != null) {
        invokeCallback<void>('onScaleStart', () {
          onScaleStart!(
            ScaleStartDetails(
              focalPoint: focalPoint,
              localFocalPoint: _scale.localFocalPoint,
              pointerCount: pointerCount,
              sourceTimeStamp: _scale.initialEventTimestamp,
            ),
          );
        });
      }
    }

    if (_scale.active && _drag.count >= 2) {
      _scale.velocityTracker?.addPosition(event.timeStamp, focalPoint);

      if (onScaleUpdate != null) {
        invokeCallback<void>('onScaleUpdate', () {
          onScaleUpdate!(
            ScaleUpdateDetails(
              scale: _scale.scaleFactor,
              horizontalScale: _scale.horizontalScaleFactor,
              verticalScale: _scale.verticalScaleFactor,
              focalPoint: focalPoint,
              localFocalPoint: _scale.localFocalPoint,
              rotation: _computeRotationFactor(),
              pointerCount: pointerCount,
              focalPointDelta: _scale.delta,
              sourceTimeStamp: event.timeStamp,
            ),
          );
        });
      }
    }
  }

  void _endScaleIfNeeded() {
    if (!_scale.active || _drag.count >= 2) {
      return;
    }
    if (onScaleEnd != null) {
      final velocity = _scale.velocityTracker?.getVelocity() ?? Velocity.zero;

      if (_isFlingGesture(velocity)) {
        final pixelsPerSecond = velocity.pixelsPerSecond;
        if (pixelsPerSecond.distanceSquared >
            kMaxFlingVelocity * kMaxFlingVelocity) {
          final clampedVelocity = Velocity(
            pixelsPerSecond:
                (pixelsPerSecond / pixelsPerSecond.distance) *
                kMaxFlingVelocity,
          );
          invokeCallback<void>(
            'onScaleEnd',
            () => onScaleEnd!(
              ScaleEndDetails(
                velocity: clampedVelocity,
                pointerCount: pointerCount,
              ),
            ),
          );
        } else {
          invokeCallback<void>(
            'onScaleEnd',
            () => onScaleEnd!(
              ScaleEndDetails(
                velocity: velocity,
                pointerCount: pointerCount,
              ),
            ),
          );
        }
      } else {
        invokeCallback<void>(
          'onScaleEnd',
          () => onScaleEnd!(
            ScaleEndDetails(pointerCount: pointerCount),
          ),
        );
      }
    }

    _scale.reset();
  }

  bool _checkScaleGestureThreshold() {
    if (_drag.pointers.isEmpty || _scale.initialFocalPoint == null) {
      return false;
    }

    final kind = _drag.pointers.values.first.kind;
    final spanDelta = (_scale.currentSpan - _scale.initialSpan).abs();
    final scaleFactor = _scale.scaleFactor;
    final focalDelta =
        (_scale.currentFocalPoint! - _scale.initialFocalPoint!).distance;

    if (spanDelta > computeScaleSlop(kind) ||
        math.max(scaleFactor, 1.0 / scaleFactor) > scaleThreshold ||
        focalDelta > computePanSlop(kind, gestureSettings)) {
      for (final state in _drag.pointers.values) {
        if (!state._resolved) {
          state._arenaEntry?.resolve(GestureDisposition.accepted);
        }
      }
      return true;
    }
    return false;
  }

  void _updateScaleFields() {
    final previousFocalPoint = _scale.currentFocalPoint;

    var focalPoint = Offset.zero;
    for (final state in _drag.pointers.values) {
      focalPoint += state.currentPosition;
    }
    _scale.currentFocalPoint = _drag.pointers.isEmpty
        ? Offset.zero
        : focalPoint / _drag.pointers.length.toDouble();

    if (previousFocalPoint == null) {
      _scale.localFocalPoint = PointerEvent.transformPosition(
        _scale.lastTransform,
        _scale.currentFocalPoint!,
      );
      _scale.delta = Offset.zero;
    } else {
      _scale.localFocalPoint = PointerEvent.transformPosition(
        _scale.lastTransform,
        _scale.currentFocalPoint!,
      );
      _scale.delta = _scale.currentFocalPoint! - previousFocalPoint;
    }

    var totalDeviation = 0.0;
    var totalHorizontalDeviation = 0.0;
    var totalVerticalDeviation = 0.0;
    for (final state in _drag.pointers.values) {
      totalDeviation +=
          (_scale.currentFocalPoint! - state.currentPosition).distance;
      totalHorizontalDeviation +=
          (_scale.currentFocalPoint!.dx - state.currentPosition.dx).abs();
      totalVerticalDeviation +=
          (_scale.currentFocalPoint!.dy - state.currentPosition.dy).abs();
    }
    final count = _drag.pointers.length;
    _scale.currentSpan = count > 0 ? totalDeviation / count : 0.0;
    _scale.currentHorizontalSpan = count > 0
        ? totalHorizontalDeviation / count
        : 0.0;
    _scale.currentVerticalSpan = count > 0
        ? totalVerticalDeviation / count
        : 0.0;
  }

  void _updateLines() {
    final count = _drag.pointers.length;
    final pointerIds = _drag.pointers.keys.toList();

    if (count < 2) {
      _scale.initialLine = _scale.currentLine;
    } else if (_scale.initialLine != null &&
        _scale.initialLine!.pointerStartId == pointerIds[0] &&
        _scale.initialLine!.pointerEndId == pointerIds[1]) {
      _scale.currentLine = _LineBetweenPointers(
        pointerStartId: pointerIds[0],
        pointerStartLocation: _drag.pointers[pointerIds[0]]!.currentPosition,
        pointerEndId: pointerIds[1],
        pointerEndLocation: _drag.pointers[pointerIds[1]]!.currentPosition,
      );
    } else {
      _scale.initialLine = _LineBetweenPointers(
        pointerStartId: pointerIds[0],
        pointerStartLocation: _drag.pointers[pointerIds[0]]!.currentPosition,
        pointerEndId: pointerIds[1],
        pointerEndLocation: _drag.pointers[pointerIds[1]]!.currentPosition,
      );
      _scale.currentLine = _scale.initialLine;
    }
  }

  double _computeRotationFactor() {
    var factor = 0.0;
    final initialLine = _scale.initialLine;
    final currentLine = _scale.currentLine;
    if (initialLine != null && currentLine != null) {
      final fx = initialLine.pointerStartLocation.dx;
      final fy = initialLine.pointerStartLocation.dy;
      final sx = initialLine.pointerEndLocation.dx;
      final sy = initialLine.pointerEndLocation.dy;

      final nfx = currentLine.pointerStartLocation.dx;
      final nfy = currentLine.pointerStartLocation.dy;
      final nsx = currentLine.pointerEndLocation.dx;
      final nsy = currentLine.pointerEndLocation.dy;

      final angle1 = math.atan2(fy - sy, fx - sx);
      final angle2 = math.atan2(nfy - nsy, nfx - nsx);
      factor = angle2 - angle1;
    }
    return factor;
  }

  bool _isFlingGesture(Velocity velocity) {
    final speedSquared = velocity.pixelsPerSecond.distanceSquared;
    return speedSquared > kMinFlingVelocity * kMinFlingVelocity;
  }

  Drag? _startDrag(Offset initialPosition, int pointer) {
    assert(_drag.pointers.containsKey(pointer));
    if (!hasDrag || onStart == null) {
      return null;
    }
    return invokeCallback<Drag?>('onStart', () => onStart!(initialPosition));
  }

  @override
  void acceptGesture(int pointer) {
    final state = _drag.pointers[pointer];
    if (state == null) {
      return;
    }
    state._accepted(() => _startDrag(state.initialPosition, pointer));
  }

  @override
  void rejectGesture(int pointer) {
    final state = _drag.pointers[pointer];
    if (state != null) {
      state._rejected();
      _removeState(pointer);
      if (hasScale) {
        _updateScaleFields();
        _updateLines();
        _endScaleIfNeeded();
      }
    }
  }

  void _removeState(int pointer) {
    if (!_drag.pointers.containsKey(pointer)) {
      return;
    }
    GestureBinding.instance.pointerRouter.removeRoute(pointer, _handleEvent);
    _drag.pointers.remove(pointer)!._dispose();
  }

  @override
  void dispose() {
    final pointers = _drag.pointers.keys.toList();
    for (final pointer in pointers) {
      _removeState(pointer);
    }
    assert(_drag.pointers.isEmpty);
    super.dispose();
  }

  @override
  String get debugDescription => 'multi-drag-scale';
}

/// Groups per-recognizer drag state. Per-pointer state lives in
/// [_DragPointerState].
class _DragState {
  final Map<int, _DragPointerState> pointers = {};
  int get count => pointers.length;
}

/// Groups all scale-tracking state for a [MultiDragScaleGestureRecognizer].
class _ScaleState {
  bool active = false;
  Offset? initialFocalPoint;
  Offset? currentFocalPoint;
  double initialSpan = 0.0;
  double currentSpan = 0.0;
  double initialHorizontalSpan = 0.0;
  double currentHorizontalSpan = 0.0;
  double initialVerticalSpan = 0.0;
  double currentVerticalSpan = 0.0;
  Offset localFocalPoint = Offset.zero;
  _LineBetweenPointers? initialLine;
  _LineBetweenPointers? currentLine;
  Matrix4? lastTransform;
  Offset delta = Offset.zero;
  VelocityTracker? velocityTracker;
  Duration? initialEventTimestamp;

  // Spans are mean distances from the focal point, so they are always >= 0.
  double get scaleFactor => initialSpan > 0.0 ? currentSpan / initialSpan : 1.0;

  double get horizontalScaleFactor => initialHorizontalSpan > 0.0
      ? currentHorizontalSpan / initialHorizontalSpan
      : 1.0;

  double get verticalScaleFactor => initialVerticalSpan > 0.0
      ? currentVerticalSpan / initialVerticalSpan
      : 1.0;

  void reset() {
    active = false;
    velocityTracker = null;
  }
}

class _DragPointerState {
  _DragPointerState({
    required this.recognizer,
    required PointerDownEvent event,
  }) : initialPosition = event.position,
       currentPosition = event.position,
       kind = event.kind {
    velocityTracker = VelocityTracker.withKind(kind);
  }

  final MultiDragScaleGestureRecognizer recognizer;
  final Offset initialPosition;
  final PointerDeviceKind kind;

  Offset currentPosition;
  late VelocityTracker velocityTracker;
  GestureArenaEntry? _arenaEntry;
  Drag? _drag;
  bool _resolved = false;

  // Accumulates deltas before the gesture is accepted so they can be delivered
  // as a single initial update (matches ImmediateMultiDragGestureRecognizer).
  Offset _pendingDelta = Offset.zero;

  set arenaEntry(GestureArenaEntry entry) {
    _arenaEntry = entry;
  }

  void _move(PointerMoveEvent event) {
    if (!event.synthesized) {
      velocityTracker.addPosition(event.timeStamp, event.position);
    }

    final delta = event.position - currentPosition;
    currentPosition = event.position;

    if (!_resolved) {
      _pendingDelta += delta;
      if (!recognizer.hasScale) {
        // Drag-only mode: accept on any movement. If accepted synchronously,
        // _accepted fires the initial update with _pendingDelta; no extra
        // update fires here because we are still in the if(!_resolved) branch.
        _arenaEntry?.resolve(GestureDisposition.accepted);
      } else {
        final distance = (currentPosition - initialPosition).distance;
        if (distance > computePanSlop(kind, recognizer.gestureSettings)) {
          _arenaEntry?.resolve(GestureDisposition.accepted);
        } else if (recognizer._drag.count >= 2) {
          recognizer._checkScaleGestureThreshold();
        }
      }
    } else if (_drag != null) {
      _drag!.update(
        DragUpdateDetails(
          globalPosition: event.position,
          delta: delta,
          sourceTimeStamp: event.timeStamp,
          localPosition: PointerEvent.transformPosition(
            event.transform,
            event.position,
          ),
        ),
      );
    }
  }

  void _up(PointerUpEvent event) {
    if (_drag != null) {
      _drag!.end(DragEndDetails(velocity: velocityTracker.getVelocity()));
    }
    _resolved = true;
  }

  void _cancel(PointerCancelEvent event) {
    _drag?.cancel();
    _resolved = true;
  }

  void _accepted(Drag? Function() starter) {
    if (!_resolved) {
      _resolved = true;
      _drag = starter();
      // In drag-only mode, fire an initial update matching
      // ImmediateMultiDragGestureRecognizer: delta is Offset.zero when
      // accepted before any moves (via microtask), or the accumulated
      // pending delta when accepted during a move.
      // Scale mode skips this to avoid an extra update per pointer.
      if (_drag != null && !recognizer.hasScale) {
        _drag!.update(
          DragUpdateDetails(
            globalPosition: initialPosition,
            delta: _pendingDelta,
          ),
        );
        _pendingDelta = Offset.zero;
      }
    }
  }

  void _rejected() {
    _resolved = true;
  }

  void _dispose() {
    if (!_resolved) {
      _arenaEntry?.resolve(GestureDisposition.rejected);
    }
    _arenaEntry = null;
    _drag = null;
  }
}

class _LineBetweenPointers {
  _LineBetweenPointers({
    required this.pointerStartId,
    required this.pointerStartLocation,
    required this.pointerEndId,
    required this.pointerEndLocation,
  });

  final int pointerStartId;
  final Offset pointerStartLocation;
  final int pointerEndId;
  final Offset pointerEndLocation;
}
