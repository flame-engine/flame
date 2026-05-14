import 'package:flame/components.dart' show Component;
import 'package:flame/game.dart' show FlameGame;
import 'package:flame/src/camera/world.dart' show World;
import 'package:flame/src/components/mixins/has_world.dart' show HasWorldReference;
import 'package:flame_test/flame_test.dart' show testWithGame;
import 'package:flutter_test/flutter_test.dart' show group;
import 'package:test/expect.dart' show expect;

class _ParentComponent extends Component{
  bool wasRemoved = false;

  @override
  void onRemove() {
    wasRemoved = true;
    super.onRemove();
  }
}

class _childComponent extends _ParentComponent with HasWorldReference<World>{

}

void main() {
  group('HasGameRef', () {
    testWithGame<FlameGame>('onRemove calls super', FlameGame.new, (game) async {
      final c = _childComponent();
      game.add(c);
      await game.ready();
      game.remove(c);
      expect(c.wasRemoved, true);
    });
  });
}