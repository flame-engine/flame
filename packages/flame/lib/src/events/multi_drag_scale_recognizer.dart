import 'dart:math' as math;

import 'package:flutter/gestures.dart';

/// A gesture recognizer that can recognize both individual pointer drags 
/// and scale gestures simultaneously.
/// 
/// This recognizer tracks each pointer individually (like ImmediateMultiDragGestureRecognizer)
/// while also tracking the overall scale gesture (like ScaleGestureRecognizer).
/// When 2+ pointers are down, both drag callbacks (per pointer) and scale callbacks fire.
class MultiDragScaleGestureRecognizer extends OneSequenceGestureRecognizer {
  /// Create a gesture recognizer for tracking multi-drag and scale gestures.
  MultiDragScaleGestureRecognizer({
    super.debugOwner,
    super.supportedDevices,
    super.allowedButtonsFilter,
    this.dragStartBehavior = DragStartBehavior.down,
    this.scaleThreshold = 1.05,
  });

  /// Determines what point is used as the starting point in all calculations.
  final DragStartBehavior dragStartBehavior;

  /// The threshold for determining when a scale gesture has occurred.
  /// Default is 1.05 (5% change in scale).
  final double scaleThreshold;

  /// Called when a pointer starts dragging. One callback per pointer.
  /// Return a Drag object to receive updates for this specific pointer.
  GestureMultiDragStartCallback? onDragStart;

  /// Called when a scale gesture starts (when 2+ pointers are active).
  GestureScaleStartCallback? onScaleStart;

  /// Called when a scale gesture is updated.
  GestureScaleUpdateCallback? onScaleUpdate;

  /// Called when a scale gesture ends.
  GestureScaleEndCallback? onScaleEnd;

  _GestureState _state = _GestureState.ready;
  bool _scaleGestureActive = false;

  final Map<int, Offset> _pointerLocations = <int, Offset>{};
  final Map<int, Offset> _initialPointerLocations = <int, Offset>{};
  final List<int> _pointerQueue = <int>[];
  final Map<int, VelocityTracker> _velocityTrackers = <int, VelocityTracker>{};
  final Map<int, Drag?> _activeDrags = <int, Drag?>{};
  final Map<int, Offset> _lastPointerPositions = <int, Offset>{};

  // Scale-specific fields
  late Offset _initialFocalPoint;
  Offset? _currentFocalPoint;
  late double _initialSpan;
  late double _currentSpan;
  late double _initialHorizontalSpan;
  late double _currentHorizontalSpan;
  late double _initialVerticalSpan;
  late double _currentVerticalSpan;
  late Offset _localFocalPoint;
  _LineBetweenPointers? _initialLine;
  _LineBetweenPointers? _currentLine;
  Matrix4? _lastTransform;
  late Offset _delta;
  VelocityTracker? _scaleVelocityTracker;
  Duration? _initialScaleEventTimestamp;

  int get pointerCount => _pointerLocations.length;

  double get _pointerScaleFactor => 
      _initialSpan > 0.0 ? _currentSpan / _initialSpan : 1.0;

  double get _pointerHorizontalScaleFactor =>
      _initialHorizontalSpan > 0.0 ? _currentHorizontalSpan / _initialHorizontalSpan : 1.0;

  double get _pointerVerticalScaleFactor =>
      _initialVerticalSpan > 0.0 ? _currentVerticalSpan / _initialVerticalSpan : 1.0;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    _velocityTrackers[event.pointer] = VelocityTracker.withKind(event.kind);
    _initialPointerLocations[event.pointer] = event.position;
    _lastPointerPositions[event.pointer] = event.position;

