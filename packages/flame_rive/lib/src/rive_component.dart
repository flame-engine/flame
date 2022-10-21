import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/rendering.dart';
import 'package:rive/rive.dart';
// ignore_for_file: implementation_imports
import 'package:rive/src/rive_core/math/aabb.dart';
import 'package:rive/src/rive_core/math/mat2d.dart';
import 'package:rive/src/rive_core/math/vec2d.dart';

class RiveComponent extends PositionComponent {
  final Artboard artboard;
  final RiveArtboardRenderer _renderer;

  RiveComponent({
    required this.artboard,
    bool antialiasing = true,
    bool useArtboardSize = true,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,

    // position component arguments
    super.position,
    super.size,
    super.scale,
    double super.angle = 0.0,
    Anchor super.anchor = Anchor.topLeft,
    super.children,
    super.priority,
  }) : _renderer = RiveArtboardRenderer(
          antialiasing: antialiasing,
          useArtboardSize: useArtboardSize,
          fit: fit,
          alignment: alignment,
          artboard: artboard,
        );

  @override
  void render(ui.Canvas canvas) {
    _renderer.render(canvas, size.toSize());
  }

  @override
  void update(double dt) {
    _renderer.advance(dt);
  }
}

class RiveArtboardRenderer {
  final Artboard artboard;
  final bool antialiasing;
  final bool useArtboardSize;
  final BoxFit fit;
  final Alignment alignment;

  RiveArtboardRenderer({
    required this.antialiasing,
    required this.useArtboardSize,
    required this.fit,
    required this.alignment,
    required this.artboard,
  }) {
    artboard.antialiasing = antialiasing;
  }

  void advance(double dt) {
    artboard.advance(dt, nested: true);
  }

  AABB get aabb {
    final width = artboard.width;
    final height = artboard.height;
    return AABB.fromValues(0, 0, width, height);
  }

  void render(Canvas canvas, ui.Size size) {
    _paint(canvas, aabb, size);
  }

  void _paint(Canvas canvas, AABB bounds, ui.Size size) {
    const position = Offset.zero;

    final contentWidth = bounds[2] - bounds[0];
    final contentHeight = bounds[3] - bounds[1];

    if (contentWidth == 0 || contentHeight == 0) {
      return;
    }

    final x = -1 * bounds[0] -
        contentWidth / 2.0 -
        (alignment.x * contentWidth / 2.0);
    final y = -1 * bounds[1] -
        contentHeight / 2.0 -
        (alignment.y * contentHeight / 2.0);

    var scaleX = 1.0, scaleY = 1.0;

    canvas.save();
    canvas.clipRect(position & size);

    // fit
    switch (fit) {
      case BoxFit.fill:
        scaleX = size.width / contentWidth;
        scaleY = size.height / contentHeight;
        break;
      case BoxFit.contain:
        final minScale =
            min(size.width / contentWidth, size.height / contentHeight);
        scaleX = scaleY = minScale;
        break;
      case BoxFit.cover:
        final maxScale =
            max(size.width / contentWidth, size.height / contentHeight);
        scaleX = scaleY = maxScale;
        break;
      case BoxFit.fitHeight:
        final minScale = size.height / contentHeight;
        scaleX = scaleY = minScale;
        break;
      case BoxFit.fitWidth:
        final minScale = size.width / contentWidth;
        scaleX = scaleY = minScale;
        break;
      case BoxFit.none:
        scaleX = scaleY = 1.0;
        break;
      case BoxFit.scaleDown:
        final minScale =
            min(size.width / contentWidth, size.height / contentHeight);
        scaleX = scaleY = minScale < 1.0 ? minScale : 1.0;
        break;
    }

    final transform = Mat2D();
    transform[4] = size.width / 2.0 + (alignment.x * size.width / 2.0);
    transform[5] = size.height / 2.0 + (alignment.y * size.height / 2.0);
    Mat2D.scale(transform, transform, Vec2D.fromValues(scaleX, scaleY));
    final center = Mat2D();
    center[4] = x;
    center[5] = y;
    Mat2D.multiply(transform, transform, center);

    // translation
    canvas.translate(
      size.width / 2.0 + (alignment.x * size.width / 2.0),
      size.height / 2.0 + (alignment.y * size.height / 2.0),
    );

    canvas.scale(scaleX, scaleY);
    canvas.translate(x, y);

    artboard.draw(canvas);
    canvas.restore();
  }
}

/// Loads the Artboard from the specified Rive File.
///
/// When [artboardName] is not null it returns the artboard with the specified
/// name, an assertion is triggered if no artboard with that name exists in the
/// file.
Future<Artboard> loadArtboard(
  FutureOr<RiveFile> file, {
  String? artboardName,
}) async {
  final loaded = await file;
  if (artboardName == null) {
    return loaded.mainArtboard.instance();
  } else {
    final artboard = loaded.artboardByName(artboardName)?.instance();
    assert(
      artboard != null,
      'No artboard with the specified name exists in the RiveFile',
    );
    return artboard!;
  }
}
