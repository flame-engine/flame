import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _MyComponent extends Component {
  final List<String> events;
  final String? name;

  _MyComponent(this.events, [this.name]);

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
  void onRemove() {
    events.add('onRemove');
    super.onRemove();
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
        ['onGameResize', 'onLoad', 'onMount'],
      );
    });

    // Obsolete scenario, when we used to have a separate "prepare" stage
    flameGame.test('parent prepares the component', (game) async {
      final parentEvents = <String>[];
      final childEvents = <String>[];
      final parent = _MyComponent(parentEvents, 'parent');
      await parent.add(_MyComponent(childEvents, 'child'));
      await game.ensureAdd(parent);

      // The parent tries to prepare the component before it is added to the
      // game and fails since it doesn't have a game root and therefore re-adds
      // the child when it has a proper root.
      expect(parentEvents, ['onGameResize', 'onLoad', 'onMount']);
      expect(childEvents, ['onGameResize', 'onLoad', 'onMount']);
    });

    flameGame.test('correct lifecycle on parent change', (game) async {
      final parentEvents = <String>[];
      final childEvents = <String>[];
      final parent = _MyComponent(parentEvents, 'parent');
      final child = _MyComponent(childEvents, 'child');
      await parent.add(child);
      await game.ensureAdd(parent);
      child.changeParent(game);
      game.update(0);
      await game.ready();

      expect(parentEvents, ['onGameResize', 'onLoad', 'onMount']);
      // onLoad should only be called the first time that the component is
      // loaded.
      expect(
        childEvents,
        [
          'onGameResize',
          'onLoad',
          'onMount',
          'onRemove',
          'onGameResize',
          'onMount',
        ],
      );
    });

    flameGame.test(
      'components added in correct order even with different load times',
      (game) async {
        final a = SlowComponent(0.1);
        final b = SlowComponent(0.02);
        final c = SlowComponent(0.05);
        final d = SlowComponent(0);
        game.add(a);
        game.add(b);
        game.add(c);
        game.add(d);
        await game.ready();
        expect(game.children.toList(), equals([a, b, c, d]));
      },
    );

    flameGame.test(
      'Component starts loading before the parent is mounted',
      (game) async {
        final parent = Component();
        final child = SlowComponent(0.01);
        final future = child.addToParent(parent);
        expect(parent.isMounted, false);
        expect(parent.isLoaded, false);
        expect(child.isMounted, false);
        expect(child.isLoaded, false); // not yet..
        await future;
        expect(parent.isMounted, false);
        expect(child.isLoaded, true);
        expect(child.isMounted, false);

        game.add(parent);
        expect(parent.isLoaded, true);
        await game.ready();
        expect(child.isMounted, true);
      },
    );
  });
}

class SlowComponent extends Component {
  SlowComponent(this.loadTime);
  final double loadTime;

  @override
  Future<void> onLoad() async {
    final ms = (loadTime * 1000).toInt();
    await Future<int?>.delayed(Duration(milliseconds: ms));
  }
}
