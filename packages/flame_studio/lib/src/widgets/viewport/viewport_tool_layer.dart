import 'package:collection/collection.dart';
import 'package:flame/components.dart'
    show Component, PositionComponent, Vector2;
import 'package:flame_studio/src/core/game_controller.dart';
import 'package:flame_studio/src/core/gizmo/canvas_mapping.dart';
import 'package:flame_studio/src/core/gizmo/gizmo_drag.dart';
import 'package:flame_studio/src/core/gizmo/gizmo_geometry.dart';
import 'package:flame_studio/src/core/gizmo/move_drag.dart';
import 'package:flame_studio/src/core/gizmo/rotate_drag.dart';
import 'package:flame_studio/src/core/gizmo/scale_drag.dart';
import 'package:flame_studio/src/core/selection.dart';
import 'package:flame_studio/src/core/snap_settings.dart';
import 'package:flame_studio/src/core/viewport_tool.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Covers the game while a tool other than [ViewportTool.interact] is in use,
/// handling the pointer events for that tool and keeping them from the game.
///
/// With the interact tool this layer is empty, so that the pointer events
/// reach the game.
class const ViewportToolLayer({super.key}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<ViewportToolLayer> createState() => _ViewportToolLayerState();
}

class _ViewportToolLayerState() extends ConsumerState<ViewportToolLayer> {
  MouseCursor _cursor = SystemMouseCursors.precise;

  /// Where the pointer went down, in global coordinates. Drags are measured
  /// from this point, so that the drag slop doesn't offset the component.
  Offset? _downPosition;
  Offset? _lastPosition;
  GizmoDrag? _drag;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  /// Applies the drag again when Shift is pressed or released, so that
  /// snapping toggles without having to move the pointer.
  bool _handleKeyEvent(KeyEvent event) {
    final lastPosition = _lastPosition;
    final isShift =
        event.logicalKey == LogicalKeyboardKey.shiftLeft ||
        event.logicalKey == LogicalKeyboardKey.shiftRight;
    if (_drag != null && lastPosition != null && isShift) {
      _updateDrag(lastPosition);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final tool = ref.watch(viewportToolProvider);
    if (tool == ViewportTool.interact) {
      return const SizedBox.shrink();
    }
    final canDrag = tool != ViewportTool.select;
    return MouseRegion(
      cursor: _cursor,
      onHover: canDrag ? (event) => _hover(event.position) : null,
      onExit: (_) => _setActiveHandle(null),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        dragStartBehavior: DragStartBehavior.down,
        onTapUp: (details) => _select(details.globalPosition),
        onPanDown: canDrag
            ? (details) => _downPosition = details.globalPosition
            : null,
        onPanStart: canDrag ? (_) => _startDrag() : null,
        onPanUpdate: canDrag
            ? (details) => _updateDrag(details.globalPosition)
            : null,
        onPanEnd: canDrag ? (_) => _endDrag() : null,
        onPanCancel: canDrag ? _endDrag : null,
      ),
    );
  }

  /// The root component of the game, and [globalPosition] in its canvas space.
  (Component, Offset)? _toCanvas(Offset globalPosition) {
    final game = ref.read(gameControllerProvider).game;
    if (game == null || !game.isAttached || game is! Component) {
      return null;
    }
    return (
      game as Component,
      game.renderBox.globalToLocal(globalPosition),
    );
  }

  /// The handle of the selected component's gizmo at [canvasPoint], and the
  /// gizmo it belongs to.
  (GizmoGeometry, GizmoHandle)? _handleAt(Offset canvasPoint) {
    final selected = ref.read(selectedComponentProvider);
    final tool = ref.read(viewportToolProvider);
    if (selected is! PositionComponent ||
        tool == ViewportTool.interact ||
        tool == ViewportTool.select) {
      return null;
    }
    for (final geometry in GizmoGeometry.of(selected)) {
      final handle = geometry.handleAt(
        canvasPoint,
        ring: tool == ViewportTool.rotate,
      );
      if (handle != null) {
        return (geometry, handle);
      }
    }
    return null;
  }

