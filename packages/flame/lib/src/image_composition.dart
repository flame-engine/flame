import 'dart:async';
import 'dart:ui';

import 'package:flame/extensions.dart';

export '../extensions.dart';

/// The [ImageComposition] allows for composing multiple images onto a single
/// image.
///
/// **Note:** Composing images is a heavy async operation and should not be
/// called inside the game loop.
class ImageComposition {
  ImageComposition({
    this.defaultBlendMode = BlendMode.srcOver,
    this.defaultAntiAlias = false,
  });

  /// The values that will be used to compose the image
  final List<_Fragment> _composes = [];

  /// The [defaultBlendMode] can be used to change how each image will be
  /// blended onto the composition. Defaults to [BlendMode.srcOver].
  final BlendMode defaultBlendMode;

  /// The [defaultAntiAlias] can be used to if each image will be anti aliased.
  final bool defaultAntiAlias;

  /// Add an image to the [ImageComposition].
  ///
  /// The [image] will be added at the given [position] on the composition.
  ///
  /// An optional [source] can be used to only add the data that is within the
  /// [source] of the [image].
  ///
  /// An optional [angle] (in radians) can be used to rotate the image when it
  /// gets added to the composition. It will be rotated in a clock-wise
  /// direction around the [anchor].
  ///
  /// By default the [anchor] will be the [source].width and [source].height
  /// divided by `2`.
  ///
  /// [isAntiAlias] can be used to if the [image] will be anti aliased. Defaults
  /// to [defaultAntiAlias].
  ///
  /// The [blendMode] can be used to change how the [image] will be blended onto
  /// the composition. Defaults to [defaultBlendMode].
  void add(
    Image image,
    Vector2 position, {
    Rect? source,
    double angle = 0,
    Vector2? anchor,
    bool? isAntiAlias,
    BlendMode? blendMode,
  }) {
    final imageRect = image.getBoundingRect();
    source ??= imageRect;
    anchor ??= source.toVector2() / 2;
    blendMode ??= defaultBlendMode;
    isAntiAlias ??= defaultAntiAlias;

    assert(
      imageRect.topLeft <= source.topLeft &&
          imageRect.bottomRight >= source.bottomRight,
      'Source rect should fit within the image',
    );

    _composes.add(
      _Fragment(
        image,
        position,
        source,
        angle,
        anchor,
        isAntiAlias,
        blendMode,
      ),
    );
  }

  void clear() => _composes.clear();

  /// Compose all the images into a single composition.
  Future<Image> compose() async {
    // Rect used to determine how big the output image will be.
    var output = const Rect.fromLTWH(0, 0, 0, 0);
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    for (final compose in _composes) {
      final image = compose.image;
      final position = compose.position;
      final source = compose.source;
      final rotation = compose.angle;
      final anchor = compose.anchor;
      final isAntiAlias = compose.isAntiAlias;
      final blendMode = compose.blendMode;
      final destination = Rect.fromLTWH(0, 0, source.width, source.height);
      final realDest = destination.translate(position.x, position.y);

      canvas
        ..save()
        ..translateVector(position)
        ..translateVector(anchor)
        ..rotate(rotation)
        ..translateVector(-anchor)
        ..drawImageRect(
          image,
          source,
          destination,
          Paint()
            ..blendMode = blendMode
            ..isAntiAlias = isAntiAlias,
        )
        ..restore();

      // Expand the output so it can be used later on when the output image gets
      // created.
      output = output.expandToInclude(realDest);
    }

    return recorder
        .endRecording()
        .toImage(output.width.toInt(), output.height.toInt());
  }
}

class _Fragment {
  _Fragment(
    this.image,
    this.position,
    this.source,
    this.angle,
    this.anchor,
    this.isAntiAlias,
    this.blendMode,
  );

  /// The image that will be composed.
  final Image image;

  /// The position where the [image] will be composed.
  final Vector2 position;

  /// The source on the [image] that will be composed.
  final Rect source;

  /// The angle (in radians) used to rotate the [image] around it's [anchor].
  final double angle;

  /// The point around which the [image] will be rotated
  /// (defaults to the centre of the [source]).
  final Vector2 anchor;

  final bool isAntiAlias;

  /// The [BlendMode] that will be used when composing the [image].
  final BlendMode blendMode;
}
