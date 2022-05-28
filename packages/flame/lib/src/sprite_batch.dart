import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/src/cache/images.dart';
import 'package:flame/src/extensions/image.dart';
import 'package:flame/src/extensions/picture_extension.dart';
import 'package:flame/src/flame.dart';

extension SpriteBatchExtension on Game {
  /// Utility method to load and cache the image for a [SpriteBatch] based on
  /// its options
  Future<SpriteBatch> loadSpriteBatch(
    String path, {
    Color defaultColor = const Color(0x00000000),
    BlendMode defaultBlendMode = BlendMode.srcOver,
    RSTransform? defaultTransform,
    bool useAtlas = true,
  }) {
    return SpriteBatch.load(
      path,
      defaultColor: defaultColor,
      defaultBlendMode: defaultBlendMode,
      defaultTransform: defaultTransform,
      images: images,
      useAtlas: useAtlas,
    );
  }
}

/// This is the scale value used in [BatchItem.matrix], we can't determine this
/// from the [BatchItem.transform], but we also don't need to do so because it
/// is already calculated inside the transform values.
const _defaultScale = 0.0;

/// A single item in a SpriteBatch.
///
/// Holds all the important information of a batch item,
class BatchItem {
  /// The source rectangle on the [SpriteBatch.atlas].
  final Rect source;

  /// The destination rectangle for the Canvas.
  ///
  /// It will be transformed by [matrix].
  final Rect destination;

  /// The transform values for this batch item.
  final RSTransform transform;

  /// The flip value for this batch item.
  final bool flip;

  /// The background color for this batch item.
  final Color color;

  /// Fallback matrix for the web.
  ///
  /// Because `Canvas.drawAtlas` is not supported on the web we also
  /// build a `Matrix4` based on the [transform] and [flip] values.
  final Matrix4 matrix;

  /// Paint object used for the web.
  final Paint paint;

  BatchItem({
    required this.source,
    required this.transform,
    this.flip = false,
    required this.color,
  })  : matrix = Matrix4(
          transform.scos * (flip ? -1 : 1), transform.ssin, 0, 0, //
          -transform.ssin, transform.scos, 0, 0, //
          0, 0, _defaultScale, 0, //
          transform.tx, transform.ty, 0, 1, //
        ),
        paint = Paint()..color = color,
        destination = Offset.zero & source.size;
}

/// The SpriteBatch API allows for rendering multiple items at once.
///
/// This class allows for optimization when you want to draw many parts of an
/// image onto the canvas. It is more efficient than using multiple calls to
/// [Canvas.drawImageRect] and provides more functionality by allowing each
/// [BatchItem] to have their own transform rotation and color.
///
/// By collecting all the necessary transforms on a single image and sending
/// those transforms in a single batch to the GPU, we can render multiple parts
/// of a single image at once.
///
/// **Note**: If you are experiencing problems with ghost lines, the less
/// performant [Canvas.drawImageRect] can be used instead of [Canvas.drawAtlas].
/// To activate this mode, pass in `useAtlas = false` to the constructor or
/// load method that you are using and each [BatchItem] will be rendered using
/// the [Canvas.drawImageRect] method instead.
class SpriteBatch {
  /// List of all the existing batch items.
  final _batchItems = <BatchItem>[];

  /// The sources to use on the [atlas].
  final _sources = <Rect>[];

  /// The sources list shouldn't be modified directly, that is why an
  /// [UnmodifiableListView] is used. If you want to add sources use the
  /// [add] or [addTransform] method.
  UnmodifiableListView<Rect> get sources {
    return UnmodifiableListView<Rect>(_sources);
  }

  /// The transforms that should be applied on the [_sources].
  final _transforms = <RSTransform>[];

  /// The transforms list shouldn't be modified directly, that is why an
  /// [UnmodifiableListView] is used. If you want to add transforms use the
  /// [add] or [addTransform] method.
  UnmodifiableListView<RSTransform> get transforms {
    return UnmodifiableListView<RSTransform>(_transforms);
  }