    if (_state == _GestureState.ready) {
      _state = _GestureState.possible;
      _initialSpan = 0.0;
      _currentSpan = 0.0;
      _initialHorizontalSpan = 0.0;
      _currentHorizontalSpan = 0.0;
      _initialVerticalSpan = 0.0;
      _currentVerticalSpan = 0.0;
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    assert(_state != _GestureState.ready);
    bool didChangeConfiguration = false;
    bool shouldStartIfAccepted = false;

    if (event is PointerMoveEvent) {
      final VelocityTracker tracker = _velocityTrackers[event.pointer]!;
      if (!event.synthesized) {
        tracker.addPosition(event.timeStamp, event.position);
      }
      
      final Offset lastPosition = _lastPointerPositions[event.pointer]!;
      final Offset delta = event.position - lastPosition;
      _lastPointerPositions[event.pointer] = event.position;
      
      // Update individual drag
      final Drag? drag = _activeDrags[event.pointer];
      if (drag != null) {
        drag.update(DragUpdateDetails(
          globalPosition: event.position,
          delta: delta,
          sourceTimeStamp: event.timeStamp,
          localPosition: PointerEvent.transformPosition(event.transform, event.position),
        ));
      }
      
      _pointerLocations[event.pointer] = event.position;
      shouldStartIfAccepted = true;
      _lastTransform = event.transform;
    } else if (event is PointerDownEvent) {
      _pointerLocations[event.pointer] = event.position;
      _pointerQueue.add(event.pointer);
      didChangeConfiguration = true;
      shouldStartIfAccepted = true;
      _lastTransform = event.transform;
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      // End individual drag
      final Drag? drag = _activeDrags[event.pointer];
      if (drag != null) {
        final VelocityTracker tracker = _velocityTrackers[event.pointer]!;
        if (event is PointerUpEvent) {
          drag.end(DragEndDetails(
            velocity: tracker.getVelocity(),
          ));
        } else {
          drag.cancel();
        }
        _activeDrags.remove(event.pointer);
      }
      
      _pointerLocations.remove(event.pointer);
      _initialPointerLocations.remove(event.pointer);
      _lastPointerPositions.remove(event.pointer);
      _pointerQueue.remove(event.pointer);
      didChangeConfiguration = true;
      _lastTransform = event.transform;
    }

    _updateLines();
    _update();

    if (!didChangeConfiguration || _reconfigure(event.pointer)) {
      _advanceStateMachine(shouldStartIfAccepted, event);
    }
    stopTrackingIfPointerNoLongerDown(event);
  }

  void _update() {
    final Offset? previousFocalPoint = _currentFocalPoint;

    // Compute the focal point
    Offset focalPoint = Offset.zero;
    for (final int pointer in _pointerLocations.keys) {
      focalPoint += _pointerLocations[pointer]!;
    }
    _currentFocalPoint = _pointerLocations.isEmpty
        ? Offset.zero
        : focalPoint / _pointerLocations.length.toDouble();

    if (previousFocalPoint == null) {
      _localFocalPoint = PointerEvent.transformPosition(
          _lastTransform, _currentFocalPoint!);
      _delta = Offset.zero;
    } else {
      final Offset localPreviousFocalPoint = _localFocalPoint;
      _localFocalPoint = PointerEvent.transformPosition(
          _lastTransform, _currentFocalPoint!);
      _delta = _localFocalPoint - localPreviousFocalPoint;
    }

    final int count = _pointerLocations.keys.length;
    Offset pointerFocalPoint = Offset.zero;
    for (final int pointer in _pointerLocations.keys) {
      pointerFocalPoint += _pointerLocations[pointer]!;
    }
    if (count > 0) {
      pointerFocalPoint = pointerFocalPoint / count.toDouble();
    }

    // Calculate span
    double totalDeviation = 0.0;
    double totalHorizontalDeviation = 0.0;
    double totalVerticalDeviation = 0.0;
    for (final int pointer in _pointerLocations.keys) {
      totalDeviation += (pointerFocalPoint - _pointerLocations[pointer]!).distance;
      totalHorizontalDeviation += 
          (pointerFocalPoint.dx - _pointerLocations[pointer]!.dx).abs();
      totalVerticalDeviation += 
          (pointerFocalPoint.dy - _pointerLocations[pointer]!.dy).abs();
    }
    _currentSpan = count > 0 ? totalDeviation / count : 0.0;
    _currentHorizontalSpan = count > 0 ? totalHorizontalDeviation / count : 0.0;
    _currentVerticalSpan = count > 0 ? totalVerticalDeviation / count : 0.0;
  }

  void _updateLines() {
    final int count = _pointerLocations.keys.length;
    assert(_pointerQueue.length >= count);

    if (count < 2) {
      _initialLine = _currentLine;
    } else if (_initialLine != null &&
        _initialLine!.pointerStartId == _pointerQueue[0] &&
        _initialLine!.pointerEndId == _pointerQueue[1]) {
      _currentLine = _LineBetweenPointers(
        pointerStartId: _pointerQueue[0],
        pointerStartLocation: _pointerLocations[_pointerQueue[0]]!,
        pointerEndId: _pointerQueue[1],
        pointerEndLocation: _pointerLocations[_pointerQueue[1]]!,
      );
    } else {
      _initialLine = _LineBetweenPointers(
        pointerStartId: _pointerQueue[0],
        pointerStartLocation: _pointerLocations[_pointerQueue[0]]!,
        pointerEndId: _pointerQueue[1],
        pointerEndLocation: _pointerLocations[_pointerQueue[1]]!,
      );
      _currentLine = _initialLine;
    }
  }

