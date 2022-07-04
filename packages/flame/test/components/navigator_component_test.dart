import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NavigatorComponent', () {
    testWithFlameGame('normal route pushing/popping', (game) async {
      final navigator = NavigatorComponent(
        routes: {
          'A': Route(builder: _ComponentA.new),
          'B': Route(builder: _ComponentB.new),
          'C': Route(builder: _ComponentC.new),
        },
        initialRoute: 'A',
      );
      game.add(navigator);
      await game.ready();

      expect(navigator.currentRoute.name, 'A');
      expect(navigator.currentRoute.children.length, 1);
      expect(navigator.currentRoute.children.first, isA<_ComponentA>());

      navigator.pushNamed('B');
      await game.ready();
      expect(navigator.currentRoute.name, 'B');
      expect(navigator.currentRoute.children.length, 1);
      expect(navigator.currentRoute.children.first, isA<_ComponentB>());

      navigator.pop();
      await game.ready();
      expect(navigator.currentRoute.name, 'A');

      navigator.pushRoute(Route(builder: _ComponentD.new), name: 'Dee');
      await game.ready();
      expect(navigator.currentRoute.name, 'Dee');
      expect(navigator.currentRoute.children.length, 1);
      expect(navigator.currentRoute.children.first, isA<_ComponentD>());
    });

    testWithFlameGame('Route factories', (game) async {
      final navigator = NavigatorComponent(
        initialRoute: 'initial',
        routes: {'initial': Route(builder: _ComponentD.new)},
        routeFactories: {
          'a': (arg) => Route(builder: _ComponentA.new),
          'b': (arg) => Route(builder: _ComponentB.new),
        },
      );
      game.add(navigator);
      await game.ready();

      expect(navigator.currentRoute.name, 'initial');

      navigator.pushNamed('a/101');
      await game.ready();
      expect(navigator.currentRoute.name, 'a/101');
      expect(navigator.currentRoute.children.first, isA<_ComponentA>());

      navigator.pushNamed('b/something');
      await game.ready();
      expect(navigator.currentRoute.name, 'b/something');
      expect(navigator.currentRoute.children.first, isA<_ComponentB>());
    });

    testWithFlameGame('onUnknownRoute', (game) async {
      final navigator = NavigatorComponent(
        initialRoute: 'home',
        routes: {'home': Route(builder: _ComponentA.new)},
        onUnknownRoute: (name) => Route(builder: _ComponentD.new),
      )..addToParent(game);
      await game.ready();

      navigator.pushNamed('hello');
      await game.ready();
      expect(navigator.currentRoute.name, 'hello');
      expect(navigator.currentRoute.children.first, isA<_ComponentD>());
    });

    testWithFlameGame('default unknown route handling', (game) async {
      final navigator = NavigatorComponent(
        initialRoute: 'home',
        routes: {'home': Route(builder: _ComponentA.new)},
      )..addToParent(game);
      await game.ready();

      expect(
        () => navigator.pushNamed('hello'),
        throwsA(
          predicate(
            (e) =>
                e is ArgumentError &&
                e.message ==
                    'Route "hello" could not be resolved by the Navigator',
          ),
        ),
      );
    });
  });
}

class _ComponentA extends Component {}

class _ComponentB extends Component {}

class _ComponentC extends Component {}

class _ComponentD extends Component {}
