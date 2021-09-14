import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:forge2d/forge2d.dart';

import 'balls.dart';
import 'boundaries.dart';

class CompositionSample extends Forge2DGame with HasTappableComponents {
  static const info = '''
This example shows how to compose a `BodyComponent` together with a normal Flame
component. Click the ball to see the number increment.
''';

  CompositionSample() : super(zoom: 20, gravity: Vector2(0, -10.0));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final boundaries = createBoundaries(this);
    boundaries.forEach(add);
    final center = screenToWorld(camera.viewport.effectiveSize / 2);
    add(TapableBall(center));
  }
}

class TapableBall extends Ball with Tappable {
  late final TextComponent textComponent;
  int counter = 0;
  final TextPaintConfig _textConfig =
      TextPaintConfig(color: BasicPalette.white.color, fontSize: 4);
  late final TextPaint _textPaint;

  TapableBall(Vector2 position) : super(position) {
    originalPaint = BasicPalette.white.paint();
    paint = originalPaint;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _textPaint = TextPaint(config: _textConfig);
    textComponent = TextComponent(counter.toString(), textRenderer: _textPaint);
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
