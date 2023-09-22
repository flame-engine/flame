import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../custom_component.dart';

void main() {
  group('Component', () {
    group('Lifecycle', () {
      testWithFlameGame('correct order', (game) async {
        final component = LifecycleComponent();
        await game.world.add(component);
        await game.ready();

        expect(
          component.events,
          ['onLoad', 'onGameResize [800.0,600.0]', 'onMount'],
        );
      });

      testWithFlameGame('component mounted completes', (game) async {
        final component = LifecycleComponent();
        final mounted = component.mounted;
        await game.world.add(component);
        await game.ready();

        await expectLater(mounted, completes);
        await expectLater(component.mounted, completes);
      });

      testWithFlameGame(
        'component.removed completes if obtained before the game was ready',
        (game) async {
          final component = LifecycleComponent();
          final removed = component.removed;
          await game.world.add(component);
          await game.ready();

          game.world.remove(component);
          game.update(0);

          await expectLater(removed, completes);
        },
      );

      testWithFlameGame(
        'component removed completes when set after game is ready',
        (game) async {
          final component = LifecycleComponent();
          await game.world.add(component);
          await game.ready();
          final removed = component.removed;

          game.world.remove(component);
          game.update(0);
          await expectLater(removed, completes);
        },
      );

      testWithFlameGame(
        'component removed completes after changing parent',
        (game) async {
          final parent = LifecycleComponent('parent')..addToParent(game);
          final child = LifecycleComponent('child')..addToParent(parent);
          await game.ready();
          final removed = child.removed;

          child.parent = game;
          game.update(0);
          await expectLater(removed, completes);

          final removedFromParent = child.removed;
          child.removeFromParent();
          game.update(0);
          await expectLater(removedFromParent, completes);
        },
      );

      testWithFlameGame('remove parent of child that has removed set',
          (game) async {
        final parent = LifecycleComponent('parent')..addToParent(game);
        final child = LifecycleComponent('child')..addToParent(parent);
        await game.ready();
        final removed = child.removed;

        parent.removeFromParent();
        game.update(0);
        await expectLater(removed, completes);
        expect(child.isRemoved, true);
      });

      testWithFlameGame(
        'component mounted completes when changing parent',
        (game) async {
          final parent = LifecycleComponent('parent');
          final child = LifecycleComponent('child');
          parent.add(child);
          game.world.add(parent);

          var mounted = child.mounted;
          await game.ready();

          await expectLater(mounted, completes);

          child.parent = game;
          mounted = child.mounted;
          game.update(0);
          await game.ready();

          await expectLater(mounted, completes);
        },
      );

      testWithFlameGame(
        'component mounted completes when changing parent from a null parent',
        (game) async {
          final parent = LifecycleComponent('parent');
          final child = LifecycleComponent('child');
          game.world.add(parent);

          final mounted = child.mounted;
          await game.ready();

          child.parent = parent;
          game.update(0);
          await game.ready();

          expect(child.parent, parent);
          expect(child.isMounted, true);
          await expectLater(mounted, completes);
        },
      );

      testWithFlameGame(
        'Component.mounted completes after the component is mounted',
        (game) async {
          final child = LifecycleComponent();
          var mountedFutureCompleted = false;
          final future = child.mounted.then((_) {
            expect(child.isMounted, true);
            expect(child.events, contains('onMount'));
            mountedFutureCompleted = true;
          });
          game.world.add(child);
          await game.ready();
          expect(child.isMounted, true);
          await future;
          expect(mountedFutureCompleted, true);
        },
      );

      testWithFlameGame('component loaded completes', (game) async {
        final component = LifecycleComponent();
        await game.world.add(component);
        final loaded = component.loaded;

        await game.ready();

        await expectLater(loaded, completes);
        await expectLater(component.loaded, completes);
      });

      testWithFlameGame(
        'loaded completes even if accessed before the component added to game',
        (game) async {
          final component = Component();
          final loadedFuture = component.loaded;
          game.world.add(component);
          await game.ready();
          expectLater(loadedFuture, completes);
        },
      );

      testWithFlameGame('correct lifecycle on parent change', (game) async {
        final parent = LifecycleComponent('parent');
        final child = LifecycleComponent('child');
        parent.add(child);
        game.world.add(parent);
        await game.ready();
        child.parent = game;
        game.update(0);
        await game.ready();

        expect(
          parent.events,
          ['onLoad', 'onGameResize [800.0,600.0]', 'onMount'],
        );
        // onLoad should only be called the first time that the component is
        // loaded.
        expect(
          child.events,
          [
            'onLoad',
            'onGameResize [800.0,600.0]',
            'onMount',
            'onRemove',
            'onGameResize [800.0,600.0]',
            'onMount',
          ],
        );
      });

      testWithFlameGame(
        'components added in correct order even with different load times',
        (game) async {
          final a = SlowComponent('A', 0.1);
          final b = SlowComponent('B', 0.02);
          final c = SlowComponent('C', 0.05);
          final d = SlowComponent('D', 0);
          game.world.add(a);
          game.world.add(b);
          game.world.add(c);
          game.world.add(d);
          await game.ready();
          expect(game.world.children.toList(), equals([a, b, c, d]));
        },
      );

      testWidgets('Multi-widget game', (WidgetTester tester) {
        return tester.runAsync(() async {
          final game1 = FlameGame();
          final game2 = FlameGame();
          // Device size is set to 800x600
          await tester.pumpWidget(
            Row(
              textDirection: TextDirection.ltr,
              children: [
                SizedBox(width: 295, child: GameWidget(game: game1)),
                SizedBox(width: 505, child: GameWidget(game: game2)),
              ],
            ),
          );
          final component1 = LifecycleComponent('A')..addToParent(game1);
          final component2 = LifecycleComponent('B')..addToParent(game2);
          await game1.ready();
          await game2.ready();
          expect(
            component1.events,
            ['onLoad', 'onGameResize [295.0,600.0]', 'onMount'],
          );
          expect(
            component2.events,
            ['onLoad', 'onGameResize [505.0,600.0]', 'onMount'],
          );
        });
      });

      testWithFlameGame(
        'Remove and re-add component with children',
        (game) async {
          final parent = LifecycleComponent('parent');
          final child = LifecycleComponent('child')..addToParent(parent);
          await game.world.add(parent);
          await game.ready();

          expect(parent.isMounted, true);
          expect(child.isMounted, true);
          expect(parent.parent, game.world);
          expect(parent.parent?.parent, game);
          expect(child.parent, parent);

          parent.removeFromParent();
          await game.ready();

          expect(parent.isMounted, false);
          expect(child.isMounted, false);
          expect(parent.parent, isNull);
          expect(child.parent, isNull);

          await game.world.add(parent);
          await game.ready();

          expect(parent.isMounted, true);
          expect(child.isMounted, true);
          expect(parent.parent, game.world);
          expect(parent.parent?.parent, game);
          expect(child.parent, parent);
        },
      );

      _myDetachableGame(open: false).testGameWidget(
        'Confirm child component only loads once with game widget change',
        verify: (game, tester) async {
          final child = LifecycleComponent();
          expect(game.onAttachCalled, false);
          expect(game.isLoaded, false);
          expect(game.isMounted, false);

          await tester.tap(find.text('Toggle'));
          // First will be the build of the wrapper
          await tester.pump();
          // Second will be the build of the game widget itself
          await tester.pump();

          expect(game.onAttachCalled, true);
          expect(game.onDetachCalled, false);
          expect(game.isAttached, true);
          expect(game.isLoaded, true);
          expect(game.isMounted, true);
          expect(child.isLoaded, false);
          expect(child.isMounted, false);
          await game.world.add(child);
          expect(child.isLoaded, true);
          await tester.pump();
          expect(child.isMounted, true);
          expect(game.world.children.length, 1);

          await tester.tap(find.text('Toggle'));
          await tester.pump();

          expect(game.onDetachCalled, true);
          expect(game.world.children.length, 1);
          game.resetValues();
          expect(game.isAttached, false);
          expect(game.isMounted, true);
          expect(child.isMounted, true);

          await tester.tap(find.text('Toggle'));
          await tester.pump();
          await tester.pump();

          expect(game.onAttachCalled, true);
          expect(game.isAttached, true);
          expect(game.isMounted, true);
          expect(child.isMounted, true);
        },
      );
    });

    group('onGameResize', () {
      testWithFlameGame('game calls onGameResize during add', (game) async {
        final a = _GameResizeComponent('a');
        await game.ensureAdd(a);
        expect(a.gameSize, Vector2(800, 600));
      });

      testWithFlameGame('game calls resize after added', (game) async {
        final a = _GameResizeComponent('a');
        await game.ensureAdd(a);
        game.onGameResize(Vector2(100, 100));
        expect(a.gameSize, Vector2(100, 100));
      });

      testWithFlameGame(
        "game calls doesn't change component size",
        (game) async {
          final a = _GameResizeComponent('a');
          await game.ensureAdd(a);
          game.onGameResize(Vector2.all(100));
          expect(a.size, isNot(Vector2.all(100)));
        },
      );
    });

    group('Adding components', () {
      testWithFlameGame(
        'child is not added until the component is loaded',
        (game) async {
          final child = Component();
          final parent = Component();
          await parent.add(child);

          expect(child.isLoaded, false);
          expect(child.isMounted, false);

          await game.ensureAdd(parent);

          expect(child.isLoaded, true);
          expect(child.isMounted, true);
          expect(parent.contains(child), true);
        },
      );

      testWithFlameGame('children in the constructor', (game) async {
        game.world.add(
          Component(
            children: [ComponentA(), ComponentB()],
          ),
        );
        await game.ready();

        expect(game.world.children.length, 1);
        expect(game.world.children.first.children.length, 2);
        expect(
          game.world.children.first.children.elementAt(0),
          isA<ComponentA>(),
        );
        expect(
          game.world.children.first.children.elementAt(1),
          isA<ComponentB>(),
        );
      });

      testWithFlameGame('add multiple children with addAll', (game) async {
        final children = List.generate(10, (_) => _AsyncLoadingChild());
        final parent = Component(children: children);
        await game.ensureAdd(parent);
        expect(parent.children.length, children.length);
      });

      testWithFlameGame(
        'removing a component and re-adding it to the same parent in the '
        'same tick',
        (game) async {
          final child = Component();
          final parent = Component(children: [child]);
          await game.ensureAdd(parent);
          child.removeFromParent();
          parent.add(child);
          game.update(0);
          expect(child.parent, parent);
          expect(parent.children, [child]);
          expect(child.isMounted, isTrue);
          expect(child.isRemoving, isFalse);
        },
      );

      testWithFlameGame(
        'removing a component and re-adding it to the same parent in the '
        'same tick with setter',
        (game) async {
          final child = Component();
          final parent = Component(children: [child]);
          await game.ensureAdd(parent);
          child.removeFromParent();
          child.parent = parent;
          game.update(0);
          expect(child.parent, parent);
          expect(parent.children, [child]);
          expect(child.isMounted, isTrue);
          expect(child.isRemoving, isFalse);
        },
      );

      testWithFlameGame(
        'removing a component and adding it to another parent in the same tick',
        (game) async {
          final child = Component();
          final parent = Component(children: [child]);
          final otherParent = Component();
          await game.ensureAddAll([parent, otherParent]);
          child.removeFromParent();
          otherParent.add(child);
          game.update(0);
          expect(child.parent, otherParent);
          expect(parent.children, []);
          expect(otherParent.children, [child]);
          expect(child.isMounted, isTrue);
        },
      );

      testWithFlameGame(
        'swapping between multiple parents in the same tick',
        (game) async {
          final child = Component();
          final parents = [
            Component(children: [child]),
            Component(),
            Component(),
          ];
          await game.ensureAddAll(parents);
          child.parent = parents[1];
          child.parent = parents[2];
          game.update(0);
          expect(child.parent, parents[2]);
          expect(parents[0].children, []);
          expect(parents[1].children, []);
          expect(parents[2].children, [child]);
          expect(child.isMounted, isTrue);
        },
      );

      testWithFlameGame('children in constructor and onLoad', (game) async {
        final component = TwoChildrenComponent(
          children: [ComponentA(), ComponentB()],
        );
        game.world.add(component);
        await game.ready();

        expect(game.world.children.length, 1);
        expect(game.world.children.first, component);
        expect(component.children.length, 4);
        expect(component.children.elementAt(0), isA<ComponentA>());
        expect(component.children.elementAt(1), isA<ComponentB>());
        expect(component.children.elementAt(2), component.child1);
        expect(component.children.elementAt(3), component.child2);
      });

      testWithGame<_PrepareGame>(
        'adding children to a parent that is not yet added to a game should '
        'not run double onMount',
        _PrepareGame.new,
        (game) async {
          await game.ready();
          final parent = game.prepareParent;
          expect(parent.onMountRuns, 1);
          expect(parent.children.isNotEmpty, true);
          expect((parent.children.first as _OnPrepareComponent).onMountRuns, 1);
        },
      );

      testWithFlameGame(
        'game resize while components are being added',
        (game) async {
          final component = ComponentWithSizeHistory();
          game.world.add(component);
          expect(component.history, isEmpty);
          expect(component.isLoading, false);
          expect(component.isLoaded, true);
          expect(component.isMounted, false);
          game.onGameResize(Vector2(500, 300));
          game.onGameResize(Vector2(300, 500));
          expect(
            component.history,
            equals([Vector2(500, 300), Vector2(300, 500)]),
          );
          await game.ready();
          expect(component.history.length, 3);
          expect(component.history.last, equals(Vector2(300, 500)));
        },
      );

      testWithFlameGame(
        'when child is async loading, the child is added to the component '
        'only after loading',
        (game) async {
          final child = _AsyncLoadingChild();
          final wrapper = Component();
          await game.ensureAdd(wrapper);

          final future = wrapper.add(child);
          expect(wrapper.contains(child), false);
          await future;
          expect(wrapper.contains(child), false);
          await game.ready();
          expect(wrapper.contains(child), true);
        },
      );
    });

    group('Removing components', () {
      testWithFlameGame('removing child from a component', (game) async {
        final child = Component();
        final parent = Component();
        await game.ensureAdd(parent);
        expect(parent.isMounted, true);

        await parent.add(child);
        game.update(0); // children are only added on the next tick
        expect(parent.contains(child), true);

        parent.remove(child);
        game.update(0); // children are only removed on the next tick
        expect(parent.contains(child), false);
      });

      testWithFlameGame(
        'removeFromParent()',
        (game) async {
          final component = Component()..addToParent(game);
          await game.ready();

          expect(component.isMounted, true);
          component.removeFromParent();
          await game.ready();

          expect(component.isMounted, false);
          expect(component.isLoaded, true);
          expect(game.world.children.length, 0);
        },
      );

      testWithFlameGame(
        'remove and re-add should not double trigger onRemove',
        (game) async {
          final component = LifecycleComponent();
          await game.ensureAdd(component);

          component.removeFromParent();
          game.update(0);
          expect(component.countEvents('onRemove'), 1);
          expect(component.isMounted, false);

          game.world.add(component);
          await game.ready();
          expect(component.countEvents('onRemove'), 1);
          expect(game.world.children.length, 1);
        },
      );

      testWithFlameGame(
        'try to remove a component before it was ever added',
        (game) async {
          expect(
            () => game.world.remove(Component()),
            failsAssert(
              "Trying to remove a component that doesn't belong to any parent",
            ),
          );
        },
      );

      testWithFlameGame(
        'try to remove component from a wrong parent',
        (game) async {
          final badParent = Component()..addToParent(game);
          final child = Component()..addToParent(game);
          await game.ready();
          expect(
            () => badParent.remove(child),
            failsAssert(
              'Trying to remove a component that belongs to a different '
              "parent: this = Instance of 'Component', component's parent = "
              "Instance of 'FlameGame<World>'",
            ),
          );
        },
      );

      testWithFlameGame(
        'remove an uninitialized component',
        (game) async {
          final parent = Component();
          final child = Component()..addToParent(parent);
          expect(child.isLoading, false);
          expect(child.isLoaded, false);
          expect(child.isMounted, false);
          child.removeFromParent();

          game.world.add(parent);
          await game.ready();

          expect(child.isLoading, false);
          expect(child.isLoaded, false);
          expect(child.isMounted, false);
          expect(parent.isMounted, true);
          expect(parent.children.length, 0);
          expect(child.parent, isNull);
        },
      );

      testWithFlameGame(
        'remove and re-add uninitialized component with non-trivial onLoad',
        (game) async {
          final parent = Component();
          final component = _SlowLoadingComponent();
          parent.add(component);
          // Since [parent] is detached, the [component] cannot start loading
          expect(component.isLoading, false);
          parent.remove(component);
          expect(component.isLoading, false);
          expect(component.onLoadCalledCount, 0);

          final newParent = Component()..addToParent(game);
          newParent.add(component);
          expect(component.isLoading, true);
          expect(component.onLoadCalledCount, 1);
          await game.ready();
          expect(component.isMounted, true);
          expect(newParent.children.length, 1);
          expect(newParent.children.first, component);
        },
      );

      testWithFlameGame(
        'remove component immediately after adding',
        (game) async {
          final component = LifecycleComponent();
          game.world.add(component);
          expect(component.isLoading, true);
          expect(component.isLoaded, false);
          game.world.remove(component);
          await game.ready();

          expect(game.world.children.length, 0);
          expect(component.isLoaded, true);
          expect(component.isMounted, false);
          // onRemove shouldn't be called because there was never an onMount
          expect(component.events, ['onLoad']);
        },
      );

      testWithFlameGame(
        'remove slow-loading component immediately after adding',
        (game) async {
          final component = _SlowLoadingComponent();
          game.world.add(component);
          expect(component.isLoading, true);
          expect(component.isLoaded, false);
          game.world.remove(component);
          await game.ready();

          expect(game.world.children.length, 0);
          expect(component.isMounted, false);
        },
      );

      testWithFlameGame(
        'component removes itself from onLoad',
        (game) async {
          final component = _SelfRemovingOnLoadComponent();
          game.world.add(component);
          await game.ready();

          expect(game.world.children.length, 0);
          expect(component.isLoaded, true);
          expect(component.isMounted, false);
        },
      );

      testWithFlameGame(
        'component removes itself from onMount',
        (game) async {
          final component = _SelfRemovingOnMountComponent();
          game.world.add(component);
          await game.ready();

          expect(game.world.children.length, 0);
          expect(component.isLoaded, true);
          expect(component.isMounted, false);
        },
      );

      testWithFlameGame(
        'Quickly removed component can be re-added',
        (game) async {
          final component = LifecycleComponent();
          game.world.add(component);
          game.world.remove(component);
          await game.ready();
          component.events.add('--');

          expect(game.world.children.length, 0);
          game.world.add(component);
          await game.ready();

          expect(game.world.children.length, 1);
          expect(component.isMounted, true);
          expect(component.isLoaded, true);
          expect(
            component.events,
            [
              'onLoad',
              '--',
              'onGameResize [800.0,600.0]',
              'onMount',
            ],
          );
        },
      );

      testWithFlameGame('remove a tree of components', (game) async {
        final component1 = Component();
        final component2 = Component();
        final component3 = Component();
        component1.addAll([component2, component3]);
        game.world.add(component1);
        await game.ready();

        expect(component1.isMounted, true);
        expect(component2.isMounted, true);
        expect(component3.isMounted, true);
        component1.removeFromParent();
        component1.remove(component2);
        await game.ready();

        expect(component1.isMounted, false);
        expect(component2.isMounted, false);
        expect(component3.isMounted, false);

        game.world.add(component1);
        game.world.add(component2);
        await game.ready();

        expect(component1.isMounted, true);
        expect(component2.isMounted, true);
        expect(component3.isMounted, true);
        expect(game.world.children.length, 2);
        expect(component1.children.length, 1);

        game.descendants().forEach((component) {
          expect(component.isMounted, true);
          expect(component.parent!.children.contains(component), true);
        });
      });

      testWithFlameGame(
        'remove component from a paused game',
        (game) async {
          game.pauseEngine();

          final component = Component();
          await game.world.add(component);
          game.world.remove(component);

          game.resumeEngine();
          game.update(0);
        },
      );

      testWithFlameGame(
        'removeWhere removes the correct components',
        (game) async {
          final components = List.generate(
            10,
            _IdentifiableComponent.new,
          );
          game.world.addAll(components);
          await game.ready();
          expect(game.world.children.length, 10);
          game.world.removeWhere(
            (c) => (c as _IdentifiableComponent).id.isEven,
          );
          game.update(0);
          expect(game.world.children.length, 5);
          expect(
            game.world.children
                .every((c) => (c as _IdentifiableComponent).id.isOdd),
            true,
          );
        },
      );

      testWithFlameGame(
        'removeWhere works before all components are mounted',
        (game) async {
          game.world.add(_RemoveWhereComponent());
          expect(
            () async {
              await game.ready();
            },
            returnsNormally,
          );
        },
      );
    });

    group('Moving components', () {
      testWithFlameGame('moving to unrelated component', (game) async {
        final parentA = Component()..addToParent(game);
        final parentB = Component()..addToParent(game);
        final child = Component()..addToParent(parentA);
        await game.ready();

        expect(child.isMounted, true);
        expect(child.parent, parentA);

        child.parent = parentB;
        await game.ready();
        expect(child.isMounted, true);
        expect(child.parent, parentB);
        expect(parentA.hasChildren, false);
        expect(parentB.hasChildren, true);
      });

      testWithFlameGame('moving to sibling', (game) async {
        final componentA = Component()..addToParent(game.world);
        final componentB = Component()..addToParent(game.world);
        await game.ready();
        expect(game.world.children.toList(), [componentA, componentB]);
        expect(componentA.hasChildren, false);
        expect(componentB.hasChildren, false);

        componentA.parent = componentB;
        await game.ready();
        expect(game.world.children.toList(), [componentB]);
        expect(componentB.children.toList(), [componentA]);
        expect(componentA.parent, componentB);
      });

      testWithFlameGame('moving to parent', (game) async {
        final parent = Component()..addToParent(game.world);
        final child = Component()..addToParent(parent);
        await game.ready();
        expect(game.world.children.toList(), [parent]);
        expect(parent.children.toList(), [child]);

        child.parent = game.world;
        await game.ready();
        expect(game.world.children.toList(), [parent, child]);
        expect(parent.children.toList(), isEmpty);
      });
    });

    group('descendants()', () {
      testWithFlameGame(
        'descendants in a deep component tree',
        (game) async {
          expect(game.world.descendants().length, 0);
          final component = Component()..add(Component()..add(Component()));
          game.world.add(component);
          expect(game.hasLifecycleEvents, true);
          expect(game.world.descendants().length, 0);
          await game.ready();

          expect(game.world.descendants().length, 3);

          final descendantsWithSelf = game.world.descendants(includeSelf: true);
          expect(descendantsWithSelf.length, 4);
          for (final component in descendantsWithSelf) {
            expect(component.findGame() != null, true);
          }
        },
      );

      testWithFlameGame(
        'length should not change when hasPendingLifecycleEvents is true after '
        'adding',
        (game) async {
          final component = Component()..add(Component()..add(Component()));
          await game.world.add(component);
          await game.ready();
          expect(game.hasLifecycleEvents, false);

          game.world.add(Component());

          expect(game.hasLifecycleEvents, true);
          expect(game.world.descendants().length, 3);
          // Remember that CameraComponent, Viewport, Viewfinder and World are
          // added by default.
          expect(game.descendants().length, 7);
        },
      );

      testWithFlameGame(
        'order must adhere to the "depth-first search" algorithm',
        (game) async {
          final world = game.world;
          final componentA = Component()..addToParent(world);
          final componentB = Component()..addToParent(world);
          final componentC = Component()..addToParent(world);
          final componentD = Component()..addToParent(componentB);
          final componentE = Component()..addToParent(componentB);
          final componentF = Component()..addToParent(componentE);
          await game.ready();

          final expectedOrder = [
            componentA,
            componentB,
            componentD,
            componentE,
            componentF,
            componentC,
          ];
          expect(
            world.descendants().toList(),
            expectedOrder,
          );
          expect(
            world.descendants(includeSelf: true).toList(),
            [world, ...expectedOrder],
          );
          expect(
            world.descendants(reversed: true).toList(),
            expectedOrder.reversed.toList(),
          );
          expect(
            world.descendants(reversed: true, includeSelf: true).toList(),
            [...expectedOrder.reversed, world],
          );
        },
      );

      testWithFlameGame('descendants() iterator is lazy', (game) async {
        final componentA = Visitor()..addToParent(game);
        final componentB = Visitor()..addToParent(game);
        final componentC = Visitor()..addToParent(componentB);
        final componentD = Visitor()..addToParent(componentB);
        final componentE = Visitor()..addToParent(game);
        await game.ready();

        game.descendants().whereType<Visitor>().firstWhere((component) {
          component.visited = true;
          return component == componentC;
        });
        expect(componentA.visited, true);
        expect(componentB.visited, true);
        expect(componentC.visited, true);
        expect(componentD.visited, false);
        expect(componentE.visited, false);
      });

      testWithFlameGame(
        'firstChild returns the first child on the matching type',
        (game) async {
          final firstA = ComponentA();
          final firstB = ComponentB();

          await game.ensureAdd(firstA);
          await game.ensureAdd(ComponentA());
          await game.ensureAdd(firstB);
          await game.ensureAdd(ComponentB());

          final childA = game.firstChild<ComponentA>();
          expect(childA, isNotNull);
          expect(childA, equals(firstA));

          final childB = game.firstChild<ComponentB>();
          expect(childB, isNotNull);
          expect(childB, equals(firstB));

          final nonExistentChild = game.firstChild<SpriteComponent>();
          expect(nonExistentChild, isNull);
        },
      );

      testWithFlameGame(
        'lastChild returns the last child on the matching type',
        (game) async {
          final lastA = ComponentA();
          final lastB = ComponentB();

          await game.ensureAdd(ComponentA());
          await game.ensureAdd(lastA);
          await game.ensureAdd(ComponentB());
          await game.ensureAdd(lastB);

          final childA = game.lastChild<ComponentA>();
          expect(childA, isNotNull);
          expect(childA, equals(lastA));

          final childB = game.lastChild<ComponentB>();
          expect(childB, isNotNull);
          expect(childB, equals(lastB));

          final nonExistentChild = game.lastChild<SpriteComponent>();
          expect(nonExistentChild, isNull);
        },
      );
    });

    group('onChildrenChanged()', () {
      testWithFlameGame(
        'after adding a child the method onChildrenChanged should be called',
        (game) async {
          final child = Component();
          final parent = _OnChildrenChangedComponent();
          await game.ensureAdd(parent);
          expect(parent.onChangedChildrenRuns, 0);
          await parent.ensureAdd(child);
          expect(parent.onChangedChildrenRuns, 1);
          expect(parent.lastChangeType, ChildrenChangeType.added);
        },
      );

      testWithFlameGame(
        'after adding several children using addAll the method '
        'onChildrenChanged should be called list.length times',
        (game) async {
          final list = [Component(), Component()];
          final parent = _OnChildrenChangedComponent();
          await game.ensureAdd(parent);
          expect(parent.onChangedChildrenRuns, 0);
          await parent.ensureAddAll(list);
          expect(parent.onChangedChildrenRuns, 2);
          expect(parent.lastChangeType, ChildrenChangeType.added);
        },
      );

      testWithFlameGame(
        'changing the parent should call onChildrenChanged on both parents',
        (game) async {
          final child = Component();
          final parent1 = _OnChildrenChangedComponent();
          final parent2 = _OnChildrenChangedComponent();
          await game.ensureAdd(parent1);
          await game.ensureAdd(parent2);
          await parent1.ensureAdd(child);
          child.parent = parent2;
          await game.ready();
          expect(parent1.onChangedChildrenRuns, 2);
          expect(parent1.lastChangeType, ChildrenChangeType.removed);
          expect(parent2.onChangedChildrenRuns, 1);
          expect(parent2.lastChangeType, ChildrenChangeType.added);
        },
      );

      testWithFlameGame(
        'after removing a child the method onChildrenChanged should be called',
        (game) async {
          final child = Component();
          final parent = _OnChildrenChangedComponent();
          await game.ensureAdd(parent);
          await parent.ensureAdd(child);
          parent.remove(child);
          await game.ready();
          expect(parent.onChangedChildrenRuns, 2);
          expect(parent.lastChangeType, ChildrenChangeType.removed);
        },
      );

      testWithFlameGame(
        'after removing a list of components the method onChildrenChanged '
        'should be called list.length times',
        (game) async {
          final list = [Component(), Component()];
          final parent = _OnChildrenChangedComponent();
          await game.ensureAdd(parent);
          await parent.ensureAddAll(list);
          parent.removeAll(list);
          await game.ready();
          expect(parent.onChangedChildrenRuns, 4);
          expect(parent.lastChangeType, ChildrenChangeType.removed);
        },
      );
    });

    group('componentsAtPoint()', () {
      testWithFlameGame('nested components', (game) async {
        final world = game.world;
        final componentA = PositionComponent()
          ..size = Vector2(200, 150)
          ..scale = Vector2.all(2)
          ..position = Vector2(350, 50)
          ..addToParent(world);
        final componentB = CircleComponent(radius: 10)
          ..position = Vector2(150, 75)
          ..anchor = Anchor.center
          ..addToParent(componentA);
        await game.ready();

        void matchComponentsAtPoint(Vector2 point, List<_Pair> expected) {
          final nested = <Vector2>[];
          var i = 0;
          for (final component in world.componentsAtPoint(point, nested)) {
            expect(i, lessThan(expected.length));
            expect(component, expected[i].component);
            expect(nested, expected[i].points);
            i++;
          }
          expect(i, expected.length);
        }

        matchComponentsAtPoint(Vector2(0, 0), [
          _Pair(world, [Vector2(0, 0)]),
        ]);
        matchComponentsAtPoint(Vector2(400, 100), [
          _Pair(componentA, [Vector2(400, 100), Vector2(25, 25)]),
          _Pair(world, [Vector2(400, 100)]),
        ]);
        matchComponentsAtPoint(Vector2(650, 200), [
          _Pair(
            componentB,
            [Vector2(650, 200), Vector2(150, 75), Vector2(10, 10)],
          ),
          _Pair(componentA, [Vector2(650, 200), Vector2(150, 75)]),
          _Pair(world, [Vector2(650, 200)]),
        ]);
        matchComponentsAtPoint(Vector2(664, 214), [
          _Pair(
            componentB,
            [Vector2(664, 214), Vector2(157, 82), Vector2(17, 17)],
          ),
          _Pair(componentA, [Vector2(664, 214), Vector2(157, 82)]),
          _Pair(world, [Vector2(664, 214)]),
        ]);
        matchComponentsAtPoint(Vector2(664, 216), [
          _Pair(componentA, [Vector2(664, 216), Vector2(157, 83)]),
          _Pair(world, [Vector2(664, 216)]),
        ]);
      });
    });

    group('findRootGame()', () {
      testWithFlameGame('finds root game in nested game structure',
          (game) async {
        final component = Component();
        await game.ensureAdd(
          FlameGame(
            children: [
              Component(children: [component]),
            ],
          ),
        );
        expect(component.findRootGame(), game);
      });

      testWithFlameGame('finds root game in non-nested game structure',
          (game) async {
        final component = Component();
        await game.ensureAdd(component);
        expect(component.findRootGame(), game);
      });
    });

    group('miscellaneous', () {
      testWithFlameGame('childrenFactory', (game) async {
        final component0 = Component();
        expect(component0.children.strictMode, false);

        Component.childrenFactory = () => ComponentSet(strictMode: true);
        final component1 = Component();
        final component2 = Component();
        component1.add(component2);
        component2.add(Component());
        expect(component1.children.strictMode, true);
        expect(component2.children.strictMode, true);
      });

      testWithFlameGame('initially same debugMode as parent', (game) async {
        final child = Component();
        final parent = Component();
        parent.debugMode = true;

        parent.add(child);
        game.world.add(parent);
        await game.ready();

        expect(child.debugMode, true);
        parent.debugMode = false;
        expect(child.debugMode, true);
      });

      testWithFlameGame('debugMode propagates to descendants', (game) async {
        final child = Component();
        final parent = Component();
        final grandParent = Component();
        parent.add(child);
        grandParent.add(parent);
        grandParent.debugMode = true;

        game.world.add(grandParent);
        await game.ready();

        expect(child.debugMode, true);
        expect(parent.debugMode, true);
        expect(grandParent.debugMode, true);
      });

      testWithFlameGame(
        'propagateToChildren visits children in the correct order',
        (game) async {
          final component1 = IntComponent()..addToParent(game.world);
          final component2 = IntComponent()..addToParent(game.world);
          final component3 = IntComponent()..addToParent(component2);
          final component4 = IntComponent()..addToParent(component2);
          await game.ready();

          var order = 0;
          game.world.propagateToChildren(
            (component) {
              order += 1;
              if (component is IntComponent) {
                expect(component.value, 0);
                component.value = order;
              } else {
                expect(component, equals(game.world));
                expect(order, 5);
              }
              return true;
            },
            includeSelf: true,
          );
          expect(component4.value, 1);
          expect(component3.value, 2);
          expect(component2.value, 3);
          expect(component1.value, 4);
          expect(order, 5);
        },
      );

      testWithFlameGame(
        'Components added in onLoad can be accessed in onMount',
        (game) async {
          final component = CustomComponent(
            onLoad: (self) {
              self.add(Component());
              self.add(_SlowLoadingComponent());
              self.add(Component());
            },
            onMount: (self) {
              expect(self.children.length, 3);
              self.children.elementAt(0).add(Component());
            },
          );
          game.world.add(component);
          await game.ready();

          expect(component.isMounted, true);
          expect(component.children.length, 3);
          expect(component.children.first.children.length, 1);
        },
      );

      testWithFlameGame(
        'Components can be retrieved via a named key',
        (game) async {
          final component = ComponentA(key: ComponentKey.named('A'));
          game.world.add(component);
          await game.ready();

          expect(ComponentKey.named('A'), equals(ComponentKey.named('A')));

          final retrieved = game.findByKey(ComponentKey.named('A'));
          expect(retrieved, equals(component));
        },
      );

      testWithFlameGame(
        'Components can be retrieved via an unique key',
        (game) async {
          final key1 = ComponentKey.unique();
          final key2 = ComponentKey.unique();
          final component1 = ComponentA(key: key1);
          final component2 = ComponentA(key: key2);

          game.world.add(component1);
          game.world.add(component2);
          await game.ready();

          expect(key1, isNot(equals(key2)));

          final retrieved1 = game.findByKey(key1);
          expect(retrieved1, equals(component1));

          final retrieved2 = game.findByKey(key2);
          expect(retrieved2, equals(component2));

          expect(retrieved1, isNot(equals(component2)));
        },
      );

      testWithFlameGame(
        'Components can be retrieved via their name',
        (game) async {
          final component = ComponentA(key: ComponentKey.named('A'));
          game.world.add(component);
          await game.ready();

          final retrieved = game.findByKeyName('A');
          expect(retrieved, equals(component));
        },
      );

      testWithFlameGame(
        'findByKey returns null if no component is found',
        (game) async {
          await game.ready();

          expect(game.findByKey(ComponentKey.unique()), isNull);
        },
      );

      testWithFlameGame(
        'findByKey returns null when the component is removed',
        (game) async {
          final key = ComponentKey.unique();
          final component = ComponentA(key: key);

          game.world.add(component);
          await game.ready();

          final retrieved1 = game.findByKey(key);
          expect(retrieved1, equals(component));

          component.removeFromParent();
          await game.ready();

          final retrieved2 = game.findByKey(key);
          expect(retrieved2, isNull);
        },
      );

      testWithFlameGame(
        'Throws assertion error when registering a component with the same key',
        (game) async {
          final component = ComponentA(key: ComponentKey.named('A'));
          final component2 = ComponentA(key: ComponentKey.named('A'));

          game.world.add(component);
          game.world.add(component2);

          await expectLater(
            () => game.ready(),
            throwsA(
              isA<AssertionError>().having(
                (e) => e.message,
                'message',
                'Key ${ComponentKey.named('A')} is already registered',
              ),
            ),
          );
        },
      );
    });
  });
}

