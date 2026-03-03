import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/rendering.dart';
import 'package:rive/rive.dart';

class RiveComponent extends PositionComponent {
  final Artboard artboard;
  final StateMachine? stateMachine;
  final RiveArtboardRenderer _renderer;
  late Size _renderSize;

  RiveComponent({
    required this.artboard,
    this.stateMachine,
    bool antialiasing = true,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
    bool clipToBounds = false,

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
         clipToBounds: clipToBounds,
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
    if (stateMachine != null) {
      stateMachine!.advanceAndApply(dt);
    } else {
      _renderer.advance(dt);
    }
  }
}

class RiveArtboardRenderer {
  final Artboard artboard;
  final bool antialiasing;
  final BoxFit fit;
  final Alignment alignment;
  final bool clipToBounds;

  RiveArtboardRenderer({
    required this.antialiasing,
    required this.fit,
    required this.alignment,
    required this.artboard,
    required this.clipToBounds,
  });

  void advance(double dt) {
    artboard.advance(dt);
  }

  void render(Canvas canvas, Size size) {
    _paint(canvas, size);
  }

  void _paint(Canvas canvas, Size size) {
    canvas.save();

    if (clipToBounds) {
      canvas.clipRect(Offset.zero & size);
    }

    if (!antialiasing) {
      canvas.saveLayer(
        Offset.zero & size,
        Paint()..isAntiAlias = false,
      );
    }

    final renderer = Renderer.make(canvas);
    try {
      final artboardBounds = artboard.bounds;
      final frame = AABB.fromValues(0, 0, size.width, size.height);

      // Convert BoxFit to Rive Fit
      final riveFit = _toRiveFit(fit);

      renderer.align(
        riveFit,
        alignment,
        frame,
        artboardBounds,
        1.0,
      );
      artboard.draw(renderer);
    } finally {
      renderer.dispose();
      if (!antialiasing) {
        canvas.restore();
      }
      canvas.restore();
    }
  }

  Fit _toRiveFit(BoxFit fit) {
    switch (fit) {
      case BoxFit.fill:
        return Fit.fill;
      case BoxFit.contain:
        return Fit.contain;
      case BoxFit.cover:
        return Fit.cover;
      case BoxFit.fitHeight:
        return Fit.fitHeight;
      case BoxFit.fitWidth:
        return Fit.fitWidth;
      case BoxFit.none:
        return Fit.none;
      case BoxFit.scaleDown:
        return Fit.scaleDown;
    }
  }
}

/// Loads the Artboard from the specified Rive File.
///
/// When [artboardName] is not null it returns the artboard with the specified
/// name, an assertion is triggered if no artboard with that name exists in the
/// file.
Future<Artboard> loadArtboard(
  FutureOr<File> file, {
  String? artboardName,
}) async {
  final loaded = await file;
  if (artboardName == null) {
    return loaded.defaultArtboard()!;
  } else {
    final artboard = loaded.artboard(artboardName);
    assert(
      artboard != null,
      'No artboard with the specified name exists in the RiveFile',
    );
    return artboard!;
  }
}
