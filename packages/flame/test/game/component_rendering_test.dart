import 'dart:ui';

import 'package:canvas_test/canvas_test.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class _MyComponent extends Component {
  @override
  bool isHud;

  _MyComponent(int priority, {this.isHud = false}) : super(priority: priority);

  @override
  void render(Canvas canvas) {
    final p = Vector2Extension.fromInts(priority, priority);
    final s = Vector2.all(1.0);
    canvas.drawRect(p & s, BasicPalette.white.paint());
  }
}

void main() {
  group('components are rendered according to their priorities', () {
    flameGame.test(
      'only camera components',
      (game) async {
        await game.ensureAddAll([
          _MyComponent(4),
          _MyComponent(1),
          _MyComponent(2),
        ]);

        final canvas = MockCanvas();
        game.camera.snapTo(Vector2(12.0, 18.0));
        game.render(canvas);

        expect(
          canvas,
          MockCanvas()
            ..translate(-12.0, -18.0)
            ..drawRect(const Rect.fromLTWH(1, 1, 1, 1))
            ..drawRect(const Rect.fromLTWH(2, 2, 1, 1))
            ..drawRect(const Rect.fromLTWH(4, 4, 1, 1))
            ..translate(0.0, 0.0),
        );
      },
    );

    flameGame.test(
      'only HUD components',
      (game) async {
        await game.ensureAddAll([
          _MyComponent(4, isHud: true),
          _MyComponent(1, isHud: true),
          _MyComponent(2, isHud: true),
        ]);
        final canvas = MockCanvas();
        game.camera.snapTo(Vector2(12.0, 18.0));
        game.render(canvas);

        expect(
          canvas,
          MockCanvas()
            ..drawRect(const Rect.fromLTWH(1, 1, 1, 1))
            ..drawRect(const Rect.fromLTWH(2, 2, 1, 1))
            ..drawRect(const Rect.fromLTWH(4, 4, 1, 1)),
        );
      },
    );

    flameGame.test(
      'mixed',
      (game) async {
        await game.ensureAddAll([
          _MyComponent(4),
          _MyComponent(1),
          _MyComponent(2, isHud: true),
          _MyComponent(5, isHud: true),
          _MyComponent(3, isHud: true),
          _MyComponent(0),
        ]);

        final canvas = MockCanvas();
        game.camera.snapTo(Vector2(12.0, 18.0));
        game.render(canvas);

        expect(
          canvas,
          MockCanvas()
            ..translate(-12.0, -18.0)
            ..drawRect(const Rect.fromLTWH(0, 0, 1, 1))
            ..drawRect(const Rect.fromLTWH(1, 1, 1, 1))
            ..translate(0.0, 0.0)
            ..drawRect(const Rect.fromLTWH(2, 2, 1, 1))
            ..drawRect(const Rect.fromLTWH(3, 3, 1, 1))
            ..translate(-12.0, -18.0)
            ..drawRect(const Rect.fromLTWH(4, 4, 1, 1))
            ..translate(0.0, 0.0)
            ..drawRect(const Rect.fromLTWH(5, 5, 1, 1)),
        );
      },
    );
  });
}
