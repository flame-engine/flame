import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

class MyComponent extends Component {
  final List<String> events;

  MyComponent(this.events);

  @override
  void prepare(Component parent) {
    super.prepare(parent);
    events.add('prepared: $isPrepared');
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    events.add('onLoad');
  }

  @override
  void onMount() {
    events.add('onMount');
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
      final game = FlameGame();
      game.onGameResize(Vector2.zero());
      await game.add(MyComponent(events));

      expect(
        events,
        ['onGameResize', 'prepared: true', 'onLoad', 'onMount'],
      );
    });

    test('Parent prepares the component', () async {
      final parentEvents = <String>[];
      final childEvents = <String>[];
      final game = FlameGame();
      game.onGameResize(Vector2.zero());
      final parent = MyComponent(parentEvents);
      await parent.add(MyComponent(childEvents));
      await game.add(parent);

      // The parent tries to prepare the component before it is added to the
      // game and fails since it doesn't have a game root and therefore re-adds
      // the child when it has a proper root.
      expect(
        parentEvents,
        ['onGameResize', 'prepared: true', 'onLoad', 'onMount'],
      );
      expect(
        childEvents,
        [
          'prepared: false',
          'onGameResize',
          'prepared: true',
          'onLoad',
          'onMount',
        ],
      );
    });

    test('Correct lifecycle on parent change', () async {
      final parentEvents = <String>[];
      final childEvents = <String>[];
      final game = FlameGame();
      game.onGameResize(Vector2.zero());
      final parent = MyComponent(parentEvents);
      final child = MyComponent(childEvents);
      await parent.add(child);
      await game.add(parent);
      game.update(0);
      child.changeParent(game);
      game.update(0);

      expect(
        parentEvents,
        [
          'onGameResize',
          'prepared: true',
          'onLoad',
          'onMount',
        ],
      );
      // onLoad should only be called the first time that the component is
      // loaded.
      expect(
        childEvents,
        [
          'prepared: false',
          'onGameResize',
          'prepared: true',
          'onLoad',
          'onMount',
          'onGameResize',
          'prepared: true',
          'onMount',
        ],
      );
    });
  });
}
