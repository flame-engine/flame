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

  /// The [BlendMode] that will be used when composing the [image].
  final BlendMode blendMode;

  _Composed(this.image, this.position, this.source, this.blendMode);
}

class Composition {
  /// The values that will be used to compose the image
  final List<_Composed> _composes = [];

  /// Add an image to the [Composition].
  ///
  /// The [image] will be added at the given [position] on the composition.
  ///
  /// An optional [source] can be used to only add the data that is within the
  /// [source] of the [image].
  ///
  /// The [blendMode] can be used to change how the [image] will be blended onto
  /// the composition. Defaults to [BlendMode.srcOver].
  void add(
    Image image,
    Vector2 position, {
    Rect source,
    BlendMode blendMode = BlendMode.srcOver,
  }) {
    assert(image != null, 'Image is required to add to the Atlas');
    assert(position != null, 'Position is required');
    assert(
      position.x >= 0 && position.y >= 0,
      'Position values have to be equal or greater than zero',
    );
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
    assert(blendMode != null, 'blendMode should not be null');
    source ??= Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );

    _composes.add(_Composed(image, position, source, blendMode));
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
      final blendMode = _composes[i].blendMode;
      final destination = Rect.fromLTWH(
        position.x,
        position.y,
        source.width,
        source.height,
      );

      canvas.drawImageRect(
        image,
        source,
        destination,
        Paint()..blendMode = blendMode,
      );

      // If the destination is not fully contained inside the current output,
      // we have to resize the data list.
      if (!(output.contains(destination.topLeft) &&
          output.contains(destination.topRight) &&
          output.contains(destination.bottomLeft) &&
          output.contains(destination.bottomRight))) {
        output = output.expandToInclude(destination);
      }
    }

    final picture = recorder.endRecording();
    return picture.toImage(output.width.toInt(), output.height.toInt());
  }
}
