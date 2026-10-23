import 'package:flame/components.dart' show Component, PositionComponent;
import 'package:flame_studio/src/core/game_controller.dart';
import 'package:flame_studio/src/core/gizmo/gizmo_geometry.dart';
import 'package:flame_studio/src/core/selection.dart';
import 'package:flame_studio/src/core/theme.dart';
import 'package:flame_studio/src/core/viewport_tool.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Draws a gizmo on top of the game for the selected component, showing its
/// outline, its anchor and the directions of its local axes, together with
/// the handles of the tool in use.
///
/// The overlay must cover the game widget, but may be larger than it. The
/// gizmo is updated every frame while a [PositionComponent] is selected.
class const GizmoOverlay({super.key}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<GizmoOverlay> createState() => _GizmoOverlayState();
}

class _GizmoOverlayState()
    extends ConsumerState<GizmoOverlay>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker((_) => _update());
  List<GizmoGeometry> _geometry = const [];

  @override
  void initState() {
    super.initState();
    ref.listenManual(
      selectedComponentProvider,
      (_, component) => _handleSelectionChange(component),
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _handleSelectionChange(Component? component) {
    if (component is PositionComponent) {
      if (!_ticker.isActive) {
        _ticker.start();
      }
    } else {
      _ticker.stop();
      if (_geometry.isNotEmpty) {
        setState(() => _geometry = const []);
      }
    }
  }

  void _update() {
    final component = ref.read(selectedComponentProvider);
    final geometry = component is PositionComponent && component.isMounted
        ? GizmoGeometry.of(component)
        : const <GizmoGeometry>[];
    if (!listEquals(geometry, _geometry)) {
      setState(() => _geometry = geometry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameControllerProvider.select((s) => s.game));
    final tool = ref.watch(viewportToolProvider);
    return _GizmoPaint(
      geometry: _geometry,
      gameBox: (game?.isAttached ?? false) ? game!.renderBox : null,
      theme: ref.watch(themeProvider),
      tool: tool,
      activeHandle: ref.watch(activeGizmoHandleProvider),
    );
  }
}

class const _GizmoPaint({
  required final List<GizmoGeometry> geometry,
  required final RenderBox? gameBox,
  required final Theme theme,
  required final ViewportTool tool,
  required final GizmoHandle? activeHandle,
}) extends LeafRenderObjectWidget {
  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderGizmo()
      ..geometry = geometry
      ..gameBox = gameBox
      ..theme = theme
      ..tool = tool
      ..activeHandle = activeHandle;
  }

  @override
  void updateRenderObject(BuildContext context, _RenderGizmo renderObject) {
    renderObject
      ..geometry = geometry
      ..gameBox = gameBox
      ..theme = theme
      ..tool = tool
      ..activeHandle = activeHandle;
  }
}

/// Paints the gizmos, converting their points from the canvas space of the
/// game into the local space of this render box.
class _RenderGizmo() extends RenderBox {
  static const double arrowSize = 6.0;
  static const double anchorRadius = 4.0;

  List<GizmoGeometry> _geometry = const [];
  RenderBox? _gameBox;
  Theme? _theme;
  ViewportTool _tool = ViewportTool.interact;
  GizmoHandle? _activeHandle;

  set geometry(List<GizmoGeometry> value) {
    if (!identical(_geometry, value)) {
      _geometry = value;
      markNeedsPaint();
    }
  }

  set gameBox(RenderBox? value) {
    if (_gameBox != value) {
      _gameBox = value;
      markNeedsPaint();
    }
  }

  set theme(Theme value) {
    if (_theme != value) {
      _theme = value;
      markNeedsPaint();
    }
  }

  set tool(ViewportTool value) {
    if (_tool != value) {
      _tool = value;
      markNeedsPaint();
    }
  }

  set activeHandle(GizmoHandle? value) {
    if (_activeHandle != value) {
      _activeHandle = value;
      markNeedsPaint();
    }
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void paint(PaintingContext context, Offset offset) {
    final gameBox = _gameBox;
    final theme = _theme;
    if (_geometry.isEmpty ||
        gameBox == null ||
        !gameBox.attached ||
        theme == null) {
      return;
    }
    Offset toLocal(Offset canvasPoint) {
      return globalToLocal(gameBox.localToGlobal(canvasPoint)) + offset;
    }

    Color handleColor(GizmoHandle handle, Color color) {
      return handle == _activeHandle ? theme.gizmoActiveColor : color;
    }

    final canvas = context.canvas;
    for (final gizmo in _geometry) {
      final outline = Path()
        ..addPolygon(gizmo.corners.map(toLocal).toList(), true);
      canvas.drawPath(
        outline,
        Paint()..color = theme.gizmoColor.withAlpha(0x22),
      );
      _stroke(canvas, outline, theme.gizmoColor, 1.5);

      final anchor = toLocal(gizmo.anchor);
      final isRotating = _tool == ViewportTool.rotate;
      final isScaling = _tool == ViewportTool.scale;
      if (isRotating) {
        final radius =
            (toLocal(gizmo.anchor + const Offset(GizmoGeometry.ringRadius, 0)) -
                    anchor)
                .distance;
        _stroke(
          canvas,
          Path()..addOval(Rect.fromCircle(center: anchor, radius: radius)),
          handleColor(GizmoHandle.ring, theme.gizmoRotationColor),
          2,
        );
        if (gizmo.xAxis != Offset.zero) {
          // Shows the current angle of the component.
          final end = toLocal(
            gizmo.anchor + gizmo.xAxis * GizmoGeometry.ringRadius,
          );
          _stroke(
            canvas,
            Path()
              ..moveTo(anchor.dx, anchor.dy)
              ..lineTo(end.dx, end.dy),
            theme.gizmoXAxisColor,
            1.5,
          );
        }
      }
      final showsFreeHandle = _tool == ViewportTool.move || isScaling;
      if (showsFreeHandle && gizmo.xAxis != Offset.zero) {
        final color = handleColor(GizmoHandle.free, theme.gizmoColor);
        final square = Path()
          ..addPolygon(gizmo.freeHandleCorners.map(toLocal).toList(), true);
        _fill(canvas, square, color.withAlpha(0xAA));
        _stroke(canvas, square, color, 1);
      }
      if (!isRotating) {
        for (final (handle, axis, end, color) in [
          (GizmoHandle.x, gizmo.xAxis, gizmo.xAxisEnd, theme.gizmoXAxisColor),
          (GizmoHandle.y, gizmo.yAxis, gizmo.yAxisEnd, theme.gizmoYAxisColor),
        ]) {
          if (axis != Offset.zero) {
            _drawAxis(
              canvas,
              anchor,
              toLocal(end),
              handleColor(handle, color),
              boxed: isScaling,
            );
          }
        }
      }
      final anchorCircle = Path()
        ..addOval(Rect.fromCircle(center: anchor, radius: anchorRadius));
      _fill(canvas, anchorCircle, const Color(0xFFFFFFFF));
      _stroke(canvas, anchorCircle, theme.gizmoColor, 1.5);
    }
  }

  /// Strokes [path] over a dark halo, so that it stands out on any background.
  void _stroke(Canvas canvas, Path path, Color color, double width) {
    canvas.drawPath(
      path,
      Paint()
        ..color = _theme!.gizmoHaloColor
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = width + 2,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  /// Fills [path] over a dark halo, so that it stands out on any background.
  void _fill(Canvas canvas, Path path, Color color) {
    canvas.drawPath(
      path,
      Paint()
        ..color = _theme!.gizmoHaloColor
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 2,
    );
    canvas.drawPath(path, Paint()..color = color);
  }

  /// Draws an axis from [start] to [end], ending in an arrow head, or in a
  /// square when [boxed], which is the handle of the scale tool.
  void _drawAxis(
    Canvas canvas,
    Offset start,
    Offset end,
    Color color, {
    required bool boxed,
  }) {
    final direction = end - start;
    final distance = direction.distance;
    if (distance == 0) {
      return;
    }
    final unit = direction / distance;
    final normal = Offset(-unit.dy, unit.dx) * (arrowSize / 2);
    final headBase = end - unit * arrowSize;
    _stroke(
      canvas,
      Path()
        ..moveTo(start.dx, start.dy)
        ..lineTo(headBase.dx, headBase.dy),
      color,
      2,
    );
    final head = boxed
        ? [headBase + normal, end + normal, end - normal, headBase - normal]
        : [end, headBase + normal, headBase - normal];
    _fill(canvas, Path()..addPolygon(head, true), color);
  }
}
