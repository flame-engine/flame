import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/src/events/interfaces/scale_listener.dart';
import 'package:flame/src/events/tagged_component.dart';
import 'package:flame/src/game/game_widget/gesture_detector_builder.dart';
import 'package:flame/src/image_composition.dart';
import 'package:flutter/gestures.dart';
import 'package:meta/meta.dart';

/// Defines a line between two pointers on screen.
///
/// [_LineBetweenPointers] is an abstraction of a line between two pointers in
/// contact with the screen. Used to track the rotation and scale of a scaleAabb
///  gesture.
class _LineBetweenPointers {
  /// Creates a [_LineBetweenPointers]. None of the [pointerStartLocation]
  /// [pointerEndLocation]  must be null.
  /// should be different.
  _LineBetweenPointers({
    this.pointerStartLocation = Offset.zero,
    this.pointerEndLocation = Offset.zero,
  });

  // The location and the id of the pointer that marks the start of the line.
  final Offset pointerStartLocation;

  // The location and the id of the pointer that marks the end of the line.
  final Offset pointerEndLocation;
}

/// Unique key for the [ScaleDispatcher] so the game can identify it.
class ScaleDispatcherKey implements ComponentKey {
  const ScaleDispatcherKey();

  @override
  int get hashCode => 31650892; // arbitrary unique number

  @override
  bool operator ==(Object other) =>
      other is ScaleDispatcherKey && other.hashCode == hashCode;
}

/// A component that dispatches scale (pinch/zoom) events to components
/// implementing [ScaleCallbacks]. It will be attached to
/// the [FlameGame] instance automatically whenever any [ScaleCallbacks]
/// components are mounted into the component tree.
class ScaleDispatcher extends Component implements ScaleListener {
  /// Records all components currently being scaled, keyed by pointerId.
  final Set<TaggedComponent<ScaleCallbacks>> _records = {};

  FlameGame get game => parent! as FlameGame;

  /// Store the last drag events
  DragStartDetails? lastDragStart;
  DragUpdateDetails? lastDragUpdate;
  DragEndDetails? lastDragEnd;

  _LineBetweenPointers? _currentLine;

  _LineBetweenPointers? _lineAtFirstUpdate;

  MultiDragDispatcher? _multiDragDispatcher;

  /// Called when the user starts a scale gesture.
  @mustCallSuper
  void onScaleStart(ScaleStartEvent event) {
    event.deliverAtPoint(
      rootComponent: game,
      eventHandler: (ScaleCallbacks component) {
        _records.add(TaggedComponent(event.pointerId, component));
        component.onScaleStart(event);
      },
    );
  }

  /// Called continuously as the user updates the scale gesture.
  @mustCallSuper
  void onScaleUpdate(ScaleUpdateEvent event) {
    final updated = <TaggedComponent<ScaleCallbacks>>{};

    // Deliver to components under the pointer
    event.deliverAtPoint(
      rootComponent: game,
      deliverToAll: true,
      eventHandler: (ScaleCallbacks component) {
        final record = TaggedComponent(event.pointerId, component);
        if (_records.contains(record)) {
          component.onScaleUpdate(event);
          updated.add(record);
        }
      },
    );

    // Also deliver to components that started the scale but weren't under
    // the pointer this frame
    // Currently, the id passed to the scale
    // events is always 0, so maybe it's not relevant.
    for (final record in _records) {
      if (record.pointerId == event.pointerId && !updated.contains(record)) {
        record.component.onScaleUpdate(event);
      }
    }
  }

  /// Called when the scale gesture ends.
  @mustCallSuper
  void onScaleEnd(ScaleEndEvent event) {
    _records.removeWhere((record) {
      if (record.pointerId == event.pointerId) {
        record.component.onScaleEnd(event);
        return true;
      }
      return false;
    });
  }

  //#region ScaleListener API

  @internal
  @override
  void handleScaleStart(ScaleStartDetails details) {
    onScaleStart(ScaleStartEvent(0, game, details));
  }

