import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RouterComponent', () {
    testWithFlameGame('normal route pushing/popping', (game) async {
      final router = RouterComponent(
        routes: {
          'A': Route(builder: _ComponentA.new),
          'B': Route(builder: _ComponentB.new),
          'C': Route(builder: _ComponentC.new),
        },
        initialRoute: 'A',
      );
      game.add(router);
      await game.ready();

      expect(router.routes.length, 3);
      expect(router.currentRoute.name, 'A');
      expect(router.currentRoute.children.length, 1);
      expect(router.currentRoute.children.first, isA<_ComponentA>());

      router.pushNamed('B');
      await game.ready();
      expect(router.currentRoute.name, 'B');
      expect(router.currentRoute.children.length, 1);
      expect(router.currentRoute.children.first, isA<_ComponentB>());
      expect(router.stack.length, 2);

      router.pop();
      await game.ready();
      expect(router.currentRoute.name, 'A');
      expect(router.stack.length, 1);

      router.pushRoute(Route(builder: _ComponentD.new), name: 'Dee');
      await game.ready();
      expect(router.routes.length, 4);
      expect(router.currentRoute.name, 'Dee');
      expect(router.currentRoute.children.length, 1);
      expect(router.currentRoute.children.first, isA<_ComponentD>());
      expect(router.stack.length, 2);
    });

    testWithFlameGame('Route factories', (game) async {
      final router = RouterComponent(
        initialRoute: 'initial',
        routes: {'initial': Route(builder: _ComponentD.new)},
        routeFactories: {
          'a': (arg) => Route(builder: _ComponentA.new),
          'b': (arg) => Route(builder: _ComponentB.new),
        },
      );
      game.add(router);
      await game.ready();

      expect(router.currentRoute.name, 'initial');

      router.pushNamed('a/101');
      await game.ready();
      expect(router.currentRoute.name, 'a/101');
      expect(router.currentRoute.children.first, isA<_ComponentA>());

      router.pushNamed('b/something');
      await game.ready();
      expect(router.currentRoute.name, 'b/something');
      expect(router.currentRoute.children.first, isA<_ComponentB>());
    });

    testWithFlameGame('push an existing route', (game) async {
      final router = RouterComponent(
        routes: {
          'A': Route(builder: _ComponentA.new),
          'B': Route(builder: _ComponentB.new),
          'C': Route(builder: _ComponentC.new),
        },
        initialRoute: 'A',
      )..addToParent(game);
      await game.ready();

      router.pushNamed('A');
      await game.ready();
      expect(router.stack.length, 1);

      router.pushNamed('B');
      router.pushNamed('C');
      expect(router.stack.length, 3);

      router.pushNamed('B');
      expect(router.stack.length, 3);
      router.pushNamed('A');
      expect(router.stack.length, 3);

      await game.ready();
      expect(router.children.length, 3);
      expect((router.children.elementAt(0) as Route).name, 'C');
      expect((router.children.elementAt(1) as Route).name, 'B');
      expect((router.children.elementAt(2) as Route).name, 'A');
    });

    testWithFlameGame('onUnknownRoute', (game) async {
      final router = RouterComponent(
        initialRoute: 'home',
        routes: {'home': Route(builder: _ComponentA.new)},
        onUnknownRoute: (name) => Route(builder: _ComponentD.new),
      )..addToParent(game);
      await game.ready();

      router.pushNamed('hello');
      await game.ready();
      expect(router.currentRoute.name, 'hello');
      expect(router.currentRoute.children.first, isA<_ComponentD>());
    });

    testWithFlameGame('default unknown route handling', (game) async {
      final router = RouterComponent(
        initialRoute: 'home',
        routes: {'home': Route(builder: _ComponentA.new)},
      )..addToParent(game);
      await game.ready();

      expect(
        () => router.pushNamed('hello'),
        throwsA(
          predicate(
            (e) =>
                e is ArgumentError &&
                e.message ==
                    'Route "hello" could not be resolved by the Router',
          ),
        ),
      );
    });

    testWithFlameGame('cannot pop last remaining route', (game) async {
      final router = RouterComponent(
        initialRoute: 'home',
        routes: {'home': Route(builder: _ComponentA.new)},
      )..addToParent(game);
      await game.ready();

      expect(
        router.pop,
        failsAssert('Cannot pop the last route from the Router'),
      );
    });

    testWithFlameGame('popUntilNamed', (game) async {
      final router = RouterComponent(
        routes: {
          'A': Route(builder: _ComponentA.new),
          'B': Route(builder: _ComponentB.new),
          'C': Route(builder: _ComponentC.new),
        },
        initialRoute: 'A',
      );
      game.add(router);
      await game.ready();

      router.pushNamed('B');
      router.pushNamed('C');
      await game.ready();
      expect(router.stack.length, 3);
      expect(router.children.length, 3);

      router.popUntilNamed('A');
      await game.ready();
      expect(router.stack.length, 1);
      expect(router.children.length, 1);
      expect(router.currentRoute.name, 'A');
    });
  });
}

class _ComponentA extends Component {}

class _ComponentB extends Component {}

class _ComponentC extends Component {}

class _ComponentD extends Component {}
