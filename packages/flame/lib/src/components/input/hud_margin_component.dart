import 'package:flutter/widgets.dart' show EdgeInsets;
import 'package:meta/meta.dart';

import '../../../components.dart';
import '../../../extensions.dart';
import '../../../game.dart';

class HudMarginComponent<T extends FlameGame> extends PositionComponent
    with HasGameRef<T> {
  @override
  bool isHud = true;

  /// Instead of setting a position of the [HudMarginComponent] a margin
  /// from the edges of the viewport can be used instead.
  EdgeInsets? margin;

  HudMarginComponent({
    this.margin,
    Vector2? position,
    Vector2? size,
    Anchor anchor = Anchor.topLeft,
  })  : assert(
          margin != null || position != null,
          'Either margin or position must be defined',
        ),
        super(
          size: size,
          position: position,
          anchor: anchor,
        );

  @override
  @mustCallSuper
  Future<void> onLoad() async {
    super.onLoad();
    final size = gameRef.camera.viewport.effectiveSize;
    if (margin != null) {
      final margin = this.margin!;
      final x = margin.left != 0
          ? margin.left + scaledSize.x / 2
          : size.x - margin.right - scaledSize.x / 2;
      final y = margin.top != 0
          ? margin.top + scaledSize.y / 2
          : size.y - margin.bottom - scaledSize.y / 2;
      position.setValues(x, y);
      position =
          Anchor.center.toOtherAnchorPosition(center, anchor, scaledSize);
    } else {
      final topLeft = size -
          anchor.toOtherAnchorPosition(
            position,
            Anchor.topLeft,
            scaledSize,
          );
      final bottomRight = size -
          anchor.toOtherAnchorPosition(
            position,
            Anchor.bottomRight,
            scaledSize,
          );
      margin = EdgeInsets.fromLTRB(
        topLeft.x,
        topLeft.y,
        bottomRight.x,
        bottomRight.y,
      );
    }
  }
}
