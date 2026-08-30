import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('HasTimeScale self-scaling', () {
    testWithFlameGame('scales the dt of the component it is mixed onto', (
      game,
    ) async {
      final component = _ScaledRecorder()..timeScale = 0.5;
      await game.world.ensureAdd(component);

      game.update(1.0);
      expect(component.recordedDts, [0.5]);
    });

    testWithFlameGame('skips the whole subtree while paused', (game) async {
      final child = _Recorder();
      final component = _ScaledRecorder(children: [child]);
      await game.world.ensureAdd(component);

      component.pause();
      game.update(1.0);
      expect(component.recordedDts, isEmpty);
      expect(child.recordedDts, isEmpty);

      component.resume();
      game.update(1.0);
      expect(component.recordedDts, [1.0]);
      expect(child.recordedDts, [1.0]);
    });

    testWithGame<_PausableGame>(
      'components added while the game is paused are still mounted',
      _PausableGame.new,
      (game) async {
        game.pause();
        final component = _Recorder();
        game.world.add(component);
        game.update(1.0);
        expect(component.isMounted, isTrue);
        expect(component.recordedDts, isEmpty);

        game.resume();
        game.update(1.0);
        expect(component.recordedDts, [1.0]);
      },
    );
  });
}

class _Recorder extends Component {
  _Recorder({super.children});

  final List<double> recordedDts = [];

  @override
  void update(double dt) {
    recordedDts.add(dt);
  }
}

class _ScaledRecorder extends _Recorder with CustomTraversal, HasTimeScale {
  _ScaledRecorder({super.children});
}

class _PausableGame extends FlameGame with HasTimeScale {}
