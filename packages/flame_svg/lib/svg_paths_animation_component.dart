import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_svg/flame_svg.dart';

/// A position component playing an [SvgPathsAnimation], like a
/// [SpriteAnimationComponent] does with a [SpriteAnimation].
///
/// All frames are rendered from the common [SvgPathsAnimation.area], fitted
/// within the [size] of the component, which is by default the size of that
/// area.
///
/// With [hitboxes], each [SvgPaths] of the frames gets an [SvgPathsHitbox],
/// which is only a child of the component while one of its frames is shown,
/// so that the hidden frames neither collide nor get hit by rays. While the
/// component is mounted, the hitboxes change at the next tick, like any child.
class SvgPathsAnimationComponent(
  /// The animation of the component.
  final SvgPathsAnimation animation, {

  /// Whether the frames get hitboxes.
  final bool hitboxes = true,

  /// Whether the hitboxes of the frames shown are rendered.
  final bool renderHitboxes = false,

  /// Whether the animation is paused or playing.
  var bool playing = true,

  /// Whether the component is removed once the animation has finished, which
  /// requires the animation not to loop.
  var bool removeOnFinish = false,

  /// Whether to reset the animation when the component is removed from the
  /// component tree.
  var bool resetOnRemove = false,
  bool? filter,
  double sampling = 1.0,
  double? tolerance,
  Vector2? size,
  super.position,
  super.scale,
  super.angle,
  super.anchor,
  super.children,
  super.priority,
  super.key,
}) extends PositionComponent {
  /// Create from the given [animation]. The [filter], [sampling] and
  /// [tolerance] of the hitboxes are those of
  /// [SvgPathsComponent.createSvgPathsHitbox].
  this : super(size: size ?? animation.area.size.toVector2()) {
    if (hitboxes) {
      for (final frame in animation.frames) {
        if (frame.svg.length > 0) {
          _hitboxes[frame.svg] ??= SvgPathsComponent.createSvgPathsHitbox(
            frame.svg,
            this.size,
            renderHitboxes: renderHitboxes,
            filter: filter,
            sampling: sampling,
            tolerance: tolerance,
            area: animation.area,
          );
        }
      }
      _updateHitboxes();
    }
  }

  /// The ticker of the [animation].
  late final SvgPathsAnimationTicker animationTicker = animation.createTicker();

  /// The hitbox of each [SvgPaths] of the frames.
  final Map<SvgPaths, SvgPathsHitbox> _hitboxes = {};

  /// The frame indices that the hitboxes are updated for.
  List<int>? _hitboxIndices;

  @override
  void render(Canvas canvas) {
    for (final frame in animationTicker.currentFrames) {
      frame.svg.render(canvas, size, area: animation.area);
    }
  }

  @override
  void update(double dt) {
    if (playing) {
      animationTicker.update(dt);
    }
    // Also while not playing, since the ticker can be changed directly.
    _updateHitboxes();
    if (removeOnFinish && animationTicker.done()) {
      removeFromParent();
    }
  }

  @override
  void onMount() {
    super.onMount();
    // The children are not mounted yet, so they change right away.
    _updateHitboxes();
  }

  @override
  void onRemove() {
    super.onRemove();
    // The hitboxes are updated when the component is mounted again, since
    // they are being removed together with it.
    if (resetOnRemove) {
      animationTicker.reset();
    }
  }

  /// Adds the hitboxes of the frames shown, and removes the others.
  void _updateHitboxes() {
    final indices = animationTicker.currentIndices;
    if (_hitboxes.isEmpty || identical(indices, _hitboxIndices)) {
      return;
    }
    _hitboxIndices = indices;
    final shown = {for (final i in indices) animation.frames[i].svg};
    _hitboxes.forEach((svg, hitbox) {
      final isChild = hitbox.parent == this && !hitbox.isRemoving;
      if (shown.contains(svg)) {
        if (!isChild) {
          add(hitbox);
        }
      } else if (isChild) {
        remove(hitbox);
      }
    });
  }
}