  bool _reconfigure(int pointer) {
    _initialFocalPoint = _currentFocalPoint!;
    _initialSpan = _currentSpan;
    _initialLine = _currentLine;
    _initialHorizontalSpan = _currentHorizontalSpan;
    _initialVerticalSpan = _currentVerticalSpan;

    if (_state == _GestureState.started && _scaleGestureActive) {
      // Check if we should end the scale gesture
      if (_pointerLocations.length < 2) {
        if (onScaleEnd != null) {
          final VelocityTracker tracker = _velocityTrackers[pointer]!;
          Velocity velocity = tracker.getVelocity();
          
          if (_isFlingGesture(velocity)) {
            final Offset pixelsPerSecond = velocity.pixelsPerSecond;
            if (pixelsPerSecond.distanceSquared > 
                kMaxFlingVelocity * kMaxFlingVelocity) {
              velocity = Velocity(
                pixelsPerSecond: 
                    (pixelsPerSecond / pixelsPerSecond.distance) * kMaxFlingVelocity,
              );
            }
            invokeCallback<void>('onScaleEnd', () => onScaleEnd!(
              ScaleEndDetails(
                velocity: velocity,
                scaleVelocity: _scaleVelocityTracker?.getVelocity().pixelsPerSecond.dx ?? -1,
                pointerCount: pointerCount,
              ),
            ));
          } else {
            invokeCallback<void>('onScaleEnd', () => onScaleEnd!(
              ScaleEndDetails(
                scaleVelocity: _scaleVelocityTracker?.getVelocity().pixelsPerSecond.dx ?? -1,
                pointerCount: pointerCount,
              ),
            ));
          }
        }
        _scaleGestureActive = false;
        _state = _GestureState.accepted;
        _scaleVelocityTracker = VelocityTracker.withKind(PointerDeviceKind.touch);
        return false;
      }
    }

    _scaleVelocityTracker = VelocityTracker.withKind(PointerDeviceKind.touch);
    return true;
  }

  void _advanceStateMachine(bool shouldStartIfAccepted, PointerEvent event) {
    if (_state == _GestureState.ready) {
      _state = _GestureState.possible;
    }

    if (_state == _GestureState.possible) {
      // Check if we should start accepting gestures
      bool shouldAccept = false;
      
      if (_pointerLocations.length >= 2) {
        final double spanDelta = (_currentSpan - _initialSpan).abs();
        final double scaleFactor = _pointerScaleFactor;
        
        if (spanDelta > computeScaleSlop(event.kind) ||
            math.max(scaleFactor, 1.0 / scaleFactor) > scaleThreshold) {
          shouldAccept = true;
        }
      } else if (_pointerLocations.length == 1) {
        final int pointer = _pointerLocations.keys.first;
        final Offset initialPosition = _initialPointerLocations[pointer]!;
        final Offset currentPosition = _pointerLocations[pointer]!;
        final double distance = (currentPosition - initialPosition).distance;
        
        if (distance > computePanSlop(event.kind, gestureSettings)) {
          shouldAccept = true;
        }
      }
      
      if (shouldAccept) {
        resolve(GestureDisposition.accepted);
      }
    } else if (_state.index >= _GestureState.accepted.index) {
      resolve(GestureDisposition.accepted);
    }

    if (_state == _GestureState.accepted && shouldStartIfAccepted) {
      _state = _GestureState.started;
      
      // Start individual drags for all pointers that don't have one yet
      for (final int pointer in _pointerLocations.keys) {
        if (!_activeDrags.containsKey(pointer)) {
          _startDragForPointer(pointer);
        }
      }
      
      // Start scale gesture if we have 2+ pointers
      if (_pointerLocations.length >= 2 && !_scaleGestureActive) {
        _scaleGestureActive = true;
        _initialScaleEventTimestamp = event.timeStamp;
        _dispatchOnScaleStartCallback();
      }
    }

    if (_state == _GestureState.started) {
      // Start scale gesture if we just got a second pointer
      if (!_scaleGestureActive && _pointerLocations.length >= 2) {
        _scaleGestureActive = true;
        _initialScaleEventTimestamp = event.timeStamp;
        _dispatchOnScaleStartCallback();
      }
      
      // Update scale gesture if active and we still have 2+ pointers
      if (_scaleGestureActive && _pointerLocations.length >= 2) {
        _scaleVelocityTracker?.addPosition(
            event.timeStamp, Offset(_pointerScaleFactor, 0));
        if (onScaleUpdate != null) {
          invokeCallback<void>('onScaleUpdate', () {
            onScaleUpdate!(ScaleUpdateDetails(
              scale: _pointerScaleFactor,
              horizontalScale: _pointerHorizontalScaleFactor,
              verticalScale: _pointerVerticalScaleFactor,
              focalPoint: _currentFocalPoint!,
              localFocalPoint: _localFocalPoint,
              rotation: _computeRotationFactor(),
              pointerCount: pointerCount,
              focalPointDelta: _delta,
              sourceTimeStamp: event.timeStamp,
            ));
          });
        }
      }
    }
  }

