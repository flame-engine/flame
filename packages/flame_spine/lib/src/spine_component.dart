import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:spine_flutter/spine_flutter.dart';

class SpineComponent extends PositionComponent {
  final BoundsProvider _boundsProvider;
  final SkeletonDrawable _drawable;
  late final Bounds _bounds;
  final bool _ownsDrawable;

  SpineComponent(
    this._drawable, {
    bool ownsDrawable = true,
    BoundsProvider boundsProvider = const SetupPoseBounds(),
    super.position,
    super.scale,
    double super.angle = 0.0,
    Anchor super.anchor = Anchor.topLeft,
    super.children,
    super.priority,
    super.key,
  }) : _ownsDrawable = ownsDrawable,
       _boundsProvider = boundsProvider {
    _drawable.update(0);
    _bounds = _boundsProvider.computeBounds(_drawable);
    size = Vector2(_bounds.width, _bounds.height);
  }

  static Future<SpineComponent> fromAssets({
    required String atlasFile,
    required String skeletonFile,
    AssetBundle? bundle,
    BoundsProvider boundsProvider = const SetupPoseBounds(),
    Vector2? position,
    Vector2? scale,
    double angle = 0.0,
    Anchor anchor = Anchor.topLeft,
    Iterable<Component>? children,
    int? priority,
  }) async {
    return SpineComponent(
      await SkeletonDrawable.fromAsset(
        atlasFile,
        skeletonFile,
        bundle: bundle,
      ),
      boundsProvider: boundsProvider,
      position: position,
      scale: scale,
      angle: angle,
      anchor: anchor,
      children: children,
      priority: priority,
    );
  }

  void dispose() {
    if (_ownsDrawable) {
      _drawable.dispose();
    }
  }

  @override
  void update(double dt) {
    _drawable.update(dt);
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(-_bounds.x, -_bounds.y);
    _drawable.renderToCanvas(canvas);
    canvas.restore();
  }

  AnimationState get animationState => _drawable.animationState;

  AnimationStateData get animationStateData => _drawable.animationStateData;

  Skeleton get skeleton => _drawable.skeleton;
}
