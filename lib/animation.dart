import 'dart:math' as math;
import 'sprite.dart';

/// Represents an animation, that is, a list of sprites that change with time.
class Animation {

  /// The sprites that compose this animation.
  List<Sprite> sprites;

  /// Time that it takes to go to the next sprite on the list, in seconds.
  double stepTime = 0.1;

  /// Current life time (total time) of this animation.
  ///
  /// It's ticked by the update method.
  double lifeTime = 0.0;

  /// Wether the animation loops after the last sprite of the list, going back to the first, or keeps returning the last when done.
  bool loop = true;

  /// Creates an empty animation
  Animation() {
    this.sprites = [];
  }

  /// Creates an animation based on the parameters
  Animation.spriteList(this.sprites, {this.stepTime, this.lifeTime, this.loop});

  /// Automatically creates a sequenced animation, that is, an animation based on a sprite sheet.
  ///
  /// From a single image source, it creates multiple sprites based on the parameters:
  /// [amount]: how many sprites this animation is composed of
  /// [textureX]: x position on the original image to start (defaults to 0)
  /// [textureY]: y position on the original image to start (defaults to 0)
  /// [textureWidth]: width of each frame (defaults to null, that is, full width of the sprite sheet)
  /// [textureHeight]: height of each frame (defaults to null, that is, full height of the sprite sheet)
  ///
  /// For example, if you have a spritesheet where each row is an animation, and each frame is 32x32
  ///     new Animation.sequenced('sheet.png', 8, textureY: 32.0 * i, textureWidth: 32.0, textureHeight: 32.0);
  /// This will create the i-th animation on the 'sheet.png', given it has 8 frames.
  Animation.sequenced(
    String imagePath,
    int amount, {
    double textureX = 0.0,
    double textureY = 0.0,
    double textureWidth = null,
    double textureHeight = null,
  }) {
    this.sprites = new List<Sprite>(amount);
    for (var i = 0; i < amount; i++) {
      this.sprites[i] = new Sprite(
        imagePath,
        x: textureX + i * textureWidth,
        y: textureY,
        width: textureWidth,
        height: textureHeight,
      );
    }
  }

  /// Current step of the animation, that is, which frame should be shown (ignoring boundary conditions)
  int get currentStep => (lifeTime / stepTime).round();

  /// Gets tha current [Sprite] that should be shown, given the [currentStep] and the boundary conditions.
  ///
  /// In case [currentStep] is greater than the sprites length:
  ///  * If [loop] is true, it will return the last sprite. Otherwise, it will go back to the first.
  Sprite getSprite() {
    int i = currentStep;
    return sprites[loop ? i % sprites.length : math.min(i, sprites.length - 1)];
  }

  /// If [loop] is false, returns wether the animation is done (fixed in the last Sprite).
  ///
  /// Always returns false otherwise.
  bool done() {
    return loop ? false : currentStep >= sprites.length;
  }

  /// Updates this animation, ticking the lifeTime by an amount [dt] (in seconds).
  void update(double dt) {
    this.lifeTime += dt;
  }

  /// Wether all sprites composing this animation are loaded.
  bool loaded() {
    return !sprites.any((sprite) => !sprite.loaded());
  }
}
