import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:test/test.dart';

class PriorityComponent extends BaseComponent {
  PriorityComponent(int priority) : super(priority: priority);
}

bool isSorted<T>(Iterable<T> list, [int Function(T, T)? compare]) {
  compare ??= (T a, T b) => (a as Comparable<T>).compareTo(b);
  T? prev;
  for (final current in list) {
    if (prev == null) {
      prev = current;
      continue;
    }
    if (compare(prev, current) > 0) {
      return false;
    }
  }
  return true;
}

bool componentsSorted(Iterable<Component> components) {
  int compare(Component c1, Component c2) => c1.priority - c2.priority;
  return isSorted<Component>(components, compare);
}

void main() {
  group('priority test', () {
    test('components with different priorities are sorted in the list', () {
      final priorityComponents = List.generate(10, (i) => PriorityComponent(i));
      priorityComponents.shuffle();
      final game = BaseGame()..onResize(Vector2.zero());
      game.addAll(priorityComponents);
      game.update(0);
      expect(componentsSorted(game.components), true);
    });

    test('changing priority should reorder component list', () {
      final firstCompopnent = PriorityComponent(-1);
      final priorityComponents = List.generate(10, (i) => PriorityComponent(i))
        ..add(firstCompopnent);
      priorityComponents.shuffle();
      final game = BaseGame()..onResize(Vector2.zero());
      final components = game.components;
      game.addAll(priorityComponents);
      game.update(0);
      expect(componentsSorted(components), true);
      expect(components.first, firstCompopnent);
      game.changePriority(firstCompopnent, 11);
      expect(components.last, firstCompopnent);
    });

    test('changing priorities should reorder component list', () {
      final priorityComponents = List.generate(10, (i) => PriorityComponent(i));
      priorityComponents.shuffle();
      final game = BaseGame()..onResize(Vector2.zero());
      final components = game.components;
      game.addAll(priorityComponents);
      game.update(0);
      expect(componentsSorted(components), true);
      final first = components.first;
      final last = components.last;
      game.changePriorities({first : 20, last : -1});
      expect(components.first, last);
      expect(components.last, first);
    });

    test('changing child priority should reorder component list', () {
      final parentComponent = PriorityComponent(0);
      final priorityComponents = List.generate(10, (i) => PriorityComponent(i));
      priorityComponents.shuffle();
      final game = BaseGame()..onResize(Vector2.zero());
      game.add(parentComponent);
      parentComponent.addChildren(priorityComponents, gameRef: game);
      final children = parentComponent.children;
      game.update(0);
      expect(componentsSorted(children), true);
      final first = children.first;
      game.changePriority(first, 20);
      expect(children.last, first);
    });

    test('changing child priorities should reorder component list', () {
      final parentComponent = PriorityComponent(0);
      final priorityComponents = List.generate(10, (i) => PriorityComponent(i));
      priorityComponents.shuffle();
      final game = BaseGame()..onResize(Vector2.zero());
      game.add(parentComponent);
      parentComponent.addChildren(priorityComponents, gameRef: game);
      final children = parentComponent.children;
      game.update(0);
      expect(componentsSorted(children), true);
      final first = children.first;
      final last = children.last;
      game.changePriorities({first : 20, last : -1});
      expect(children.first, last);
      expect(children.last, first);
    });

    test('changing grand child priority should reorder component list', () {
      final grandParentComponent = PriorityComponent(0);
      final parentComponent = PriorityComponent(0);
      final priorityComponents = List.generate(10, (i) => PriorityComponent(i));
      priorityComponents.shuffle();
      final game = BaseGame()..onResize(Vector2.zero());
      game.add(grandParentComponent);
      grandParentComponent.addChild(parentComponent, gameRef: game);
      parentComponent.addChildren(priorityComponents, gameRef: game);
      final children = parentComponent.children;
      game.update(0);
      expect(componentsSorted(children), true);
      final first = children.first;
      game.changePriority(first, 20);
      expect(children.last, first);
    });
  });
}
