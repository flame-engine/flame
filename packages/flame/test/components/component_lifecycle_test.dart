import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

class MyComponent extends Component {
  final List<String> events;

  MyComponent(this.events);

  @override
  void prepare(Component component) {
    super.prepare(component);
    events.add('prepare');
  }

  @override
  Future<void> onLoad() async {
    events.add('onLoad');
  }

  @override
  Future<void> onParentChange() async {
    events.add('onParentChange');
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    events.add('onGameResize');
  }
}

void main() {
  group('Component - Lifecycle', () {
    test('Lifecycle in correct order', () async {
      final events = <String>[];
      final game = BaseGame();
      game.onGameResize(Vector2.zero());
      await game.add(MyComponent(events));

      expect(events, ['onGameResize', 'onLoad', 'onParentChange']);
    });

    test('Parent prepares the component', () async {
      final parentEvents = <String>[];
      final childEvents = <String>[];
      final game = BaseGame();
      game.onGameResize(Vector2.zero());
      final parent = MyComponent(parentEvents);
      await parent.add(MyComponent(childEvents));
      await game.add(parent);

      // The parent tries to prepare the component before it is added to the
      // game and fails since it doesn't have a game root and therefore re-adds
      // the child when it has a proper root.
      expect(
        parentEvents,
        ['prepare', 'onGameResize', 'onLoad', 'onParentChange', 'prepare'],
      );
      expect(childEvents, ['onGameResize', 'onLoad', 'onParentChange']);
    });
  });
}
