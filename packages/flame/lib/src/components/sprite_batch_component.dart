import 'dart:ui';

import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/sprite_batch.dart';
import 'package:meta/meta.dart';

class SpriteBatchComponent extends Component {
  final SpriteBatch spriteBatch;
  final BlendMode? blendMode;
  final Rect? cullRect;
  final Paint? paint;

  /// Creates a component with an empty sprite batch which can populated later
  SpriteBatchComponent({
    required this.spriteBatch,
    this.blendMode,
    this.cullRect,
    this.paint,
    super.key,
    super.children,
    super.priority,
  });

  @mustCallSuper
  @override
  void render(Canvas canvas) {
    spriteBatch.render(
      canvas,
      blendMode: blendMode,
      cullRect: cullRect,
      paint: paint,
    );
  }
}
