import 'dart:convert';

import 'flame.dart';
import 'sprite.dart';

/// Represents a single animation frame.
class Frame {
  /// The [Sprite] to be displayed.
  Sprite sprite;

  /// The duration to display it, in seconds.
  double stepTime;

  /// Create based on the parameters.
  Frame(this.sprite, this.stepTime);
}

typedef OnCompleteAnimation = void Function();

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

  /// Total elapsed time of this animation, in seconds, since start or a reset.
  double elapsed = 0.0;

  /// Whether the animation loops after the last sprite of the list, going back to the first, or keeps returning the last when done.
  bool loop = true;

  /// Registered method to be triggered when the animation complete.
  OnCompleteAnimation onCompleteAnimation;

  /// Creates an animation given a list of frames.
  Animation(this.frames, {this.loop = true});

  /// Creates an empty animation
  Animation.empty();

  /// Creates an animation based on the parameters.
  ///
  /// All frames have the same [stepTime].
  Animation.spriteList(List<Sprite> sprites,
      {double stepTime, this.loop = true}) {
    if (sprites.isEmpty) {
      throw Exception('You must have at least one frame!');
    }
    frames = sprites.map((s) => Frame(s, stepTime)).toList();
  }

  /// Automatically creates a sequenced animation, that is, an animation based on a sprite sheet.
  ///
  /// From a single image source, it creates multiple sprites based on the parameters:
  /// [amount]: how many sprites this animation is composed of
  /// [amountPerRow]: If the sprites used to create an animation are not on the same row,
  ///     you can use this parameter to specify how many sprites per row.
  ///     For detailed, please refer to example at "/doc/examples/animations".
  /// [textureX]: x position on the original image to start (defaults to 0)
  /// [textureY]: y position on the original image to start (defaults to 0)
  /// [textureWidth]: width of each frame (defaults to null, that is, full width of the sprite sheet)
  /// [textureHeight]: height of each frame (defaults to null, that is, full height of the sprite sheet)
  ///
  /// For example, if you have a sprite sheet where each row is an animation, and each frame is 32x32
  ///     Animation.sequenced('sheet.png', 8, textureY: 32.0 * i, textureWidth: 32.0, textureHeight: 32.0);
  /// This will create the i-th animation on the 'sheet.png', given it has 8 frames.
  Animation.sequenced(
    String imagePath,
    int amount, {
    int amountPerRow,
    double textureX = 0.0,
    double textureY = 0.0,
    double textureWidth,
    double textureHeight,
    double stepTime = 0.1,
    this.loop = true,
  }) : assert(amountPerRow == null || amount >= amountPerRow) {
    amountPerRow ??= amount;
    frames = List<Frame>.filled(amount, null);
    for (var i = 0; i < amount; i++) {
      final Sprite sprite = Sprite(
        imagePath,
        x: textureX + (i % amountPerRow) * textureWidth,
        y: textureY + (i ~/ amountPerRow) * textureHeight,
        width: textureWidth,
        height: textureHeight,
      );
      frames[i] = Frame(sprite, stepTime);
    }
  }

  /// Works just like [Animation.sequenced], but it takes a list of variable [stepTimes], associating each one with one frame in the sequence.
  Animation.variableSequenced(
    String imagePath,
    int amount,
    List<double> stepTimes, {
    int amountPerRow,
    double textureX = 0.0,
    double textureY = 0.0,
    double textureWidth,
    double textureHeight,
    this.loop = true,
  }) : assert(amountPerRow == null || amount >= amountPerRow) {
    amountPerRow ??= amount;
    frames = List<Frame>.filled(amount, null);
    for (var i = 0; i < amount; i++) {
      final Sprite sprite = Sprite(
        imagePath,
        x: textureX + (i % amountPerRow) * textureWidth,
        y: textureY + (i ~/ amountPerRow) * textureHeight,
        width: textureWidth,
        height: textureHeight,
      );
      frames[i] = Frame(sprite, stepTimes[i]);
    }
  }

  /// Automatically creates an Animation Object using animation data provided by the json file
  /// provided by Aseprite
  ///
  /// [imagePath]: Source of the sprite sheet animation
  /// [dataPath]: Animation's exported data in json format
  static Future<Animation> fromAsepriteData(
      String imagePath, String dataPath) async {
    final String content = await Flame.assets.readFile(dataPath);
    final Map<String, dynamic> json = jsonDecode(content);

    final Map<String, dynamic> jsonFrames = json['frames'];

    final frames = jsonFrames.values.map((value) {
      final frameData = value['frame'];
      final int x = frameData['x'];
      final int y = frameData['y'];
      final int width = frameData['w'];
      final int height = frameData['h'];

      final stepTime = value['duration'] / 1000;

      final Sprite sprite = Sprite(
        imagePath,
        x: x.toDouble(),
        y: y.toDouble(),
        width: width.toDouble(),
        height: height.toDouble(),
      );

      return Frame(sprite, stepTime);
    });

    return Animation(frames.toList(), loop: true);
  }

  /// The current frame that should be displayed.
  Frame get currentFrame => frames[currentIndex];

  /// Returns whether the animation is on the last frame.
  bool get isLastFrame => currentIndex == frames.length - 1;

  /// Returns whether the animation has only a single frame (and is, thus, a still image).
  bool get isSingleFrame => frames.length == 1;

  /// Sets a different step time to each frame. The sizes of the arrays must match.
  set variableStepTimes(List<double> stepTimes) {
    assert(stepTimes.length == frames.length);
    for (int i = 0; i < frames.length; i++) {
      frames[i].stepTime = stepTimes[i];
    }
  }

  /// Sets a fixed step time to all frames.
  set stepTime(double stepTime) {
    frames.forEach((frame) => frame.stepTime = stepTime);
  }

  /// Resets the animation, like it would just have been created.
  void reset() {
    clock = 0.0;
    elapsed = 0.0;
    currentIndex = 0;
  }

  /// Gets the current [Sprite] that should be shown.
  ///
  /// In case it reaches the end:
  ///  * If [loop] is true, it will return the last sprite. Otherwise, it will go back to the first.
  Sprite getSprite() {
    return currentFrame.sprite;
  }

  /// If [loop] is false, returns whether the animation is done (fixed in the last Sprite).
  ///
  /// Always returns false otherwise.
  bool done() {
    return loop ? false : (isLastFrame && clock >= currentFrame.stepTime);
  }

  /// Updates this animation, ticking the lifeTime by an amount [dt] (in seconds).
  void update(double dt) {
    clock += dt;
    elapsed += dt;
    if (isSingleFrame) {
      return;
    }
    if (!loop && isLastFrame) {
      onCompleteAnimation?.call();
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

  /// Returns a new Animation based on this animation, but with its frames in reversed order
  Animation reversed() {
    return Animation(frames.reversed.toList(), loop: loop);
  }

  /// Whether all sprites composing this animation are loaded.
  bool loaded() {
    return frames.every((frame) => frame.sprite.loaded());
  }

  /// Computes the total duration of this animation (before it's done or repeats).
  double totalDuration() {
    return frames.map((f) => f.stepTime).reduce((a, b) => a + b);
  }
}
