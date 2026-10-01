import 'dart:convert';
import 'dart:developer';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/devtools/dev_tools_connector.dart';

/// The [GameSnapshotConnector] is responsible for rendering the whole game,
/// the same way that it is currently shown on the screen, to a PNG image.
///
/// The optional `pixelRatio` parameter can be used to render the image in a
/// higher (or lower) resolution than the logical size of the game. With the
/// `world` parameter set to `true`, or a `rect` given as `x,y,width,height`
/// in world coordinates, the world is rendered directly instead of through
/// the camera, which also shows the components that are off screen.
class GameSnapshotConnector extends DevToolsConnector {
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
        if (!game.hasLayout) {
          return ServiceExtensionResponse.error(
            ServiceExtensionResponse.extensionError,
            'The game has not been laid out yet, so it has no size to render.',
          );
        }

        final Image image;
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
          image = await snapshotWorld(game, rect, pixelRatio: pixelRatio);
        } else {
          image = await snapshotGame(game, pixelRatio: pixelRatio);
        }

        final width = image.width;
        final height = image.height;
        final snapshot = await encodePng(image);

        return ServiceExtensionResponse.result(
          json.encode({
            'snapshot': snapshot,
            'width': width,
            'height': height,
          }),
        );
      },
    );
  }

  /// Renders the whole [game], including its background color, to an image
  /// with the size of the game's canvas multiplied by [pixelRatio].
  ///
  /// Flutter overlays are not part of the game's canvas, so they are not
  /// included in the image.
  static Future<Image> snapshotGame(
    FlameGame game, {
    double pixelRatio = 1,
  }) async {
    final size = game.canvasSize;
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder)
      ..scale(pixelRatio)
      ..drawColor(game.backgroundColor(), BlendMode.src);

    game.render(canvas);

    return _toImage(pictureRecorder, size.x, size.y, pixelRatio);
  }

  /// Renders the [rect] of the world of the [game], in world coordinates,
  /// directly and without the camera, to an image with the size of the rect
  /// multiplied by [pixelRatio].
  static Future<Image> snapshotWorld(
    FlameGame game,
    Rect rect, {
    double pixelRatio = 1,
  }) async {
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder)
      ..scale(pixelRatio)
      ..drawColor(game.backgroundColor(), BlendMode.src)
      ..translate(-rect.left, -rect.top);

    for (final child in game.world.children) {
      child.renderTree(canvas);
    }

    return _toImage(pictureRecorder, rect.width, rect.height, pixelRatio);
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

  static Future<Image> _toImage(
    PictureRecorder pictureRecorder,
    double width,
    double height,
    double pixelRatio,
  ) async {
    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(
      max((width * pixelRatio).ceil(), 1),
      max((height * pixelRatio).ceil(), 1),
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
