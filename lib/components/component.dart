import 'dart:math';
import 'dart:ui';

import '../sprite.dart';
import '../position.dart';
import 'package:flutter/painting.dart';

/// This represents a Component for your game.
///
/// Components can be bullets flying on the screen, a spaship or your player's fighter.
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

  /// Wether this component has been loaded yet. If not loaded, [BaseGame] will not try to render it.
  ///
  /// Sprite based components can use this to let [BaseGame] know not to try to render when the [Sprite] has not been loaded yet.
  /// Note that for a more consistent experience, you can pre-load all your assets beforehand with [Flame.images.loadAll].
  bool loaded() => true;

  /// Wether this should be destroyed or not.
  ///
  /// It will be called once per component per loop, and if it returns true, [BaseGame] will mark your component for deletion and remove it before the next loop.
  bool destroy() => false;

  /// Wether this component is HUD object or not.
  ///
  /// HUD objects ignore the [BaseGame.camera] when rendered (so their position coordinates are considered relative to the device screen).
  bool isHud() => false;
}

/// A [Component] implementation that represents a component that has a specific, possibly mutatable position on the screen.
///
/// It represents a rectangle of dimension ([width], [height]), on the position ([x], [y]), rotate around its center with angle [angle].
abstract class PositionComponent extends Component {
  double x = 0.0, y = 0.0, angle = 0.0;
  double width = 0.0, height = 0.0;

  Position toPosition() => new Position(x, y);
  void setByPosition(Position position) {
    this.x = position.x;
    this.y = position.y;
  }

  Position toSize() => new Position(width, height);
  void setBySize(Position size) {
    this.width = size.x;
    this.height = size.y;
  }

  Rect toRect() => new Rect.fromLTWH(x, y, width, height);
  void setByRect(Rect rect) {
    this.x = rect.left;
    this.y = rect.top;
    this.width = rect.width;
    this.height = rect.height;
  }

  double angleBetween(PositionComponent c) {
    return (atan2(c.x - this.x, this.y - c.y) - pi / 2) % (2 * pi);
  }

  double distance(PositionComponent c) {
    return sqrt(pow(this.y - c.y, 2) + pow(this.x - c.x, 2));
  }

  void prepareCanvas(Canvas canvas) {
    canvas.translate(x, y);

    // rotate around center
    canvas.translate(width / 2, height / 2);
    canvas.rotate(angle);
    canvas.translate(-width / 2, -height / 2);
  }
}

class SpriteComponent extends PositionComponent {
  Sprite sprite;

  final Paint paint = new Paint()..color = new Color(0xffffffff);

  SpriteComponent();

  SpriteComponent.square(double size, String imagePath)
      : this.rectangle(size, size, imagePath);

  SpriteComponent.rectangle(double width, double height, String imagePath)
      : this.fromSprite(width, height, new Sprite(imagePath));

  SpriteComponent.fromSprite(double width, double height, this.sprite) {
    this.width = width;
    this.height = height;
  }

  @override
  render(Canvas canvas) {
    if (sprite != null && sprite.loaded() && x != null && y != null) {
      prepareCanvas(canvas);
      sprite.render(canvas, width, height);
    }
  }

  @override
  bool loaded() {
    return this.sprite.loaded();
  }

  @override
  void update(double t) {}
}
