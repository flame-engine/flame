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

      router.pushReplacementNamed('B');
      await game.ready();
      expect(router.routes.length, 4);
      expect(router.currentRoute.name, 'B');
      expect(router.currentRoute.children.length, 1);
      expect(router.currentRoute.children.first, isA<_ComponentB>());

      router.pushReplacement(Route(_ComponentE.new), name: 'E');
      await game.ready();
      expect(router.routes.length, 5);
      expect(router.currentRoute.name, 'E');
      expect(router.currentRoute.children.length, 1);
      expect(router.currentRoute.children.first, isA<_ComponentE>());
      expect(router.stack.length, 2);
    });

    testWithFlameGame('replacing with 2 routes', (game) async {
      final router = RouterComponent(
        routes: {
          'A': Route(_ComponentA.new),
          'B': Route(_ComponentB.new),
        },
        initialRoute: 'A',
      );
      game.add(router);
      await game.ready();

      expect(router.routes.length, 2);
      expect(router.currentRoute.name, 'A');
      expect(router.currentRoute.children.length, 1);
      expect(router.currentRoute.children.first, isA<_ComponentA>());

      router.pushReplacementNamed('B');
      await game.ready();
      expect(router.currentRoute.name, 'B');
      expect(router.currentRoute.children.length, 1);
      expect(router.currentRoute.children.first, isA<_ComponentB>());
      expect(router.stack.length, 1);
    });

    testWithFlameGame(
      'didPop/onPop/didPush/onPush was called correctly',
      (game) async {
        const initialRouteName = 'A';
        final router = RouterComponent(
          routes: {
            'A': _TestRoute(_ComponentA.new),
            'B': _TestRoute(_ComponentB.new),
            'C': _TestRoute(_ComponentC.new),
          },
          initialRoute: initialRouteName,
        );
        game.add(router);
        await game.ready();

        expect(
          router.routes.values.whereType<_TestRoute>().every(
            (e) =>
                e.onPopTimes == 0 &&
                e.didPopTimes == 0 &&
                (e.name == initialRouteName ||
                    (e.onPushTimes == 0 && e.didPushTimes == 0)),
          ),
          isTrue,
        );

        final routeA = router.routes[initialRouteName]! as _TestRoute;
        expect(routeA.onPushTimes, 1);
        expect(routeA.didPushTimes, 1);
        expect(routeA.lastDidPushPreviousRoute, isNull);
        expect(routeA.lastOnPushPreviousRoute, isNull);
        expect(routeA.lastDidPopNextRoute, isNull);
        expect(routeA.lastOnPopNextRoute, isNull);

        router.pushNamed('B');
        await game.ready();

        final routeB = router.routes['B']! as _TestRoute;
        expect(routeB.onPopTimes, 0);
        expect(routeB.didPopTimes, 0);
        expect(routeB.onPushTimes, 1);
        expect(routeB.didPushTimes, 1);

        expect(routeA.lastDidPushPreviousRoute, isNull);
        expect(routeA.lastOnPushPreviousRoute, isNull);
        expect(routeA.lastDidPopNextRoute, isNull);
        expect(routeA.lastOnPopNextRoute, isNull);

        expect(routeB.lastDidPushPreviousRoute, routeA.name);
        expect(routeB.lastOnPushPreviousRoute, routeA.name);
        expect(routeB.lastDidPopNextRoute, isNull);
        expect(routeB.lastOnPopNextRoute, isNull);

        router.pop();
        expect(routeB.onPopTimes, 1);
        expect(routeB.didPopTimes, 1);
        expect(routeB.onPushTimes, 1);
        expect(routeB.didPushTimes, 1);

        expect(routeB.lastDidPushPreviousRoute, routeA.name);
        expect(routeB.lastOnPushPreviousRoute, routeA.name);
        expect(routeB.lastDidPopNextRoute, routeA.name);
        expect(routeB.lastOnPopNextRoute, routeA.name);

        // Check that all other still hasn't been called.
        expect(
          router.routes.values
              .whereType<_TestRoute>()
              .where((e) => e.name != 'B')
              .every(
                (e) =>
                    e.onPopTimes == 0 &&
                    e.didPopTimes == 0 &&
                    (e.name == initialRouteName ||
                        (e.onPushTimes == 0 && e.didPushTimes == 0)),
              ),
          isTrue,
        );
        await game.ready();

        final routeD = _TestRoute(_ComponentD.new);
        router.pushReplacement(routeD, name: 'D');
        expect(routeD.onPopTimes, 0);
        expect(routeD.didPopTimes, 0);
        expect(routeD.onPushTimes, 1);
        expect(routeD.didPushTimes, 1);

        expect(routeA.onPopTimes, 1);
        expect(routeA.didPopTimes, 1);
        expect(routeA.onPushTimes, 1);
        expect(routeA.didPushTimes, 1);

        expect(routeA.lastDidPushPreviousRoute, isNull);
        expect(routeA.lastOnPushPreviousRoute, isNull);
        expect(routeA.lastDidPopNextRoute, routeD.name);
        expect(routeA.lastOnPopNextRoute, routeD.name);

        expect(routeD.lastDidPushPreviousRoute, routeA.name);
        expect(routeD.lastOnPushPreviousRoute, routeA.name);
        expect(routeD.lastDidPopNextRoute, isNull);
        expect(routeD.lastOnPopNextRoute, isNull);

        await game.ready();

        router.pushReplacementNamed('B');
        expect(routeB.onPopTimes, 1);
        expect(routeB.didPopTimes, 1);
        expect(routeB.onPushTimes, 2);
        expect(routeB.didPushTimes, 2);

        expect(routeD.onPopTimes, 1);
        expect(routeD.didPopTimes, 1);
        expect(routeD.onPushTimes, 1);
        expect(routeD.didPushTimes, 1);

        expect(routeB.lastDidPushPreviousRoute, routeD.name);
        expect(routeB.lastOnPushPreviousRoute, routeD.name);
        expect(routeB.lastDidPopNextRoute, routeA.name);
        expect(routeB.lastOnPopNextRoute, routeA.name);

        expect(routeD.lastDidPushPreviousRoute, routeA.name);
        expect(routeD.lastOnPushPreviousRoute, routeA.name);
        expect(routeD.lastDidPopNextRoute, routeB.name);
        expect(routeD.lastOnPopNextRoute, routeB.name);
      },
    );

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
      await game.ready();
      router.pushNamed('C');
      await game.ready();
      expect(router.stack.length, 3);

      router.pushNamed('B');
      await game.ready();
      expect(router.stack.length, 3);
      router.pushNamed('A');
      await game.ready();
      expect(router.stack.length, 3);

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

    testWithFlameGame('canPop returns correct value', (game) async {
      final router = RouterComponent(
        routes: {
          'A': Route(_ComponentA.new),
          'B': Route(_ComponentB.new),
        },
        initialRoute: 'A',
      )..addToParent(game);
      await game.ready();

      // Should return false when only one route is on the stack
      expect(router.canPop(), false);
      expect(router.stack.length, 1);

      // Should return true when multiple routes are on the stack
      router.pushNamed('B');
      await game.ready();
      expect(router.canPop(), true);
      expect(router.stack.length, 2);

      // Should return false again after popping back to one route
      router.pop();
      await game.ready();
      expect(router.canPop(), false);
      expect(router.stack.length, 1);
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
        router.pop();
        await tester.pump();
        expect(game.overlays.activeOverlays, ['first!']);

        router.pushRoute(
          OverlayRoute((ctx, game) => Container(key: key3)),
          name: 'new-route',
        );
        await tester.pump();
        expect(game.overlays.activeOverlays, ['first!', 'new-route']);
        expect(find.byKey(key1), findsOneWidget);
        expect(find.byKey(key2), findsNothing);
        expect(find.byKey(key3), findsOneWidget);

        router.pushReplacementOverlay('second');
        await tester.pump();
        expect(game.overlays.activeOverlays, ['first!', 'second']);
        expect(find.byKey(key1), findsOneWidget);
        expect(find.byKey(key2), findsOneWidget);
        expect(find.byKey(key3), findsNothing);
      },
    );
  });
}

class _ComponentA extends Component {}

class _ComponentB extends Component {}

class _ComponentC extends Component {}

class _ComponentD extends Component {}

class _ComponentE extends Component {}

class _TestRoute extends Route {
  int onPopTimes = 0;
  int onPushTimes = 0;
  int didPopTimes = 0;
  int didPushTimes = 0;
  String? lastOnPopNextRoute;
  String? lastOnPushPreviousRoute;
  String? lastDidPopNextRoute;
  String? lastDidPushPreviousRoute;

  _TestRoute(super.builder);

  @override
  void onPop(Route nextRoute) {
    super.onPop(nextRoute);
    onPopTimes++;
    lastOnPopNextRoute = nextRoute.name;
  }

  @override
  void onPush(Route? previousRoute) {
    super.onPush(previousRoute);
    onPushTimes++;
    lastOnPushPreviousRoute = previousRoute?.name;
  }

  @override
  void didPop(Route nextRoute) {
    super.didPop(nextRoute);
    didPopTimes++;
    lastDidPopNextRoute = nextRoute.name;
  }

  @override
  void didPush(Route? previousRoute) {
    super.didPush(previousRoute);
    didPushTimes++;
    lastDidPushPreviousRoute = previousRoute?.name;
  }
}
