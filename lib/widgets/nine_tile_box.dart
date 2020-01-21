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

  @override
  void paint(Canvas canvas, Size size) {
    final topLeftCorner =
        Sprite.fromImage(image, x: 0, y: 0, width: tileSize, height: tileSize);
    final topRightCorner = Sprite.fromImage(image,
        x: tileSize * 2, y: 0, width: tileSize, height: tileSize);

    final bottomLeftCorner = Sprite.fromImage(image,
        x: 0, y: 2 * tileSize, width: tileSize, height: tileSize);
    final bottomRightCorner = Sprite.fromImage(image,
        x: tileSize * 2, y: 2 * tileSize, width: tileSize, height: tileSize);

    final topSide = Sprite.fromImage(image,
        x: tileSize, y: 0, width: tileSize, height: tileSize);
    final bottomSide = Sprite.fromImage(image,
        x: tileSize, y: tileSize * 2, width: tileSize, height: tileSize);

    final leftSide = Sprite.fromImage(image,
        x: 0, y: tileSize, width: tileSize, height: tileSize);
    final rightSide = Sprite.fromImage(image,
        x: tileSize * 2, y: tileSize, width: tileSize, height: tileSize);

    final middle = Sprite.fromImage(image,
        x: tileSize, y: tileSize, width: tileSize, height: tileSize);

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
    this.child,
    this.width,
    this.height,
    this.padding,
  });

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
