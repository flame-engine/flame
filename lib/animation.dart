import 'dart:ui';
import 'dart:convert';

import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';

/// Represents a single animation frame.
class Frame {
  /// The [Sprite] to be displayed.
  Sprite sprite;

  /// The duration to display it, in seconds.
  double stepTime;

  /// Create based on the parameters.
  Frame(this.sprite, this.stepTime);
}

/// Represents an animation, that is, a list of sprites that change with time.
class Animation {
  /// The frames that compose this animation.
  List<Frame> frames = [];

  /// Index of the current frame that should be displayed.
  int currentFrame = 0;

  /// Current clock time (total time) of this animation, in seconds, since last frame.
  ///
  /// It's ticked by the update method. It's reset every frame change.
  double clock = 0.0;

  /// Total elapsed time of this animation, in seconds, since start or a reset.
  double elapsed = 0.0;

  /// Whether the animation runs forwards or in reverse. Should respond to mid-animation toggling.
  bool reverse = false;

  /// Whether the animation loops after the last sprite of the list, going back to the first, or keeps returning the last when done.
  bool loop = true;

  /// Pauses the animation.
  bool paused = false;

  /// Creates an animation given a list of frames.
  ///
  /// [reverse]: reverses the animation frames if set to true (default is false)
  /// [loop]: whether the animation loops (defaults to true)
  /// [paused]: returns the animation in a paused state (default is false)
  Animation(
      this.frames,
      {
        this.loop = true,
        this.reverse = false,
        this.paused = false,
      }
  ) {
    currentFrame = reverse ? frames.length - 1 : 0;
  }

  /// Creates an empty animation
  Animation.empty();

  /// Creates an animation given a list of sprites.
  ///
  /// [stepTime]: the duration of each frame, in seconds (defaults to 0.1)
  /// [stepTimes]: list of stepTime values, one for each frame (overrides stepTime if given)
  /// [reverse]: reverses the animation frames if set to true (default is false)
  /// [loop]: whether the animation loops (defaults to true)
  /// [paused]: returns the animation in a paused state (default is false)
  Animation.fromSpriteList(
      List<Sprite> sprites,
      {
        double stepTime = 0.1,
        List<double> stepTimes,
        this.reverse = false,
        this.loop = true,
        this.paused = false,
      }
  ) {
    if (sprites.isEmpty) {
      throw Exception('You must have at least one frame!');
    }
    frames = List<Frame>(sprites.length);
    for (var i = 0; i < frames.length; i++) {
      frames[i] = Frame(sprites[i], stepTimes == null ? stepTime : stepTimes[i] ?? stepTime);
    }
    currentFrame = reverse ? frames.length - 1 : 0;
  }

  /// Creates an animation from a sprite sheet.
  ///
  /// From a single image source, it creates multiple sprites based on the parameters:
  /// [frameX]: x position in the image to start slicing from (defaults to 0)
  /// [frameY]: x position in the image to start slicing from (defaults to 0)
  /// [frameWidth]: width of each frame (defaults to null, that is, full width of the sprite sheet)
  /// [frameHeight]: height of each frame (defaults to null, that is, full height of the sprite sheet)
  /// [firstFrame]: which frame in the sprite sheet starts this animation (zero based, defaults to 0)
  /// [frameCount]: how many sprites this animation is composed of (defaults to 1)
  /// [stepTime]: the duration of each frame, in seconds (defaults to 0.1)
  /// [stepTimes]: list of stepTime values, one for each frame (overrides stepTime if given)
  /// [reverse]: reverses the animation frames if set to true (defaults to false)
  /// [loop]: whether the animation loops (defaults to true)
  /// [paused]: returns the animation in a paused state (defaults to false)
  ///
  /// For example, if you have a 320x320 sprite sheet filled with 32x32 frames (10x10 columns/rows),
  /// this will grab 8 frames of animation from the start of the third row:
  ///     Animation.fromImage(image, frameWidth: 32, frameHeight: 32, firstFrame: 20, frameCount: 8);
  /// Alternatively, so will this:
  ///     Animation.fromImage(image, frameY: 32 * 2, frameWidth: 32, frameHeight: 32, firstFrame: 0, frameCount: 8);
  /// The slicer auto-wraps when X is out of bounds, so even this will grab the same as above:
  ///     Animation.fromImage(image, frameX: 32 * 20, frameWidth: 32, frameHeight: 32, frameCount: 8);
  Animation.fromImage(
      Image image,
      {
        int frameX = 0,
        int frameY = 0,
        int frameWidth,
        int frameHeight,
        int firstFrame = 0,
        int frameCount = 1,
        double stepTime = 0.1,
        List<double> stepTimes,
        this.reverse = false,
        this.loop = true,
        this.paused = false,
      }
  ) {
    int x = frameX, y = frameY;
    x += firstFrame * frameWidth; // Exceeding image.width handled later.
    Sprite sprite;
    frames = List<Frame>(frameCount);
    for (var i = 0; i < frameCount; i++) {
      // Wrap extreme X values to the next row(s).
      // This avoids two things:
      //   1) column/row counting and props; and
      //   2) needing to calc frameY in a large sheet (if using just frameX and not firstFrame).
      if (x >= image.width) {
        y += (x ~/ image.width) * frameHeight;
        x = x % image.width;
      }
      sprite = Sprite.fromImage(
        image,
        x:      x,
        y:      y,
        width:  frameWidth,
        height: frameHeight,
      );
      frames[i] = Frame(sprite, stepTimes == null ? stepTime : stepTimes[i] ?? stepTime);
      x += frameWidth;
    }
    currentFrame = reverse ? frames.length - 1 : 0;
  }

