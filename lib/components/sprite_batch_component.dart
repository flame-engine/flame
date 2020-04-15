import 'dart:ui';

import '../sprite_batch.dart';
import 'component.dart';

class SpriteBatchComponent extends Component {
  SpriteBatch spriteBatch;
  BlendMode blendMode;
  Rect cullRect;
  Paint paint;

  SpriteBatchComponent.fromSpriteBatch(
    this.spriteBatch, {
    this.blendMode,
    this.cullRect,
    this.paint,
  });

  @override
  void render(Canvas canvas) {
    spriteBatch.render(
      canvas,
      blendMode: blendMode,
      cullRect: cullRect,
      paint: paint,
    );
  }

  @override
  bool loaded() => spriteBatch?.atlas != null;

  @override
  void update(double t) {}
}
