import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/src/game/game_render_box.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlameGame', () {
    testWithFlameGame(
      'default viewport does not change size',
      (game) async {
        game.onGameResize(Vector2(100.0, 200.0));
        expect(game.canvasSize, Vector2(100.0, 200.0));
        expect(game.size, Vector2(100.0, 200.0));
      },
    );

    testWithFlameGame('Game in game', (game) async {
      final innerGame = FlameGame();
      game.add(innerGame);
      await game.ready();

      expect(innerGame.canvasSize, closeToVector(Vector2(800, 600)));
      expect(innerGame.isLoaded, isTrue);
      expect(innerGame.isMounted, isTrue);
    });

    group('components', () {
      testWithFlameGame(
        'Add component',
        (game) async {
          final component = Component();
          await game.ensureAdd(component);

          expect(component.isMounted, isTrue);
          expect(game.children.contains(component), isTrue);
        },
      );

      testWithFlameGame(
        'Add component with onLoad function',
        (game) async {
          final component = _MyAsyncComponent();
          await game.ensureAdd(component);

          expect(game.children.contains(component), isTrue);
          expect(component.gameSize, game.size);
          expect(component.game, game);
        },
      );

      testWithFlameGame(
        'prepare adds game and calls onGameResize',
        (game) async {
          final component = _MyComponent();
          await game.ensureAdd(component);

          expect(component.gameSize, game.size);
          expect(component.game, game);
        },
      );

      testWithFlameGame(
        'component can be tapped',
        (game) async {
          final component = _MyTappableComponent();
          await game.ensureAdd(component);
          final tapDispatcher = game.firstChild<MultiTapDispatcher>()!;
          tapDispatcher.handleTapDown(
            1,
            TapDownDetails(
              kind: PointerDeviceKind.touch,
              globalPosition: const Offset(10, 10),
              localPosition: const Offset(10, 10),
            ),
          );

          expect(component.tapped, isTrue);
        },
      );

      testWidgets(
        'component render and update is called',
        (WidgetTester tester) async {
          final game = FlameGame();
          late GameRenderBox renderBox;
          await tester.pumpWidget(
            Builder(
              builder: (BuildContext context) {
                renderBox = GameRenderBox(
                  game,
                  context,
                  isRepaintBoundary: true,
                );
                return GameWidget(game: game);
              },
            ),
          );
          renderBox.attach(PipelineOwner());

          final component = _MyComponent();
          await game.add(component);
          renderBox.gameLoopCallback(1.0);

          expect(component.isUpdateCalled, isTrue);
          renderBox.paint(
            PaintingContext(ContainerLayer(), Rect.zero),
            Offset.zero,
          );
          expect(component.isRenderCalled, isTrue);
          renderBox.detach();
        },
      );

      testWithFlameGame(
        'onRemove is only called once on component',
        (game) async {
          final component = _MyComponent();
          await game.ensureAdd(component);
          // The component is removed both by removing it on the game instance
          // and by the function on the component, but the onRemove callback
          // should only be called once.
          component.removeFromParent();
          game.remove(component);
          // The component is not removed from the component list until an
          // update has been performed.
          game.update(0.0);

          expect(component.onRemoveCallCounter, 1);
        },
      );

      testWithFlameGame(
        'removes PositionComponent when removeFromParent is called',
        (game) async {
          final world = game.world;
          final component = PositionComponent();
          await world.ensureAdd(component);
          expect(world.children.length, equals(1));
          component.removeFromParent();
          game.updateTree(0);
          expect(world.children.isEmpty, equals(isTrue));
        },
      );

      testWidgets(
        'can add a component to a game without a layout',
        (WidgetTester tester) async {
          final game = FlameGame();
          final world = game.world;
          final component = Component()..addToParent(world);
          expect(game.hasLayout, isFalse);

          await tester.pumpWidget(GameWidget(game: game));
          game.update(0);
          expect(world.children.length, 1);
          expect(world.children.first, component);
        },
      );
    });

    testWithGame<FlameGame>(
      'children in the constructor',
      () {
        return FlameGame(
          world: World(
            children: [_IndexedComponent(1), _IndexedComponent(2)],
          ),
        );
      },
      (game) async {
        final world = game.world;
        world.add(_IndexedComponent(3));
        world.add(_IndexedComponent(4));
        await game.ready();

        expect(world.children.length, 4);
        expect(
          world.children
              .whereType<_IndexedComponent>()
              .map((c) => c.index)
              .isSorted((a, b) => a.compareTo(b)),
          isTrue,
        );
      },
    );

    testWithGame<FlameGame>(
      'children in the constructor and onLoad',
      () {
        return _ConstructorChildrenGame(
          constructorChildren: [_IndexedComponent(1), _IndexedComponent(2)],
          onLoadChildren: [_IndexedComponent(3), _IndexedComponent(4)],
        );
      },
      (game) async {
        game.add(_IndexedComponent(5));
        game.add(_IndexedComponent(6));
        await game.ready();

        expect(game.children.whereType<_IndexedComponent>().length, 6);
        expect(
          game.children
              .whereType<_IndexedComponent>()
              .map((c) => c.index)
              .isSorted((a, b) => a.compareTo(b)),
          isTrue,
        );
      },
    );

    group('completers', () {
      testWidgets(
        'game calls loaded completer',
        (WidgetTester tester) async {
          final game = _CompleterGame();

          await tester.pumpWidget(GameWidget(game: game));
          expect(game.loadedCompleterCount, 1);
          expect(game.mountedCompleterCount, 1);
        },
      );

      testWithGame(
        'game calls mount completer',
        _CompleterGame.new,
        (game) async {
          await game.mounted;
          expect(game.mountedCompleterCount, 1);
        },
      );

      testWidgets(
        'game calls loaded completer',
        (WidgetTester tester) async {
          final game = _CompleterGame();

          await tester.pumpWidget(GameWidget(game: game));
          expect(game.loadedCompleterCount, 1);
          expect(game.mountedCompleterCount, 1);
          await tester.pumpWidget(Container());
          expect(game.removedCompleterCount, 1);
        },
      );
    });

    group('world and camera', () {
      testWithFlameGame(
        'game world setter',
        (game) async {
          final newWorld = World();
          game.world = newWorld;
          expect(game.world, newWorld);
          expect(game.camera.world, newWorld);
        },
      );

      testWithFlameGame(
        'game camera setter',
        (game) async {
          final newCamera = CameraComponent();
          game.camera = newCamera;
          expect(game.camera, newCamera);
          expect(game.world, isNotNull);
          expect(game.camera.world, game.world);
        },
      );

      testWithFlameGame(
        'game camera setter with another world',
        (game) async {
          final camera1 = game.camera;
          final world1 = game.world;
          expect(world1, isNotNull);
          expect(camera1, isNotNull);

          final camera2 = CameraComponent();
          final world2 = World();
          camera2.world = world2;

          game.camera = camera2;
          expect(game.camera, camera2);
          expect(game.camera.world, world2);
          expect(game.world, world1);

          game.camera = camera1;
          expect(game.camera, camera1);
          expect(game.camera.world, world1);
          expect(game.world, world1);
        },
      );
    });
  });

  group('Render box attachment', () {
    testWidgets('calls on attach', (tester) async {
      await tester.runAsync(() async {
        var hasAttached = false;
        final game = _OnAttachGame(() => hasAttached = true);

        await tester.pumpWidget(GameWidget(game: game));
        await game.toBeLoaded();
        await tester.pump();

        expect(hasAttached, isTrue);
      });
    });
  });

  group('pauseWhenBackgrounded:', () {
    testWidgets(
      'game resumes when widget is rebuilt',
      (tester) async {
        final game = FlameGame();

        await tester.pumpWidget(GameWidget(game: game));
        expect(game.paused, isFalse);
        expect(game.isPausedOnBackground, isFalse);

        await tester.pumpWidget(Container());
        expect(game.paused, isTrue);
        expect(game.isPausedOnBackground, isTrue);

        await tester.pumpWidget(GameWidget(game: game));
        expect(game.paused, isFalse, reason: 'Game should resume on remount');
        expect(
          game.isPausedOnBackground,
          isFalse,
          reason: 'Background pause flag should be cleared on remount resume',
        );
      },
    );

    testWithFlameGame('true', (game) async {
      game.pauseWhenBackgrounded = true;

      game.lifecycleStateChange(AppLifecycleState.paused);
      expect(game.paused, isTrue);

      game.lifecycleStateChange(AppLifecycleState.resumed);
      expect(game.paused, isFalse);
    });

    testWithFlameGame('false', (game) async {
      game.pauseWhenBackgrounded = false;

      game.lifecycleStateChange(AppLifecycleState.paused);
      expect(game.paused, isFalse);

      game.lifecycleStateChange(AppLifecycleState.resumed);
      expect(game.paused, isFalse);
    });

    for (final startingLifecycleState in AppLifecycleState.values) {
      testWidgets(
        'game is not paused on start when initially $startingLifecycleState',
        (tester) async {
          WidgetsBinding.instance.handleAppLifecycleStateChanged(
            startingLifecycleState,
          );
          addTearDown(() {
            // Don't use [WidgetsBinding.instance.resetLifecycleState()]
            // because it sets the lifecycle to null which prevents
            // [game.onLoad] from running in other tests.
            WidgetsBinding.instance.handleAppLifecycleStateChanged(
              AppLifecycleState.resumed,
            );
          });
          expect(
            WidgetsBinding.instance.lifecycleState,
            startingLifecycleState,
          );

          final game = FlameGame();

          final gameWidget = GameWidget(game: game);
          await tester.pumpWidget(gameWidget);

          GameWidgetState.initGameStateListener(game, () {});

          expect(game.paused, isFalse);
        },
      );
    }

    testWidgets(
      'game is paused when app is backgrounded',
      (tester) async {
        final game = FlameGame();

        await tester.pumpWidget(GameWidget(game: game));

        await game.toBeLoaded();
        await tester.pump();

        expect(game.paused, isFalse);
        WidgetsBinding.instance.handleAppLifecycleStateChanged(
          AppLifecycleState.paused,
        );
        expect(game.paused, isTrue);
        WidgetsBinding.instance.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        expect(game.paused, isFalse);
      },
    );
  });
}