  /// The background color for the [_sources].
  final _colors = <Color>[];

  /// The colors list shouldn't be modified directly, that is why an
  /// [UnmodifiableListView] is used. If you want to add colors use the
  /// [add] or [addTransform] method.
  UnmodifiableListView<Color> get colors {
    return UnmodifiableListView<Color>(_colors);
  }

  /// The atlas used by the [SpriteBatch].
  Image atlas;

  /// The atlas used by the [SpriteBatch] when flips are needed.
  late final Future<Image> _flippableAtlas = flippableAtlasGenerator();

  Future<Image> Function() flippableAtlasGenerator;

  /// Whether any [BatchItem] needs a flippableAtlas.
  bool _hasFlips = false;

  /// The default color, used as a background color for a [BatchItem].
  final Color defaultColor;

  /// The default transform, used when a transform was not supplied for a
  /// [BatchItem].
  final RSTransform? defaultTransform;

  /// The default blend mode, used for blending a batch item.
  final BlendMode defaultBlendMode;

  /// The width of the [atlas].
  int get width => atlas.width;

  /// The height of the [atlas].
  int get height => atlas.height;

  /// The size of the [atlas].
  Vector2 get size => atlas.size;

  /// Whether to use [Canvas.drawAtlas] or not.
  final bool useAtlas;

  SpriteBatch(
    this.atlas, {
    this.defaultColor = const Color(0x00000000),
    this.defaultBlendMode = BlendMode.srcOver,
    this.defaultTransform,
    this.useAtlas = true,
    required this.flippableAtlasGenerator, //#TODO removed required with default
  });

  /// Takes a path of an image, and optional arguments for the SpriteBatch.
  ///
  /// When the [images] is omitted, the global [Flame.images] is used.
  static Future<SpriteBatch> load(
    String path, {
    Color defaultColor = const Color(0x00000000),
    BlendMode defaultBlendMode = BlendMode.srcOver,
    RSTransform? defaultTransform,
    Images? images,
    bool useAtlas = true,
  }) async {
    final _images = images ?? Flame.images;
    final atlas = await _images.load(path);
    return SpriteBatch(
      atlas,
      defaultColor: defaultColor,
      defaultTransform: defaultTransform ?? RSTransform(1, 0, 0, 0),
      defaultBlendMode: defaultBlendMode,
      useAtlas: useAtlas,
      flippableAtlasGenerator: () => _images.fetchOrGenerate(
        '$path$_generatedAtlasKeySuffix',
        () => _generateFlippedAtlas(atlas),
      ),
    );
  }

  static const String _generatedAtlasKeySuffix = '#withFlipAttached';

  static Future<Image> _generateFlippedAtlas(
    Image image,
  ) async {
    print("Generating Now\n");
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final _emptyPaint = Paint();
    canvas.drawImage(image, Offset.zero, _emptyPaint);
    canvas.scale(-1, 1);
    canvas.drawImage(
      image,
      Offset(-image.width.toDouble(), image.height.toDouble()),
      _emptyPaint,
    );

    final picture = recorder.endRecording();
    return picture.toImageSafe(image.width, image.height * 2);
  }

  static Future<Image> _generateFlippedAtlas2(
    Image image,
  ) async {
    final imagePixelData = await image.pixelsInUint8();
    final atlasPixelData = <int>[];
    final imageBytesWidth = image.width * 4;
    final imageStartingLength = imagePixelData.length;
    atlasPixelData.addAll(imagePixelData);
    for (var ind = 0; ind < imageStartingLength; ind += imageBytesWidth) {
      for (var byteInd = 0; byteInd < imageBytesWidth; byteInd += 4) {
        atlasPixelData.insertAll(
          ind + imageStartingLength,
          imagePixelData.getRange(ind + byteInd, ind + byteInd + 4),
        );
      }
    }
    return ImageExtension.fromPixels(
      Uint8List.fromList(atlasPixelData),
      image.width,
      image.height * 2,
    );
  }

