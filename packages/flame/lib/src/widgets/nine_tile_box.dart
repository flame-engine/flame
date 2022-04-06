import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../assets.dart';
import '../../flame.dart';
import '../nine_tile_box.dart' as non_widget;
import '../sprite.dart';
import 'base_future_builder.dart';

export '../nine_tile_box.dart';
export '../sprite.dart';

class _Painter extends CustomPainter {
  final ui.Image image;
  final double tileSize;
  final double destTileSize;
  late final non_widget.NineTileBox _nineTileBox;

  _Painter({
    required this.image,
    required this.tileSize,
    required this.destTileSize,
  }) : _nineTileBox = non_widget.NineTileBox(
          Sprite(image),
          tileSize: tileSize.toInt(),
          destTileSize: destTileSize.toInt(),
        );

  @override
  void paint(Canvas canvas, Size size) {
    _nineTileBox.drawRect(canvas, Offset.zero & size);
  }

  @override
  bool shouldRepaint(_) => false;
}

@Deprecated('Renamed to [NineTileBoxWidget], this will be remove in v1.2.0')
typedef NineTileBox = NineTileBoxWidget;

/// A [StatelessWidget] that renders NineTileBox
class NineTileBoxWidget extends StatelessWidget {
  final Future<ui.Image> Function() _imageFuture;

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

  NineTileBoxWidget({
    required ui.Image image,
    required this.tileSize,
    required this.destTileSize,
    this.width,
    this.height,
    this.child,
    this.errorBuilder,
    this.loadingBuilder,
    Key? key,
  })  : _imageFuture = (() => Future.value(image)),
        super(key: key);

  NineTileBoxWidget.asset({
    required String path,
    required this.tileSize,
    required this.destTileSize,
    Images? images,
    this.width,
    this.height,
    this.child,
    this.errorBuilder,
    this.loadingBuilder,
    Key? key,
  })  : _imageFuture = (() => (images ?? Flame.images).load(path)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseFutureBuilder<ui.Image>(
      futureBuilder: _imageFuture,
      builder: (_, image) {
        return _NineTileBox(
          image: image,
          tileSize: tileSize,
          destTileSize: destTileSize,
          width: width,
          height: height,
          child: child,
        );
      },
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
    );
  }
}

class _NineTileBox extends StatelessWidget {
  final ui.Image image;
  final double tileSize;
  final double destTileSize;
  final double? width;
  final double? height;

  final Widget? child;

  final EdgeInsetsGeometry? padding;

  const _NineTileBox({
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
