import 'dart:ui';
import 'dart:math';

import 'package:meta/meta.dart';

import '../anchor.dart';
import '../effects/effects.dart';
import '../position.dart';
import '../text_config.dart';
import 'component.dart';

/// A [Component] implementation that represents a component that has a
/// specific, possibly dynamic position on the screen.
///
/// It represents a rectangle of dimension ([width], [height]), on the position
/// ([x], [y]), rotate around its center with angle [angle].
///
/// It also uses the [anchor] property to properly position itself.
abstract class PositionComponent extends Component {
  double x = 0.0, y = 0.0, angle = 0.0;
  double width = 0.0, height = 0.0;
  Anchor anchor = Anchor.topLeft;
  bool renderFlipX = false;
  bool renderFlipY = false;
  bool debugMode = false;
  final List<PositionComponentEffect> _effects = [];

  Color get debugColor => const Color(0xFFFF00FF);

  Paint get _debugPaint => Paint()
    ..color = debugColor
    ..style = PaintingStyle.stroke;

  TextConfig get debugTextConfig => TextConfig(color: debugColor, fontSize: 12);

  Position toPosition() => Position(x, y);
  void setByPosition(Position position) {
    x = position.x;
    y = position.y;
  }

  Position toSize() => Position(width, height);
  void setBySize(Position size) {
    width = size.x;
    height = size.y;
  }

  Rect toRect() => Rect.fromLTWH(x - anchor.relativePosition.dx * width,
      y - anchor.relativePosition.dy * height, width, height);
  void setByRect(Rect rect) {
    x = rect.left + anchor.relativePosition.dx * rect.width;
    y = rect.top + anchor.relativePosition.dy * rect.height;
    width = rect.width;
    height = rect.height;
  }

  double angleBetween(PositionComponent c) {
    return (atan2(c.x - x, y - c.y) - pi / 2) % (2 * pi);
  }

  double distance(PositionComponent c) {
    return sqrt(pow(y - c.y, 2) + pow(x - c.x, 2));
  }

  void renderDebugMode(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0.0, 0.0, width, height), _debugPaint);
    debugTextConfig.render(
        canvas,
        "x: ${x.toStringAsFixed(2)} y:${y.toStringAsFixed(2)}",
        Position(-50, -15));

    final Rect rect = toRect();
    final dx = rect.right;
    final dy = rect.bottom;
    debugTextConfig.render(
        canvas,
        "x:${dx.toStringAsFixed(2)} y:${dy.toStringAsFixed(2)}",
        Position(width - 50, height));
  }

  void prepareCanvas(Canvas canvas) {
    canvas.translate(x, y);

    canvas.rotate(angle);
    final double dx = -anchor.relativePosition.dx * width;
    final double dy = -anchor.relativePosition.dy * height;
    canvas.translate(dx, dy);

    // Handle inverted rendering by moving center and flipping.
    if (renderFlipX || renderFlipY) {
      canvas.translate(width / 2, height / 2);
      canvas.scale(renderFlipX ? -1.0 : 1.0, renderFlipY ? -1.0 : 1.0);
      canvas.translate(-width / 2, -height / 2);
    }

    if (debugMode) {
      renderDebugMode(canvas);
    }
  }

  void addEffect(PositionComponentEffect effect) {
    _effects.add(effect..initialize(this));
  }

  void removeEffect(PositionComponentEffect effect) {
    effect.dispose();
  }

  void clearEffects() {
    _effects.forEach(removeEffect);
  }

  @mustCallSuper
  @override
  void update(double dt) {
    _effects.forEach((e) => e.update(dt));
    _effects.removeWhere((e) => e.hasFinished());
  }
}
