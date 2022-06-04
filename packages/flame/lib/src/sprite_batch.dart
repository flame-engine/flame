import 'dart:collection';
import 'dart:math' show pi;
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/src/cache/images.dart';
import 'package:flame/src/extensions/image.dart';
import 'package:flame/src/extensions/picture_extension.dart';
import 'package:flame/src/flame.dart';

extension SpriteBatchExtension on Game {
  /// Utility method to load and cache the image for a [SpriteBatch] based on
  /// its options.
  Future<SpriteBatch> loadSpriteBatch(
    String path, {
    Color defaultColor = const Color(0x00000000),
    BlendMode defaultBlendMode = BlendMode.srcOver,
    RSTransform? defaultTransform,
    Images? imageCache,
    bool useAtlas = true,
  }) {
    return SpriteBatch.load(
      path,
      defaultColor: defaultColor,
      defaultBlendMode: defaultBlendMode,
      defaultTransform: defaultTransform,
      images: imageCache ?? images,
      useAtlas: useAtlas,
    );
  }
}

/// A single item in a SpriteBatch.
///
/// Holds all the important information of a batch item.
class BatchItem {
  BatchItem({
    required this.source,
    required this.transform,
    this.flip = false,
    required this.color,
  })  : paint = Paint()..color = color,
        destination = Offset.zero & source.size;

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
  /// Since [Canvas.drawAtlas] is not supported on the web we also
  /// build a `Matrix4` based on the [transform] and [flip] values.
  late final Matrix4 matrix = Matrix4(
    transform.scos, transform.ssin, 0, 0, //
    -transform.ssin, transform.scos, 0, 0, //
    0, 0, 0, 0, //
    transform.tx, transform.ty, 0, 1, //
  )
    ..translate(source.width / 2, source.height / 2)
    ..rotateY(flip ? pi : 0)
    ..translate(-source.width / 2, -source.height / 2);

  /// Paint object used for the web.
  final Paint paint;
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
  SpriteBatch(
    this.atlas, {
    this.defaultColor = const Color(0x00000000),
    this.defaultBlendMode = BlendMode.srcOver,
    this.defaultTransform,
    this.useAtlas = true,
    Images? imageCache,
    String? imageKey,
  })  : _imageCache = imageCache,
        _imageKey = imageKey;

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
    return SpriteBatch(
      await _images.load(path),
      defaultColor: defaultColor,
      defaultTransform: defaultTransform ?? RSTransform(1, 0, 0, 0),
      defaultBlendMode: defaultBlendMode,
      useAtlas: useAtlas,
      imageCache: _images,
      imageKey: path,
    );
  }

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

  /// The image cache used by the [SpriteBatch] to store image assets.
  final Images? _imageCache;

  /// When the [_imageCache] isn't specified, the global [Flame.images] is used.
  Images get imageCache => _imageCache ?? Flame.images;

  /// The root key use by the [SpriteBatch] to store image assets.
  final String? _imageKey;

  /// When the [_imageKey] isn't specified [imageKey] will return either the key
  /// for the [atlas] stored in [imageCache] or a key generated from the
  /// identityHashCode.
  String get imageKey =>
      _imageKey ??
      imageCache.findKeyForImage(atlas) ??
      'image[${identityHashCode(atlas)}]';

  /// Whether any [BatchItem]s needs a flippable atlas.
  bool _hasFlips = false;

  /// The status of the atlas image loading operations.
  bool _atlasReady = true;

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

  Future<void> _makeFlippedAtlas() async {
    _hasFlips = true;
    _atlasReady = false;
    final key = '$imageKey#with-flips';
    atlas = await imageCache.fetchOrGenerate(
      key,
      () => _generateFlippedAtlas(atlas),
    );
    _atlasReady = true;
  }

  Future<Image> _generateFlippedAtlas(Image image) {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final _emptyPaint = Paint();
    canvas.drawImage(image, Offset.zero, _emptyPaint);
    canvas.scale(-1, 1);
    canvas.drawImage(image, Offset(-image.width * 2, 0), _emptyPaint);

    final picture = recorder.endRecording();
    return picture.toImageSafe(image.width * 2, image.height);
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
  }) {
    final batchItem = BatchItem(
      source: source,
      transform: transform ??= defaultTransform ?? RSTransform(1, 0, 0, 0),
      flip: flip,
      color: color ?? defaultColor,
    );

    if (flip && useAtlas && !_hasFlips) {
      _makeFlippedAtlas();
    }

    _batchItems.add(batchItem);

    _sources.add(
      flip
          ? Rect.fromLTWH(
              (atlas.width * (!_atlasReady ? 2 : 1)) - source.right,
              source.top,
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

    if (useAtlas && _atlasReady) {
      canvas.drawAtlas(
        atlas,
        _transforms,
        _sources,
        _colors,
        blendMode ?? defaultBlendMode,
        cullRect,
        paint,
      );
    } else {
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
    }
  }
}
