import 'dart:ui';

import 'package:canvas_test/canvas_test.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PositionType', () {
    testWithFlameGame(
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

    testWithFlameGame(
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

    group('PositionType.widget', () {
      testWithFlameGame(
        'viewport does not affect component with PositionType.widget',
        (game) async {
          game.camera.viewport = FixedResolutionViewport(Vector2.all(50));
          game.onGameResize(Vector2.all(200.0));
          await game.ensureAdd(
            _MyComponent(0, positionType: PositionType.widget),
          );

          final canvas = MockCanvas();
          game.render(canvas);
          expect(
            canvas,
            MockCanvas()..drawRect(const Rect.fromLTWH(0, 0, 1, 1)),
          );
        },
      );

      testWithFlameGame(
        'camera does not affect component with PositionType.widget',
        (game) async {
          await game.ensureAdd(
            _MyComponent(0, positionType: PositionType.widget),
          );
          game.camera.snapTo(Vector2(100, 100));

          final canvas = MockCanvas();
          game.render(canvas);
          expect(
            canvas,
            MockCanvas()..drawRect(const Rect.fromLTWH(0, 0, 1, 1)),
          );
        },
      );

      testWithFlameGame(
        'Several static components',
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
    });

    testWithFlameGame(
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

class _MyComponent extends Component {
  _MyComponent(int priority, {this.positionType = PositionType.game})
      : super(priority: priority);

  @override
  PositionType positionType;

  @override
  void render(Canvas canvas) {
    final p = Vector2.all(priority.toDouble());
    final size = Vector2.all(1.0);
    canvas.drawRect(p & size, BasicPalette.white.paint());
  }
}
