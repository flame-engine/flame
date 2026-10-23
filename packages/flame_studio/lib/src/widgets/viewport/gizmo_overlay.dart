import 'package:flame/components.dart' show Component, PositionComponent;
import 'package:flame_studio/src/core/game_controller.dart';
import 'package:flame_studio/src/core/gizmo/gizmo_geometry.dart';
import 'package:flame_studio/src/core/selection.dart';
import 'package:flame_studio/src/core/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Draws a gizmo on top of the game for the selected component, showing its
/// outline, its anchor and the directions of its local axes.
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
    return _GizmoPaint(
      geometry: _geometry,
      gameBox: (game?.isAttached ?? false) ? game!.renderBox : null,
      theme: ref.watch(themeProvider),
    );
  }
}

class const _GizmoPaint({
  required final List<GizmoGeometry> geometry,
  required final RenderBox? gameBox,
  required final Theme theme,
}) extends LeafRenderObjectWidget {
  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderGizmo(geometry, gameBox, theme);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderGizmo renderObject) {
    renderObject
      ..geometry = geometry
      ..gameBox = gameBox
      ..theme = theme;
  }
}

/// Paints the gizmos, converting their points from the canvas space of the
/// game into the local space of this render box.
class _RenderGizmo(
  List<GizmoGeometry> geometry,
  RenderBox? gameBox,
  Theme theme,
) extends RenderBox {
  static const double axisLength = 40.0;
  static const double arrowSize = 6.0;
  static const double anchorRadius = 4.0;

  List<GizmoGeometry> _geometry = geometry;
  RenderBox? _gameBox = gameBox;
  Theme _theme = theme;

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

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void paint(PaintingContext context, Offset offset) {
    final gameBox = _gameBox;
    if (_geometry.isEmpty || gameBox == null || !gameBox.attached) {
      return;
    }
    Offset toLocal(Offset canvasPoint) {
      return globalToLocal(gameBox.localToGlobal(canvasPoint)) + offset;
    }

    final canvas = context.canvas;
    for (final gizmo in _geometry) {
      final corners = gizmo.corners.map(toLocal).toList();
      final anchor = toLocal(gizmo.anchor);
      final outline = Path()..addPolygon(corners, true);
      canvas.drawPath(
        outline,
        Paint()..color = _theme.gizmoColor.withAlpha(0x22),
      );
      canvas.drawPath(
        outline,
        Paint()
          ..color = _theme.gizmoColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      _drawAxis(
        canvas,
        anchor,
        toLocal(gizmo.anchor + gizmo.xAxis) - anchor,
        _theme.gizmoXAxisColor,
      );
      _drawAxis(
        canvas,
        anchor,
        toLocal(gizmo.anchor + gizmo.yAxis) - anchor,
        _theme.gizmoYAxisColor,
      );
      canvas.drawCircle(
        anchor,
        anchorRadius,
        Paint()..color = const Color(0xFFFFFFFF),
      );
      canvas.drawCircle(
        anchor,
        anchorRadius,
        Paint()
          ..color = _theme.gizmoColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  void _drawAxis(Canvas canvas, Offset start, Offset direction, Color color) {
    final distance = direction.distance;
    if (distance == 0) {
      return;
    }
    final unit = direction / distance;
    final normal = Offset(-unit.dy, unit.dx);
    final end = start + unit * axisLength;
    final arrowBase = end - unit * arrowSize;
    canvas.drawLine(
      start,
      arrowBase,
      Paint()
        ..color = color
        ..strokeWidth = 2,
    );
    canvas.drawPath(
      Path()..addPolygon([
        end,
        arrowBase + normal * (arrowSize / 2),
        arrowBase - normal * (arrowSize / 2),
      ], true),
      Paint()..color = color,
    );
  }
}
