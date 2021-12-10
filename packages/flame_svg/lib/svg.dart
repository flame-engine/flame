import 'package:flame/assets.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A [Svg] to be rendered on a Flame [Game].
class Svg {
  /// The [DrawableRoot] that this [Svg] represents.
  DrawableRoot svgRoot;

  /// Creates an [Svg] with the received [svgRoot].
  Svg(this.svgRoot);

  /// Loads an [Svg] with the received [cache]. When no [cache] is provided,
  /// the global [Flame.assets] is used.
  static Future<Svg> load(String fileName, {AssetsCache? cache}) async {
    cache ??= Flame.assets;
    final svgString = await cache.readFile(fileName);
    return Svg(await svg.fromSvgString(svgString, svgString));
  }

  /// Renders the svg on the [canvas] using the dimensions provided by [size].
  void render(Canvas canvas, Vector2 size) {
    svgRoot.scaleCanvasToViewBox(canvas, size.toSize());
    svgRoot.draw(canvas, svgRoot.viewport.viewBoxRect);
  }

  /// Renders the svg on the [canvas] on the given [position] using the
  /// dimensions provided by [size].
  void renderPosition(
    Canvas canvas,
    Vector2 position,
    Vector2 size,
  ) {
    canvas.renderAt(position, (c) => render(c, size));
  }
}

/// Provides a loading method for [Svg] on the [Game] class.
extension SvgLoader on Game {
  /// Loads an [Svg] using the [Game]'s own asset loader.
  Future<Svg> loadSvg(String fileName) => Svg.load(fileName, cache: assets);
}
