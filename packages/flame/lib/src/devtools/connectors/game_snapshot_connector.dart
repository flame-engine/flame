import 'dart:convert';
import 'dart:developer';
import 'dart:math';
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/src/devtools/dev_tools_connector.dart';

/// The [GameSnapshotConnector] is responsible for rendering the whole game,
/// the same way that it is currently shown on the screen, to a PNG image.
///
/// The optional `pixelRatio` parameter can be used to render the image in a
/// higher (or lower) resolution than the logical size of the game.
class GameSnapshotConnector extends DevToolsConnector {
  @override
  void init() {
    registerExtension(
      'ext.flame_devtools.getGameSnapshot',
      (method, parameters) async {
        final pixelRatio = double.tryParse(parameters['pixelRatio'] ?? '1');
        if (pixelRatio == null || !pixelRatio.isFinite || pixelRatio <= 0) {
          return ServiceExtensionResponse.error(
            ServiceExtensionResponse.invalidParams,
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

        final image = await snapshotGame(game, pixelRatio: pixelRatio);
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

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(
      max((size.x * pixelRatio).ceil(), 1),
      max((size.y * pixelRatio).ceil(), 1),
    );
    picture.dispose();
    return image;
  }
}
