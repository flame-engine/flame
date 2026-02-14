import 'dart:math' as math;
import 'package:flutter/gestures.dart';

/// A gesture recognizer that can recognize both individual pointer drags
/// and scale gestures simultaneously.
///
/// This recognizer tracks each pointer independently
/// (like [ImmediateMultiDragGestureRecognizer])
/// while also tracking the overall
/// scale gesture (like [ScaleGestureRecognizer]).
/// Each pointer can drag independently, and when 2+ pointers are down, scale
/// callbacks also fire.
class MultiDragScaleGestureRecognizer extends GestureRecognizer {
  /// Create a gesture recognizer for tracking multi-drag and scale gestures.
  MultiDragScaleGestureRecognizer({
    super.debugOwner,
    super.supportedDevices,
    AllowedButtonsFilter? allowedButtonsFilter,
    this.dragStartBehavior = DragStartBehavior.down,
    this.scaleThreshold = 1.05,
  }) : super(
         allowedButtonsFilter:
             allowedButtonsFilter ?? _defaultButtonAcceptBehavior,
       );

  // Accept the input if, and only if, [kPrimaryButton] is pressed.
  static bool _defaultButtonAcceptBehavior(int buttons) =>
      buttons == kPrimaryButton;

  /// Determines what point is used as the starting point in all calculations.
  final DragStartBehavior dragStartBehavior;

  /// The threshold for determining when a scale gesture has occurred.
  /// Default is 1.05 (5% change in scale).
  final double scaleThreshold;

  /// Called when a pointer starts dragging. One callback per pointer.
  /// Return a Drag object to receive updates for this specific pointer.
  GestureMultiDragStartCallback? onStart;

  /// Called when a scale gesture starts (when 2+ pointers are active).
  GestureScaleStartCallback? onScaleStart;

  /// Called when a scale gesture is updated.
  GestureScaleUpdateCallback? onScaleUpdate;

  /// Called when a scale gesture ends.
  GestureScaleEndCallback? onScaleEnd;

  final Map<int, _DragPointerState> _pointers = <int, _DragPointerState>{};
  bool _scaleGestureActive = false;

  // Scale-specific fields
  Offset? _initialFocalPoint;
  Offset? _currentFocalPoint;
  double _initialSpan = 0.0;
  double _currentSpan = 0.0;
  double _initialHorizontalSpan = 0.0;
  double _currentHorizontalSpan = 0.0;
  double _initialVerticalSpan = 0.0;
  double _currentVerticalSpan = 0.0;
  Offset _localFocalPoint = Offset.zero;
  _LineBetweenPointers? _initialLine;
  _LineBetweenPointers? _currentLine;
  Matrix4? _lastTransform;
  Offset _delta = Offset.zero;
  VelocityTracker? _scaleVelocityTracker;
  Duration? _initialScaleEventTimestamp;

  int get pointerCount => _pointers.length;

  double get _pointerScaleFactor =>
      _initialSpan > 0.0 ? _currentSpan / _initialSpan : 1.0;

  double get _pointerHorizontalScaleFactor => _initialHorizontalSpan > 0.0
      ? _currentHorizontalSpan / _initialHorizontalSpan
      : 1.0;

  double get _pointerVerticalScaleFactor => _initialVerticalSpan > 0.0
      ? _currentVerticalSpan / _initialVerticalSpan
      : 1.0;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    assert(!_pointers.containsKey(event.pointer));
    final state = _DragPointerState(
      recognizer: this,
      event: event,
    );
    _pointers[event.pointer] = state;
    GestureBinding.instance.pointerRouter.addRoute(event.pointer, _handleEvent);
    state.arenaEntry = GestureBinding.instance.gestureArena.add(
      event.pointer,
      this,
    );

