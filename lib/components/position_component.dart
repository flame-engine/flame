import 'dart:ui' hide Offset;

import 'package:meta/meta.dart';
import 'package:ordered_set/comparing.dart';
import 'package:ordered_set/ordered_set.dart';

import '../anchor.dart';
import '../effects/effects.dart';
import '../game.dart';
import '../text_config.dart';
import '../extensions/offset.dart';
import '../extensions/vector2.dart';
import 'component.dart';

/// A [Component] implementation that represents a component that has a
/// specific, possibly dynamic position on the screen.
///
/// It represents a rectangle of dimension [size], on the [position],
/// rotated around its [anchor] with angle [angle].
///
/// It also uses the [anchor] property to properly position itself.
///
/// A [PositionComponent] can have children. The children are all updated and
/// rendered automatically when this is updated and rendered.
/// They are translated by this component's (x,y). They do not need to fit
/// within this component's (width, height).
abstract class PositionComponent extends Component {
  /// The position of this component on the screen (relative to the anchor).
  Vector2 position = Vector2.zero();

  /// X position of this component on the screen (relative to the anchor).
  double get x => position.x;
  set x(double x) => position.x = x;

  /// Y position of this component on the screen (relative to the anchor).
  double get y => position.y;
  set y(double y) => position.y = y;

  /// The size that this component is rendered with.
  /// This is not necessarily the source size of the asset.
  Vector2 size = Vector2.zero();

  /// Width (size) that this component is rendered with.
  double get width => size.x;
  set width(double width) => size.x = width;

  /// Height (size) that this component is rendered with.
  double get height => size.y;
  set height(double height) => size.y = height;

  /// Get the top left position regardless of the anchor
  Vector2 get topLeftPosition => anchor.translate(position, size);

  /// Set the top left position regardless of the anchor
  set topLeftPosition(Vector2 position) {
    this.position =
        position + (anchor.relativePosition..multiply(size));
  }

  /// Angle (with respect to the x-axis) this component should be rendered with.
  /// It is rotated around its anchor.
  double angle = 0.0;

  /// Anchor point for this component. This is where flame "grabs it".
  /// The [position] is relative to this point inside the component.
  /// The [angle] is rotated around this point.
  Anchor anchor = Anchor.topLeft;

  /// Whether this component should be flipped on the X axis before being rendered.
  bool renderFlipX = false;

  /// Whether this component should be flipped ofn the Y axis before being rendered.
  bool renderFlipY = false;

  /// This is set by the BaseGame to tell this component to render additional debug information,
  /// like borders, coordinates, etc.
  /// This is very helpful while debbuging. Set your BaseGame debugMode to true.
  /// You can also manually override this for certain components in order to identify issues.
  bool debugMode = false;

  final List<PositionComponentEffect> _effects = [];
  final OrderedSet<Component> _children =
      OrderedSet(Comparing.on((c) => c.priority()));

  Color get debugColor => const Color(0xFFFF00FF);

  Paint get _debugPaint => Paint()
    ..color = debugColor
    ..style = PaintingStyle.stroke;

  TextConfig get debugTextConfig => TextConfig(color: debugColor, fontSize: 12);

  /// Returns the relative position/size of this component.
  /// Relative because it might be translated by their parents (which is not considered here).
  Rect toRect() => topLeftPosition.toPositionedRect(size);

  /// Mutates position and size using the provided [rect] as basis.
  /// This is a relative rect, same definition that [toRect] use (therefore both methods are compatible, i.e. setByRect ∘ toRect = identity).
  void setByRect(Rect rect) {
    size.setValues(rect.width, rect.height);
    topLeftPosition = rect.topLeft.toVector2();
  }

  double angleTo(PositionComponent c) => position.angleTo(c.position);

  double distance(PositionComponent c) => position.distanceTo(c.position);

  void renderDebugMode(Canvas canvas) {
    canvas.drawRect(size.toRect(), _debugPaint);
    debugTextConfig.render(
      canvas,
      'x: ${x.toStringAsFixed(2)} y:${y.toStringAsFixed(2)}',
      Vector2(-50, -15),
    );

    final Rect rect = toRect();
    final dx = rect.right;
    final dy = rect.bottom;
    debugTextConfig.render(
      canvas,
      'x:${dx.toStringAsFixed(2)} y:${dy.toStringAsFixed(2)}',
      Vector2(width - 50, height),
    );
  }

  void _prepareCanvas(Canvas canvas) {
    canvas.translate(x, y);

    canvas.rotate(angle);
    final Vector2 delta = -anchor.relativePosition..multiply(size);
    canvas.translate(delta.x, delta.y);

    // Handle inverted rendering by moving center and flipping.
    if (renderFlipX || renderFlipY) {
      canvas.translate(width / 2, height / 2);
      canvas.scale(renderFlipX ? -1.0 : 1.0, renderFlipY ? -1.0 : 1.0);
      canvas.translate(-width / 2, -height / 2);
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

  /// This function recursively propagates an action to every children and grandchildren (and so on) of this component,
  /// by keeping track of their positions by composing the positions of their parents.
  /// For example, if this has a child that itself has a child, this will invoke handler for this (with no translation),
  /// for the first child translating by this, and for the grand child by translating both this and the first child.
  /// This is important to be used by the engine to propagate actions like rendering, taps, etc, but you can call it
  /// yourself if you need to apply an action to the whole component chain.
  /// It will only consider components of type T in the hierarchy, so use T = PositionComponent to target everything.
  void propagateToChildren<T extends PositionComponent>(
    void Function(T, Rect) handler,
  ) {
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
  void resize(Vector2 size) {
    super.resize(size);
    _children.forEach((child) => child.resize(size));
  }

  @mustCallSuper
  @override
  void render(Canvas canvas) {
    _prepareCanvas(canvas);

    if (debugMode) {
      renderDebugMode(canvas);
    }

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

  bool removeChild(PositionComponent c) {
    return _children.remove(c);
  }

  Iterable<PositionComponent> removeChildren(
    bool Function(PositionComponent) test,
  ) {
    return _children.removeWhere(test);
  }

  void clearChildren() {
    _children.clear();
  }
}
