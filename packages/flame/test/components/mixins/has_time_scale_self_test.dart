import 'package:flame/components.dart';
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

    testWithFlameGame('scales its own dt when called via update directly', (
      game,
    ) async {
      final component = _ScaledRecorder()..timeScale = 0.5;
      await game.world.ensureAdd(component);

      component.update(1.0);
      expect(component.recordedDts, [1.0]);
    });
  });
}

class _ScaledRecorder extends Component with HasTimeScale {
  final List<double> recordedDts = [];

  @override
  void update(double dt) {
    recordedDts.add(dt);
  }
}
