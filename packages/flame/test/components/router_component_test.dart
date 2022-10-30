import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/widgets.dart' hide Route, OverlayRoute;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RouterComponent', () {
    testWithFlameGame('normal route pushing/popping', (game) async {
      final router = RouterComponent(
        routes: {
          'A': Route(_ComponentA.new),
          'B': Route(_ComponentB.new),
          'C': Route(_ComponentC.new),
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

      router.pushRoute(Route(_ComponentD.new), name: 'Dee');
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
        routes: {'initial': Route(_ComponentD.new)},
        routeFactories: {
          'a': (arg) => Route(_ComponentA.new),
          'b': (arg) => Route(_ComponentB.new),
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
          'A': Route(_ComponentA.new),
          'B': Route(_ComponentB.new),
          'C': Route(_ComponentC.new),
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
        routes: {'home': Route(_ComponentA.new)},
        onUnknownRoute: (name) => Route(_ComponentD.new),
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
        routes: {'home': Route(_ComponentA.new)},
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
        routes: {'home': Route(_ComponentA.new)},
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
          'A': Route(_ComponentA.new),
          'B': Route(_ComponentB.new),
          'C': Route(_ComponentC.new),
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

    testWidgets(
      'can handle overlays via the Router',
      (tester) async {
        const key1 = ValueKey('one');
        const key2 = ValueKey('two');
        const key3 = ValueKey('three');
        final game = FlameGame();
        final router = RouterComponent(
          initialRoute: 'home',
          routes: {'home': Route(Component.new)},
        )..addToParent(game);

        await tester.pumpWidget(
          GameWidget(
            game: game,
            overlayBuilderMap: {
              'first!': (_, __) => Container(key: key1),
              'second': (_, __) => Container(key: key2),
            },
          ),
        );
        await tester.pump();
        await tester.pump();
        expect(router.stack.length, 1);
        expect(router.currentRoute.name, 'home');
        expect(game.overlays.activeOverlays.isEmpty, true);

        router.pushOverlay('second');
        await tester.pump();
        expect(game.overlays.activeOverlays, ['second']);
        expect(find.byKey(key1), findsNothing);
        expect(find.byKey(key2), findsOneWidget);

        router.pop();
        await tester.pump();
        expect(game.overlays.activeOverlays.isEmpty, true);
        expect(find.byKey(key1), findsNothing);
        expect(find.byKey(key2), findsNothing);

        router.pushOverlay('first!');
        router.pushOverlay('second');
        await tester.pump();
        expect(game.overlays.activeOverlays, ['first!', 'second']);
        expect(find.byKey(key1), findsOneWidget);
        expect(find.byKey(key2), findsOneWidget);

        router.pushRoute(
          OverlayRoute((ctx, game) => Container(key: key3)),
          name: 'new-route',
        );
        await tester.pump();
        expect(game.overlays.activeOverlays, ['first!', 'second', 'new-route']);
        expect(find.byKey(key1), findsOneWidget);
        expect(find.byKey(key2), findsOneWidget);
        expect(find.byKey(key3), findsOneWidget);
      },
    );
  });
}

class _ComponentA extends Component {}

class _ComponentB extends Component {}

class _ComponentC extends Component {}

class _ComponentD extends Component {}
