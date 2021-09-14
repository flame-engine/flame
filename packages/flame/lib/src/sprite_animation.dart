import 'dart:ui';

import 'assets/images.dart';
import 'extensions/vector2.dart';
import 'flame.dart';
import 'sprite.dart';

export 'sprite.dart';

class SpriteAnimationFrameData {
  /// Coordinates of the sprite of this Frame
  final Vector2 srcPosition;

  /// Size of the sprite of this Frame
  final Vector2 srcSize;

  /// The duration to display it, in seconds.
  final double stepTime;

  SpriteAnimationFrameData({
    required this.srcPosition,
    required this.srcSize,
    required this.stepTime,
  });
}

class SpriteAnimationData {
  late List<SpriteAnimationFrameData> frames;
  final bool loop;

  /// Creates a SpriteAnimationData from the given [frames] and [loop] parameters
  SpriteAnimationData(this.frames, {this.loop = true});

  /// Takes some parameters and automatically calculate and create the frames for the sprite animation data
  ///
  /// [amount] The total amount of frames present on the image
  /// [stepTimes] A list of times (in seconds) of each frame, should have a length equals to the amount parameter
  /// [textureSize] The size of each frame
  /// [amountPerRow] An optional parameter to inform how many frames there are on which row, useful for sprite sheets where the frames as disposed on multiple lines
  /// [texturePosition] An optional parameter with the initial coordinate where the frames begin on the image, default to (top: 0, left: 0)
  /// [loop] An optional parameter to inform if this animation loops or has a single iteration, defaults to true
  SpriteAnimationData.variable({
    required int amount,
    required List<double> stepTimes,
    required Vector2 textureSize,
    int? amountPerRow,
    Vector2? texturePosition,
    this.loop = true,
  }) : assert(amountPerRow == null || amount >= amountPerRow) {
    amountPerRow ??= amount;
    texturePosition ??= Vector2.zero();
    frames = List<SpriteAnimationFrameData>.generate(amount, (i) {
      final position = Vector2(
        texturePosition!.x + (i % amountPerRow!) * textureSize.x,
        texturePosition.y + (i ~/ amountPerRow) * textureSize.y,
      );
      return SpriteAnimationFrameData(
        stepTime: stepTimes[i],
        srcPosition: position,
        srcSize: textureSize,
      );
    });
  }

  /// Works just like [SpriteAnimationData.variable] but uses the same [stepTime] for all frames
  factory SpriteAnimationData.sequenced({
    required int amount,
    required double stepTime,
    required Vector2 textureSize,
    int? amountPerRow,
    Vector2? texturePosition,
    bool loop = true,
  }) {
    return SpriteAnimationData.variable(
      amount: amount,
      amountPerRow: amountPerRow,
      texturePosition: texturePosition,
      textureSize: textureSize,
      loop: loop,
      stepTimes: List.filled(amount, stepTime),
    );
  }
}

/// Represents a single sprite animation frame.
class SpriteAnimationFrame {
  /// The [Sprite] to be displayed.
  Sprite sprite;

  /// The duration to display it, in seconds.
  double stepTime;

  /// Create based on the parameters.
  SpriteAnimationFrame(this.sprite, this.stepTime);
}

typedef OnCompleteSpriteAnimation = void Function();

/// Represents a sprite animation, that is, a list of sprites that change with
/// time.
class SpriteAnimation {
  /// The frames that compose this animation.
  List<SpriteAnimationFrame> frames = [];

  /// Index of the current frame that should be displayed.
  int currentIndex = 0;

  /// Current clock time (total time) of this animation, in seconds, since last
  /// frame.
  ///
  /// It's ticked by the update method. It's reset every frame change.
  double clock = 0.0;

  /// Total elapsed time of this animation, in seconds, since start or a reset.
  double elapsed = 0.0;

  /// Whether the animation loops after the last sprite of the list, going back
  /// to the first, or keeps returning the last when done.
  bool loop = true;

  /// Registered method to be triggered when the animation complete.
  OnCompleteSpriteAnimation? onComplete;

  /// Creates an animation given a list of frames.
  SpriteAnimation(this.frames, {this.loop = true});

