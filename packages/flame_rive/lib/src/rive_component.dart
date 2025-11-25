import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/rendering.dart';
import 'package:rive/math.dart';
import 'package:rive/rive.dart';

class RiveComponent extends PositionComponent {
  final Artboard artboard;
  final RiveArtboardRenderer _renderer;
  late Size _renderSize;

  RiveComponent({
    required this.artboard,
    bool antialiasing = true,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,

    // position component arguments
    super.position,

    /// The logical size of the component.
    /// Default value is ArtboardSize
    Vector2? size,
    super.scale,
    super.angle = 0.0,
    super.anchor = Anchor.topLeft,
    super.children,
    super.priority,
    super.key,
  }) : _renderer = RiveArtboardRenderer(
         antialiasing: antialiasing,
         fit: fit,
         alignment: alignment,
         artboard: artboard,
       ),
       super(size: size ?? Vector2(artboard.width, artboard.height)) {
    void updateRenderSize() {
      _renderSize = this.size.toSize();
    }

    this.size.addListener(updateRenderSize);
    updateRenderSize();
  }

  @override
  void render(Canvas canvas) {
    _renderer.render(canvas, _renderSize);
  }

  @override
  void update(double dt) {
    _renderer.advance(dt);
  }
}

class RiveArtboardRenderer {
  final Artboard artboard;
  final bool antialiasing;
  final BoxFit fit;
  final Alignment alignment;

  RiveArtboardRenderer({
    required this.antialiasing,
    required this.fit,
    required this.alignment,
    required this.artboard,
  }) {
    artboard.antialiasing = antialiasing;
  }

  void advance(double dt) {
    artboard.advance(dt, nested: true);
  }

  late final aabb = AABB.fromValues(0, 0, artboard.width, artboard.height);

  void render(Canvas canvas, Size size) {
    _paint(canvas, aabb, size);
  }

  final _transform = Mat2D();
  final _center = Mat2D();

  void _paint(Canvas canvas, AABB bounds, Size size) {
    const position = Offset.zero;

    final contentWidth = bounds[2] - bounds[0];
    final contentHeight = bounds[3] - bounds[1];

    if (contentWidth == 0 || contentHeight == 0) {
      return;
    }

    final x =
        -1 * bounds[0] -
        contentWidth / 2.0 -
        (alignment.x * contentWidth / 2.0);
    final y =
        -1 * bounds[1] -
        contentHeight / 2.0 -
        (alignment.y * contentHeight / 2.0);

    var scaleX = 1.0;
    var scaleY = 1.0;

    canvas.save();
    if (artboard.clip) {
      canvas.clipRect(position & size);
    }

    switch (fit) {
      case BoxFit.fill:
        scaleX = size.width / contentWidth;
        scaleY = size.height / contentHeight;
      case BoxFit.contain:
        final minScale = min(
          size.width / contentWidth,
          size.height / contentHeight,
        );
        scaleX = scaleY = minScale;
      case BoxFit.cover:
        final maxScale = max(
          size.width / contentWidth,
          size.height / contentHeight,
        );
        scaleX = scaleY = maxScale;
      case BoxFit.fitHeight:
        final minScale = size.height / contentHeight;
        scaleX = scaleY = minScale;
      case BoxFit.fitWidth:
        final minScale = size.width / contentWidth;
        scaleX = scaleY = minScale;
      case BoxFit.none:
        scaleX = scaleY = 1.0;
      case BoxFit.scaleDown:
        final minScale = min(
          size.width / contentWidth,
          size.height / contentHeight,
        );
        scaleX = scaleY = minScale < 1.0 ? minScale : 1.0;
    }

    Mat2D.setIdentity(_transform);
    _transform[4] = size.width / 2.0 + (alignment.x * size.width / 2.0);
    _transform[5] = size.height / 2.0 + (alignment.y * size.height / 2.0);
    Mat2D.scale(_transform, _transform, Vec2D.fromValues(scaleX, scaleY));
    Mat2D.setIdentity(_center);
    _center[4] = x;
    _center[5] = y;
    Mat2D.multiply(_transform, _transform, _center);

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
