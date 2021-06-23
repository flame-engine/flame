import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../../assets.dart';
import '../../flame.dart';
import '../extensions/vector2.dart';
import '../sprite.dart';
import 'base_future_builder.dart';

export '../nine_tile_box.dart';
export '../sprite.dart';

class _Painter extends CustomPainter {
  final ui.Image image;
  final double tileSize;
  final double destTileSize;

  _Painter({
    required this.image,
    required this.tileSize,
    required this.destTileSize,
  });

  Sprite _getSpriteTile(double x, double y) =>
      Sprite(image, srcPosition: Vector2(x, y), srcSize: Vector2.all(tileSize));

  @override
  void paint(Canvas canvas, Size size) {
    final topLeftCorner = _getSpriteTile(0, 0);
    final topRightCorner = _getSpriteTile(tileSize * 2, 0);

    final bottomLeftCorner = _getSpriteTile(0, 2 * tileSize);
    final bottomRightCorner = _getSpriteTile(tileSize * 2, 2 * tileSize);

    final topSide = _getSpriteTile(tileSize, 0);
    final bottomSide = _getSpriteTile(tileSize, tileSize * 2);

    final leftSide = _getSpriteTile(0, tileSize);
    final rightSide = _getSpriteTile(tileSize * 2, tileSize);

    final middle = _getSpriteTile(tileSize, tileSize);

    final horizontalWidget = size.width - destTileSize * 2;
    final verticalHeight = size.height - destTileSize * 2;

    void render(Sprite sprite, double x, double y, double w, double h) {
      sprite.render(canvas, position: Vector2(x, y), size: Vector2(w, h));
    }

    // Middle
    render(
      middle,
      destTileSize,
      destTileSize,
      horizontalWidget,
      verticalHeight,
    );

    // Top and bottom side
    render(
      topSide,
      destTileSize,
      0,
      horizontalWidget,
      destTileSize,
    );
    render(
      bottomSide,
      destTileSize,
      size.height - destTileSize,
      horizontalWidget,
      destTileSize,
    );

    // Left and right side
    render(
      leftSide,
      0,
      destTileSize,
      destTileSize,
      verticalHeight,
    );
    render(
      rightSide,
      size.width - destTileSize,
      destTileSize,
      destTileSize,
      verticalHeight,
    );

    // Corners
    render(
      topLeftCorner,
      0,
      0,
      destTileSize,
      destTileSize,
    );
    render(
      topRightCorner,
      size.width - destTileSize,
      0,
      destTileSize,
      destTileSize,
    );
    render(
      bottomLeftCorner,
      0,
      size.height - destTileSize,
      destTileSize,
      destTileSize,
    );
    render(
      bottomRightCorner,
      size.width - destTileSize,
      size.height - destTileSize,
      destTileSize,
      destTileSize,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

/// A [StatefulWidget] which loads an image and metadata
/// and renders a [NineTileBox]
class NineTileBoxBuilder extends StatefulWidget {
  /// Image [path] used for the nine tile box
  final String path;

  /// The size of the tile on the image
  final double tileSize;

  /// The size of the tile that will be used to render on the canvas
  final double destTileSize;
  final double? width;
  final double? height;

  final Widget? child;

  /// A builder function that is called if the loading fails
  final WidgetBuilder? errorBuilder;

  /// A builder function that is called while the loading is on the way
  final WidgetBuilder? loadingBuilder;

  /// Images instance used to load the image, uses Flame.images when
  /// omitted
  final Images? images;

  const NineTileBoxBuilder({
    required this.path,
    required this.tileSize,
    required this.destTileSize,
    this.width,
    this.height,
    this.child,
    this.images,
    this.errorBuilder,
    this.loadingBuilder,
  });

  @override
  State<StatefulWidget> createState() {
    return _NineTileBoxBuilderState();
  }
}

class _NineTileBoxBuilderState extends State<NineTileBoxBuilder> {
  late Future<ui.Image> _imageFuture;

  @override
  void initState() {
    super.initState();

    final images = widget.images ?? Flame.images;

    _imageFuture = images.load(widget.path);
  }

  @override
  Widget build(BuildContext context) {
    return BaseFutureBuilder<ui.Image>(
      future: _imageFuture,
      builder: (_, image) {
        return NineTileBox(
          image: image,
          tileSize: widget.tileSize,
          destTileSize: widget.destTileSize,
          width: widget.width,
          height: widget.height,
          child: widget.child,
        );
      },
      errorBuilder: widget.errorBuilder,
      loadingBuilder: widget.loadingBuilder,
    );
  }
}

class NineTileBox extends StatelessWidget {
  final ui.Image image;
  final double tileSize;
  final double destTileSize;
  final double? width;
  final double? height;

  final Widget? child;

  final EdgeInsetsGeometry? padding;

  const NineTileBox({
    required this.image,
    required this.tileSize,
    required this.destTileSize,
    Key? key,
    this.child,
    this.width,
    this.height,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _Painter(
          image: image,
          tileSize: tileSize,
          destTileSize: destTileSize,
        ),
        child: Container(
          child: child,
          padding: padding,
        ),
      ),
    );
  }
}