class ComponentA extends Component {
  ComponentA({super.key});
}

class ComponentB extends Component {
  ComponentB({super.key});
}

class ComponentWithSizeHistory extends Component {
  List<Vector2> history = [];

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    history.add(size.clone());
  }
}

class Visitor extends Component {
  bool visited = false;
}

class IntComponent extends Component {
  int value = 0;
}

class TwoChildrenComponent extends Component {
  TwoChildrenComponent({super.children});

  late final Component child1;
  late final Component child2;

  @override
  Future<void> onLoad() async {
    child1 = Component();
    child2 = Component();
    add(child1);
    add(child2);
  }
}

class LifecycleComponent extends Component {
  final List<String> events = [];
  final String name;

  LifecycleComponent([this.name = '']);

  int countEvents(String event) {
    return events.where((e) => e == event).length;
  }

  @override
  Future<void> onLoad() async {
    expect(isLoading, true);
    expect(isLoaded, false);
    expect(isMounted, false);
    expect(isRemoving, false);
    events.add('onLoad');
  }

  @override
  void onMount() {
    expect(isLoading, false);
    expect(isLoaded, true);
    expect(isMounted, false);
    expect(isRemoving, false);
    events.add('onMount');
  }

  @override
  void onRemove() {
    expect(isLoaded, true);
    expect(isMounted, true);
    events.add('onRemove');
    super.onRemove();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    events.add('onGameResize $size');
  }

