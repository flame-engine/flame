import 'dart:ui';

import '../sprite_batch.dart';
import 'component.dart';

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
  void onMount() {
    assert(
      spriteBatch != null,
      'You have to set spriteBatch in either the constructor or in onLoad',
    );
  }

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
