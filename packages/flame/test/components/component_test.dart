import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/components/core/component_tree_root.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ordered_set/mapping_ordered_set.dart';
import 'package:ordered_set/ordered_set.dart';

import '../custom_component.dart';

void main() {
  group('Component', () {
    group('Lifecycle', () {
      testWithFlameGame('correct order', (game) async {
        final component = _LifecycleComponent();
        await game.world.add(component);
        await game.ready();

        expect(
          component.events,
          ['onLoad', 'onGameResize [800.0,600.0]', 'onMount'],
        );
      });

      testWithFlameGame('component mounted completes', (game) async {
        final component = _LifecycleComponent();
        final mounted = component.mounted;
        await game.world.add(component);
        await game.ready();

        await expectLater(mounted, completes);
        await expectLater(component.mounted, completes);
      });

      testWithFlameGame(
        'component.removed completes if obtained before the game was ready',
        (game) async {
          final component = _LifecycleComponent();
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
          final component = _LifecycleComponent();
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
          final parent = _LifecycleComponent('parent')..addToParent(game);
          final child = _LifecycleComponent('child')..addToParent(parent);
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
        final parent = _LifecycleComponent('parent')..addToParent(game);
        final child = _LifecycleComponent('child')..addToParent(parent);
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
          final parent = _LifecycleComponent('parent');
          final child = _LifecycleComponent('child');
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
          final parent = _LifecycleComponent('parent');
          final child = _LifecycleComponent('child');
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
          final child = _LifecycleComponent();
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
        final component = _LifecycleComponent();
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
        final parent = _LifecycleComponent('parent');
        final child = _LifecycleComponent('child');
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
          final a = _SlowComponent('A', 0.1);
          final b = _SlowComponent('B', 0.02);
          final c = _SlowComponent('C', 0.05);
          final d = _SlowComponent('D', 0);
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
          final component1 = _LifecycleComponent('A')..addToParent(game1);
          final component2 = _LifecycleComponent('B')..addToParent(game2);
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
          final parent = _LifecycleComponent('parent');
          final child = _LifecycleComponent('child')..addToParent(parent);
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
          expect(child.parent, isNotNull);

          await game.world.add(parent);
          await game.ready();

          expect(parent.isMounted, true);
          expect(child.isMounted, true);
          expect(parent.parent, game.world);
          expect(parent.parent?.parent, game);
          expect(child.parent, parent);
        },
      );

      testWithFlameGame(
        'Parent removal should not lead to null parent of descendants',
        (game) async {
          final parent = _LifecycleComponent('parent');
          final child = _LifecycleComponent('child')..addToParent(parent);
          final grandChild = _LifecycleComponent('grandchild')
            ..addToParent(child);
          await game.world.add(parent);
          await game.ready();

          expect(parent.isMounted, true);
          expect(child.isMounted, true);
          expect(grandChild.isMounted, true);
          expect(parent.parent, game.world);
          expect(parent.parent?.parent, game);
          expect(child.parent, parent);
          expect(grandChild.parent, child);

          parent.removeFromParent();
          await game.ready();

          expect(parent.isMounted, false);
          expect(child.isMounted, false);
          expect(grandChild.isMounted, false);
          expect(parent.parent, isNull);
          expect(child.parent, isNotNull);
          expect(grandChild.parent, isNotNull);
        },
      );

      _myDetachableGame(open: false).testGameWidget(
        'Confirm child component only loads once with game widget change',
        verify: (game, tester) async {
          final child = _LifecycleComponent();
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

      group('lifecycleEventsProcessed', () {
        testWithFlameGame('waits for unprocessed events', (game) async {
          await game.ready();
          final component = _LifecycleComponent();
          await game.world.add(component);
          expect(game.hasLifecycleEvents, isTrue);

          Future.delayed(Duration.zero).then((_) => game.update(0));
          await game.lifecycleEventsProcessed;
          expect(game.hasLifecycleEvents, isFalse);
        });

        testWithFlameGame("doesn't block when there are no events",
            (game) async {
          await game.ready();
          expect(game.hasLifecycleEvents, isFalse);
          await game.lifecycleEventsProcessed;
          expect(game.hasLifecycleEvents, isFalse);
        });

        testWithFlameGame('guarantees addition even with heavy onLoad',
            (game) async {
          await game.ready();
          final component = _SlowComponent('heavy', 0.1);
          final child = _SlowComponent('child', 0.1);
          await component.add(child);
          await game.world.add(component);
          expect(game.world.children, isNot(contains(component)));

          game.lifecycleEventsProcessed.then(
            expectAsync1((_) {
              expect(game.world.children, contains(component));
              expect(component.children, contains(child));
            }),
          );

          await game.ready();
        });

        testWithFlameGame('completes even with dequeued event', (game) async {
          final parent1 = Component();
          final parent2 = Component();
          game.addAll([parent1, parent2]);
          await game.ready();
          final component = _SlowComponent('heavy', 0.1);
          final child = _SlowComponent('child', 0.1);
          await component.add(child);
          await parent1.add(component);

          expect(game.lifecycleEventsProcessed, completes);

          await Future.delayed(Duration.zero).then((_) => game.update(0));
          assert(
            game.hasLifecycleEvents,
            'One update should not have been enough '
            'to add the heavy component',
          );

          // Trigger dequeue.
          component.parent = parent2;

          await game.ready();
        });
      });

      testWithFlameGame('Can wait for lifecycleEventsProcessed', (game) async {
        await game.ready();
        final component = Component();
        await game.world.add(component);
        expect(game.hasLifecycleEvents, isTrue);

        Future.delayed(Duration.zero).then((_) => game.update(0));
        await game.lifecycleEventsProcessed;
        expect(game.hasLifecycleEvents, isFalse);
      });
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
            children: [_ComponentA(), _ComponentB()],
          ),
        );
        await game.ready();

        expect(game.world.children.length, 1);
        expect(game.world.children.first.children.length, 2);
        expect(
          game.world.children.first.children.elementAt(0),
          isA<_ComponentA>(),
        );
        expect(
          game.world.children.first.children.elementAt(1),
          isA<_ComponentB>(),
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
        'move a component from a mounted parent to an unmounted one',
        (game) async {
          final child = Component();
          final mountedParent = Component(children: [child]);
          final unmountedParent = Component();
          await game.ensureAdd(mountedParent);
          unmountedParent.add(child);
          game.update(0);
          expect(child.parent, unmountedParent);
          expect(mountedParent.children, []);
          expect(unmountedParent.children, [child]);
          expect(child.isMounted, isFalse);
          await game.ensureAdd(unmountedParent);
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
        final component = _TwoChildrenComponent(
          children: [_ComponentA(), _ComponentB()],
        );
        game.world.add(component);
        await game.ready();

        expect(game.world.children.length, 1);
        expect(game.world.children.first, component);
        expect(component.children.length, 4);
        expect(component.children.elementAt(0), isA<_ComponentA>());
        expect(component.children.elementAt(1), isA<_ComponentB>());
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
          final component = _ComponentWithSizeHistory();
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

      testWithFlameGame('when parent is in removing state', (game) async {
        final parent = Component();
        final child = Component();

        await game.add(parent);
        await game.ready();

        // Remove the parent and add the child in the same tick.
        parent.removeFromParent();
        await parent.add(child);

        // Timeout is added because processLifecycleEvents of ComponentTreeRoot
        // gets blocked in such cases.

        // Expect the ready future to complete
        await expectLater(
          game.ready().timeout(const Duration(seconds: 2)),
          completes,
        );
        expect(game.hasLifecycleEvents, isFalse);

        // Adding the parent again should eventually mount the child as well.
        await game.add(parent);
        await game.ready();
        expect(child.isMounted, true);
      });

      testWithFlameGame(
        "can remove component's children before adding the parent",
        (game) async {
          final c = _ComponentWithChildrenRemoveAll();
          game.add(c);

          await game.ready();
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
          final component = _LifecycleComponent();
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
          final component = _LifecycleComponent();
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
          final component = _LifecycleComponent();
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

      testWithFlameGame(
        'A removed child should be able to be removed from onRemove',
        (game) async {
          final parent = _RemoveAllChildrenComponent();
          final child = _LifecycleComponent('child')..addToParent(parent);
          await game.world.add(parent);
          await game.ready();
          parent.removeFromParent();
          game.update(0);
          expect(parent.isMounted, false);
          expect(child.isMounted, false);
          expect(child.parent, parent);
          expect(parent.parent, isNull);
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

    group('Rebalancing components', () {
      testWithFlameGame(
        'rebalance is correctly queued',
        (game) async {
          final c = Component();
          await game.world.ensureAdd(c);

          c.priority = 10;
          expect(c.priority, 10);
          expect(
            game.queue.any(
              (e) =>
                  e.child == c &&
                  e.parent == game.world &&
                  e.kind == LifecycleEventKind.rebalance,
            ),
            isTrue,
          );

          await game.ready();
          expect(c.priority, 10);
          expect(game.queue.isEmpty, isTrue);
        },
      );

      testWithFlameGame(
        'the order of children is not changed until after rebalance',
        (game) async {
          final c1 = Component(priority: 2);
          final c2 = Component(priority: 1);
          await game.world.ensureAddAll([c1, c2]);

          c1.priority = 0;
          expect(c1.priority, 0);
          expect(c2.priority, 1);
          expect(
            game.world.children.toList(),
            [c2, c1],
          );

          game.update(0);
          expect(c1.priority, 0);
          expect(c2.priority, 1);
          expect(
            game.world.children.toList(),
            [c1, c2],
          );
        },
      );

      testWithFlameGame(
        'async rebalance, add and remove have no race condition',
        (game) async {
          final r = Random(69420);
          for (var i = 0; i < 10; i++) {
            game.world.add(Component());
          }

          Future<void> add() async {
            final white = Component();
            game.world.add(white);
            await Future.delayed(
              const Duration(milliseconds: 300),
              white.removeFromParent,
            );
          }

          Future<void> rebalance() async {
            game.world.children.forEach((it) {
              it.priority = r.nextInt(1_000);
            });
          }

          var completed = 0;
          var total = 0;
          void waitFor(int milliseconds, Future<void> Function() fn) {
            total++;
            Future.delayed(Duration(milliseconds: milliseconds), fn)
                .whenComplete(() => completed++);
          }

          Future<void> start() async {
            for (var i = 0; i < 100; i++) {
              waitFor(17 * i, rebalance);
              waitFor(31 * i, add);
            }
          }

          waitFor(0, start);

          while (completed < total || game.hasLifecycleEvents) {
            game.update(0);
            await Future.delayed(const Duration(milliseconds: 1));
          }

          await game.ready();
          expect(game.world.children.length, 10);
        },
      );
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
          // Remember that CameraComponent, Viewport, Viewfinder, Backdrop and
          // World are added by default.
          expect(game.descendants().length, 8);
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
        final componentA = _Visitor()..addToParent(game);
        final componentB = _Visitor()..addToParent(game);
        final componentC = _Visitor()..addToParent(componentB);
        final componentD = _Visitor()..addToParent(componentB);
        final componentE = _Visitor()..addToParent(game);
        await game.ready();

        game.descendants().whereType<_Visitor>().firstWhere((component) {
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
          final firstA = _ComponentA();
          final firstB = _ComponentB();

          await game.ensureAdd(firstA);
          await game.ensureAdd(_ComponentA());
          await game.ensureAdd(firstB);
          await game.ensureAdd(_ComponentB());

          final childA = game.firstChild<_ComponentA>();
          expect(childA, isNotNull);
          expect(childA, equals(firstA));

          final childB = game.firstChild<_ComponentB>();
          expect(childB, isNotNull);
          expect(childB, equals(firstB));

          final nonExistentChild = game.firstChild<SpriteComponent>();
          expect(nonExistentChild, isNull);
        },
      );

      testWithFlameGame(
        'lastChild returns the last child on the matching type',
        (game) async {
          final lastA = _ComponentA();
          final lastB = _ComponentB();

          await game.ensureAdd(_ComponentA());
          await game.ensureAdd(lastA);
          await game.ensureAdd(_ComponentB());
          await game.ensureAdd(lastB);

          final childA = game.lastChild<_ComponentA>();
          expect(childA, isNotNull);
          expect(childA, equals(lastA));

          final childB = game.lastChild<_ComponentB>();
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

        Component.childrenFactory = () => OrderedSet.mapping<num, Component>(
              (e) => e.priority,
              // ignore: avoid_redundant_argument_values
              strictMode: true,
            );
        final component1 = Component();
        final component2 = Component();
        component1.add(component2);
        component2.add(Component());
        expect(component1.children, isInstanceOf<MappingOrderedSet>());
        expect(component1.children.strictMode, isTrue);
        expect(component2.children, isInstanceOf<MappingOrderedSet>());
        expect(component2.children.strictMode, isTrue);
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
          final component1 = _IntComponent()..addToParent(game.world);
          final component2 = _IntComponent()..addToParent(game.world);
          final component3 = _IntComponent()..addToParent(component2);
          final component4 = _IntComponent()..addToParent(component2);
          await game.ready();

          var order = 0;
          game.world.propagateToChildren(
            (component) {
              order += 1;
              if (component is _IntComponent) {
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
          final component = _ComponentA(key: ComponentKey.named('A'));
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
          final component1 = _ComponentA(key: key1);
          final component2 = _ComponentA(key: key2);

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
          final component = _ComponentA(key: ComponentKey.named('A'));
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
          final component = _ComponentA(key: key);

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
        'Removed keys can be reused by components',
        (game) async {
          final key = ComponentKey.named('A');
          final parent1 = Component(children: [_ComponentA(key: key)]);

          game.world.add(parent1);
          await game.ready();

          parent1.removeFromParent();
          await game.ready();

          final component = _ComponentA(key: key);
          final parent2 = Component(children: [component]);

          game.world.add(parent2);
          await game.ready();

          final retrieved1 = game.findByKey(key);
          expect(retrieved1, equals(component));
        },
      );

      testWithFlameGame(
        'Throws assertion error when registering a component with the same key',
        (game) async {
          final component = _ComponentA(key: ComponentKey.named('A'));
          final component2 = _ComponentA(key: ComponentKey.named('A'));

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

class _ComponentA extends Component {
  _ComponentA({super.key});
}

class _ComponentB extends Component {
  _ComponentB();
}

class _ComponentWithSizeHistory extends Component {
  List<Vector2> history = [];

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    history.add(size.clone());
  }
}

class _Visitor extends Component {
  bool visited = false;
}

class _IntComponent extends Component {
  int value = 0;
}

class _TwoChildrenComponent extends Component {
  _TwoChildrenComponent({super.children});

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

class _LifecycleComponent extends Component {
  final List<String> events = [];
  final String name;

  _LifecycleComponent([this.name = '']);

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

class _SlowComponent extends Component {
  _SlowComponent(this.name, this.loadTime);
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

class _ComponentWithChildrenRemoveAll extends Component {
  @override
  void onMount() {
    super.onMount();

    add(Component());
    removeAll(children);
  }
}

class _RemoveAllChildrenComponent extends Component {
  @override
  void onRemove() {
    super.onMount();
    removeAll(children);
  }
}
