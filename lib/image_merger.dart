import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'extensions/vector2.dart';
import 'flame.dart';

class ImageMerger {
  /// The images that are going to be merged together.
  final List<Image> _images = [];

  /// The positions where each [_images] will be added.
  final List<Vector2> _positions = [];

  /// The sources that should be used on each [_images].
  final List<Rect> _sources = [];

  /// Add an image to the [ImageMerger].
  ///
  /// The [image] will be added at the given [position] on the generated image.
  ///
  /// An optional [source] can be used to only add the data that is within the
  /// [source] of the [image].
  /// TODO(wfln): Add [BlendMode support].
  void add(
    Image image,
    Vector2 position, {
    Rect source,
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
    source ??= Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );

    _images.add(image);
    _positions.add(position);
    _sources.add(source);
  }

  /// Merge all the images into a single atlas.
  Future<Image> merge() async {
    var output = const Rect.fromLTWH(0, 0, 0, 0);
    var data = Uint8List(_toLength(Vector2.zero()));

    for (var i = 0; i < _images.length; i++) {
      final image = _images[i];
      final position = _positions[i];
      final source = _sources[i];

      final destination = Rect.fromLTWH(
        position.x,
        position.y,
        source.width,
        source.height,
      );

      // If the rect is not fully contained inside the current outputRect,
      // we have to resize the data list.
      if (!(output.contains(destination.topLeft) &&
          output.contains(destination.topRight) &&
          output.contains(destination.bottomLeft) &&
          output.contains(destination.bottomRight))) {
        final newOutput = output.expandToInclude(destination);
        final newData = Uint8List(
          _toLength(Vector2(newOutput.width, newOutput.height)),
        );

        if (data.isNotEmpty) {
          for (var y = 0.0; y < output.height; y++) {
            for (var x = 0.0; x < output.width; x++) {
              final pos = Vector2(x, y);
              final oldIndex = _toIndex(pos, output.width);
              final newIndex = _toIndex(pos, newOutput.width);

              newData[newIndex] = data[oldIndex];
              newData[newIndex + 1] = data[oldIndex + 1];
              newData[newIndex + 2] = data[oldIndex + 2];
              newData[newIndex + 3] = data[oldIndex + 3];
            }
          }
        }

        output = newOutput;
        data = newData;
      }

      final offsetInBytes = _toIndex(
        Vector2(source.left, source.top),
        source.width,
      );
      final sizeInBytes = _toLength(Vector2(source.width, source.height));
      final buffer = (await image.toByteData()).buffer;
      final imageData = buffer.asUint8List(offsetInBytes, sizeInBytes);

      for (var y = 0.0; y < source.height - source.top; y++) {
        for (var x = 0.0; x < source.width - source.left; x++) {
          final pos = Vector2(x, y);
          final imageIndex = _toIndex(pos, source.width);
          final outputIndex = _toIndex(position + pos, output.width);

          data[outputIndex] = imageData[imageIndex];
          data[outputIndex + 1] = imageData[imageIndex + 1];
          data[outputIndex + 2] = imageData[imageIndex + 2];
          data[outputIndex + 3] = imageData[imageIndex + 3];
        }
      }
    }

    // Set all the unused pixels to 0.
    for (var i = 0; i < data.length; i++) {
      data[i] ??= 0;
    }

    return Flame.util.decodeImageFromPixels(
      data,
      output.width.toInt(),
      output.height.toInt(),
    );
  }

  int _toIndex(Vector2 p, double w) => (((p.y * w) + p.x) * 4).toInt();

  int _toLength(Vector2 s) => (s.x * s.y * 4).toInt();
}