    // Initialize scale tracking when first pointer is added
    if (_pointers.length == 1) {
      _update();
      _initialFocalPoint = _currentFocalPoint;
      _initialSpan = _currentSpan;
      _initialHorizontalSpan = _currentHorizontalSpan;
      _initialVerticalSpan = _currentVerticalSpan;
    }
  }

  void _handleEvent(PointerEvent event) {
    assert(_pointers.containsKey(event.pointer));
    final state = _pointers[event.pointer]!;

    if (event is PointerMoveEvent) {
      state._move(event);
      _updateScale(event);
    } else if (event is PointerUpEvent) {
      assert(event.delta == Offset.zero);
      state._up(event);
      _removeState(event.pointer);
      _updateScaleAfterRemoval(event);
    } else if (event is PointerCancelEvent) {
      assert(event.delta == Offset.zero);
      state._cancel(event);
      _removeState(event.pointer);
      _updateScaleAfterRemoval(event);
    } else if (event is! PointerDownEvent) {
      assert(false);
    }
  }

  void _updateScale(PointerEvent event) {
    _lastTransform = event.transform;

    // Update all pointer positions for scale calculation
    _update();
    _updateLines();

    // Check if we should accept all gestures based on scale threshold
    if (_pointers.length >= 2 && !_scaleGestureActive) {
      _checkScaleGestureThreshold();
    }

    // Start scale gesture if we now have 2+ pointers
    if (!_scaleGestureActive && _pointers.length >= 2) {
      _scaleGestureActive = true;
      _initialFocalPoint = _currentFocalPoint;
      _initialSpan = _currentSpan;
      _initialHorizontalSpan = _currentHorizontalSpan;
      _initialVerticalSpan = _currentVerticalSpan;
      _initialLine = _currentLine;
      _initialScaleEventTimestamp = event.timeStamp;
      _scaleVelocityTracker = VelocityTracker.withKind(PointerDeviceKind.touch);

      if (onScaleStart != null) {
        invokeCallback<void>('onScaleStart', () {
          onScaleStart!(
            ScaleStartDetails(
              focalPoint: _currentFocalPoint!,
              localFocalPoint: _localFocalPoint,
              pointerCount: pointerCount,
              sourceTimeStamp: _initialScaleEventTimestamp,
            ),
          );
        });
      }
    }

    // Update scale gesture if active and we still have 2+ pointers
    if (_scaleGestureActive && _pointers.length >= 2) {
      _scaleVelocityTracker?.addPosition(
        event.timeStamp,
        Offset(_pointerScaleFactor, 0),
      );

      if (onScaleUpdate != null) {
        invokeCallback<void>('onScaleUpdate', () {
          onScaleUpdate!(
            ScaleUpdateDetails(
              scale: _pointerScaleFactor,
              horizontalScale: _pointerHorizontalScaleFactor,
              verticalScale: _pointerVerticalScaleFactor,
              focalPoint: _currentFocalPoint!,
              localFocalPoint: _localFocalPoint,
              rotation: _computeRotationFactor(),
              pointerCount: pointerCount,
              focalPointDelta: _delta,
              sourceTimeStamp: event.timeStamp,
            ),
          );
        });
      }
    }
  }

  void _updateScaleAfterRemoval(PointerEvent event) {
    _lastTransform = event.transform;

    // Update all pointer positions for scale calculation (after removal)
    _update();
    _updateLines();

    // End scale gesture if we drop below 2 pointers
    if (_scaleGestureActive && _pointers.length < 2) {
      if (onScaleEnd != null) {
        final velocity = _scaleVelocityTracker?.getVelocity() ?? Velocity.zero;

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
                  scaleVelocity: velocity.pixelsPerSecond.dx,
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
                  scaleVelocity: velocity.pixelsPerSecond.dx,
                  pointerCount: pointerCount,
                ),
              ),
            );
          }
        } else {
          invokeCallback<void>(
            'onScaleEnd',
            () => onScaleEnd!(
              ScaleEndDetails(
                scaleVelocity: velocity.pixelsPerSecond.dx,
                pointerCount: pointerCount,
              ),
            ),
          );
        }
      }

      _scaleGestureActive = false;
      _scaleVelocityTracker = null;
    }
  }

  void _checkScaleGestureThreshold() {
    if (_pointers.isEmpty || _initialFocalPoint == null) {
      return;
    }

    final spanDelta = (_currentSpan - _initialSpan).abs();
    final scaleFactor = _pointerScaleFactor;

    // Get the kind from any pointer state
    final kind = _pointers.values.first.kind;

    // If we detect a scale gesture, accept all pointer gestures
    if (spanDelta > computeScaleSlop(kind) ||
        math.max(scaleFactor, 1.0 / scaleFactor) > scaleThreshold) {
      for (final state in _pointers.values) {
        if (!state._resolved) {
          state._arenaEntry?.resolve(GestureDisposition.accepted);
        }
      }
    }
  }

  void _update() {
    final previousFocalPoint = _currentFocalPoint;

    // Compute the focal point
    var focalPoint = Offset.zero;
    for (final state in _pointers.values) {
      focalPoint += state.currentPosition;
    }
    _currentFocalPoint = _pointers.isEmpty
        ? Offset.zero
        : focalPoint / _pointers.length.toDouble();

    if (previousFocalPoint == null) {
      _localFocalPoint = PointerEvent.transformPosition(
        _lastTransform,
        _currentFocalPoint!,
      );
      _delta = Offset.zero;
    } else {
      final localPreviousFocalPoint = _localFocalPoint;
      _localFocalPoint = PointerEvent.transformPosition(
        _lastTransform,
        _currentFocalPoint!,
      );
      _delta = _localFocalPoint - localPreviousFocalPoint;
    }

    final count = _pointers.length;
    var pointerFocalPoint = Offset.zero;
    for (final state in _pointers.values) {
      pointerFocalPoint += state.currentPosition;
    }
    if (count > 0) {
      pointerFocalPoint = pointerFocalPoint / count.toDouble();
    }

    // Calculate span
    var totalDeviation = 0.0;
    var totalHorizontalDeviation = 0.0;
    var totalVerticalDeviation = 0.0;
    for (final state in _pointers.values) {
      totalDeviation += (pointerFocalPoint - state.currentPosition).distance;
      totalHorizontalDeviation +=
          (pointerFocalPoint.dx - state.currentPosition.dx).abs();
      totalVerticalDeviation +=
          (pointerFocalPoint.dy - state.currentPosition.dy).abs();
    }
    _currentSpan = count > 0 ? totalDeviation / count : 0.0;
    _currentHorizontalSpan = count > 0 ? totalHorizontalDeviation / count : 0.0;
    _currentVerticalSpan = count > 0 ? totalVerticalDeviation / count : 0.0;
  }

  void _updateLines() {
    final count = _pointers.length;
    final pointerIds = _pointers.keys.toList();

    if (count < 2) {
      _initialLine = _currentLine;
    } else if (_initialLine != null &&
        _initialLine!.pointerStartId == pointerIds[0] &&
        _initialLine!.pointerEndId == pointerIds[1]) {
      _currentLine = _LineBetweenPointers(
        pointerStartId: pointerIds[0],
        pointerStartLocation: _pointers[pointerIds[0]]!.currentPosition,
        pointerEndId: pointerIds[1],
        pointerEndLocation: _pointers[pointerIds[1]]!.currentPosition,
      );
    } else {
      _initialLine = _LineBetweenPointers(
        pointerStartId: pointerIds[0],
        pointerStartLocation: _pointers[pointerIds[0]]!.currentPosition,
        pointerEndId: pointerIds[1],
        pointerEndLocation: _pointers[pointerIds[1]]!.currentPosition,
      );
      _currentLine = _initialLine;
    }
  }

  double _computeRotationFactor() {
    var factor = 0.0;
    if (_initialLine != null && _currentLine != null) {
      final fx = _initialLine!.pointerStartLocation.dx;
      final fy = _initialLine!.pointerStartLocation.dy;
      final sx = _initialLine!.pointerEndLocation.dx;
      final sy = _initialLine!.pointerEndLocation.dy;

      final nfx = _currentLine!.pointerStartLocation.dx;
      final nfy = _currentLine!.pointerStartLocation.dy;
      final nsx = _currentLine!.pointerEndLocation.dx;
      final nsy = _currentLine!.pointerEndLocation.dy;

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
    assert(_pointers.containsKey(pointer));
    Drag? drag;
    if (onStart != null) {
      drag = invokeCallback<Drag?>('onStart', () {
        return onStart!(initialPosition);
      });
    }
    return drag;
  }

  @override
  void acceptGesture(int pointer) {
    final state = _pointers[pointer];
    if (state == null) {
      return; // Already removed
    }
    state._accepted(() => _startDrag(state.initialPosition, pointer));
  }

  @override
  void rejectGesture(int pointer) {
    final state = _pointers[pointer];
    if (state != null) {
      state._rejected();
      _removeState(pointer);
    }
  }

  void _removeState(int pointer) {
    if (!_pointers.containsKey(pointer)) {
      return;
    }
    GestureBinding.instance.pointerRouter.removeRoute(pointer, _handleEvent);
    _pointers.remove(pointer)!._dispose();
  }

  @override
  void dispose() {
    final pointers = _pointers.keys.toList();
    for (final pointer in pointers) {
      _removeState(pointer);
    }
    assert(_pointers.isEmpty);
    super.dispose();
  }

  @override
  String get debugDescription => 'multi-drag-scale';
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
      // Check if we should resolve the gesture based on individual
      // pointer movement
      final distance = (currentPosition - initialPosition).distance;
      if (distance > computePanSlop(kind, recognizer.gestureSettings)) {
        _arenaEntry?.resolve(GestureDisposition.accepted);
      }
      // Also check if we should resolve based on scale gesture
      // This happens when multiple pointers are moving
      else if (recognizer._pointers.length >= 2) {
        recognizer._checkScaleGestureThreshold();
      }
    }

    if (_drag != null) {
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
      _drag!.end(
        DragEndDetails(
          velocity: velocityTracker.getVelocity(),
        ),
      );
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
    }
  }

  void _rejected() {
    _resolved = true;
  }

  void _dispose() {
    _arenaEntry?.resolve(GestureDisposition.rejected);
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
