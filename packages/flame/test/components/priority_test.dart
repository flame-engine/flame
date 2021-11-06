import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

class PriorityComponent extends Component {
  PriorityComponent(int priority) : super(priority: priority);
}

void componentsSorted(Iterable<Component> components) {
  final priorities = components.map<int>((c) => c.priority).toList();
  expect(priorities.toList(), orderedEquals(priorities..sort()));
}

class ParentWithReorderSpy extends Component {
  int callCount = 0;

  ParentWithReorderSpy(int priority) : super(priority: priority);

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
  group('priority test', () {
    flameGame.test(
      'components with different priorities are sorted in the list',
      (game) {
        final priorityComponents =
            List.generate(10, (i) => PriorityComponent(i));
        priorityComponents.shuffle();
        game.addAll(priorityComponents);
        game.update(0);
        componentsSorted(game.children);
      },
    );

    flameGame.test(
      'changing priority should reorder component list',
      (game) {
        final firstCompopnent = PriorityComponent(-1);
        final priorityComponents =
            List.generate(10, (i) => PriorityComponent(i))
              ..add(firstCompopnent);
        priorityComponents.shuffle();
        final components = game.children;
        game.addAll(priorityComponents);
        game.update(0);
        componentsSorted(components);
        expect(components.first, firstCompopnent);
        game.children.changePriority(firstCompopnent, 11);
        game.update(0);
        expect(components.last, firstCompopnent);
      },
    );

    flameGame.test(
      'changing priorities should reorder component list',
      (game) {
        final priorityComponents =
            List.generate(10, (i) => PriorityComponent(i));
        priorityComponents.shuffle();
        final components = game.children;
        game.addAll(priorityComponents);
        game.update(0);
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
      (game) {
        final parentComponent = PriorityComponent(0);
        final priorityComponents =
            List.generate(10, (i) => PriorityComponent(i));
        priorityComponents.shuffle();
        game.add(parentComponent);
        parentComponent.addAll(priorityComponents);
        final children = parentComponent.children;
        game.update(0);
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
      (game) {
        final parentComponent = PriorityComponent(0);
        final priorityComponents =
            List.generate(10, (i) => PriorityComponent(i));
        priorityComponents.shuffle();
        game.add(parentComponent);
        parentComponent.addAll(priorityComponents);
        final children = parentComponent.children;
        game.update(0);
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
      (game) {
        final grandParentComponent = PriorityComponent(0);
        final parentComponent = PriorityComponent(0);
        final priorityComponents =
            List.generate(10, (i) => PriorityComponent(i));
        priorityComponents.shuffle();
        game.add(grandParentComponent);
        grandParentComponent.add(parentComponent);
        parentComponent.addAll(priorityComponents);
        final children = parentComponent.children;
        game.update(0);
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
      (game) {
        final a = ParentWithReorderSpy(1);
        final a1 = PriorityComponent(1);
        final a2 = PriorityComponent(2);
        a.addAll([a1, a2]);

        final b = ParentWithReorderSpy(3);
        final b1 = PriorityComponent(1);
        b.add(b1);

        final c = ParentWithReorderSpy(2);
        final c1 = PriorityComponent(1);
        final c2 = PriorityComponent(0);
        final c3 = PriorityComponent(-1);
        c.addAll([c1, c2, c3]);

        game.addAll([a, b, c]);
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