  @override
  String toString() => 'LifecycleComponent($name)';
}

class _SlowLoadingComponent extends Component {
  int onLoadCalledCount = 0;

  @override
  Future<void> onLoad() async {
    onLoadCalledCount++;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

class SlowComponent extends Component {
  SlowComponent(this.name, this.loadTime);
  final double loadTime;
  final String name;

  @override
  Future<void> onLoad() async {
    final ms = (loadTime * 1000).toInt();
    await Future<int?>.delayed(Duration(milliseconds: ms));
  }

  @override
  String toString() => 'SlowComponent($name, loadTime=$loadTime)';
}

class _SelfRemovingOnLoadComponent extends Component {
  @override
  Future<void>? onLoad() {
    removeFromParent();
    return null;
  }
}

class _SelfRemovingOnMountComponent extends Component {
  @override
  void onMount() {
    removeFromParent();
  }
}

class _Pair {
  _Pair(this.component, this.points);
  final Component component;
  final List<Vector2> points;
}

class _PrepareGame extends FlameGame {
  late final _ParentOnPrepareComponent prepareParent;

  @override
  Future<void> onLoad() async {
    await add(prepareParent = _ParentOnPrepareComponent());
  }
}

class _OnPrepareComponent extends Component {
  int onMountRuns = 0;

  @override
  void onMount() {
    super.onMount();
    onMountRuns++;
  }
}

class _ParentOnPrepareComponent extends _OnPrepareComponent {
  @override
  Future<void> onLoad() async {
    await add(_OnPrepareComponent());
  }
}

class _IdentifiableComponent extends Component {
  final int id;

  _IdentifiableComponent(this.id);
}

class _AsyncLoadingChild extends Component {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    return Future.value();
  }
}

class _GameResizeComponent extends PositionComponent {
  _GameResizeComponent(this.name) : super(size: Vector2.all(2.0));

