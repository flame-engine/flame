/// [BridgeClock] runs after every sibling component's own update, regardless
/// of which of the two was added to the [FlameGame] first.
///
/// This is the guarantee [Flutter3dFlameWidget]'s own doc comment relies on,
/// and it does not hold by insertion order alone: on the path where this
/// widget opens its own `GraphicsDevice`, [BridgeClock] is added from the
/// widget's first `build`, before `buildScene` has run and before the host's
/// own components exist to share an insertion order with. Only an explicit
/// priority, set once in [BridgeClock]'s own constructor, makes the order the
/// same either way — which is what these two tests, ordered oppositely, both
/// check.
library;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart' show Flutter3dFlameWidget;
import 'package:flame_flutter3d/src/host/bridge_clock.dart';
import 'package:flame_flutter3d/src/host/flutter3d_flame_widget.dart'
    show Flutter3dFlameWidget;
import 'package:flutter_test/flutter_test.dart';

final class _RecordingComponent extends Component {
  _RecordingComponent(this.log, this.name);

  final List<String> log;
  final String name;

  @override
  void update(double dt) {
    super.update(dt);
    log.add(name);
  }
}

void main() {
  test('BridgeClock added before its sibling still runs after it', () {
    final log = <String>[];
    final game = FlameGame()
      ..add(BridgeClock(onTick: (double dt) => log.add('clock')))
      ..add(_RecordingComponent(log, 'sibling'));

    game.update(1 / 60);

    expect(log, <String>['sibling', 'clock']);
  });

  test('BridgeClock added after its sibling still runs after it', () {
    final log = <String>[];
    final game = FlameGame()
      ..add(_RecordingComponent(log, 'sibling'))
      ..add(BridgeClock(onTick: (double dt) => log.add('clock')));

    game.update(1 / 60);

    expect(log, <String>['sibling', 'clock']);
  });
}
