import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _MyComponent extends Component {
  final List<String> events;

  _MyComponent(this.events);

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
  group('Component Lifecycle', () {
    flameGame.test('correct order', (game) async {
      final events = <String>[];
      await game.ensureAdd(_MyComponent(events));

      expect(
        events,
        ['onGameResize', 'prepared: true', 'onLoad', 'onMount'],
      );
    });

    flameGame.test('parent prepares the component', (game) async {
      final parentEvents = <String>[];
      final childEvents = <String>[];
      final parent = _MyComponent(parentEvents);
      await parent.add(_MyComponent(childEvents));
      await game.ensureAdd(parent);

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

    flameGame.test('correct lifecycle on parent change', (game) async {
      final parentEvents = <String>[];
      final childEvents = <String>[];
      final parent = _MyComponent(parentEvents);
      final child = _MyComponent(childEvents);
      await parent.add(child);
      await game.ensureAdd(parent);
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
