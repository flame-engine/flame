import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart' show EdgeInsets;
import 'package:meta/meta.dart';

/// The [ComponentViewportMargin] positions itself by a margin to the edge of
/// the [Viewport] instead of by an absolute position on the screen or on the
/// game, so if the game is resized the component will move to keep its margin.
///
/// Note that the margin is calculated to the [Anchor], not to the edge of the
/// component.
///
/// If you set the position of the component instead of a margin when
/// initializing the component, the margin to the edge of the screen from that
/// position will be used.
mixin ComponentViewportMargin on PositionComponent, HasGameRef {
  @override
  PositionType positionType = PositionType.viewport;

  /// Instead of setting a position of the [PositionComponent] that uses
  /// [ComponentViewportMargin] a margin from the edges of the viewport can be
  /// used instead.
  EdgeInsets? margin;

  @override
  @mustCallSuper
  Future<void> onLoad() async {
    super.onLoad();
    // If margin is not null we will update the position `onGameResize` instead
    if (margin == null) {
      final screenSize = gameRef.size;
      final topLeft = anchor.toOtherAnchorPosition(
        position,
        Anchor.topLeft,
        scaledSize,
      );
      final bottomRight = screenSize -
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
    } else {
      size.addListener(_updateMargins);
    }
    _updateMargins();
  }

  @override
  @mustCallSuper
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    if (isMounted) {
      _updateMargins();
    }
  }

  void _updateMargins() {
    final screenSize = positionType == PositionType.viewport
        ? gameRef.camera.viewport.effectiveSize
        : gameRef.canvasSize;
    final margin = this.margin!;
    final x = margin.left != 0
        ? margin.left + scaledSize.x / 2
        : screenSize.x - margin.right - scaledSize.x / 2;
    final y = margin.top != 0
        ? margin.top + scaledSize.y / 2
        : screenSize.y - margin.bottom - scaledSize.y / 2;
    position.setValues(x, y);
    position = Anchor.center.toOtherAnchorPosition(
      position,
      anchor,
      scaledSize,
    );
  }
}
