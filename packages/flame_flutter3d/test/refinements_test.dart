/// Three things a crowd game found: the stepping list is not rebuilt every
/// frame and still sees who came and went, what is read before the steps is
/// read against this frame's time, and an upright card turns about its own
/// plane's normal.
library;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter3d_cpu/testing.dart';
import 'package:flutter3d_game/flutter3d_game.dart' show Bindings, InputSource;
import 'package:flutter3d_sim/flutter3d_sim.dart' show GameAction, InputState;
import 'package:flutter_test/flutter_test.dart';

final class _Stepped extends FlameGame with HasFixedStep {}

final class _Ticker extends Component with FixedStepUpdate {
  int steps = 0;

  @override
  void fixedUpdate(double step) => steps++;
}

final class _Card extends FlameGame with HasFlutter3d {}

/// A button on the screen: reads whether [action] was pressed this frame.
final class _Reader extends Component {
  _Reader(this.state, this.action);

  final InputState state;
  final GameAction action;
  bool saw = false;

  @override
  void update(double dt) {
    super.update(dt);
    if (state.pressed(action)) {
      saw = true;
    }
  }
}

Future<ui.Image> _pixel() {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    const ui.Rect.fromLTWH(0, 0, 1, 1),
    ui.Paint()..color = const ui.Color(0xFFFFFFFF),
  );
  return recorder.endRecording().toImage(1, 1);
}

void main() {
  testWithGame<_Stepped>(
    'a stepper that joins after the first frame steps, and one that leaves '
    'stops',
    _Stepped.new,
    (game) async {
      // Mutation: keep the list from the first frame for good.
      final first = _Ticker();
      game.add(first);
      await game.ready();
      game.update(1 / 60);
      expect(first.steps, 1);

      final second = _Ticker();
      game.add(second);
      await game.ready();
      game.update(1 / 60);
      expect(second.steps, 1, reason: 'joined the steps');

      first.removeFromParent();
      await game.ready();
      game.update(1 / 60);
      expect(first.steps, 2, reason: 'left them');
      expect(second.steps, 2);
    },
  );

  testWithGame<_Stepped>(
    'what is read before the steps is read against this frame',
    _Stepped.new,
    (game) async {
      // Mutation: set the frame's time after the reads, as the pad feed had
      // it.
      final seen = <double>[];
      game.beforeSteps(() => seen.add(game.frameSeconds));
      await game.ready();

      game
        ..update(1 / 60)
        ..update(1 / 20);

      expect(seen, <double>[1 / 60, 1 / 20]);
    },
  );

  testWithGame<FlameGame>(
    'an input step closed from the world is closed after the viewport has '
    'read it',
    FlameGame.new,
    (game) async {
      // The viewport is the camera's, and the camera is updated after the
      // world: closed inside the world, a press was gone before a button on
      // the screen could see it.
      //
      // Mutation: close the step in the component's own update.
      const fire = GameAction('fire');
      final input = FlameInputBridge(
        bindings: Bindings(<InputSource, GameAction>{}),
        inputState: InputState(),
      );
      final reader = _Reader(input.inputState, fire);
      game.world.add(input.stepEnd());
      game.camera.viewport.add(reader);
      await game.ready();

      input.inputState.press(fire);
      game.update(1 / 60);

      expect(reader.saw, isTrue);
      expect(input.inputState.pressed(fire), isFalse, reason: 'then closed');
    },
  );

  group('an upright card', () {
    Future<SpriteBillboardComponent> standing(
      WidgetTester tester,
      _Card game,
      BridgePlane plane,
    ) async {
      final cpu = cpuTestDevice(width: 8, height: 8);
      game.open3d(cpu.device);
      game.camera3d
        ..setPosition(3.0, 0.0, 0.0)
        ..lookAt(Vector3.zero());
      late SpriteBillboardComponent card;
      await tester.runAsync(() async {
        await initializeGame(() => game);
        final image = await _pixel();
        card = SpriteBillboardComponent(
          animation: SpriteAnimation.spriteList(<Sprite>[
            Sprite(image),
          ], stepTime: 1.0),
          device: cpu.device,
          scene: game.scene,
          plane: plane,
        );
        game.add(card);
        await game.ready();
      });
      game.update(0.0);
      return card;
    }

    testWidgets('on the ground turns about up to face the camera', (
      tester,
    ) async {
      final card = await standing(tester, _Card(), BridgePlane.ground());

      final turn = card.visual.readRotation();
      final expected = Quaternion.axisAngle(
        Vector3(0.0, 1.0, 0.0),
        math.pi / 2,
      );
      expect(turn.x, closeTo(expected.x, 1e-6));
      expect(turn.y, closeTo(expected.y, 1e-6));
      expect(turn.z, closeTo(expected.z, 1e-6));
      expect(turn.w, closeTo(expected.w, 1e-6));
    });

    testWidgets(
      'on a backdrop keeps facing out of it, whatever is to its side',
      (tester) async {
        // Mutation: turn about world Y whatever the plane, as it did — the
        // card swung round an axis lying in its own plane.
        final card = await standing(tester, _Card(), BridgePlane.backdrop());

        final turn = card.visual.readRotation();
        expect(turn.x.abs() + turn.y.abs() + turn.z.abs(), lessThan(1e-6));
      },
    );
  });
}
