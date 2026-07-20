import 'dart:math' as math;
import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';

/// The palette that the Forge2D examples share, matching the one used by the
/// Forge2D package's own examples.
abstract final class ExampleColors {
  static const background = Color(0xFF0B1020);
  static const indigo = Color(0xFF7C9CFF);
  static const sky = Color(0xFF38BDF8);
  static const amber = Color(0xFFFBBF24);
  static const rose = Color(0xFFFB7185);
  static const emerald = Color(0xFF34D399);
  static const violet = Color(0xFFA78BFA);
  static const slate = Color(0xFF64748B);
  static const text = Color(0xFFE5E9F5);

  /// The colors used for dynamic bodies.
  static const dynamics = [indigo, sky, amber, rose, emerald, violet];

  /// A stable palette color for the body number [index].
  static Color dynamicColor(int index) => dynamics[index % dynamics.length];
}

/// Renders a [BodyComponent] as a translucent fill with a bright outline, the
/// look that the Forge2D examples use.
///
/// The color comes from the component's [BodyComponent.paint], so a body only
/// has to pick a color to fit in.
mixin GlowingBody on BodyComponent {
  /// The width of the outline in world units.
  double get outlineWidth => 0.12;

  Color? _styledColor;
  late Paint _fillPaint;
  late Paint _outlinePaint;

  void _syncPaints() {
    final color = paint.color;
    if (_styledColor == color) {
      return;
    }
    _styledColor = color;
    _fillPaint = Paint()..color = color.withValues(alpha: 0.28);
    _outlinePaint = Paint()
      ..color = color.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = outlineWidth;
  }

  @override
  void renderCircle(Canvas canvas, Offset center, double radius) {
    _syncPaints();
    canvas
      ..drawCircle(center, radius, _fillPaint)
      ..drawCircle(center, radius, _outlinePaint)
      // A radius line makes the rotation of the body visible.
      ..drawLine(center, center + Offset(radius, 0), _outlinePaint);
  }

  @override
  void renderPolygon(Canvas canvas, List<Offset> points) {
    _syncPaints();
    final path = Path()..addPolygon(points, true);
    canvas
      ..drawPath(path, _fillPaint)
      ..drawPath(path, _outlinePaint);
  }

  @override
  void renderSegment(Canvas canvas, Offset p1, Offset p2) {
    _syncPaints();
    canvas.drawLine(p1, p2, _outlinePaint);
  }

  @override
  void renderCapsule(Canvas canvas, Offset p1, Offset p2, double radius) {
    _syncPaints();
    final delta = p2 - p1;
    final angle = math.atan2(delta.dy, delta.dx);
    final path = Path()
      ..addArc(
        Rect.fromCircle(center: p1, radius: radius),
        angle + math.pi / 2,
        math.pi,
      )
      ..arcTo(
        Rect.fromCircle(center: p2, radius: radius),
        angle - math.pi / 2,
        math.pi,
        false,
      )
      ..close();
    canvas
      ..drawPath(path, _fillPaint)
      ..drawPath(path, _outlinePaint);
  }
}

/// The base game for the Forge2D examples, which gives them the shared dark
/// background.
class Forge2DExampleGame extends Forge2DGame {
  Forge2DExampleGame({
    super.world,
    super.camera,
    super.gravity,
    super.metersToPixels,
  });

  @override
  Color backgroundColor() => ExampleColors.background;
}
