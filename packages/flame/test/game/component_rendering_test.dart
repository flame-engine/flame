import 'dart:ui';

import 'package:canvas_test/canvas_test.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class _MyComponent extends Component {
  @override
  PositionType positionType;

  _MyComponent(int priority, {this.positionType = PositionType.game})
      : super(priority: priority);

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
      'PositionType.game',
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
      'PositionType.viewport',
      (game) async {
        await game.ensureAddAll([
          _MyComponent(4, positionType: PositionType.viewport),
          _MyComponent(1, positionType: PositionType.viewport),
          _MyComponent(2, positionType: PositionType.viewport),
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
      'PositionType.widget',
      (game) async {
        await game.ensureAddAll([
          _MyComponent(5, positionType: PositionType.widget),
          _MyComponent(1, positionType: PositionType.widget),
          _MyComponent(2, positionType: PositionType.widget),
        ]);

        final canvas = MockCanvas();
        game.camera.snapTo(Vector2(12.0, 18.0));
        game.render(canvas);

        expect(
          canvas,
          MockCanvas()
            ..drawRect(const Rect.fromLTWH(1, 1, 1, 1))
            ..drawRect(const Rect.fromLTWH(2, 2, 1, 1))
            ..drawRect(const Rect.fromLTWH(5, 5, 1, 1)),
        );
      },
    );

    flameGame.test(
      'mixed',
      (game) async {
        await game.ensureAddAll([
          _MyComponent(4),
          _MyComponent(1),
          _MyComponent(7, positionType: PositionType.viewport),
          _MyComponent(5, positionType: PositionType.viewport),
          _MyComponent(3, positionType: PositionType.viewport),
          _MyComponent(0),
          _MyComponent(6, positionType: PositionType.widget),
          _MyComponent(2, positionType: PositionType.widget),
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
            ..drawRect(const Rect.fromLTWH(5, 5, 1, 1))
            ..drawRect(const Rect.fromLTWH(6, 6, 1, 1))
            ..drawRect(const Rect.fromLTWH(7, 7, 1, 1)),
        );
      },
    );
  });
}