  void _setActiveHandle(GizmoHandle? handle) {
    ref.read(activeGizmoHandleProvider.notifier).set(handle);
  }

  void _select(Offset globalPosition) {
    final target = _toCanvas(globalPosition);
    if (target == null) {
      return;
    }
    final (root, point) = target;
    if (_handleAt(point) != null) {
      // Clicking a handle keeps the selection.
      return;
    }
    final candidates = selectableComponentsAt(
      root,
      Vector2(point.dx, point.dy),
    );
    ref
        .read(selectedComponentProvider.notifier)
        .select(pickNext(candidates, ref.read(selectedComponentProvider)));
  }

  void _hover(Offset globalPosition) {
    final target = _toCanvas(globalPosition);
    final handle = target == null ? null : _handleAt(target.$2)?.$2;
    _setActiveHandle(handle);
    final cursor = handle == null
        ? SystemMouseCursors.precise
        : switch (ref.read(viewportToolProvider)) {
            ViewportTool.rotate => SystemMouseCursors.grab,
            ViewportTool.scale => SystemMouseCursors.resizeUpLeftDownRight,
            _ => SystemMouseCursors.move,
          };
    if (cursor != _cursor) {
      setState(() => _cursor = cursor);
    }
  }

  void _startDrag() {
    final downPosition = _downPosition;
    final target = downPosition == null ? null : _toCanvas(downPosition);
    if (target == null) {
      return;
    }
    final (root, point) = target;
    final tool = ref.read(viewportToolProvider);
    final snapSettings = ref.read(snapSettingsProvider);
    final hit = _handleAt(point);
    if (hit != null) {
      final component =
          ref.read(selectedComponentProvider)! as PositionComponent;
      final (geometry, handle) = hit;
      _drag = switch (tool) {
        ViewportTool.rotate => RotateDrag.start(
          component,
          geometry,
          point,
          snapStep: snapSettings.rotateStep,
        ),
        ViewportTool.scale => ScaleDrag.start(
          component,
          handle,
          geometry,
          snapStep: snapSettings.scaleStep,
        ),
        _ => MoveDrag.start(
          component,
          handle,
          camera: geometry.camera,
          snapStep: snapSettings.moveStep,
        ),
      };
      _setActiveHandle(handle);
    } else if (tool == ViewportTool.move) {
      // Dragging a component moves it freely, selecting it if needed.
      final selected = ref.read(selectedComponentProvider);
      final candidates = selectableComponentsAt(
        root,
        Vector2(point.dx, point.dy),
      );
      final picked = candidates.contains(selected)
          ? selected! as PositionComponent
          : candidates.firstOrNull;
      if (picked == null) {
        return;
      }
      ref.read(selectedComponentProvider.notifier).select(picked);
      final camera =
          GizmoGeometry.of(picked)
              .firstWhereOrNull((geometry) => geometry.containsPoint(point))
              ?.camera ??
          camerasFor(picked).firstOrNull;
      _drag = MoveDrag.start(
        picked,
        GizmoHandle.free,
        camera: camera,
        snapStep: snapSettings.moveStep,
      );
      _setActiveHandle(GizmoHandle.free);
    }
  }

  void _updateDrag(Offset globalPosition) {
    final drag = _drag;
    final downPosition = _downPosition;
    final game = ref.read(gameControllerProvider).game;
    if (drag == null ||
        downPosition == null ||
        game == null ||
        !game.isAttached) {
      return;
    }
    _lastPosition = globalPosition;
    final gameBox = game.renderBox;
    final delta =
        gameBox.globalToLocal(globalPosition) -
        gameBox.globalToLocal(downPosition);
    drag.update(
      Vector2(delta.dx, delta.dy),
      snap: HardwareKeyboard.instance.isShiftPressed,
    );
    ref.read(gameControllerProvider.notifier).repaint();
  }

  void _endDrag() {
    if (_drag != null) {
      _setActiveHandle(null);
    }
    _drag = null;
    _downPosition = null;
    _lastPosition = null;
  }
}
