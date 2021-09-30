part of flame_flare;

class _FlareActorComponentPipelineOwner extends PipelineOwner {}

/// A [PositionComponent] that renders a [FlareActorAnimation]
class FlareActorComponent extends PositionComponent {
  final FlareActorAnimation flareAnimation;

  FlareActorComponent(
    this.flareAnimation, {
    required Vector2 size,
    Vector2? position,
  }) : super(position: position, size: size);

  @override
  void onMount() {
    super.onMount();
    flareAnimation.init();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    flareAnimation.render(canvas, size);
  }

  @mustCallSuper
  @override
  void update(double dt) {
    super.update(dt);
    flareAnimation.advance(dt);
  }

  @override
  void onRemove() {
    flareAnimation.destroy();
    super.onRemove();
  }
}
