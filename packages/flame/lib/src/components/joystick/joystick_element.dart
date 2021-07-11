import 'dart:ui';

import '../../../components.dart';
import '../../../extensions.dart';

/// This is an element used to draw a part of a [JoystickComponent].
///
/// It can be either a [sprite] or a [paint] (colored circle). Not both.
class JoystickElement extends PositionComponent {
  final Sprite? sprite;
  final Paint? paint;

  JoystickElement.sprite(
    this.sprite, {
    required Vector2 size,
    Anchor anchor = Anchor.center,
  })  : paint = null,
        super(size: size, anchor: anchor);

  JoystickElement.paint(
    this.paint, {
    required Vector2 size,
    Anchor anchor = Anchor.center,
  })  : sprite = null,
        super(size: size, anchor: anchor);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final sprite = this.sprite;
    final paint = this.paint;

    if (sprite == null) {
      assert(paint != null, '`paint` must not be `null` if `sprite` is `null`');

      canvas.drawCircle(Offset.zero, size.x / 2, paint!);
    } else {
      sprite.render(
        canvas,
        size: size,
      );
    }
  }
}
