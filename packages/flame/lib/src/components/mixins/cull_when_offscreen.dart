import 'dart:math';
import 'dart:ui';

import 'package:flame/src/camera/camera_component.dart';
import 'package:flame/src/camera/world.dart';
import 'package:flame/src/components/position_component.dart';
import 'package:meta/meta.dart';

/// Skips rendering a [PositionComponent], and all of its children, while it is
/// outside of the area visible through the camera that is currently rendering
/// it.
///
/// Only rendering is skipped, the component is still updated as usual. Culling
/// is conservative: a component is only skipped when its [cullBounds] (grown by
/// [cullPadding]) do not overlap the camera's `visibleWorldRect`.
///
/// Components that are not part of a [World] (for example children of the
/// viewport, like a HUD) are never culled.
///
/// Since the whole subtree is skipped, children that are drawn outside of the
/// bounds of this component will disappear together with it. Increase
/// [cullPadding] or override [cullBounds] in that case.
///
/// Prefer applying this to many small components (sprites, tiles, enemies)
/// rather than to a single large parent. For scenery that never changes,
/// consider a `SpriteBatchComponent` instead.
mixin CullWhenOffscreen on PositionComponent {
  /// Whether this component is currently culled when it is off-screen.
  ///
  /// Set to false to always render the component, for example to compare
  /// the cost of culling, or while a component is temporarily drawn outside of
  /// its bounds.
  bool cullingEnabled = true;

  /// Extra margin, in world units, added around [cullBounds] before checking
  /// for visibility. Useful when the component draws outside of its [size], for
  /// example shadows, outlines or effects.
  double cullPadding = 0;

  /// The area in the world coordinate space that this component occupies.
  ///
  /// Defaults to the absolute bounding rectangle of the component. Override
  /// this when [size] is not representative of what is drawn, for example for
  /// components with a zero size.
  Rect get cullBounds {
    // Fast path for the common case of a direct, unrotated child of the world,
    // which avoids the vector allocations of `toAbsoluteRect`.
    if (angle == 0 && parent is World) {
      final width = size.x * scale.x;
      final height = size.y * scale.y;
      final left = position.x - anchor.x * width;
      final top = position.y - anchor.y * height;
      return Rect.fromLTRB(
        min(left, left + width),
        min(top, top + height),
        max(left, left + width),
        max(top, top + height),
      );
    }
    return toAbsoluteRect();
  }

  World? _world;

  @mustCallSuper
  @override
  void onMount() {
    super.onMount();
    _world = findParent<World>();
  }

  @mustCallSuper
  @override
  void onRemove() {
    _world = null;
    super.onRemove();
  }

  @override
  void renderTree(Canvas canvas) {
    if (_isOffscreen()) {
      return;
    }
    super.renderTree(canvas);
  }

  bool _isOffscreen() {
    final world = _world;
    if (!cullingEnabled ||
        world == null ||
        CameraComponent.currentCameras.isEmpty) {
      return false;
    }
    // The innermost camera is the one currently rendering this component.
    final camera = CameraComponent.currentCameras.last;
    if (camera.world != world) {
      return false;
    }
    final bounds = cullBounds;
    return !camera.visibleWorldRect.overlaps(
      cullPadding == 0 ? bounds : bounds.inflate(cullPadding),
    );
  }
}
