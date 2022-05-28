import 'package:flame/game.dart';
import 'package:flame_oxygen/flame_oxygen.dart';
import 'package:flame_oxygen_example/component/timer_component.dart';
import 'package:flutter/material.dart';

class KawabungaSystem extends BaseSystem with UpdateSystem {
  @override
  List<Filter<Component>> get filters => [
        Has<TextComponent>(),
        Has<TimerComponent>(),
      ];

  @override
  void renderEntity(Canvas canvas, Entity entity) {
    final timer = entity.get<TimerComponent>()!;
    final textComponent = entity.get<TextComponent>()!;
    final textRenderer = TextPaint(
      style: textComponent.style.copyWith(
        color: textComponent.style.color!.withOpacity(1 - timer.percentage),
      ),
    );

    textRenderer.render(
      canvas,
      textComponent.text,
      Vector2.zero(),
    );
  }

  @override
  void update(double delta) {
    for (final entity in entities) {
      final textComponent = entity.get<TextComponent>()!;
      final size = entity.get<SizeComponent>()!.size;
      final textRenderer = TextPaint(style: textComponent.style);
      size.setFrom(textRenderer.measureText(textComponent.text));

      final timer = entity.get<TimerComponent>()!;
      timer.timePassed = timer.timePassed + delta;
      if (timer.done) {
        entity.dispose();
      }
    }
  }
}
