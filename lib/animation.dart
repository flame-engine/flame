import 'sprite.dart';

/// Represents a single animation frame
class Frame {
  /// The [Sprite] to be displayed
  Sprite sprite;

  /// The duration to display it, in seconds
  double stepTime;

  /// Create based on the parameters
  Frame(this.sprite, this.stepTime);
}

/// Represents an animation, that is, a list of sprites that change with time.
class Animation {
  /// The frames that compose this animation.
  List<Frame> frames = [];

  /// Index of the current frame that should be displayed.
  int currentIndex = 0;

  /// Current clock time (total time) of this animation, in seconds, since last frame.
  ///
  /// It's ticked by the update method. It's reset every frame change.
  double clock = 0.0;

  /// Wether the animation loops after the last sprite of the list, going back to the first, or keeps returning the last when done.
  bool loop = true;

  /// Creates an empty animation
  Animation.empty();

  /// Creates an animation based on the parameters.
  ///
  /// All frames have the same [stepTime].
  Animation.spriteList(List<Sprite> sprites, {double stepTime, this.loop}) {
    this.frames = sprites.map((s) => new Frame(s, stepTime)).toList();
  }

  /// Creates an animation given a list of frames.
  Animation(this.frames, {this.loop});

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
    double stepTime = 0.1,
  }) {
    this.frames = new List<Frame>(amount);
    for (var i = 0; i < amount; i++) {
      Sprite sprite = new Sprite(
        imagePath,
        x: textureX + i * textureWidth,
        y: textureY,
        width: textureWidth,
        height: textureHeight,
      );
      this.frames[i] = new Frame(sprite, stepTime);
    }
  }

  /// Works just like [Animation.sequenced], but it takes a list of variable [stepTimes], associating each one with one frame in the sequence.
  Animation.variableSequenced(
    String imagePath,
    int amount,
    List<double> stepTimes, {
    double textureX = 0.0,
    double textureY = 0.0,
    double textureWidth = null,
    double textureHeight = null,
  }) {
    this.frames = new List<Frame>(amount);
    for (var i = 0; i < amount; i++) {
      Sprite sprite = new Sprite(
        imagePath,
        x: textureX + i * textureWidth,
        y: textureY,
        width: textureWidth,
        height: textureHeight,
      );
      this.frames[i] = new Frame(sprite, stepTimes[i]);
    }
  }

  /// The current frame that should be displayed.
  Frame get currentFrame => frames[currentIndex];

  /// Returns whether the animation is on the last frame.
  bool get isLastFrame => currentIndex == frames.length - 1;

  /// Sets a different step time to each frame. The sizes of the arrays must match.
  void set variableStepTimes(List<double> stepTimes) {
    assert(stepTimes.length == frames.length);
    for (int i = 0; i < frames.length; i++) {
      frames[i].stepTime = stepTimes[i];
    }
  }

  /// Sets a fixed step time to all frames.
  void set stepTime(double stepTime) {
    this.frames.forEach((frame) => frame.stepTime = stepTime);
  }

  /// Resets the animation, like it'd just been created.
  void reset() {
    this.clock = 0.0;
    this.currentIndex = 0;
  }

  /// Gets tha current [Sprite] that should be shown.
  ///
  /// In case it reaches the end:
  ///  * If [loop] is true, it will return the last sprite. Otherwise, it will go back to the first.
  Sprite getSprite() {
    return currentFrame.sprite;
  }

  /// If [loop] is false, returns wether the animation is done (fixed in the last Sprite).
  ///
  /// Always returns false otherwise.
  bool done() {
    return loop ? false : (isLastFrame && clock >= currentFrame.stepTime);
  }

  /// Updates this animation, ticking the lifeTime by an amount [dt] (in seconds).
  void update(double dt) {
    clock += dt;
    if (!loop && isLastFrame) {
      return;
    }
    while (clock > currentFrame.stepTime) {
      if (!isLastFrame) {
        clock -= currentFrame.stepTime;
        currentIndex++;
      } else if (loop) {
        clock -= currentFrame.stepTime;
        currentIndex = 0;
      } else {
        break;
      }
    }
  }

  /// Wether all sprites composing this animation are loaded.
  bool loaded() {
    return frames.every((frame) => frame.sprite.loaded());
  }

  /// Computes the total duration of this animation (before it's done or repeats).
  double totalDuration() {
    return frames.map((f) => f.stepTime).reduce((a, b) => a + b);
  }
}
