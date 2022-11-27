import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Component', () {
    group('Lifecycle', () {
      testWithFlameGame('correct order', (game) async {
        final component = LifecycleComponent();
        await game.add(component);
        await game.ready();

        expect(
          component.events,
          ['onGameResize [800.0,600.0]', 'onLoad', 'onMount'],
        );
      });

      testWithFlameGame('component mounted completes', (game) async {
        final component = LifecycleComponent();
        final mounted = component.mounted;
        await game.add(component);
        await game.ready();

        await expectLater(mounted, completes);
        await expectLater(component.mounted, completes);
      });

      testWithFlameGame(
          'component.removed completes if obtained before the game was ready',
          (game) async {
        final component = LifecycleComponent('component');
        final removed = component.removed;
        await game.add(component);
        await game.ready();

        game.remove(component);
        game.update(0);

        await expectLater(removed, completes);
      });

      testWithFlameGame(
          'component removed completes when set after game is ready',
          (game) async {
        final component = LifecycleComponent('component');
        await game.add(component);
        await game.ready();
        final removed = component.removed;

        game.remove(component);
        game.update(0);
        await expectLater(removed, completes);
      });

      testWithFlameGame(
        'component removed completes after changing parent',
        (game) async {
          final parent = LifecycleComponent('parent')..addToParent(game);
          final child = LifecycleComponent('child')..addToParent(parent);
          await game.ready();
          final removed = child.removed;

          child.changeParent(game);
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
          game.add(parent);

          var mounted = child.mounted;
          await game.ready();

          await expectLater(mounted, completes);

          child.changeParent(game);
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
          game.add(parent);

          final mounted = child.mounted;
          await game.ready();

          child.changeParent(parent);
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
          game.add(child);
          await game.ready();
          expect(child.isMounted, true);
          await future;
          expect(mountedFutureCompleted, true);
        },
      );

      testWithFlameGame('component loaded completes', (game) async {
        final component = LifecycleComponent();
        await game.add(component);
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
          game.add(component);
          await game.ready();
          expectLater(loadedFuture, completes);
        },
      );

      testWithFlameGame('correct lifecycle on parent change', (game) async {
        final parent = LifecycleComponent('parent');
        final child = LifecycleComponent('child');
        parent.add(child);
        game.add(parent);
        await game.ready();
        child.changeParent(game);
        game.update(0);
        await game.ready();

        expect(
          parent.events,
          ['onGameResize [800.0,600.0]', 'onLoad', 'onMount'],
        );
        // onLoad should only be called the first time that the component is
        // loaded.
        expect(
          child.events,
          [
            'onGameResize [800.0,600.0]',
            'onLoad',
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
          final a = SlowComponent(0.1);
          final b = SlowComponent(0.02);
          final c = SlowComponent(0.05);
          final d = SlowComponent(0);
          game.add(a);
          game.add(b);
          game.add(c);
          game.add(d);
          await game.ready();
          expect(game.children.toList(), equals([a, b, c, d]));
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
            ['onGameResize [295.0,600.0]', 'onLoad', 'onMount'],
          );
          expect(
            component2.events,
            ['onGameResize [505.0,600.0]', 'onLoad', 'onMount'],
          );
        });
      });

      testWithFlameGame(
        'Remove and re-add component with children',
        (game) async {
          final parent = LifecycleComponent('parent');
          final child = LifecycleComponent('child')..addToParent(parent);
          await game.add(parent);
          await game.ready();

          expect(parent.isMounted, true);
          expect(child.isMounted, true);
          expect(parent.parent, game);
          expect(child.parent, parent);

          parent.removeFromParent();
          await game.ready();

          expect(parent.isMounted, false);
          expect(child.isMounted, false);
          expect(parent.parent, isNull);
          expect(child.parent, isNull);

          await game.add(parent);
          await game.ready();

          expect(parent.isMounted, true);
          expect(child.isMounted, true);
          expect(parent.parent, game);
          expect(child.parent, parent);
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
        game.add(
          Component(
            children: [ComponentA(), ComponentB()],
          ),
        );
        await game.ready();

        expect(game.children.length, 1);
        expect(game.children.first.children.length, 2);
        expect(game.children.first.children.elementAt(0), isA<ComponentA>());
        expect(game.children.first.children.elementAt(1), isA<ComponentB>());
      });

      testWithFlameGame('add multiple children with addAll', (game) async {
        final children = List.generate(10, (_) => _AsyncLoadingChild());
        final parent = Component(children: children);
        await game.ensureAdd(parent);
        expect(parent.children.length, children.length);
      });

      testWithFlameGame('children in constructor and onLoad', (game) async {
        final component = TwoChildrenComponent(
          children: [ComponentA(), ComponentB()],
        );
        game.add(component);
        await game.ready();

        expect(game.children.length, 1);
        expect(game.children.first, component);
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
          game.add(component);
          expect(component.history, equals([Vector2(800, 600)]));
          expect(component.isMounted, false);
          game.onGameResize(Vector2(500, 300));
          game.onGameResize(Vector2(300, 500));
          expect(
            component.history,
            equals([Vector2(800, 600), Vector2(500, 300), Vector2(300, 500)]),
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
          expect(game.children.length, 0);
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

          game.add(component);
          await game.ready();
          expect(component.countEvents('onRemove'), 1);
          expect(game.children.length, 1);
        },
      );

      testWithFlameGame(
        'try to remove a component before it was ever added',
        (game) async {
          expect(
            () => game.remove(Component()),
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
              "Instance of 'FlameGame'",
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

          game.add(parent);
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
          game.add(component);
          expect(component.isLoading, true);
          expect(component.isLoaded, false);
          game.remove(component);
          await game.ready();

          expect(game.children.length, 0);
          expect(component.isLoaded, true);
          expect(component.isMounted, false);
          // onRemove shouldn't be called because there was never an onMount
          expect(component.events, ['onGameResize [800.0,600.0]', 'onLoad']);
        },
      );

      testWithFlameGame(
        'remove slow-loading component immediately after adding',
        (game) async {
          final component = _SlowLoadingComponent();
          game.add(component);
          expect(component.isLoading, true);
          expect(component.isLoaded, false);
          game.remove(component);
          await game.ready();

          expect(game.children.length, 0);
          expect(component.isLoaded, true);
          expect(component.isMounted, false);
        },
      );

      testWithFlameGame(
        'component removes itself from onLoad',
        (game) async {
          final component = _SelfRemovingOnLoadComponent();
          game.add(component);
          await game.ready();

          expect(game.children.length, 0);
          expect(component.isLoaded, true);
          expect(component.isMounted, false);
        },
      );

      testWithFlameGame(
        'component removes itself from onMount',
        (game) async {
          final component = _SelfRemovingOnMountComponent();
          game.add(component);
          await game.ready();

          expect(game.children.length, 0);
          expect(component.isLoaded, true);
          expect(component.isMounted, false);
        },
      );

      testWithFlameGame(
        'Quickly removed component can be re-added',
        (game) async {
          final component = LifecycleComponent();
          game.add(component);
          game.remove(component);
          await game.ready();
          component.events.add('--');

          expect(game.children.length, 0);
          game.add(component);
          await game.ready();

          expect(game.children.length, 1);
          expect(component.isMounted, true);
          expect(component.isLoaded, true);
          expect(
            component.events,
            [
              'onGameResize [800.0,600.0]',
              'onLoad',
              '--',
              'onGameResize [800.0,600.0]',
              'onMount',
            ],
          );
        },
      );

      testWithFlameGame(
        'remove component from a paused game',
        (game) async {
          game.pauseEngine();

          final component = Component();
          await game.add(component);
          game.remove(component);

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
          game.addAll(components);
          await game.ready();
          expect(game.children.length, 10);
          game.removeWhere((c) => (c as _IdentifiableComponent).id.isEven);
          game.update(0);
          expect(game.children.length, 5);
          expect(
            game.children.every((c) => (c as _IdentifiableComponent).id.isOdd),
            true,
          );
        },
      );
    });

    group('descendants()', () {
      testWithFlameGame(
        'descendants in a deep component tree',
        (game) async {
          expect(game.descendants().length, 0);
          final component = Component()..add(Component()..add(Component()));
          game.add(component);
          expect(game.hasPendingLifecycleEvents, true);
          expect(game.descendants().length, 0);
          await game.ready();

          expect(game.descendants().length, 3);

          final descendantsWithSelf = game.descendants(includeSelf: true);
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
          await game.add(component);
          await game.ready();
          expect(game.hasPendingLifecycleEvents, false);

          game.add(Component());

          expect(game.hasPendingLifecycleEvents, true);
          expect(game.descendants().length, 3);
        },
      );

      testWithFlameGame(
        'order must adhere to the "depth-first search" algorithm',
        (game) async {
          final componentA = Component()..addToParent(game);
          final componentB = Component()..addToParent(game);
          final componentC = Component()..addToParent(game);
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
            game.descendants().toList(),
            expectedOrder,
          );
          expect(
            game.descendants(includeSelf: true).toList(),
            [game, ...expectedOrder],
          );
          expect(
            game.descendants(reversed: true).toList(),
            expectedOrder.reversed.toList(),
          );
          expect(
            game.descendants(reversed: true, includeSelf: true).toList(),
            [...expectedOrder.reversed, game],
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
        'after adding several childs using addAll the method onChildrenChanged '
        'should be called list.length times',
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
          child.changeParent(parent2);
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
        final compA = PositionComponent()
          ..size = Vector2(200, 150)
          ..scale = Vector2.all(2)
          ..position = Vector2(350, 50)
          ..addToParent(game);
        final compB = CircleComponent(radius: 10)
          ..position = Vector2(150, 75)
          ..anchor = Anchor.center
          ..addToParent(compA);
        await game.ready();

        void matchComponentsAtPoint(Vector2 point, List<_Pair> expected) {
          final nested = <Vector2>[];
          var i = 0;
          for (final component in game.componentsAtPoint(point, nested)) {
            expect(i, lessThan(expected.length));
            expect(component, expected[i].component);
            expect(nested, expected[i].points);
            i++;
          }
          expect(i, expected.length);
        }

        matchComponentsAtPoint(Vector2(0, 0), [
          _Pair(game, [Vector2(0, 0)])
        ]);
        matchComponentsAtPoint(Vector2(400, 100), [
          _Pair(compA, [Vector2(400, 100), Vector2(25, 25)]),
          _Pair(game, [Vector2(400, 100)]),
        ]);
        matchComponentsAtPoint(Vector2(650, 200), [
          _Pair(compB, [Vector2(650, 200), Vector2(150, 75), Vector2(10, 10)]),
          _Pair(compA, [Vector2(650, 200), Vector2(150, 75)]),
          _Pair(game, [Vector2(650, 200)]),
        ]);
        matchComponentsAtPoint(Vector2(664, 214), [
          _Pair(compB, [Vector2(664, 214), Vector2(157, 82), Vector2(17, 17)]),
          _Pair(compA, [Vector2(664, 214), Vector2(157, 82)]),
          _Pair(game, [Vector2(664, 214)]),
        ]);
        matchComponentsAtPoint(Vector2(664, 216), [
          _Pair(compA, [Vector2(664, 216), Vector2(157, 83)]),
          _Pair(game, [Vector2(664, 216)]),
        ]);
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
        game.add(parent);
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

        game.add(grandParent);
        await game.ready();

        expect(child.debugMode, true);
        expect(parent.debugMode, true);
        expect(grandParent.debugMode, true);
      });

      testWithFlameGame(
        'propagateToChildren visits children in the correct order',
        (game) async {
          final component1 = IntComponent()..addToParent(game);
          final component2 = IntComponent()..addToParent(game);
          final component3 = IntComponent()..addToParent(component2);
          final component4 = IntComponent()..addToParent(component2);
          await game.ready();

          var order = 0;
          game.propagateToChildren(
            (component) {
              order += 1;
              if (component is IntComponent) {
                expect(component.value, 0);
                component.value = order;
              } else {
                expect(component, equals(game));
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
    });
  });
}

class ComponentA extends Component {}

class ComponentB extends Component {}

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
  final String? name;

  LifecycleComponent([this.name]);

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
  SlowComponent(this.loadTime);
  final double loadTime;

  @override
  Future<void> onLoad() async {
    final ms = (loadTime * 1000).toInt();
    await Future<int?>.delayed(Duration(milliseconds: ms));
  }
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
