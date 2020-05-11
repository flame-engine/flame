import 'dart:math';
import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:ordered_set/comparing.dart';
import 'package:ordered_set/ordered_set.dart';

import '../anchor.dart';
import '../effects/effects.dart';
import '../game.dart';
import '../game/game.dart';
import '../position.dart';
import '../text_config.dart';
import 'component.dart';

/// A [Component] implementation that represents a component that has a specific, possibly dynamic position on the screen.
///
/// It represents a rectangle of dimension ([width], [height]), on the position ([x], [y]), rotate around its center with angle [angle].
/// It also uses the [anchor] property to properly position itself.
abstract class PositionComponent extends Component {
  /// X position of this component on the screen (measured from the top left corner).
  double x = 0.0;

  /// Y position of this component on the screen (measured from the top left corner).
  double y = 0.0;

  /// Angle (with respect to the x-axis) this component should be rendered with.
  /// It is rotated around its anchor.
  double angle = 0.0;

  /// Width (size) that this component is rendered with.
  /// This is not necessarily the source width of the asset.
  double width = 0.0;

  /// Height (size) that this component is rendered with.
  /// This is not necessarily the source height of the asset.
  double height = 0.0;

  /// Anchor point for this component. This is where flame "grabs it".
  /// The [x], [y] coordinates are relative to this point inside the component.
  /// The [angle] is rotated around this point.
  Anchor anchor = Anchor.topLeft;

  /// Wether this component should be flipped on the X axis before being rendered.
  bool renderFlipX = false;

  /// Wether this component should be flipped ofn the Y axis before being rendered.
  bool renderFlipY = false;

  /// This is set by the BaseGame to tell this component to render additional debug information,
  /// like borders, coordinates, etc.
  /// This is very helpful while debbuging. Set your BaseGame debugMode to true.
  bool debugMode = false;

  final List<PositionComponentEffect> _effects = [];
  final OrderedSet<Component> _children =
      OrderedSet(Comparing.on((c) => c.priority()));

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
      Position(-50, -15),
    );

    final Rect rect = toRect();
    final dx = rect.right;
    final dy = rect.bottom;
    debugTextConfig.render(
      canvas,
      "x:${dx.toStringAsFixed(2)} y:${dy.toStringAsFixed(2)}",
      Position(width - 50, height),
    );
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
    _effects.add(effect..component = this);
  }

  void propagateToChildren<T extends PositionComponent>(
      void Function(T, Rect) handler) {
    final rect = toRect();
    if (this is T) {
      handler(this as T, rect);
    }
    _children.forEach((c) {
      if (c is PositionComponent) {
        final newRect = c.toRect().translate(rect.left, rect.top);
        if (c is T) {
          handler(this as T, newRect);
        }
        c.propagateToChildren(handler);
      }
    });
  }

  @mustCallSuper
  @override
  void resize(Size size) {
    super.resize(size);
    _children.forEach((child) => child.resize(size));
  }

  @mustCallSuper
  @override
  void render(Canvas canvas) {
    prepareCanvas(canvas);
    canvas.save();
    _children.forEach((comp) => _renderChild(canvas, comp));
    canvas.restore();
  }

  void _renderChild(Canvas canvas, Component c) {
    if (!c.loaded()) {
      return;
    }
    c.render(canvas);
    canvas.restore();
    canvas.save();
  }

  void addChild(Game gameRef, Component c) {
    if (gameRef is BaseGame) {
      gameRef.preAdd(c);
    }
    _children.add(c);
  }

  @mustCallSuper
  @override
  void update(double dt) {
    _effects.forEach((e) => e.update(dt));
    _effects.removeWhere((e) => e.hasFinished());
  }
}
