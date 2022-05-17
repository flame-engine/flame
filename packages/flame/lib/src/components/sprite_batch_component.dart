import 'dart:ui';

import 'package:flame/src/components/component.dart';
import 'package:flame/src/sprite_batch.dart';
import 'package:meta/meta.dart';

class SpriteBatchComponent extends Component {
  SpriteBatch? spriteBatch;
  BlendMode? blendMode;
  Rect? cullRect;
  Paint? paint;

  /// Creates a component with an empty sprite batch which can be set later
  SpriteBatchComponent({
    this.spriteBatch,
    this.blendMode,
    this.cullRect,
    this.paint,
  });

  @override
  @mustCallSuper
  void onMount() {
    assert(
      spriteBatch != null,
      'You have to set spriteBatch in either the constructor or in onLoad',
    );
  }

  @mustCallSuper
  @override
  void render(Canvas canvas) {
    spriteBatch?.render(
      canvas,
      blendMode: blendMode,
      cullRect: cullRect,
      paint: paint,
    );
  }
}