  void _startDragForPointer(int pointer) {
    if (onDragStart != null) {
      final Offset initialPosition = _initialPointerLocations[pointer]!;
      final Drag? drag = invokeCallback<Drag?>('onDragStart', () {
        return onDragStart!(initialPosition);
      });
      _activeDrags[pointer] = drag;
    }
  }

  void _dispatchOnScaleStartCallback() {
    if (onScaleStart != null) {
      invokeCallback<void>('onScaleStart', () {
        onScaleStart!(ScaleStartDetails(
          focalPoint: _currentFocalPoint!,
          localFocalPoint: _localFocalPoint,
          pointerCount: pointerCount,
          sourceTimeStamp: _initialScaleEventTimestamp,
        ));
      });
    }
  }

  double _computeRotationFactor() {
    double factor = 0.0;
    if (_initialLine != null && _currentLine != null) {
      final double fx = _initialLine!.pointerStartLocation.dx;
      final double fy = _initialLine!.pointerStartLocation.dy;
      final double sx = _initialLine!.pointerEndLocation.dx;
      final double sy = _initialLine!.pointerEndLocation.dy;

      final double nfx = _currentLine!.pointerStartLocation.dx;
      final double nfy = _currentLine!.pointerStartLocation.dy;
      final double nsx = _currentLine!.pointerEndLocation.dx;
      final double nsy = _currentLine!.pointerEndLocation.dy;

      final double angle1 = math.atan2(fy - sy, fx - sx);
      final double angle2 = math.atan2(nfy - nsy, nfx - nsx);

      factor = angle2 - angle1;
    }
    return factor;
  }

  bool _isFlingGesture(Velocity velocity) {
    final double speedSquared = velocity.pixelsPerSecond.distanceSquared;
    return speedSquared > kMinFlingVelocity * kMinFlingVelocity;
  }

  @override
  void acceptGesture(int pointer) {
    if (_state == _GestureState.possible) {
      _state = _GestureState.started;
      
      // Start drag for this pointer
      _startDragForPointer(pointer);
      
      // Start scale gesture if we have 2+ pointers
      if (_pointerLocations.length >= 2 && !_scaleGestureActive) {
        _scaleGestureActive = true;
        _dispatchOnScaleStartCallback();
      }
      
      if (dragStartBehavior == DragStartBehavior.start) {
        _initialFocalPoint = _currentFocalPoint!;
        _initialSpan = _currentSpan;
        _initialLine = _currentLine;
        _initialHorizontalSpan = _currentHorizontalSpan;
        _initialVerticalSpan = _currentVerticalSpan;
      }
    }
  }

  @override
  void rejectGesture(int pointer) {
    final Drag? drag = _activeDrags[pointer];
    if (drag != null) {
      drag.cancel();
      _activeDrags.remove(pointer);
    }
    
    _pointerLocations.remove(pointer);
    _initialPointerLocations.remove(pointer);
    _lastPointerPositions.remove(pointer);
    _pointerQueue.remove(pointer);
    stopTrackingPointer(pointer);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    switch (_state) {
      case _GestureState.possible:
        resolve(GestureDisposition.rejected);
      case _GestureState.ready:
        assert(false); // Should never happen
      case _GestureState.accepted:
      case _GestureState.started:
        // Valid states - gesture was active and all pointers lifted
        break;
    }
    _state = _GestureState.ready;
    _scaleGestureActive = false;
  }

  @override
  void dispose() {
    _velocityTrackers.clear();
    for (final Drag? drag in _activeDrags.values) {
      drag?.cancel();
    }
    _activeDrags.clear();
    super.dispose();
  }

  @override
  String get debugDescription => 'multi-drag-scale';
}

enum _GestureState {
  ready,
  possible,
  accepted,
  started,
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