  @internal
  @override
  void handleScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount != 1) {
      onScaleUpdate(ScaleUpdateEvent(0, game, details));
      return;
    }

    final newDetails = _buildNewUpdateDetails(details);
    if (newDetails != null) {
      onScaleUpdate(ScaleUpdateEvent(0, game, newDetails));
    }
  }

  /// If the user is doing a scale gesture, and we have more
  /// than one pointer in contact with the screen, we don't have
  /// anything special to do.
  /// However, if the user is doing a scale gesture but a single pointer
  /// is registered (such as when [ImmediateMultiDragGestureRecognizer] is
  /// added to the [GestureDetectorBuilder] game gesture detectors), then
  /// the [ScaleUpdateDetails] details won't contain any useful data, so
  /// we need to rebuild it using data from the drag gesture.
  ScaleUpdateDetails? _buildNewUpdateDetails(ScaleUpdateDetails details) {
    if (lastDragUpdate == null) {
      return null;
    }

    _currentLine = _LineBetweenPointers(
      pointerStartLocation: details.focalPoint,
      pointerEndLocation: lastDragUpdate!.globalPosition,
    );

    // Register the line between the two pointers when the first update is
    // triggered. This line will serve as a reference to compute scale
    // and rotation data.
    _lineAtFirstUpdate ??= _currentLine;

    // Do we also need to recompute local focal point,
    // local relative to what ?
    return ScaleUpdateDetails(
      focalPoint: _computeFocalPoint(details),
      rotation: _computeRotationFactor(details),
      scale: _computeScale(details),
      verticalScale: _computeVerticalScale(details),
      horizontalScale: _computeHorizontalScale(details),
      pointerCount: details.pointerCount,
      focalPointDelta: details.focalPointDelta,
      sourceTimeStamp: details.sourceTimeStamp,
    );
  }

  /// Compute the focal point of the scale gesture using the one pointer
  /// focal point (which is just the position of the pointer itself) and
  /// the position of the last pointer triggering a drag update.
  Offset _computeFocalPoint(ScaleUpdateDetails details) {
    if (lastDragUpdate != null) {
      return details.focalPoint + lastDragUpdate!.globalPosition / 2.0;
    } else {
      return details.focalPoint;
    }
  }

  /// Compute the rotation of the scale gesture using the initial
  /// line formed between the two pointers that form the scale gesture,
  /// and the subsequent lines they form as they move. The rotation factor
  /// is just the angle in radian between the two lines.
  double _computeRotationFactor(ScaleUpdateDetails details) {
    if (lastDragUpdate == null ||
        _lineAtFirstUpdate == null ||
        _currentLine == null) {
      return 0.0;
    }

    final fx = _lineAtFirstUpdate!.pointerStartLocation.dx;
    final fy = _lineAtFirstUpdate!.pointerStartLocation.dy;
    final sx = _lineAtFirstUpdate!.pointerEndLocation.dx;
    final sy = _lineAtFirstUpdate!.pointerEndLocation.dy;

    final nfx = _currentLine!.pointerStartLocation.dx;
    final nfy = _currentLine!.pointerStartLocation.dy;
    final nsx = _currentLine!.pointerEndLocation.dx;
    final nsy = _currentLine!.pointerEndLocation.dy;

    final angle1 = math.atan2(fy - sy, fx - sx);
    final angle2 = math.atan2(nfy - nsy, nfx - nsx);

    return angle2 - angle1;
  }

  /// Compute the scale of the scale gesture using the initial
  /// line formed between the two pointers that form the scale gesture,
  /// and the subsequent lines they form as they move. The scale factor
  /// is just length of current line over length of initial line.
  double _computeScale(ScaleUpdateDetails details) {
    if (lastDragUpdate == null ||
        _currentLine == null ||
        _lineAtFirstUpdate == null) {
      return 1.0;
    }

    final currentLineDistance =
        (_currentLine!.pointerStartLocation - _currentLine!.pointerEndLocation)
            .distance;

    final firstLineDistance =
        (_lineAtFirstUpdate!.pointerStartLocation -
                _lineAtFirstUpdate!.pointerEndLocation)
            .distance;

    return currentLineDistance / firstLineDistance;
  }

  /// Compute the vertical scale of the scale gesture using the initial
  /// line formed between the two pointers that form the scale gesture,
  /// and the subsequent lines they form as they move. The scale factor
  /// is just length of current line vertical part over
  /// length of initial line part.
  double _computeVerticalScale(ScaleUpdateDetails details) {
    if (lastDragUpdate == null ||
        _currentLine == null ||
        _lineAtFirstUpdate == null) {
      return 1.0;
    }

    final currentLineVerticalDistance =
        (_currentLine!.pointerStartLocation.dy -
                _currentLine!.pointerEndLocation.dy)
            .abs();
    final firstLineVerticalDistance =
        (_lineAtFirstUpdate!.pointerStartLocation.dy -
                _lineAtFirstUpdate!.pointerEndLocation.dy)
            .abs();

    return currentLineVerticalDistance / firstLineVerticalDistance;
  }

  /// Compute the vertical scale of the scale gesture using the initial
  /// line formed between the two pointers that form the scale gesture,
  /// and the subsequent lines they form as they move. The scale factor
  /// is just length of current line horizontal part over
  /// length of initial line part.
  double _computeHorizontalScale(ScaleUpdateDetails details) {
    if (lastDragUpdate == null ||
        _currentLine == null ||
        _lineAtFirstUpdate == null) {
      return 1.0;
    }

    final currentLineHorizontalDistance =
        (_currentLine!.pointerStartLocation.dx -
                _currentLine!.pointerEndLocation.dx)
            .abs();
    final firstLineHorizontalDistance =
        (_lineAtFirstUpdate!.pointerStartLocation.dx -
                _lineAtFirstUpdate!.pointerEndLocation.dx)
            .abs();

    return currentLineHorizontalDistance / firstLineHorizontalDistance;
  }

  @internal
  @override
  void handleScaleEnd(ScaleEndDetails details) {
    _currentLine = null;
    _lineAtFirstUpdate = null;
    onScaleEnd(ScaleEndEvent(0, details));
  }

  //#endregion

  @override
  void onMount() {
    game.gestureDetectors.add<ScaleGestureRecognizer>(
      ScaleGestureRecognizer.new,
      (ScaleGestureRecognizer instance) {
        instance
          ..onStart = handleScaleStart
          ..onUpdate = handleScaleUpdate
          ..onEnd = handleScaleEnd;
      },
    );

    final existingDispatcher = game.findByKey(const MultiDragDispatcherKey());
    if (existingDispatcher != null) {
      _attachMultiDragDispatcher(existingDispatcher as MultiDragDispatcher);
    }

    super.onMount();
  }

  @override
  void onChildrenChanged(Component child, ChildrenChangeType type) {
    super.onChildrenChanged(child, type);

    if (type == ChildrenChangeType.added && child is MultiDragDispatcher) {
      _attachMultiDragDispatcher(child);
    }
  }

  void _attachMultiDragDispatcher(MultiDragDispatcher newDispatcher) {
    if (_multiDragDispatcher != null) {
      return;
    }

    _multiDragDispatcher = newDispatcher;
    listenToDragDispatcher(newDispatcher);
  }

  @override
  void onRemove() {
    game.gestureDetectors.remove<ScaleGestureRecognizer>();
    super.onRemove();
  }

  /// Subscribe to an external MultiDragDispatcher, we need
  /// this in order to get the data of pointers used by
  /// [ImmediateMultiDragGestureRecognizer], as it is necessary
  /// to compute things such as rotation and scale of the scale gesture.
  void listenToDragDispatcher(MultiDragDispatcher multiDragDispatcher) {
    multiDragDispatcher.onUpdate.listen((event) {
      lastDragUpdate = event.raw;
    });
    multiDragDispatcher.onStart.listen((event) {
      lastDragStart = event.raw;
    });
    multiDragDispatcher.onEnd.listen((event) {
      lastDragEnd = event.raw;
    });
  }
}
