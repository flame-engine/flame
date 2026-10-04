import 'dart:ui';

import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/components/mixins/image_retainer.dart';
import 'package:flame/src/sprite_batch.dart';
import 'package:meta/meta.dart';

/// A component that renders a [SpriteBatch], which can also be set later.
class SpriteBatchComponent({
  var SpriteBatch? _spriteBatch,
  var BlendMode? blendMode,
  var Rect? cullRect,
  var Paint? paint,
  super.key,
  super.children,
  super.priority,
}) extends Component with ImageRetainer {
  /// The atlas that was retained at the last render, so that a [SpriteBatch]
  /// that swaps its atlas for a flipped one gets the new atlas retained.
  Image? _retainedAtlas;

  /// The [SpriteBatch] that this component renders.
  SpriteBatch? get spriteBatch => _spriteBatch;

  set spriteBatch(SpriteBatch? value) {
    _spriteBatch = value;
    updateRetainedImages();
  }

  @override
  Iterable<Image> get retainedImages {
    final atlas = _spriteBatch?.atlas;
    return atlas == null ? const [] : [atlas];
  }

  @override
  @mustCallSuper
  void onMount() {
    assert(
      spriteBatch != null,
      'You have to set spriteBatch in either the constructor or in onLoad',
    );
    super.onMount();
  }

  @mustCallSuper
  @override
  void render(Canvas canvas) {
    final spriteBatch = _spriteBatch;
    if (spriteBatch == null) {
      return;
    }
    if (!identical(spriteBatch.atlas, _retainedAtlas)) {
      _retainedAtlas = spriteBatch.atlas;
      updateRetainedImages();
    }
    spriteBatch.render(
      canvas,
      blendMode: blendMode,
      cullRect: cullRect,
      paint: paint,
    );
  }
}
