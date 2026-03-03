import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/rendering.dart';
import 'package:rive/rive.dart';

class RiveComponent extends PositionComponent {
  final Artboard artboard;
  final StateMachine? stateMachine;
  final Alignment _alignment;
  final bool _clipToBounds;
  final Fit _riveFit;
  final Paint? _layerPaint;

  late Size _renderSize;
  AABB _frame = AABB();
  Size _frameSize = Size.zero;

  RiveComponent({
    required this.artboard,
    this.stateMachine,
    bool antialiasing = true,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
    bool clipToBounds = false,
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
  }) : _alignment = alignment,
       _clipToBounds = clipToBounds,
       _riveFit = _toRiveFit(fit),
       _layerPaint = antialiasing ? null : (Paint()..isAntiAlias = false),
       super(size: size ?? Vector2(artboard.width, artboard.height)) {
    void updateRenderSize() {
      _renderSize = this.size.toSize();
    }

    this.size.addListener(updateRenderSize);
    updateRenderSize();
  }

  @override
  void render(Canvas canvas) {
    canvas.save();

    if (_clipToBounds) {
      canvas.clipRect(Offset.zero & _renderSize);
    }

    if (_layerPaint != null) {
      canvas.saveLayer(Offset.zero & _renderSize, _layerPaint);
    }

    final renderer = Renderer.make(canvas);
    try {
      if (_frameSize != _renderSize) {
        _frameSize = _renderSize;
        _frame = AABB.fromValues(
          0,
          0,
          _renderSize.width,
          _renderSize.height,
        );
      }

      renderer.align(
        _riveFit,
        _alignment,
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

  @override
  void update(double dt) {
    if (stateMachine != null) {
      stateMachine!.advanceAndApply(dt);
    } else {
      artboard.advance(dt);
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