  /// Add a new batch item using a RSTransform.
  ///
  /// The [source] parameter is the source location on the [atlas].
  ///
  /// You can position, rotate, scale and flip it on the canvas using the
  /// [transform] and [flip] parameters.
  ///
  /// The [color] parameter allows you to render a color behind the batch item,
  /// as a background color.
  ///
  /// The [add] method may be a simpler way to add a batch item to the batch.
  /// However, if there is a way to factor out the computations of the sine and
  /// cosine of the rotation so that they can be reused over multiple calls to
  /// this constructor, it may be more efficient to directly use this method
  /// instead.
  void addTransform({
    required Rect source,
    RSTransform? transform,
    bool flip = false,
    Color? color,
  }) async {
    final batchItem = BatchItem(
      source: source,
      transform: transform ??= defaultTransform ?? RSTransform(1, 0, 0, 0),
      flip: flip,
      color: color ?? defaultColor,
    );

    if (flip && useAtlas && !_hasFlips) {
      _hasFlips = true;
      atlas = await _flippableAtlas;
    }

    _batchItems.add(batchItem);

    _sources.add(
      flip
          ? Rect.fromLTWH(
              atlas.width - source.right,
              source.top + source.height,
              source.width,
              source.height,
            )
          : batchItem.source,
    );
    _transforms.add(batchItem.transform);
    _colors.add(batchItem.color);
  }

  /// Add a new batch item.
  ///
  /// The [source] parameter is the source location on the [atlas]. You can
  /// position it on the canvas using the [offset] parameter.
  ///
  /// You can transform the sprite from its [offset] using [scale], [rotation],
  /// [anchor] and [flip].
  ///
  /// The [color] paramater allows you to render a color behind the batch item,
  /// as a background color.
  ///
  /// This method creates a new [RSTransform] based on the given transform
  /// arguments. If many [RSTransform] objects are being created and there is a
  /// way to factor out the computations of the sine and cosine of the rotation
  /// (which are computed each time this method is called) and reuse them over
  /// multiple [RSTransform] objects,
  /// it may be more efficient to directly use the more direct [addTransform]
  /// method instead.
  void add({
    required Rect source,
    double scale = 1.0,
    Vector2? anchor,
    double rotation = 0,
    Vector2? offset,
    bool flip = false,
    Color? color,
  }) {
    anchor ??= Vector2.zero();
    offset ??= Vector2.zero();
    RSTransform? transform;

    // If any of the transform arguments is different from the defaults,
    // then we create one. This is to prevent unnecessary computations
    // of the sine and cosine of the rotation.
    if (scale != 1.0 ||
        anchor != Vector2.zero() ||
        rotation != 0 ||
        offset != Vector2.zero()) {
      transform = RSTransform.fromComponents(
        scale: scale,
        anchorX: anchor.x,
        anchorY: anchor.y,
        rotation: rotation,
        translateX: offset.x,
        translateY: offset.y,
      );
    }

    addTransform(
      source: source,
      transform: transform,
      flip: flip,
      color: color,
    );
  }

  /// Clear the SpriteBatch so it can be reused.
  void clear() {
    _sources.clear();
    _transforms.clear();
    _colors.clear();
    _batchItems.clear();
  }

  // Used to not create new paint objects in [render] on every tick.
  final Paint _emptyPaint = Paint();

  void render(
    Canvas canvas, {
    BlendMode? blendMode,
    Rect? cullRect,
    Paint? paint,
  }) {
    paint ??= _emptyPaint;

    if (!useAtlas) {
      for (final batchItem in _batchItems) {
        paint.blendMode = blendMode ?? paint.blendMode;

        canvas
          ..save()
          ..transform(batchItem.matrix.storage)
          ..drawRect(batchItem.destination, batchItem.paint)
          ..drawImageRect(
            atlas,
            batchItem.source,
            batchItem.destination,
            paint,
          )
          ..restore();
      }
    } else {
      canvas.drawAtlas(
        atlas,
        _transforms,
        _sources,
        _colors,
        blendMode ?? defaultBlendMode,
        cullRect,
        paint,
      );
    }
  }
}
