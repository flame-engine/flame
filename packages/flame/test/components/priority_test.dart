import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:ordered_set/mapping_ordered_set.dart';
import 'package:ordered_set/ordered_set.dart';
import 'package:test/test.dart';

import '../custom_component.dart';

void main() {
  void componentsSorted(Iterable<Component> components) {
    final priorities = components.map<int>((c) => c.priority).toList();
    expect(priorities.toList(), orderedEquals(priorities..sort()));
  }

  group('priority test', () {
    testWithFlameGame(
      'components with different priorities are sorted in the list',
      (game) async {
        final priorityComponents = List.generate(10, _PriorityComponent.new);
        priorityComponents.shuffle();
        await game.ensureAddAll(priorityComponents);
        componentsSorted(game.children);
      },
    );

    testWithFlameGame(
      'changing priority with the priority setter should reorder the list',
      (game) async {
        final firstComponent = _PriorityComponent(-1);
        final priorityComponents = List.generate(10, _PriorityComponent.new)
          ..add(firstComponent);
        priorityComponents.shuffle();
        final components = game.world.children;
        await game.world.ensureAddAll(priorityComponents);
        componentsSorted(components);
        expect(components.first, firstComponent);
        firstComponent.priority = 11;
        game.update(0);
        expect(components.last, firstComponent);
      },
    );

    testWithFlameGame(
      'changing priorities should reorder component list',
      (game) async {
        final priorityComponents = List.generate(10, _PriorityComponent.new);
        priorityComponents.shuffle();
        final components = game.children;
        await game.ensureAddAll(priorityComponents);
        componentsSorted(components);
        final first = components.first;
        final last = components.last;
        first.priority = 20;
        last.priority = -1;
        expect(components.first, first);
        expect(components.last, last);
        game.update(0);
        expect(components.first, last);
        expect(components.last, first);
      },
    );

    testWithFlameGame(
      'changing child priority should reorder component list',
      (game) async {
        final parentComponent = _PriorityComponent(0);
        final priorityComponents = List.generate(10, _PriorityComponent.new);
        priorityComponents.shuffle();
        await game.ensureAdd(parentComponent);
        await parentComponent.ensureAddAll(priorityComponents);
        final children = parentComponent.children;
        componentsSorted(children);
        final first = children.first;
        first.priority = 20;
        expect(children.last, isNot(first));
        game.update(0);
        expect(children.last, first);
      },
    );

    testWithFlameGame(
      'changing child priorities should reorder component list',
      (game) async {
        final parentComponent = _PriorityComponent(0);
        final priorityComponents = List.generate(10, _PriorityComponent.new);
        priorityComponents.shuffle();
        await game.ensureAdd(parentComponent);
        await parentComponent.ensureAddAll(priorityComponents);
        final children = parentComponent.children;
        componentsSorted(children);
        final first = children.first;
        final last = children.last;
        first.priority = 20;
        last.priority = -1;
        expect(children.first, first);
        expect(children.last, last);
        game.update(0);
        expect(children.first, last);
        expect(children.last, first);
      },
    );

    testWithFlameGame(
      'changing grand child priority should reorder component list',
      (game) async {
        final grandParentComponent = _PriorityComponent(0);
        final parentComponent = _PriorityComponent(0);
        final priorityComponents = List.generate(10, _PriorityComponent.new);
        priorityComponents.shuffle();
        await game.ensureAdd(grandParentComponent);
        await grandParentComponent.ensureAdd(parentComponent);
        await parentComponent.ensureAddAll(priorityComponents);
        final children = parentComponent.children;
        componentsSorted(children);
        final first = children.first;
        first.priority = 20;
        expect(children.last, isNot(first));
        game.update(0);
        expect(children.last, first);
      },
    );

    testWithFlameGame(
      '#reorderChildren is only called once per parent per tick',
      (game) async {
        final a = _ParentWithReorderSpy(1);
        final a1 = _PriorityComponent(1);
        final a2 = _PriorityComponent(2);
        a.addAll([a1, a2]);

        final b = _ParentWithReorderSpy(3);
        final b1 = _PriorityComponent(1);
        b.add(b1);

        final c = _ParentWithReorderSpy(2);
        final c1 = _PriorityComponent(1);
        final c2 = _PriorityComponent(0);
        final c3 = _PriorityComponent(-1);
        c.addAll([c1, c2, c3]);

        await game.ensureAddAll([a, b, c]);
        componentsSorted(game.children);
        componentsSorted(a.children);
        componentsSorted(b.children);
        componentsSorted(c.children);
        a.assertCalled(0);
        b.assertCalled(0);
        c.assertCalled(0);

        a.priority = 10;
        game.update(0);
        await game.ready();

        componentsSorted(game.children);
        componentsSorted(a.children);
        componentsSorted(b.children);
        componentsSorted(c.children);
        a.assertCalled(0);
        b.assertCalled(0);
        c.assertCalled(0);

        // Change priority multiple times on c and once on a (and zero on b).
        c3.priority = 2;
        c1.priority = 10;
        a2.priority = 0;
        game.update(0);
        await game.ready();

        a.assertCalled(1);
        b.assertCalled(0);
        c.assertCalled(1);

        componentsSorted(game.children);
        componentsSorted(a.children);
        componentsSorted(b.children);
        componentsSorted(c.children);

        // Change of b now.
        b1.priority = 2;
        a1.priority = 1; // no-op!
        game.update(0);
        await game.ready();

        a.assertCalled(0);
        b.assertCalled(1);
        c.assertCalled(0);

        componentsSorted(game.children);
        componentsSorted(a.children);
        componentsSorted(b.children);
        componentsSorted(c.children);
      },
    );

    testWithFlameGame('child can update priority of its parent', (game) async {
      final renderEvents = <String>[];

      final parent = CustomComponent(
        priority: 0,
        onRender: (self, canvas) {
          renderEvents.add('render:parent');
        },
      );
      final child = CustomComponent(
        onUpdate: (self, dt) {
          self.parent!.priority = 10;
        },
      );
      parent.add(child);
      game.add(parent);
      game.add(
        CustomComponent(
          priority: 1,
          onRender: (self, canvas) {
            renderEvents.add('render:another');
          },
        ),
      );
      await game.ready();

      expect(parent.priority, 0);
      expect(child.priority, 0);

      game.update(0.1);
      await game.ready();

      expect(parent.priority, 10);
      expect(child.priority, 0);
      expect(renderEvents, isEmpty);
      game.render(Canvas(PictureRecorder()));
      expect(renderEvents, ['render:another', 'render:parent']);
    });
  });
}

class _SpyComponentSet extends MappingOrderedSet<num, Component> {
  int callCount = 0;

  _SpyComponentSet() : super((e) => e.priority);

  @override
  void rebalanceAll() {
    callCount++;
    super.rebalanceAll();
  }
}

class _PriorityComponent extends Component {
  _PriorityComponent(int priority) : super(priority: priority);
}

class _ParentWithReorderSpy extends Component {
  _ParentWithReorderSpy(int priority) : super(priority: priority);

  @override
  OrderedSet<Component> createComponentSet() => _SpyComponentSet();

  void assertCalled(int n) {
    final componentSet = children as _SpyComponentSet;
    expect(componentSet.callCount, n);
    componentSet.callCount = 0;
  }
}
