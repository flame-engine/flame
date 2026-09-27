import 'package:flame/components.dart' show Component;
import 'package:flame/game.dart' show FlameGame;
import 'package:flame/src/camera/world.dart' show World;
import 'package:flame/src/components/mixins/has_world_ref.dart'
    show HasWorldRef;
import 'package:flame_test/flame_test.dart' show testWithGame;
import 'package:flutter_test/flutter_test.dart' show group;
import 'package:test/expect.dart' show expect;

class _ParentComponent extends Component {
  bool wasRemoved = false;

  @override
  void onRemove() {
    wasRemoved = true;
    super.onRemove();
  }
}

class _ChildComponent extends _ParentComponent with HasWorldRef<World> {}

void main() {
  group('HasWorldRef', () {
    testWithGame<FlameGame>('onRemove calls super', FlameGame.new, (
      game,
    ) async {
      final c = _ChildComponent();
      game.add(c);
      await game.ready();
      game.remove(c);
      await game.ready();
      expect(c.wasRemoved, true);
    });
  });
}
