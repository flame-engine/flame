import 'dart:io';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'tracks update and render times.',
    (widgetTester) async {
      final game = _GameWithPerformanceTracker(
        children: [_SlowComponent()],
      );

      expect(game.updateTime, 0);
      expect(game.renderTime, 0);

      await widgetTester.pumpFrames(
        GameWidget(game: game),
        const Duration(seconds: 1),
      );

      expect(
        game.updateTime,
        greaterThanOrEqualTo(_SlowComponent.duration.inMilliseconds),
      );
      expect(
        game.renderTime,
        greaterThanOrEqualTo(_SlowComponent.duration.inMilliseconds),
      );
    },
  );
}

class _GameWithPerformanceTracker extends FlameGame with HasPerformanceTracker {
  _GameWithPerformanceTracker({super.children});
}

class _SlowComponent extends Component {
  static const duration = Duration(milliseconds: 8);
  @override
  void update(double dt) => sleep(duration);
  @override
  void render(Canvas canvas) => sleep(duration);
}
