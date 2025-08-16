import 'dart:async';
import 'dart:ui';

import 'package:flame/src/cache/images.dart';
import 'package:flame/src/extensions/vector2.dart';
import 'package:flame/src/flame.dart';
import 'package:flame/src/sprite.dart';
import 'package:flame/src/sprite_animation_ticker.dart';

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

  /// Creates a SpriteAnimationData from the given [frames] and [loop]
  /// parameters.
  SpriteAnimationData(this.frames, {this.loop = true});

  /// Takes some parameters and automatically calculate and create the frames
  /// for the sprite animation data.
  ///
  /// [amount] The total amount of frames present on the image.
  /// [stepTimes] A list of times (in seconds) of each frame, should have a
  /// length equals to the amount parameter.
  /// [textureSize] The size of each frame.
  /// [amountPerRow] An optional parameter to inform how many frames there are
  /// on which row, useful for sprite sheets where the frames as disposed on
  /// multiple lines.
  /// [texturePosition] An optional parameter with the initial coordinate where
  /// the frames begin on the image, default to (top: 0, left: 0).
  /// [loop] An optional parameter to inform if this animation loops or has a
  /// single iteration, defaults to true.
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

  /// Specifies the range of the sprite grid.
  ///
  /// Make sure your sprites are placed left-to-right and top-to-bottom
  ///
  /// [start] is the start frame index.
  /// [end] is the end frame index.
  SpriteAnimationData.range({
    required int start,
    required int end,
    required int amount,
    required List<double> stepTimes,
    required Vector2 textureSize,
    int? amountPerRow,
    Vector2? texturePosition,
    this.loop = true,
  }) : assert(amountPerRow == null || amount >= amountPerRow),
       assert(start <= end && start >= 0 && end <= amount),
       assert(stepTimes.length >= end - start + 1) {
    amountPerRow ??= amount;
    texturePosition ??= Vector2.zero();
    frames = List<SpriteAnimationFrameData>.generate(end - start + 1, (index) {
      final i = index + start;
      final position = Vector2(
        texturePosition!.x + (i % amountPerRow!) * textureSize.x,
        texturePosition.y + (i ~/ amountPerRow) * textureSize.y,
      );
      return SpriteAnimationFrameData(
        stepTime: stepTimes[index],
        srcPosition: position,
        srcSize: textureSize,
      );
    });
  }

  /// Works just like [SpriteAnimationData.variable] but uses the same
  /// [stepTime] for all frames.
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

/// Represents a sprite animation, that is, a list of sprites that change with
/// time.
class SpriteAnimation {
  SpriteAnimation(this.frames, {this.loop = true})
    : assert(frames.isNotEmpty, 'There must be at least one animation frame'),
      assert(
        frames.every((frame) => frame.stepTime > 0),
        'All frames must have positive durations',
      );

  /// Create animation from a list of [sprites] all having the same transition
  /// time [stepTime].
  factory SpriteAnimation.spriteList(
    List<Sprite> sprites, {
    required double stepTime,
    bool loop = true,
  }) {
    return SpriteAnimation(
      sprites.map((sprite) => SpriteAnimationFrame(sprite, stepTime)).toList(),
      loop: loop,
    );
  }

  /// Create animation from a list of [sprites] each having its own duration
  /// provided in the [stepTimes] list.
  factory SpriteAnimation.variableSpriteList(
    List<Sprite> sprites, {
    required List<double> stepTimes,
    bool loop = true,
  }) {
    assert(
      stepTimes.length == sprites.length,
      'Lengths of stepTimes and sprites lists must be equal',
    );
    return SpriteAnimation(
      [
        for (var i = 0; i < sprites.length; i++)
          SpriteAnimationFrame(sprites[i], stepTimes[i]),
      ],
      loop: loop,
    );
  }

  /// Create animation from a single [image] that contains all frames.
  ///
  /// The [data] argument provides the description of where the individual
  /// sprites are located within the main image.
  factory SpriteAnimation.fromFrameData(
    Image image,
    SpriteAnimationData data,
  ) {
    return SpriteAnimation(
      [
        for (final frameData in data.frames)
          SpriteAnimationFrame(
            Sprite(
              image,
              srcSize: frameData.srcSize,
              srcPosition: frameData.srcPosition,
            ),
            frameData.stepTime,
          ),
      ],
      loop: data.loop,
    );
  }

  /// Automatically creates an Animation Object using animation data provided by
  /// the json file provided by Aseprite.
  ///
  /// [image]: sprite sheet animation image.
  /// [jsonData]: animation's data in json format.
  factory SpriteAnimation.fromAsepriteData(
    Image image,
    Map<String, dynamic> jsonData,
  ) {
    final jsonFrames = jsonData['frames'] as Map<String, dynamic>;
    return SpriteAnimation(
      jsonFrames.values.map((dynamic value) {
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
      }).toList(),
    );
  }

  /// Takes a path of an image, a [SpriteAnimationData] and loads the sprite
  /// animation.
  /// When the [images] is omitted, the global [Flame.images] is used.
  static Future<SpriteAnimation> load(
    String src,
    SpriteAnimationData data, {
    Images? images,
  }) async {
    final imagesCache = images ?? Flame.images;
    final image = await imagesCache.load(src);
    return SpriteAnimation.fromFrameData(image, data);
  }

  /// The frames that compose this animation.
  List<SpriteAnimationFrame> frames = [];

  /// Whether the animation loops after the last sprite of the list, going back
  /// to the first, or keeps returning the last when done.
  bool loop = true;

  /// Sets a different step time to each frame.
  /// The sizes of the arrays must match.
  set variableStepTimes(List<double> stepTimes) {
    assert(stepTimes.length == frames.length);
    for (var i = 0; i < frames.length; i++) {
      assert(stepTimes[i] > 0, 'All step times must be positive');
      frames[i].stepTime = stepTimes[i];
    }
  }

  /// Sets a fixed step time to all frames.
  set stepTime(double stepTime) {
    assert(stepTime > 0, 'Step time must be positive');
    frames.forEach((frame) => frame.stepTime = stepTime);
  }

  /// Returns a new Animation equal to this one in definition, but each copy can
  /// be run independently.
  SpriteAnimation clone() {
    return SpriteAnimation(frames.toList(), loop: loop);
  }

  /// Returns a new Animation based on this animation, but with its frames in
  /// reversed order
  SpriteAnimation reversed() {
    return SpriteAnimation(frames.reversed.toList(), loop: loop);
  }

  /// Creates and returns a new [SpriteAnimationTicker].
  SpriteAnimationTicker createTicker() => SpriteAnimationTicker(this);
}