class _IndexedComponent extends Component {
  final int index;

  _IndexedComponent(this.index);
}

class _ConstructorChildrenGame extends FlameGame {
  final Iterable<_IndexedComponent> onLoadChildren;

  _ConstructorChildrenGame({
    required Iterable<_IndexedComponent> constructorChildren,
    required this.onLoadChildren,
  }) : super(children: constructorChildren);

  @override
  Future<void> onLoad() async {
    addAll(onLoadChildren);
  }
}

class _MyTappableComponent extends _MyComponent with TapCallbacks {
  bool tapped = false;

  @override
  void onTapDown(TapDownEvent info) {
    info.continuePropagation = true;
    tapped = true;
  }
}

class _MyComponent extends PositionComponent with HasGameReference {
  bool isUpdateCalled = false;
  bool isRenderCalled = false;
  int onRemoveCallCounter = 0;
  late Vector2 gameSize;

  @override
  void update(double dt) {
    isUpdateCalled = true;
  }

  @override
  void render(Canvas canvas) {
    isRenderCalled = true;
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    this.gameSize = gameSize;
  }

  @override
  bool containsLocalPoint(_) => true;

  @override
  void onRemove() {
    super.onRemove();
    ++onRemoveCallCounter;
  }
}

class _MyAsyncComponent extends _MyComponent {
  @override
  Future<void> onLoad() {
    return Future.value();
  }
}

class _OnAttachGame extends FlameGame {
  final VoidCallback onAttachCallback;

  _OnAttachGame(this.onAttachCallback);

  @override
  void onAttach() {
    onAttachCallback();
  }

  @override
  Future<void>? onLoad() {
    return Future.delayed(const Duration(seconds: 1));
  }
}

class _CompleterGame extends FlameGame {
  int loadedCompleterCount = 0;
  int mountedCompleterCount = 0;
  int removedCompleterCount = 0;

  _CompleterGame() {
    loaded.whenComplete(() => loadedCompleterCount++);
    mounted.whenComplete(() => mountedCompleterCount++);
    removed.whenComplete(() => removedCompleterCount++);
  }
}
