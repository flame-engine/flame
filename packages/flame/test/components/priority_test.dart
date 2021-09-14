import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:test/test.dart';

class PriorityComponent extends Component {
  PriorityComponent(int priority) : super(priority: priority);
}

void componentsSorted(Iterable<Component> components) {
  final priorities = components.map<int>((c) => c.priority).toList();
  expect(priorities.toList(), orderedEquals(priorities..sort()));
}

void main() {
  group('priority test', () {
    test('components with different priorities are sorted in the list', () {
      final priorityComponents = List.generate(10, (i) => PriorityComponent(i));
      priorityComponents.shuffle();
      final game = FlameGame()..onGameResize(Vector2.zero());
      game.addAll(priorityComponents);
      game.update(0);
      componentsSorted(game.children);
    });

    test('changing priority should reorder component list', () {
      final firstCompopnent = PriorityComponent(-1);
      final priorityComponents = List.generate(10, (i) => PriorityComponent(i))
        ..add(firstCompopnent);
      priorityComponents.shuffle();
      final game = FlameGame()..onGameResize(Vector2.zero());
      final components = game.children;
      game.addAll(priorityComponents);
      game.update(0);
      componentsSorted(components);
      expect(components.first, firstCompopnent);
      game.changePriority(firstCompopnent, 11);
      expect(components.last, firstCompopnent);
    });

    test('changing priorities should reorder component list', () {
      final priorityComponents = List.generate(10, (i) => PriorityComponent(i));
      priorityComponents.shuffle();
      final game = FlameGame()..onGameResize(Vector2.zero());
      final components = game.children;
      game.addAll(priorityComponents);
      game.update(0);
      componentsSorted(components);
      final first = components.first;
      final last = components.last;
      game.changePriorities({first: 20, last: -1});
      expect(components.first, last);
      expect(components.last, first);
    });

    test('changing child priority should reorder component list', () {
      final parentComponent = PriorityComponent(0);
      final priorityComponents = List.generate(10, (i) => PriorityComponent(i));
      priorityComponents.shuffle();
      final game = FlameGame()..onGameResize(Vector2.zero());
      game.add(parentComponent);
      parentComponent.addAll(priorityComponents);
      final children = parentComponent.children;
      game.update(0);
      componentsSorted(children);
      final first = children.first;
      game.changePriority(first, 20);
      expect(children.last, first);
    });

    test('changing child priorities should reorder component list', () {
      final parentComponent = PriorityComponent(0);
      final priorityComponents = List.generate(10, (i) => PriorityComponent(i));
      priorityComponents.shuffle();
      final game = FlameGame()..onGameResize(Vector2.zero());
      game.add(parentComponent);
      parentComponent.addAll(priorityComponents);
      final children = parentComponent.children;
      game.update(0);
      componentsSorted(children);
      final first = children.first;
      final last = children.last;
      game.changePriorities({first: 20, last: -1});
      expect(children.first, last);
      expect(children.last, first);
    });

    test('changing grand child priority should reorder component list', () {
      final grandParentComponent = PriorityComponent(0);
      final parentComponent = PriorityComponent(0);
      final priorityComponents = List.generate(10, (i) => PriorityComponent(i));
      priorityComponents.shuffle();
      final game = FlameGame()..onGameResize(Vector2.zero());
      game.add(grandParentComponent);
      grandParentComponent.add(parentComponent);
      parentComponent.addAll(priorityComponents);
      final children = parentComponent.children;
      game.update(0);
      componentsSorted(children);
      final first = children.first;
      game.changePriority(first, 20);
      expect(children.last, first);
    });
  });
}
