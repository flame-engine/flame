import 'dart:convert';
import 'dart:developer';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/devtools/dev_tools_connector.dart';
import 'package:flame/src/devtools/snapshot_annotations.dart';

/// The [GameSnapshotConnector] is responsible for rendering the whole game,
/// the same way that it is currently shown on the screen, to a PNG image.
///
/// The optional `pixelRatio` parameter can be used to render the image in a
/// higher (or lower) resolution than the logical size of the game. With the
/// `world` parameter set to `true`, or a `rect` given as `x,y,width,height`
/// in world coordinates, the world is rendered directly instead of through
/// the camera, which also shows the components that are off screen. See
/// [SnapshotOptions] for the parameters that annotate the image and limit its
/// size.
class GameSnapshotConnector() extends DevToolsConnector {
  @override
  void init() {
    registerExtension(
      'ext.flame_devtools.getGameSnapshot',
      (method, parameters) async {
        final pixelRatio = double.tryParse(parameters['pixelRatio'] ?? '1');
        if (pixelRatio == null || !pixelRatio.isFinite || pixelRatio <= 0) {
          return _invalidParams(
            'pixelRatio has to be a positive number, '
            'got ${parameters['pixelRatio']}.',
          );
        }
        final SnapshotOptions options;
        try {
          options = SnapshotOptions.parse(parameters);
        } on FormatException catch (error) {
          return _invalidParams(error.message);
        }
        if (!game.hasLayout) {
          return ServiceExtensionResponse.error(
            ServiceExtensionResponse.extensionError,
            'The game has not been laid out yet, so it has no size to render.',
          );
        }

        final Image image;
        final double effectivePixelRatio;
        var annotations = const <SnapshotAnnotation>[];
        final rectParameter = parameters['rect'];
        if (rectParameter != null || parameters['world'] == 'true') {
          final rect = rectParameter == null
              ? worldBounds(game.world)
              : _parseRect(rectParameter);
          if (rect == null) {
            return _invalidParams(
              rectParameter == null
                  ? 'The world has no components with a size, pass a rect '
                        'to render.'
                  : 'rect has to be four numbers x,y,width,height with a '
                        'positive width and height, got $rectParameter.',
            );
          }
          effectivePixelRatio = options.fitPixelRatio(pixelRatio, rect.size);
          if (options.annotate) {
            annotations = annotateWorld(
              game,
              rect,
              pixelRatio: effectivePixelRatio,
              filter: options.annotationFilter,
            );
          }
          image = await snapshotWorld(
            game,
            rect,
            pixelRatio: effectivePixelRatio,
            annotations: annotations,
          );
        } else {
          effectivePixelRatio = options.fitPixelRatio(
            pixelRatio,
            game.canvasSize.toSize(),
          );
          if (options.annotate) {
            annotations = annotateGame(
              game,
              pixelRatio: effectivePixelRatio,
              filter: options.annotationFilter,
            );
          }
          image = await snapshotGame(
            game,
            pixelRatio: effectivePixelRatio,
            annotations: annotations,
          );
        }

        final width = image.width;
        final height = image.height;
        final snapshot = await encodePng(image);

        return ServiceExtensionResponse.result(
          json.encode({
            'snapshot': snapshot,
            'width': width,
            'height': height,
            'pixelRatio': effectivePixelRatio,
            if (options.annotate)
              'annotations': [
                for (final annotation in annotations) annotation.toJson(),
              ],
          }),
        );
      },
    );
  }

  /// Renders the whole [game], including its background color, to an image
  /// with the size of the game's canvas multiplied by [pixelRatio].
  ///
  /// Flutter overlays are not part of the game's canvas, so they are not
  /// included in the image. The [annotations] are drawn on top of the game.
  static Future<Image> snapshotGame(
    FlameGame game, {
    double pixelRatio = 1,
    List<SnapshotAnnotation> annotations = const [],
  }) async {
    final size = game.canvasSize;
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder)
      ..save()
      ..scale(pixelRatio)
      ..drawColor(game.backgroundColor(), BlendMode.src);

