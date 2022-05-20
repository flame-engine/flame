import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

class _PriorityComponent extends Component {
  _PriorityComponent(int priority) : super(priority: priority);
}

class _ParentWithReorderSpy extends Component {
  int callCount = 0;

  _ParentWithReorderSpy(int priority) : super(priority: priority);

  @override
  void reorderChildren() {
    callCount++;
    super.reorderChildren();
  }

  void assertCalled(int n) {
    expect(callCount, n);
    callCount = 0;
  }
}

void main() {
  void componentsSorted(Iterable<Component> components) {
    final priorities = components.map<int>((c) => c.priority).toList();
    expect(priorities.toList(), orderedEquals(priorities..sort()));
  }

  group('priority test', () {
    flameGame.test(
      'components with different priorities are sorted in the list',
      (game) async {
        final priorityComponents = List.generate(10, _PriorityComponent.new);
        priorityComponents.shuffle();
        await game.ensureAddAll(priorityComponents);
        componentsSorted(game.children);
      },
    );

    flameGame.test(
      'changing priority should reorder component list',
      (game) async {
        final firstComponent = _PriorityComponent(-1);
        final priorityComponents = List.generate(10, _PriorityComponent.new)
          ..add(firstComponent);
        priorityComponents.shuffle();
        final components = game.children;
        await game.ensureAddAll(priorityComponents);
        componentsSorted(components);
        expect(components.first, firstComponent);
        game.children.changePriority(firstComponent, 11);
        game.update(0);
        expect(components.last, firstComponent);
      },
    );

    flameGame.test(
      'changing priority with the priority setter should reorder the list',
      (game) async {
        final firstComponent = _PriorityComponent(-1);
        final priorityComponents = List.generate(10, _PriorityComponent.new)
          ..add(firstComponent);
        priorityComponents.shuffle();
        final components = game.children;
        await game.ensureAddAll(priorityComponents);
        componentsSorted(components);
        expect(components.first, firstComponent);
        firstComponent.priority = 11;
        game.update(0);
        expect(components.last, firstComponent);
      },
    );

    flameGame.test(
      'changing priorities should reorder component list',
      (game) async {
        final priorityComponents = List.generate(10, _PriorityComponent.new);
        priorityComponents.shuffle();
        final components = game.children;
        await game.ensureAddAll(priorityComponents);
        componentsSorted(components);
        final first = components.first;
        final last = components.last;
        game.children.changePriority(first, 20);
        game.children.changePriority(last, -1);
        expect(components.first, first);
        expect(components.last, last);
        game.update(0);
        expect(components.first, last);
        expect(components.last, first);
      },
    );

    flameGame.test(
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
        game.children.changePriority(first, 20);
        expect(children.last, isNot(first));
        game.update(0);
        expect(children.last, first);
      },
    );

    flameGame.test(
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
        game.children.changePriority(first, 20);
        game.children.changePriority(last, -1);
        expect(children.first, first);
        expect(children.last, last);
        game.update(0);
        expect(children.first, last);
        expect(children.last, first);
      },
    );

    flameGame.test(
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
        game.children.changePriority(first, 20);
        expect(children.last, isNot(first));
        game.update(0);
        expect(children.last, first);
      },
    );

    flameGame.test(
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

        game.children.changePriority(a, 10);
        game.update(0);

        componentsSorted(game.children);
        componentsSorted(a.children);
        componentsSorted(b.children);
        componentsSorted(c.children);
        a.assertCalled(0);
        b.assertCalled(0);
        c.assertCalled(0);

        // change priority multiple times on c and once on a (and zero on b)
        game.children.changePriority(c3, 2);
        game.children.changePriority(c1, 10);
        game.children.changePriority(a2, 0);
        game.update(0);

        a.assertCalled(1);
        b.assertCalled(0);
        c.assertCalled(1);

        componentsSorted(game.children);
        componentsSorted(a.children);
        componentsSorted(b.children);
        componentsSorted(c.children);

        // change of b now
        game.children.changePriority(b1, 2);
        game.children.changePriority(a1, 1); // no-op!
        game.update(0);

        a.assertCalled(0);
        b.assertCalled(1);
        c.assertCalled(0);

        componentsSorted(game.children);
        componentsSorted(a.children);
        componentsSorted(b.children);
        componentsSorted(c.children);
      },
    );
  });
}
