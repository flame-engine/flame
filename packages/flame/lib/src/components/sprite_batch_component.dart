import 'dart:ui';

import '../sprite_batch.dart';
import 'component.dart';

class SpriteBatchComponent extends Component {
  SpriteBatch? spriteBatch;
  BlendMode? blendMode;
  Rect? cullRect;
  Paint? paint;

  /// Creates a component with an empty sprite batch which can be set later
  SpriteBatchComponent();

  SpriteBatchComponent.fromSpriteBatch(
    this.spriteBatch, {
    this.blendMode,
    this.cullRect,
    this.paint,
  });

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    spriteBatch?.render(
      canvas,
      blendMode: blendMode,
      cullRect: cullRect,
      paint: paint,
    );
  }
}
