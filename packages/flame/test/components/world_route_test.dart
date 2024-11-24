import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestWorld1 extends World {
  int value = 0;
}

class _TestWorld2 extends World {}

void main() {
  group('WorldRoute', () {
    testWidgets('can set a new world', (tester) async {
      final router = RouterComponent(
        initialRoute: '/',
        routes: {
          '/': Route(Component.new),
          '/world': WorldRoute(_TestWorld1.new),
        },
      );
      final game = FlameGame(children: [router]);
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();
      expect(router.currentRoute.name, '/');
      expect(game.world, isNot(isA<_TestWorld1>));

      router.pushNamed('/world');
      await tester.pump();
      expect(router.currentRoute.name, '/world');
      expect(game.world, isA<_TestWorld1>());
    });

    testWidgets('changes back to previous world on pop', (tester) async {
      final router = RouterComponent(
        initialRoute: '/world1',
        routes: {
          '/world1': WorldRoute(_TestWorld1.new),
          '/world2': WorldRoute(_TestWorld2.new),
        },
      );
      final game = FlameGame(children: [router]);
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();
      expect(router.currentRoute.name, '/world1');
      expect(game.world, isA<_TestWorld1>());

      router.pushNamed('/world2');
      expect(router.currentRoute.name, '/world2');
      expect(game.world, isA<_TestWorld2>());

      router.pop();
      expect(router.currentRoute.name, '/world1');
      expect(game.world, isA<_TestWorld1>());
    });

    testWidgets('retains the state of the world', (tester) async {
      final router = RouterComponent(
        initialRoute: '/world1',
        routes: {
          '/world1': WorldRoute(_TestWorld1.new),
          '/world2': WorldRoute(_TestWorld2.new),
        },
      );
      final game = FlameGame(children: [router]);
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();
      expect(router.currentRoute.name, '/world1');
      expect(game.world, isA<_TestWorld1>());
      expect((game.world as _TestWorld1).value, isZero);
      (game.world as _TestWorld1).value = 1;

      router.pushReplacementNamed('/world2');
      expect(router.currentRoute.name, '/world2');
      expect(game.world, isA<_TestWorld2>());

      router.pushReplacementNamed('/world1');
      expect(router.currentRoute.name, '/world1');
      expect(game.world, isA<_TestWorld1>());
      expect((game.world as _TestWorld1).value, 1);
    });

    testWidgets('does not retain the state of world', (tester) async {
      final router = RouterComponent(
        initialRoute: '/world1',
        routes: {
          '/world1': WorldRoute(_TestWorld1.new, maintainState: false),
          '/world2': WorldRoute(_TestWorld2.new),
        },
      );
      final game = FlameGame(children: [router]);
      await tester.pumpWidget(GameWidget(game: game));
      await tester.pump();
      await tester.pump();
      expect(router.currentRoute.name, '/world1');
      expect(game.world, isA<_TestWorld1>());
      expect((game.world as _TestWorld1).value, isZero);
      (game.world as _TestWorld1).value = 1;

      router.pushReplacementNamed('/world2');
      expect(router.currentRoute.name, '/world2');
      expect(game.world, isA<_TestWorld2>());

      router.pushReplacementNamed('/world1');
      expect(router.currentRoute.name, '/world1');
      expect(game.world, isA<_TestWorld1>());
      expect((game.world as _TestWorld1).value, isZero);
    });
  });
}
