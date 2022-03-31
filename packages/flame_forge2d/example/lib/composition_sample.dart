import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import 'balls.dart';
import 'boundaries.dart';

const TextStyle _textStyle = TextStyle(color: Colors.white, fontSize: 4);

class CompositionSample extends Forge2DGame with HasTappables {
  static const info = '''
This example shows how to compose a `BodyComponent` together with a normal Flame
component. Click the ball to see the number increment.
''';

  CompositionSample() : super(zoom: 20, gravity: Vector2(0, -10.0));

  @override
  Future<void> onLoad() async {
    final boundaries = createBoundaries(this);
    boundaries.forEach(add);
    final viewportCenter = camera.viewport.effectiveSize / 2;
    add(TappableText(screenToFlameWorld(viewportCenter)..y = 5));
    add(TappableBall(screenToWorld(viewportCenter)));
  }
}

class TappableText extends TextComponent with Tappable {
  TappableText(Vector2 position)
      : super(
          text: 'A normal Flame component',
          textRenderer: TextPaint(style: _textStyle),
          position: position,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    final scaleEffect = ScaleEffect.by(
      Vector2.all(1.1),
      EffectController(
        duration: 0.7,
        alternate: true,
        infinite: true,
      ),
    );
    add(scaleEffect);
  }

  @override
  bool onTapDown(TapDownInfo info) {
    add(
      MoveEffect.by(
        Vector2.all(5),
        EffectController(
          speed: 5,
          alternate: true,
        ),
      ),
    );
    return true;
  }
}

class TappableBall extends Ball with Tappable {
  late final TextComponent textComponent;
  int counter = 0;
  late final TextPaint _textPaint;

  TappableBall(Vector2 position) : super(position) {
    originalPaint = Paint()..color = Colors.amber;
    paint = originalPaint;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _textPaint = TextPaint(style: _textStyle);
    textComponent = TextComponent(
      text: counter.toString(),
      textRenderer: _textPaint,
    );
    add(textComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // This is unfortunately needed since [BodyComponent] will set all its
    // children to `debugMode = true` currently, we should come up with a
    // nicer solution to this.
    textComponent.debugMode = false;
    textComponent.text = counter.toString();
  }

  @override
  bool onTapDown(_) {
    counter++;
    body.applyLinearImpulse(Vector2.random() * 1000);
    paint = randomPaint();
    return false;
  }
}
