import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../inventory_cubit.dart';
import '../player_cubit.dart';

class PlayerListener extends Component
    with FlameBlocListenable<PlayerCubit, PlayerState> {
  PlayerState? last;
  @override
  void onNewState(PlayerState state) {
    super.onNewState(state);

    last = state;
  }
}

class SadPlayerListener extends Component
    with FlameBlocListenable<PlayerCubit, PlayerState> {
  PlayerState? last;

  @override
  bool listenWhen(PlayerState previousState, PlayerState newState) {
    return newState == PlayerState.sad;
  }

  @override
  void onNewState(PlayerState state) {
    super.onNewState(state);

    last = state;
  }
}

void main() {
  group('FlameBlocListenable', () {
    testWithFlameGame(
      'throws assertion error when the bloc is not provided',
      (game) async {
        final bloc = InventoryCubit();
        final provider =
            FlameBlocProvider<InventoryCubit, InventoryState>.value(
          value: bloc,
        );
        await game.ensureAdd(provider);

        final component = PlayerListener();
        expect(() => provider.ensureAdd(component), throwsAssertionError);
      },
    );

    testWithFlameGame(
      'throws assertion error when the bloc set multiple times',
      (game) async {
        final bloc = PlayerCubit();
        final component = PlayerListener()..bloc = bloc;
        expect(() => component.bloc = bloc, throwsAssertionError);
      },
    );

    testWithFlameGame(
      'closes the subscription when it is removed',
      (game) async {
        final bloc = PlayerCubit();
        final provider = FlameBlocProvider<PlayerCubit, PlayerState>.value(
          value: bloc,
        );
        await game.ensureAdd(provider);

        final component = PlayerListener();
        await provider.ensureAdd(component);

        component.removeFromParent();
        await game.ready();

        bloc.makeSad();
        await Future.microtask(() {});
        expect(component.last, isNull);
      },
    );

    testWithFlameGame(
      'listen only listenWhen returns true',
      (game) async {
        final bloc = PlayerCubit();
        final provider = FlameBlocProvider<PlayerCubit, PlayerState>.value(
          value: bloc,
        );
        await game.ensureAdd(provider);

        final component = SadPlayerListener();
        await provider.ensureAdd(component);

        bloc.kill();
        await Future.microtask(() {});
        expect(component.last, isNull);
      },
    );

    testWithFlameGame(
      'successfully retreive the bloc via getter',
      (game) async {
        final bloc = PlayerCubit();
        final provider = FlameBlocProvider<PlayerCubit, PlayerState>.value(
          value: bloc,
        );
        await game.ensureAdd(provider);

        final component = PlayerListener();
        await provider.ensureAdd(component);

        expect(component.bloc, bloc);
      },
    );

    testWithFlameGame(
        'successfully revisit previously visited route with bloc listener',
        (game) async {
      var playerPushCalled = 0;
      var playerPopCalled = 0;
      var sadPushCalled = 0;
      var sadPopCalled = 0;
      final router = RouterComponent(
        routes: {
          'start': Route(Component.new),
          'playerRoute': CustomBlocRoute(
            onPush: (self, prevRoute) {
              playerPushCalled++;
            },
            onPop: (self, prevRoute) {
              playerPopCalled++;
            },
            build: (self) => PlayerListener(),
          ),
          'sadRoute': CustomBlocRoute(
            onPush: (self, prevRoute) {
              sadPushCalled++;
            },
            onPop: (self, prevRoute) {
              sadPopCalled++;
            },
            build: (self) => SadPlayerListener(),
          ),
        },
        initialRoute: 'start',
      );

      final bloc = PlayerCubit();
      final provider = FlameBlocProvider<PlayerCubit, PlayerState>.value(
        value: bloc,
        children: [router],
      );

      await game.ensureAdd(provider);

      //Visit routes first time
      router.pushNamed('playerRoute');
      await game.ready();
      expect(router.currentRoute.name, 'playerRoute');
      expect(playerPushCalled, 1);
      router.pop();
      await game.ready();
      expect(playerPushCalled, 1);
      expect(playerPopCalled, 1);
      router.pushNamed('sadRoute');
      await game.ready();
      expect(sadPushCalled, 1);
      expect(router.currentRoute.name, 'sadRoute');
      router.pop();

      //Revisit playerRoute
      await game.ready();
      expect(sadPushCalled, 1);
      expect(sadPopCalled, 1);
      router.pushNamed('playerRoute');

      await game.ready();
      expect(playerPushCalled, 2);
      router.pop();

      //Revisit sadRoute
      await game.ready();
      router.pushNamed('sadRoute');
      await game.ready();
      expect(sadPushCalled, 2);
    });
  });
}

class CustomBlocRoute extends Route {
  CustomBlocRoute({
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
