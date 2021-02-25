import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../extensions/vector2.dart';
import '../sprite.dart';

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
