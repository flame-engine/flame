import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/rendering.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Route', () {
    testWithFlameGame('Route without a builder', (game) async {
      final router = RouterComponent(
        initialRoute: 'start',
        routes: {
          'start': Route(Component.new),
          'new': Route(null),
        },
      )..addToParent(game);
      await game.ready();
      expect(
        () => router.pushNamed('new'),
        failsAssert(
          'Either provide `builder` in the constructor, or override the '
          'build() method',
        ),
      );
    });

    testWithFlameGame('onPush and onPop methods', (game) async {
      var onPushCalled = 0;
      var onPopCalled = 0;
      var buildCalled = 0;
      Route? previousRoute;
      final router = RouterComponent(
        initialRoute: 'start',
        routes: {
          'start': Route(Component.new),
          'new': CustomRoute(
            onPush: (self, prevRoute) {
              onPushCalled++;
              previousRoute = prevRoute;
            },
            onPop: (self, prevRoute) {
              onPopCalled++;
              previousRoute = prevRoute;
            },
            build: (self) {
              buildCalled++;
              return PositionComponent();
            },
          ),
        },
      )..addToParent(game);
      await game.ready();

      router.pushNamed('new');
      expect(buildCalled, 1);
      await game.ready();
      expect(router.currentRoute.name, 'new');
      expect(router.currentRoute.children.first, isA<PositionComponent>());
      expect(onPushCalled, 1);
      expect(onPopCalled, 0);
      expect(previousRoute!.name, 'start');

      previousRoute = null;
      router.pop();
      await game.ready();
      expect(onPushCalled, 1);
      expect(onPopCalled, 1);
      expect(previousRoute!.name, 'start');
      expect(router.currentRoute.name, 'start');
    });

    testWithFlameGame('Stop and resume time', (game) async {
      final router = RouterComponent(
        initialRoute: 'start',
        routes: {
          'start': Route(_TimerComponent.new),
          'pause': CustomRoute(
            builder: Component.new,
            onPush: (self, route) => route?.stopTime(),
            onPop: (self, route) => route.resumeTime(),
          ),
        },
      )..addToParent(game);
      await game.ready();

      final timer = router.currentRoute.children.first as _TimerComponent;
      expect(timer.elapsedTime, 0);

      game.update(1);
      expect(timer.elapsedTime, 1);

      router.pushNamed('pause');
      await game.ready();
      expect(router.currentRoute.name, 'pause');
      expect(router.previousRoute!.timeSpeed, 0);

      game.update(10);
      expect(timer.elapsedTime, 1);

      router.previousRoute!.timeSpeed = 0.1;
      game.update(10);
      expect(timer.elapsedTime, 2);

      router.pop();
      await game.ready();
      expect(router.currentRoute.name, 'start');
      expect(router.currentRoute.timeSpeed, 1);

      game.update(10);
      expect(timer.elapsedTime, 12);
    });

    testGolden(
      'Rendering of opaque routes',
      (game) async {
        final router = RouterComponent(
          initialRoute: 'initial',
          routes: {
            'initial': Route(
              () => _ColoredComponent(
                color: const Color(0xFFFF0000),
                size: Vector2.all(100),
              ),
            ),
            'green': Route(
              () => _ColoredComponent(
                color: const Color(0x8800FF00),
                position: Vector2.all(10),
                size: Vector2.all(80),
              ),
            ),
          },
        )..addToParent(game);
        await game.ready();
        router.pushNamed('green');
      },
      size: Vector2(100, 100),
      goldenFile: '../_goldens/route_opaque.png',
    );

    testGolden(
      'Rendering of transparent routes',
      (game) async {
        final router = RouterComponent(
          initialRoute: 'initial',
          routes: {
            'initial': Route(
              () => _ColoredComponent(
                color: const Color(0xFFFF0000),
                size: Vector2.all(100),
              ),
            ),
            'green': Route(
              () => _ColoredComponent(
                color: const Color(0x8800FF00),
                position: Vector2.all(10),
                size: Vector2.all(80),
              ),
              transparent: true,
            ),
          },
        )..addToParent(game);
        await game.ready();
        router.pushNamed('green');
      },
      size: Vector2(100, 100),
      goldenFile: '../_goldens/route_transparent.png',
    );

    testGolden(
      'Rendering of transparent routes with decorators',
      (game) async {
        final router = RouterComponent(
          initialRoute: 'initial',
          routes: {
            'initial': Route(
              () => _ColoredComponent(
                color: const Color(0xFFFF0000),
                size: Vector2.all(100),
              ),
            ),
            'green': CustomRoute(
              builder: () => _ColoredComponent(
                color: const Color(0x8800FF00),
                position: Vector2.all(10),
                size: Vector2.all(80),
              ),
              transparent: true,
              onPush: (self, route) =>
                  route!.addRenderEffect(PaintDecorator.grayscale()),
              onPop: (self, route) => route.removeRenderEffect(),
            ),
          },
        )..addToParent(game);
        await game.ready();
        router.pushNamed('green');
      },
      size: Vector2(100, 100),
      goldenFile: '../_goldens/route_with_decorators.png',
    );

    testGolden(
      'Rendering effect can be removed',
      (game) async {
        final router = RouterComponent(
          initialRoute: 'initial',
          routes: {
            'initial': Route(
              () => _ColoredComponent(
                color: const Color(0xFFFF0000),
                size: Vector2.all(100),
              ),
            ),
            'green': CustomRoute(
              builder: () => _ColoredComponent(
                color: const Color(0x8800FF00),
                position: Vector2.all(10),
                size: Vector2.all(80),
              ),
              transparent: true,
              onPush: (self, route) =>
                  route!.addRenderEffect(PaintDecorator.grayscale()),
              onPop: (self, route) => route.removeRenderEffect(),
            ),
          },
        )..addToParent(game);
        await game.ready();
        router.pushNamed('green');
        await game.ready();
        router.pop();
      },
      size: Vector2(100, 100),
      goldenFile: '../_goldens/route_decorator_removed.png',
    );

    testWithFlameGame('componentsAtPoint for opaque route', (game) async {
      final router = RouterComponent(
        initialRoute: 'initial',
        routes: {
          'initial': Route(
            () => PositionComponent(size: Vector2.all(100)),
          ),
          'new': Route(
            () => PositionComponent(size: Vector2.all(100)),
          ),
        },
      )..addToParent(game);
      await game.ready();

      router.pushNamed('new');
      await game.ready();
      expect(
        game.componentsAtPoint(Vector2(50, 50)).toList(),
        [router.currentRoute.children.first, game],
      );
    });

    testWithFlameGame('componentsAtPoint for transparent route', (game) async {
      final router = RouterComponent(
        initialRoute: 'initial',
        routes: {
          'initial': Route(
            () => PositionComponent(size: Vector2.all(100)),
          ),
          'new': Route(
            () => PositionComponent(size: Vector2.all(100)),
            transparent: true,
          ),
        },
      )..addToParent(game);
      await game.ready();

      router.pushNamed('new');
      await game.ready();
      expect(
        game.componentsAtPoint(Vector2(50, 50)).toList(),
        [
          router.currentRoute.children.first,
          router.previousRoute!.children.first,
          game,
        ],
      );
    });
  });
}

class CustomRoute extends Route {
  CustomRoute({
    Component Function()? builder,
    super.transparent,
    void Function(Route, Route?)? onPush,
    void Function(Route, Route)? onPop,
    Component Function(Route)? build,
  })  : _onPush = onPush,
        _onPop = onPop,
        _build = build,
        super(builder);

  final void Function(Route, Route?)? _onPush;
  final void Function(Route, Route)? _onPop;
  final Component Function(Route)? _build;

  @override
  void onPush(Route? route) => _onPush?.call(this, route);

  @override
  void onPop(Route route) => _onPop?.call(this, route);

  @override
  Component build() => _build?.call(this) ?? super.build();
}

class _TimerComponent extends Component {
  double elapsedTime = 0;

  @override
  void update(double dt) {
    elapsedTime += dt;
  }
}

class _ColoredComponent extends PositionComponent {
  _ColoredComponent({
    required Color color,
    super.position,
    super.size,
  }) : _paint = Paint()..color = color;

  final Paint _paint;

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _paint);
  }
}
