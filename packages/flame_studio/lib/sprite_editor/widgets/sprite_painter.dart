import 'dart:ui' as ui;

import 'package:flame_studio/sprite_editor/widgets/sprite_view_transform.dart';
import 'package:flutter/material.dart';

/// {@template sprite_painter}
/// Draws the image of the sprite editor, without smoothing so that its
/// pixels can be told apart, dimming everything but the selected region.
/// {@endtemplate}
class const SpritePainter({
  /// The image.
  required final ui.Image image,

  /// The selected region, in pixels of the image.
  required final Rect region,

  /// Where the image is drawn.
  required final SpriteViewTransform transform,
}) extends CustomPainter {
  /// {@macro sprite_painter}
  this;

  /// The color of the selection and of its handles.
  static const accentColor = Color(0xFFFF00FF);

  /// The color laid over the parts of the image that aren't selected.
  static const dimColor = Color(0x99000000);

  /// The radius of the handles.
  static const handleRadius = 5.0;

  @override
  void paint(Canvas canvas, Size size) {
    final source = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final destination = transform.rectToCanvas(source);
    final selection = transform.rectToCanvas(region);

    canvas
      ..drawImageRect(
        image,
        source,
        destination,
        Paint()..filterQuality = FilterQuality.none,
      )
      ..drawPath(
        Path.combine(
          PathOperation.difference,
          Path()..addRect(destination),
          Path()..addRect(selection),
        ),
        Paint()..color = dimColor,
      )
      ..drawRect(
        selection,
        Paint()
          ..color = accentColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

    for (final handle in SpriteRegionHandle.values) {
      final center = transform.handleOffset(handle, region);
      canvas
        ..drawCircle(center, handleRadius, Paint()..color = Colors.white)
        ..drawCircle(
          center,
          handleRadius,
          Paint()
            ..color = accentColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
    }
  }

  @override
  bool shouldRepaint(SpritePainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.region != region ||
        oldDelegate.transform != transform;
  }
}
