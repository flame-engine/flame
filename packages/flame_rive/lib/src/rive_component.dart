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
  final Alignment alignment;
  final bool clipToBounds;
  final Fit _riveFit;
  final Paint? _layerPaint;

  AABB _frame = AABB();
  Size _frameSize = Size.zero;

  RiveArtboardRenderer({
    required bool antialiasing,
    required BoxFit fit,
    required this.alignment,
    required this.artboard,
    required this.clipToBounds,
  }) : _riveFit = _toRiveFit(fit),
       _layerPaint = antialiasing ? null : (Paint()..isAntiAlias = false);

  void advance(double dt) {
    artboard.advance(dt);
  }

  void render(Canvas canvas, Size size) {
    canvas.save();

    if (clipToBounds) {
      canvas.clipRect(Offset.zero & size);
    }

    if (_layerPaint != null) {
      canvas.saveLayer(Offset.zero & size, _layerPaint);
    }

    final renderer = Renderer.make(canvas);
    try {
      if (_frameSize != size) {
        _frameSize = size;
        _frame = AABB.fromValues(0, 0, size.width, size.height);
      }

      renderer.align(
        _riveFit,
        alignment,
        _frame,
        artboard.bounds,
        1.0,
      );
      artboard.draw(renderer);
    } finally {
      renderer.dispose();
      if (_layerPaint != null) {
        canvas.restore();
      }
      canvas.restore();
    }
  }

  static Fit _toRiveFit(BoxFit fit) => switch (fit) {
    BoxFit.fill => Fit.fill,
    BoxFit.contain => Fit.contain,
    BoxFit.cover => Fit.cover,
    BoxFit.fitHeight => Fit.fitHeight,
    BoxFit.fitWidth => Fit.fitWidth,
    BoxFit.none => Fit.none,
    BoxFit.scaleDown => Fit.scaleDown,
  };
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
