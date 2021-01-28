import 'dart:async';
import 'dart:ui';

import 'extensions.dart';

export 'extensions.dart';

class _Composed {
  /// The image that will be composed.
  final Image image;

  /// The position where the [image] will be composed.
  final Vector2 position;

  /// The source on the [image] that will be composed.
  final Rect source;

  final double rotation;

  final Vector2 anchor;

  final bool isAntiAlias;

  /// The [BlendMode] that will be used when composing the [image].
  final BlendMode blendMode;

  _Composed(
    this.image,
    this.position,
    this.source,
    this.rotation,
    this.anchor,
    this.isAntiAlias,
    this.blendMode,
  );
}

class Composition {
  /// The values that will be used to compose the image
  final List<_Composed> _composes = [];

  /// The [defaultBlendMode] can be used to change how each image will be
  /// blended onto the composition. Defaults to [BlendMode.srcOver].
  final BlendMode defaultBlendMode;

  /// The [defaultAntiAlias] can be used to if each image will be anti aliased.
  final bool defaultAntiAlias;

  Composition({
    this.defaultBlendMode = BlendMode.srcOver,
    this.defaultAntiAlias = false,
  })  : assert(defaultBlendMode != null, 'defaultBlendMode can not be null'),
        assert(defaultAntiAlias != null, 'defaultAntiAlias can not be null');

  /// Add an image to the [Composition].
  ///
  /// The [image] will be added at the given [position] on the composition.
  ///
  /// An optional [source] can be used to only add the data that is within the
  /// [source] of the [image].
  ///
  /// An optional [rotation] (in radians) can be used to rotate the image when it
  /// gets added to the composition. You can use [anchor] to set the point on
  /// which it will rotate.
  ///
  /// By default the [anchor] will be the [source.width] and [source.height]
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
    Rect source,
    double rotation = 0,
    Vector2 anchor,
    bool isAntiAlias,
    BlendMode blendMode,
  }) {
    assert(image != null, 'Image is required to add to the Atlas');
    assert(position != null, 'Position is required');
    // assert(
    //   position.x >= 0 && position.y >= 0,
    //   'Position values have to be equal or greater than zero',
    // );
    assert(
      source == null ||
          source.width <= image.width &&
              source.height <= image.height &&
              source.top + source.height <= image.height &&
              source.top >= 0 &&
              source.left + source.width <= image.width &&
              source.left >= 0,
      'Source rect should fit within in the image constraints',
    );
    assert(rotation != null, 'rotation can not be null');
    blendMode ??= defaultBlendMode;
    isAntiAlias ??= defaultAntiAlias;
    source ??= Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    anchor ??= Vector2(source.width / 2, source.height / 2);

    _composes.add(_Composed(
      image,
      position,
      source,
      rotation,
      anchor,
      isAntiAlias,
      blendMode,
    ));
  }

  void clear() => _composes.clear();

  /// Compose all the images into a single composition.
  Future<Image> compose() async {
    // Rect used to determine how big the output image will be.
    var output = const Rect.fromLTWH(0, 0, 0, 0);
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    for (var i = 0; i < _composes.length; i++) {
      final image = _composes[i].image;
      final position = _composes[i].position;
      final source = _composes[i].source;
      final rotation = _composes[i].rotation;
      final anchor = _composes[i].anchor;
      final isAntiAlias = _composes[i].isAntiAlias;
      final blendMode = _composes[i].blendMode;
      final destination = Rect.fromLTWH(0, 0, source.width, source.height);

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

      // If the destination is not fully contained inside the current output,
      // we have to resize the data list.
      if (!(output.contains(destination.topLeft) &&
          output.contains(destination.topRight) &&
          output.contains(destination.bottomLeft) &&
          output.contains(destination.bottomRight))) {
        output = output.expandToInclude(
          Rect.fromLTWH(-position.x, -position.y, source.width, source.height),
        );
      }
    }
    print(output);

    final picture = recorder.endRecording();
    return picture.toImage(output.width.toInt(), output.height.toInt());
  }
}
