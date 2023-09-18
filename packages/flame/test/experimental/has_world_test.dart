import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _WorldReferenceWorld extends World {
  bool calledFoo = false;
  void foo() {
    calledFoo = true;
  }
}

void main() {
  group('HasWorld', () {
    testWithGame(
      'component with default HasWorld',
      () => FlameGame(world: _WorldReferenceWorld()),
      (game) async {
        final component1 = _Component<World>();
        final component2 = _Component<_WorldReferenceWorld>();
        game.world.addAll([component1, component2]);
        expect(component1.world, game.world);
        expect(component2.world, game.world);
      },
    );

    testWithGame<_MyGame>(
      'component with typed HasWorld',
      _MyGame.new,
      (game) async {
        final component = _Component<_WorldReferenceWorld>();
        game.world.ensureAdd(component);
        expect(component.world, game.world);
      },
    );

    testWithFlameGame(
      'world reference accessed too early',
      (game) async {
        final component = _Component();
        expect(
          () => component.world,
          failsAssert('Could not find a World instance of type World'),
        );
      },
    );

    testWithFlameGame(
      'game reference of wrong type',
      (game) async {
        final component = _Component<_WorldReferenceWorld>();
        game.world.add(component);
        expect(
          () => component.world,
          failsAssert(
            'Could not find a World instance of type _WorldReferenceWorld',
          ),
        );
      },
    );

    testWithFlameGame(
      'game reference propagates quickly',
      (game) async {
        final component1 = _Component()..addToParent(game.world);
        final component2 = _Component()..addToParent(component1);
        final component3 = _Component()..addToParent(component2);
        expect(component3.world, game.world);
      },
    );

    testWithGame<_MyGame>('simple test', _MyGame.new, (game) async {
      final c = _FooComponent();
      game.world.add(c);
      c.foo();
      expect(c.world.calledFoo, isTrue);
    });

    testWithGame<_MyGame>('gameRef can be mocked', _MyGame.new, (game) async {
      final component = _BarComponent();
      await game.world.ensureAdd(component);

      component.world = MockWorld();

      expect(component.world, isA<MockWorld>());
    });
  });
}

class _Component<T extends World> extends Component with HasWorld<T> {}

class _MyGame extends FlameGame {
  _MyGame() : super(world: _WorldReferenceWorld());
}

class _FooComponent extends Component with HasWorld<_WorldReferenceWorld> {
  void foo() {
    world.foo();
  }
}

class _BarComponent extends Component with HasWorld<_WorldReferenceWorld> {}

class MockWorld extends Mock implements _WorldReferenceWorld {}