  String name;
  late Vector2 gameSize;

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    this.gameSize = gameSize;
  }
}

class _OnChildrenChangedComponent extends PositionComponent {
  int onChangedChildrenRuns = 0;
  ChildrenChangeType? lastChangeType;

  @override
  void onChildrenChanged(Component child, ChildrenChangeType type) {
    onChangedChildrenRuns++;
    lastChangeType = type;
  }
}

class _RemoveWhereComponent extends Component {
  @override
  Future<void> onLoad() async {
    add(Component());
    removeWhere((_) => true);
  }
}

class _Wrapper extends StatefulWidget {
  const _Wrapper({
    required this.child,
    this.open = false,
  });

  final Widget child;
  final bool open;

  @override
  State<_Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<_Wrapper> {
  late bool _open;

  @override
  void initState() {
    super.initState();

    _open = widget.open;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            if (_open) Expanded(child: widget.child),
            ElevatedButton(
              child: const Text('Toggle'),
              onPressed: () {
                setState(() => _open = !_open);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DetachableFlameGame extends FlameGame {
  bool onAttachCalled = false;
  bool onDetachCalled = false;

  void resetValues() {
    onAttachCalled = false;
    onDetachCalled = false;
  }

  @override
  void onAttach() {
    super.onAttach();
    onAttachCalled = true;
  }

  @override
  void onDetach() {
    super.onDetach();
    onDetachCalled = true;
  }
}

FlameTester<_DetachableFlameGame> _myDetachableGame({required bool open}) {
  return FlameTester(
    _DetachableFlameGame.new,
    pumpWidget: (gameWidget, tester) async {
      await tester.pumpWidget(_Wrapper(open: open, child: gameWidget));
    },
  );
}
