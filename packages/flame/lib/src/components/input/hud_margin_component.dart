import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart' show EdgeInsets;
import 'package:meta/meta.dart';

/// The [HudMarginComponent] positions itself by a margin to the edge of the
/// screen instead of by an absolute position on the screen or on the game, so
/// if the game is resized the component will move to keep its margin.
///
/// Note that the margin is calculated to the [Anchor], not to the edge of the
/// component.
///
/// If you set the position of the component instead of a margin when
/// initializing the component, the margin to the edge of the screen from that
/// position will be used.
class HudMarginComponent extends PositionComponent {
  HudMarginComponent({
    this.margin,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
  }) : assert(
          margin != null || position != null,
          'Either margin or position must be defined',
        );

  /// Instead of setting a position of the [HudMarginComponent] a margin
  /// from the edges of the viewport can be used instead.
  EdgeInsets? margin;

  late SizeProvider _sizeProvider;

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    final sizeProvider =
        ancestors().firstWhereOrNull((c) => c is SizeProvider) as SizeProvider?;
    assert(
      sizeProvider != null,
      'The parent of a HudMarginComponent needs to be a SizeProvider, for '
      'example a PositionComponent.',
    );
    // If margin is not null we will update the position `onGameResize` instead
    if (margin == null) {
      final topLeft = anchor.toOtherAnchorPosition(
        position,
        Anchor.topLeft,
        scaledSize,
      );
      final bottomRight = sizeProvider!.size -
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
      if (sizeProvider.size is NotifyingVector2) {
        (sizeProvider.size as NotifyingVector2).addListener(_updateMargins);
      }
    } else {
      size.addListener(_updateMargins);
    }
    _updateMargins();
  }

  void _updateMargins() {
    final margin = this.margin!;
    final x = margin.left != 0
        ? margin.left + scaledSize.x / 2
        : _sizeProvider.size.x - margin.right - scaledSize.x / 2;
    final y = margin.top != 0
        ? margin.top + scaledSize.y / 2
        : _sizeProvider.size.y - margin.bottom - scaledSize.y / 2;
    position.setValues(x, y);
    position = Anchor.center.toOtherAnchorPosition(
      position,
      anchor,
      scaledSize,
    );
  }
}