    game.render(canvas);
    canvas.restore();
    SnapshotAnnotation.paint(
      canvas,
      annotations,
      imageSize(size.x, size.y, pixelRatio),
    );

    return await _toImage(pictureRecorder, size.x, size.y, pixelRatio);
  }

  /// Finds where the visible position components are in a snapshot of the
  /// whole [game], taken with [snapshotGame].
  static List<SnapshotAnnotation> annotateGame(
    FlameGame game, {
    double pixelRatio = 1,
    RegExp? filter,
  }) {
    return SnapshotAnnotation.collect(
      game,
      space: game,
      imageSize: imageSize(game.canvasSize.x, game.canvasSize.y, pixelRatio),
      pixelRatio: pixelRatio,
      filter: filter,
    );
  }

  /// Renders the [rect] of the world of the [game], in world coordinates,
  /// directly and without the camera, to an image with the size of the rect
  /// multiplied by [pixelRatio].
  ///
  /// The [annotations] are drawn on top of the world.
  static Future<Image> snapshotWorld(
    FlameGame game,
    Rect rect, {
    double pixelRatio = 1,
    List<SnapshotAnnotation> annotations = const [],
  }) async {
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder)
      ..save()
      ..scale(pixelRatio)
      ..drawColor(game.backgroundColor(), BlendMode.src)
      ..translate(-rect.left, -rect.top);

    for (final child in game.world.children) {
      child.renderTree(canvas);
    }
    canvas.restore();
    SnapshotAnnotation.paint(
      canvas,
      annotations,
      imageSize(rect.width, rect.height, pixelRatio),
    );

    return await _toImage(pictureRecorder, rect.width, rect.height, pixelRatio);
  }

  /// Finds where the visible position components are in a snapshot of the
  /// [rect] of the world of the [game], taken with [snapshotWorld].
  static List<SnapshotAnnotation> annotateWorld(
    FlameGame game,
    Rect rect, {
    double pixelRatio = 1,
    RegExp? filter,
  }) {
    return SnapshotAnnotation.collect(
      game.world,
      space: game.world,
      imageSize: imageSize(rect.width, rect.height, pixelRatio),
      origin: rect.topLeft,
      pixelRatio: pixelRatio,
      filter: filter,
    );
  }

  /// The smallest rectangle, in world coordinates, that contains every
  /// [PositionComponent] in the [world], or null if there is none.
  static Rect? worldBounds(World world) {
    Rect? bounds;
    for (final component in world.descendants()) {
      if (component is PositionComponent) {
        final rect = component.toAbsoluteRect();
        bounds = bounds == null ? rect : bounds.expandToInclude(rect);
      }
    }
    if (bounds == null || bounds.isEmpty) {
      return null;
    }
    return bounds;
  }

  /// The size in pixels of an image that is rendered from the logical [width]
  /// and [height] with [pixelRatio].
  static Size imageSize(double width, double height, double pixelRatio) {
    return Size(
      max((width * pixelRatio).ceil(), 1).toDouble(),
      max((height * pixelRatio).ceil(), 1).toDouble(),
    );
  }

  static Future<Image> _toImage(
    PictureRecorder pictureRecorder,
    double width,
    double height,
    double pixelRatio,
  ) async {
    final picture = pictureRecorder.endRecording();
    final size = imageSize(width, height, pixelRatio);
    final image = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    picture.dispose();
    return image;
  }

  static Rect? _parseRect(String value) {
    final parts = value.split(',').map(double.tryParse).toList();
    if (parts.length != 4 || parts.any((p) => p == null || !p.isFinite)) {
      return null;
    }
    final rect = Rect.fromLTWH(parts[0]!, parts[1]!, parts[2]!, parts[3]!);
    return rect.width <= 0 || rect.height <= 0 ? null : rect;
  }

  static ServiceExtensionResponse _invalidParams(String message) {
    return ServiceExtensionResponse.error(
      ServiceExtensionResponse.invalidParams,
      message,
    );
  }
}