  /// Shortcut wrapper to [fromImage] for skipping a discrete Image get.
  Animation.fromImageCache(
      String fileName,
      {
        int frameX = 0,
        int frameY = 0,
        int frameWidth,
        int frameHeight,
        int firstFrame = 0,
        int frameCount = 1,
        double stepTime = 0.1,
        List<double> stepTimes,
        bool reverse = false,
        bool loop = true,
        bool paused = false,
      }
  ) : this.fromImage(
      Flame.images.fromCache(fileName),
      frameX:      frameX,
      frameY:      frameY,
      frameWidth:  frameWidth,
      frameHeight: frameHeight,
      firstFrame:  firstFrame,
      frameCount:  frameCount,
      stepTime:    stepTime,
      stepTimes:   stepTimes,
      reverse:     reverse,
      loop:        loop,
      paused:      paused,
  );

  /// Asynchronous wrapper to [fromImage] for files (cached or not).
  static Future<Animation> fromFile(
      String fileName,
      {
        int frameX = 0,
        int frameY = 0,
        int frameWidth,
        int frameHeight,
        int firstFrame = 0,
        int frameCount = 1,
        double stepTime = 0.1,
        List<double> stepTimes,
        bool reverse = false,
        bool loop = true,
        bool paused = false,
      }
  ) async {
    final Image image = await Flame.images.load(fileName);
    return Animation.fromImage(
      image,
      frameX:      frameX,
      frameY:      frameY,
      frameWidth:  frameWidth,
      frameHeight: frameHeight,
      firstFrame:  firstFrame,
      frameCount:  frameCount,
      stepTime:    stepTime,
      stepTimes:   stepTimes,
      reverse:     reverse,
      loop:        loop,
      paused:      paused,
    );
  }

  /// Creates an Animation using animation data provided by the json file
  /// provided by Aseprite.
  ///
  /// [imagePath]: Source of the sprite sheet animation
  /// [dataPath]: Animation's exported data in json format
  static Future<Animation> fromAsepriteData(
      String imagePath,
      String dataPath,
      {
        bool reverse = false,
        bool loop = true,
        bool paused = false,
      }
  ) async {
    final Image image = await Flame.images.load(imagePath);
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

      final Sprite sprite = Sprite.fromImage(
        image,
        x:      x,
        y:      y,
        width:  width,
        height: height,
      );

      return Frame(sprite, stepTime);
    });

    return Animation(frames.toList(), reverse: reverse, loop: loop, paused: paused);
  }

  /// Returns whether the animation is on the last frame.
  bool get isLastFrame => currentFrame == frames.length - 1;
  /// Returns whether the animation is on the first frame.
  bool get isFirstFrame => currentFrame == 0;

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

  /// Advances the animation one frame, looping if allowed, obeys reverse if set.
  void advance() {
    if (reverse) {
      if (!isFirstFrame) {
        currentFrame--;
      } else if (loop) {
        currentFrame = frames.length - 1;
      }
    } else {
      if (!isLastFrame) {
        currentFrame++;
      } else if (loop) {
        currentFrame = 0;
      }
    }
  }

  /// Pause the animation.
  void pause() {
    paused = true;
  }

  /// Resume the animation.
  void resume() {
    paused = false;
  }

  /// Resets the animation, like it had just been created.
  void reset() {
    clock = 0.0;
    elapsed = 0.0;
    currentFrame = reverse ? frames.length - 1 : 0;
  }

  /// Gets the current [Sprite] that should be shown.
  Sprite getCurrentSprite() {
    return frames[currentFrame].sprite;
  }

  /// If [loop] is false, returns whether the animation is finished (fixed at the last Sprite).
  ///
  /// Always returns false otherwise.
  bool done() {
    return loop ? false : ((reverse && isFirstFrame) || (!reverse && isLastFrame)) && (clock >= frames.last.stepTime);
  }

  /// Updates this animation, ticking the lifeTime by an amount [dt] (in seconds).
  void update(double dt) {
    if (paused) {
      // Exit before any time vars increment.
      return;
    }
    clock += dt;
    elapsed += dt;
    if (isSingleFrame) {
      return;
    }
    if (!loop && isLastFrame) {
      return;
    }
    while (clock > frames[currentFrame].stepTime) {
      if (loop || (reverse && !isFirstFrame) || (!reverse && !isLastFrame)) {
        clock -= frames[currentFrame].stepTime;
        advance();
      } else {
        break;
      }
    }
  }

  /// Returns a new Animation based on this animation, but with its frames in reversed order
  ///
  /// Deprecating: not a fan of surprising deep-copy functions. If wanting this,
  /// implement a copy function and then reverse it (or with an option to reverse).
  //Animation reversed() {
  //  return Animation(frames, reverse: true, loop: loop, paused: paused);
  //}

  /// Whether all sprites composing this animation are loaded.
  bool loaded() {
    return frames.every((frame) => frame.sprite.loaded());
  }

  /// Computes the total duration of this animation (before it's done or repeats).
  double totalDuration() {
    return frames.map((f) => f.stepTime).reduce((a, b) => a + b);
  }
}
