import 'dart:ui';

import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/sprite_batch.dart';
import 'package:meta/meta.dart';

/// A component that renders a [SpriteBatch], which can also be set later.
class SpriteBatchComponent({
  var SpriteBatch? spriteBatch,
  var BlendMode? blendMode,
  var Rect? cullRect,
  var Paint? paint,
  super.key,
  super.children,
  super.priority,
}) extends Component {
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
