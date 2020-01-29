import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:meta/meta.dart';
import '../sprite.dart';
import 'dart:ui';

class _Painter extends widgets.CustomPainter {
  final Image image;
  final double tileSize;
  final double destTileSize;

  _Painter(
      {@required this.image,
      @required this.tileSize,
      @required this.destTileSize});

  Sprite _getSpriteTile(double x, double y) =>
      Sprite.fromImage(image, x: x, y: y, width: tileSize, height: tileSize);

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

    // Middle
    for (var y = destTileSize;
        y < size.height - destTileSize;
        y = y + destTileSize) {
      for (var x = destTileSize;
          x < size.width - destTileSize;
          x = x + destTileSize) {
        middle.renderRect(
            canvas, Rect.fromLTWH(x, y, destTileSize, destTileSize));
      }
    }

    // Top and bottom side
    for (var i = destTileSize;
        i < size.width - destTileSize;
        i = i + destTileSize) {
      topSide.renderRect(
          canvas, Rect.fromLTWH(i, 0, destTileSize, destTileSize));
      bottomSide.renderRect(
          canvas,
          Rect.fromLTWH(
              i, size.height - destTileSize, destTileSize, destTileSize));
    }

    // Left and right side
    for (var i = destTileSize;
        i < size.height - destTileSize;
        i = i + destTileSize) {
      leftSide.renderRect(
          canvas, Rect.fromLTWH(0, i, destTileSize, destTileSize));
      rightSide.renderRect(
          canvas,
          Rect.fromLTWH(
              size.width - destTileSize, i, destTileSize, destTileSize));
    }

    // Corners
    topLeftCorner.renderRect(
        canvas, Rect.fromLTWH(0, 0, destTileSize, destTileSize));
    topRightCorner.renderRect(
        canvas,
        Rect.fromLTWH(
            size.width - destTileSize, 0, destTileSize, destTileSize));

    bottomLeftCorner.renderRect(
        canvas,
        Rect.fromLTWH(
            0, size.height - destTileSize, destTileSize, destTileSize));
    bottomRightCorner.renderRect(
        canvas,
        Rect.fromLTWH(size.width - destTileSize, size.height - destTileSize,
            destTileSize, destTileSize));
  }

  @override
  bool shouldRepaint(_) => false;
}

class NineTileBox extends widgets.StatelessWidget {
  final Image image;
  final double tileSize;
  final double destTileSize;
  final double width;
  final double height;

  final widgets.Widget child;

  final widgets.EdgeInsetsGeometry padding;

  NineTileBox({
    @required this.image,
    @required this.tileSize,
    @required this.destTileSize,
    Key key,
    this.child,
    this.width,
    this.height,
    this.padding,
  }) : super(key: key);

  @override
  widgets.Widget build(widgets.BuildContext context) {
    return widgets.Container(
      width: width,
      height: height,
      child: widgets.CustomPaint(
        painter: _Painter(
          image: image,
          tileSize: tileSize,
          destTileSize: destTileSize,
        ),
        child: widgets.Container(
          child: child,
          padding: padding,
        ),
      ),
    );
  }
}
