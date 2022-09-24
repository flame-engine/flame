import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ValueRoute', () {
    testWidgets('can return a value', (tester) async {
      final router = RouterComponent(
        initialRoute: '/',
        routes: {'/': Route(Component.new)},
      );
      await tester.pumpWidget(
        GameWidget(
          game: FlameGame(children: [router]),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(router.currentRoute.name, '/');

      final future = router.pushAndWait(
        _CustomValueRoute<int>(
          defaultValue: 100,
          builder: (route) {
            return _CustomComponent(
              onUpdate: (double dt) {
                Future.microtask(() => route.completeWith(5));
              },
            );
          },
        ),
      );
      await tester.pump();
      expect(await future, 5);
    });

    testWidgets('default return value', (tester) async {
      final router = RouterComponent(
        initialRoute: '/',
        routes: {'/': Route(Component.new)},
      );
      await tester.pumpWidget(
        GameWidget(
          game: FlameGame(children: [router]),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(router.currentRoute.name, '/');

      final future = router.pushAndWait(
        _CustomValueRoute<int>(
          defaultValue: 100,
          builder: (route) => Component(),
        ),
      );
      await tester.pump();
      router.pop();
      await tester.pump();
      expect(await future, 100);

      final future2 = router.pushAndWait(
        _CustomValueRoute<int>(
          defaultValue: 17,
          builder: (route) {
            return _CustomComponent(
              onUpdate: (double dt) {
                Future.microtask(() => route.complete());
              },
            );
          },
        ),
      );
      await tester.pump();
      expect(await future2, 17);
    });

    testWidgets('routes over the ValueRoute', (tester) async {
      final router = RouterComponent(
        initialRoute: '/',
        routes: {'/': Route(Component.new)},
      );
      await tester.pumpWidget(
        GameWidget(
          game: FlameGame(children: [router]),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(router.currentRoute.name, '/');

      final customRoute = _CustomValueRoute<String>(
        defaultValue: '',
        builder: (route) => Component(),
      );
      final future = router.pushAndWait(customRoute);
      router.pushRoute(Route(Component.new), name: 'one');
      router.pushRoute(Route(Component.new), name: 'two');
      await tester.pump();
      expect(router.currentRoute.name, 'two');

      customRoute.completeWith('ok!');
      await tester.pump();
      expect(await future, 'ok!');
      expect(router.currentRoute.name, '/');
    });
  });
}

class _CustomValueRoute<T> extends ValueRoute<T> {
  _CustomValueRoute({
    required T defaultValue,
    required this.builder,
  }) : super(value: defaultValue);

  final Component Function(_CustomValueRoute<T>) builder;

  @override
  Component build() => builder(this);
}

class _CustomComponent extends Component {
  _CustomComponent({this.onUpdate});

  final void Function(double dt)? onUpdate;

  @override
  void update(double dt) => onUpdate?.call(dt);
}
