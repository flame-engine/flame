import 'dart:math';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';

import '../anchor.dart';
import '../effects/effects.dart';
import '../position.dart';
import '../sprite.dart';
import '../text_config.dart';

/// This represents a Component for your game.
///
/// Components can be bullets flying on the screen, a spaceship or your player's fighter.
/// Anything that either renders or updates can be added to the list on [BaseGame]. It will deal with calling those methods for you.
/// Components also have other methods that can help you out if you want to overwrite them.
abstract class Component {
  /// This method is called periodically by the game engine to request that your component updates itself.
  ///
  /// The time [t] in seconds (with microseconds precision provided by Flutter) since the last update cycle.
  /// This time can vary according to hardware capacity, so make sure to update your state considering this.
  /// All components on [BaseGame] are always updated by the same amount. The time each one takes to update adds up to the next update cycle.
  void update(double t);

  /// Renders this component on the provided Canvas [c].
  void render(Canvas c);

  /// This is a hook called by [BaseGame] to let this component know that the screen (or flame draw area) has been update.
  ///
  /// It receives the new size.
  /// You can use the [Resizable] mixin if you want an implementation of this hook that keeps track of the current size.
  void resize(Size size) {}

  /// Whether this component has been loaded yet. If not loaded, [BaseGame] will not try to render it.
  ///
  /// Sprite based components can use this to let [BaseGame] know not to try to render when the [Sprite] has not been loaded yet.
  /// Note that for a more consistent experience, you can pre-load all your assets beforehand with Flame.images.loadAll.
  bool loaded() => true;

  /// Whether this should be destroyed or not.
  ///
  /// It will be called once per component per loop, and if it returns true, [BaseGame] will mark your component for deletion and remove it before the next loop.
  bool destroy() => false;

  /// Whether this component is HUD object or not.
  ///
  /// HUD objects ignore the [BaseGame.camera] when rendered (so their position coordinates are considered relative to the device screen).
  bool isHud() => false;

  /// Render priority of this component. This allows you to control the order in which your components are rendered.
  ///
  /// Components are always updated and rendered in the order defined by this number.
  /// The smaller the priority, the sooner your component will be updated/rendered.
  /// It can be any integer (negative, zero, or positive).
  /// If two components share the same priority, they will probably be drawn in the order they were added.
  int priority() => 0;

  /// Called when the component has been added and preperad by the game instance.
  ///
  /// This can be used to make initializations on your component as, when this method is called,
  /// things like resize (and other mixins) are already set and usable.
  void onMount() {}

  /// Called right before the component is destroyed and removed from the game
  void onDestroy() {}
}

/// A [Component] implementation that represents a component that has a specific, possibly dynamic position on the screen.
///
/// It represents a rectangle of dimension ([width], [height]), on the position ([x], [y]), rotate around its center with angle [angle].
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

/// A [PositionComponent] that renders a single [Sprite] at the designated position, scaled to have the designated size and rotated to the designated angle.
///
/// This is the most commonly used child of [Component].
class SpriteComponent extends PositionComponent {
  Sprite sprite;
  Paint overridePaint;

  SpriteComponent();

  SpriteComponent.square(double size, String imagePath)
      : this.rectangle(size, size, imagePath);

  SpriteComponent.rectangle(double width, double height, String imagePath)
      : this.fromSprite(width, height, Sprite(imagePath));

  SpriteComponent.fromSprite(double width, double height, this.sprite) {
    this.width = width;
    this.height = height;
  }

  @override
  void render(Canvas canvas) {
    prepareCanvas(canvas);
    sprite.render(canvas,
        width: width, height: height, overridePaint: overridePaint);
  }

  @override
  bool loaded() {
    return sprite != null && sprite.loaded() && x != null && y != null;
  }
}
