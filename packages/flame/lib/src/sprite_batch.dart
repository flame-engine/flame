import 'dart:collection';
import 'dart:math' show pi;
import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:meta/meta.dart';

extension SpriteBatchExtension on Game {
  /// Utility method to load and cache the image for a [SpriteBatch] based on
  /// its options.
  Future<SpriteBatch> loadSpriteBatch(
    String path, {
    Color? defaultColor,
    BlendMode? defaultBlendMode,
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
    Color? color,
    this.flip = false,
  }) : paint = Paint()..color = color ?? const Color(0x00000000),
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

  /// Fallback matrix for the web.
  ///
  /// Since [Canvas.drawAtlas] is not supported on the web we also
  /// build a `Matrix4` based on the [transform] and [flip] values.
  late final Matrix4 matrix =
      Matrix4(
          transform.scos,
          transform.ssin,
          0,
          0, //
          -transform.ssin,
          transform.scos,
          0,
          0, //
          0,
          0,
          0,
          0, //
          transform.tx,
          transform.ty,
          0,
          1, //
        )
        ..translateByDouble(source.width / 2, source.height / 2, 0.0, 1.0)
        ..rotateY(flip ? pi : 0)
        ..translateByDouble(-source.width / 2, -source.height / 2, 0.0, 1.0);

  /// Paint object used for the web.
  final Paint paint;
}

@internal
enum FlippedAtlasStatus {
  /// There is no need to generate a flipped atlas yet.
  none,

  /// The flipped atlas generation is currently in progress.
  generating,

  /// The flipped atlas image has been generated.
  generated;

  bool get isNone => this == FlippedAtlasStatus.none;
  bool get isGenerating => this == FlippedAtlasStatus.generating;
  bool get isGenerated => this == FlippedAtlasStatus.generated;
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
    this.defaultTransform,
    this.useAtlas = true,
    this.defaultColor,
    this.defaultBlendMode,
    Images? imageCache,
    String? imageKey,
  }) : _imageCache = imageCache,
       _imageKey = imageKey;

  /// Takes a path of an image, and optional arguments for the SpriteBatch.
  ///
  /// When the [images] is omitted, the global [Flame.images] is used.
  static Future<SpriteBatch> load(
    String path, {
    RSTransform? defaultTransform,
    Images? images,
    Color? defaultColor,
    BlendMode? defaultBlendMode,
    bool useAtlas = true,
  }) async {
    final imagesCache = images ?? Flame.images;
    return SpriteBatch(
      await imagesCache.load(path),
      defaultTransform: defaultTransform ?? RSTransform(1, 0, 0, 0),
      defaultColor: defaultColor,
      defaultBlendMode: defaultBlendMode,
      useAtlas: useAtlas,
      imageCache: imagesCache,
      imageKey: path,
    );
  }

  FlippedAtlasStatus _flippedAtlasStatus = FlippedAtlasStatus.none;

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

  /// The default color, used as a background color for a [BatchItem].
  final Color? defaultColor;

  /// The default transform, used when a transform was not supplied for a
  /// [BatchItem].
  final RSTransform? defaultTransform;

  /// The default blend mode, used for blending a batch item.
  final BlendMode? defaultBlendMode;

  /// The width of the [atlas].
  int get width => atlas.width;

  /// The height of the [atlas].
  int get height => atlas.height;

  /// The size of the [atlas].
  Vector2 get size => atlas.size;

  /// Whether to use [Canvas.drawAtlas] or not.
  final bool useAtlas;

  /// Does this batch contain any operations?
  bool get isEmpty => _batchItems.isEmpty;

  Future<void> _makeFlippedAtlas() async {
    _flippedAtlasStatus = FlippedAtlasStatus.generating;
    final key = '$imageKey#with-flips';
    atlas = await imageCache.fetchOrGenerate(
      key,
      () => _generateFlippedAtlas(atlas),
    );
    _flippedAtlasStatus = FlippedAtlasStatus.generated;
  }

  Future<Image> _generateFlippedAtlas(Image image) {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawImage(image, Offset.zero, _emptyPaint);
    canvas.scale(-1, 1);
    canvas.drawImage(image, Offset(-image.width * 2, 0), _emptyPaint);

    final picture = recorder.endRecording();
    return picture.toImageSafe(image.width * 2, image.height);
  }

  int get length => _sources.length;

  /// Replace provided values of a batch item at the [index], when a parameter
  /// is not provided, the original value of the batch item will be used.
  ///
  /// Throws an [ArgumentError] if the [index] is out of bounds.
  /// At least one of the parameters must be different from null.
  void replace(
    int index, {
    Rect? source,
    Color? color,
    RSTransform? transform,
  }) {
    assert(
      source != null || color != null || transform != null,
      'At least one of the parameters must be different from null.',
    );

    if (index < 0 || index >= length) {
      throw ArgumentError('Index out of bounds: $index');
    }

    final currentBatchItem = _batchItems[index];
    final newBatchItem = BatchItem(
      source: source ?? currentBatchItem.source,
      transform: transform ?? currentBatchItem.transform,
      color: color ?? currentBatchItem.paint.color,
      flip: currentBatchItem.flip,
    );

    _batchItems[index] = newBatchItem;

    _sources[index] = newBatchItem.source;
    _transforms[index] = newBatchItem.transform;
    _colors[index] = color ?? _defaultColor;
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

    if (flip && useAtlas && _flippedAtlasStatus.isNone) {
      _makeFlippedAtlas();
    }

    _batchItems.add(batchItem);
    _sources.add(
      flip
          ? Rect.fromLTWH(
              // The atlas is twice as wide when the flipped atlas is generated.
              (atlas.width * (_flippedAtlasStatus.isGenerated ? 1 : 2)) -
                  source.right,
              source.top,
              source.width,
              source.height,
            )
          : batchItem.source,
    );
    _transforms.add(batchItem.transform);
    _colors.add(color ?? _defaultColor);
  }

  /// Add a new batch item.
  ///
  /// The [source] parameter is the source location on the [atlas]. You can
  /// position it on the canvas using the [offset] parameter.
  ///
  /// You can transform the sprite from its [offset] using [scale], [rotation],
  /// [anchor] and [flip].
  ///
  /// The [color] parameter allows you to render a color behind the batch item,
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

  // Used to not create new Paint objects in [render] and
  // [generateFlippedAtlas].
  final _emptyPaint = Paint();

  void render(
    Canvas canvas, {
    BlendMode? blendMode,
    Rect? cullRect,
    Paint? paint,
  }) {
    if (isEmpty) {
      return;
    }

    final renderPaint = paint ?? _emptyPaint;

    final hasNoColors = _colors.every((c) => c == _defaultColor);
    final actualBlendMode = blendMode ?? defaultBlendMode;
    if (!hasNoColors && actualBlendMode == null) {
      throw 'When setting any colors, a blend mode must be provided.';
    }

    if (useAtlas && !_flippedAtlasStatus.isGenerating) {
      canvas.drawAtlas(
        atlas,
        _transforms,
        _sources,
        hasNoColors ? null : _colors,
        actualBlendMode,
        cullRect,
        renderPaint,
      );
    } else {
      for (final batchItem in _batchItems) {
        renderPaint.blendMode = blendMode ?? renderPaint.blendMode;

        canvas
          ..save()
          ..transform32(batchItem.matrix.storage)
          ..drawRect(batchItem.destination, batchItem.paint)
          ..drawImageRect(
            atlas,
            batchItem.source,
            batchItem.destination,
            renderPaint,
          )
          ..restore();
      }
    }
  }

  static const _defaultColor = Color(0x00000000);
}