  /// Creates an empty animation
  SpriteAnimation.empty();

  /// Creates an animation based on the parameters.
  ///
  /// All frames have the same [stepTime].
  SpriteAnimation.spriteList(
    List<Sprite> sprites, {
    required double stepTime,
    this.loop = true,
  }) {
    if (sprites.isEmpty) {
      throw Exception('You must have at least one frame!');
    }
    frames = sprites.map((s) => SpriteAnimationFrame(s, stepTime)).toList();
  }

  /// Creates an SpriteAnimation based on its [data].
  ///
  /// Check [SpriteAnimationData] constructors for more info.
  SpriteAnimation.fromFrameData(
    Image image,
    SpriteAnimationData data,
  ) {
    frames = data.frames.map((frameData) {
      return SpriteAnimationFrame(
        Sprite(
          image,
          srcSize: frameData.srcSize,
          srcPosition: frameData.srcPosition,
        ),
        frameData.stepTime,
      );
    }).toList();
    loop = data.loop;
  }

  /// Automatically creates an Animation Object using animation data provided by the json file
  /// provided by Aseprite
  ///
  /// [imagePath]: Source of the sprite sheet animation
  /// [dataPath]: Animation's exported data in json format
  SpriteAnimation.fromAsepriteData(
    Image image,
    Map<String, dynamic> jsonData,
  ) {
    final jsonFrames = jsonData['frames'] as Map<String, dynamic>;

    final frames = jsonFrames.values.map((dynamic value) {
      final map = value as Map;
      final frameData = map['frame'] as Map<String, dynamic>;
      final x = frameData['x'] as int;
      final y = frameData['y'] as int;
      final width = frameData['w'] as int;
      final height = frameData['h'] as int;

      final stepTime = (map['duration'] as int) / 1000;

      final sprite = Sprite(
        image,
        srcPosition: Vector2Extension.fromInts(x, y),
        srcSize: Vector2Extension.fromInts(width, height),
      );

      return SpriteAnimationFrame(sprite, stepTime);
    });

    this.frames = frames.toList();
    loop = true;
  }

  /// Takes a path of an image, a [SpriteAnimationData] and loads the sprite animation
  /// When the [images] is omitted, the global [Flame.images] is used
  static Future<SpriteAnimation> load(
    String src,
    SpriteAnimationData data, {
    Images? images,
  }) async {
    final _images = images ?? Flame.images;
    final image = await _images.load(src);
    return SpriteAnimation.fromFrameData(image, data);
  }

  /// The current frame that should be displayed.
  SpriteAnimationFrame get currentFrame => frames[currentIndex];

  /// Returns whether the animation is on the last frame.
  bool get isLastFrame => currentIndex == frames.length - 1;

  /// Returns whether the animation has only a single frame (and is, thus, a still image).
  bool get isSingleFrame => frames.length == 1;

  /// Sets a different step time to each frame. The sizes of the arrays must match.
  set variableStepTimes(List<double> stepTimes) {
    assert(stepTimes.length == frames.length);
    for (var i = 0; i < frames.length; i++) {
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
    _done = false;
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
  bool _done = false;
  bool done() => _done;

  /// Updates this animation, ticking the lifeTime by an amount [dt] (in seconds).
  void update(double dt) {
    clock += dt;
    elapsed += dt;
    if (isSingleFrame || _done) {
      return;
    }
    while (clock >= currentFrame.stepTime) {
      if (isLastFrame) {
        if (loop) {
          clock -= currentFrame.stepTime;
          currentIndex = 0;
        } else {
          _done = true;
          onComplete?.call();
          return;
        }
      } else {
        clock -= currentFrame.stepTime;
        currentIndex++;
      }
    }
  }

  /// Returns a new Animation based on this animation, but with its frames in reversed order
  SpriteAnimation reversed() {
    return SpriteAnimation(frames.reversed.toList(), loop: loop);
  }

  /// Computes the total duration of this animation (before it's done or repeats).
  double totalDuration() {
    return frames.map((f) => f.stepTime).reduce((a, b) => a + b);
  }
}
