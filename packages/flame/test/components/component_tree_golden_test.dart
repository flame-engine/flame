import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

/// Golden tests that pin the observable behavior of the component tree:
/// lifecycle event ordering in same-tick edge cases, hit-test order, and
/// the ordering guarantees for children with equal priorities.
///
/// These behaviors must survive any change to the children container or the
/// traversal machinery.
void main() {
  group('Lifecycle ordering', () {
    testWithFlameGame('add to a new parent during remove, same tick', (
      game,
    ) async {
      final parent1 = Component();
      final parent2 = Component();
      await game.world.ensureAdd(parent1);
      await game.world.ensureAdd(parent2);
      final child = _EventLogComponent();
      await parent1.ensureAdd(child);
      expect(child.events, ['onMount']);

      parent1.remove(child);
      parent2.add(child);
      game.update(0);
      await game.ready();

      expect(child.parent, parent2);
      expect(child.isMounted, isTrue);
      expect(parent1.children, isEmpty);
      expect(parent2.children, [child]);
      expect(child.events, ['onMount', 'onRemove', 'onMount']);
    });

    testWithFlameGame('move to a new parent while old parent is removed', (
      game,
    ) async {
      final parent1 = Component();
      final parent2 = Component();
      await game.world.ensureAdd(parent1);
      await game.world.ensureAdd(parent2);
      final child = _EventLogComponent();
      await parent1.ensureAdd(child);

      child.parent = parent2;
      parent1.removeFromParent();
      game.update(0);
      await game.ready();

      expect(parent1.isMounted, isFalse);
      expect(child.parent, parent2);
      expect(child.isMounted, isTrue);
      expect(parent2.children, [child]);
      expect(child.events, ['onMount', 'onRemove', 'onMount']);
    });

    testWithFlameGame('remove and re-add to the same parent, same tick', (
      game,
    ) async {
      final parent = Component();
      await game.world.ensureAdd(parent);
      final child = _EventLogComponent();
      await parent.ensureAdd(child);

      parent.remove(child);
      parent.add(child);
      game.update(0);
      await game.ready();

      expect(child.parent, parent);
      expect(child.isMounted, isTrue);
      expect(parent.children, [child]);
    });
  });

  group('Hit-test order', () {
    testWithFlameGame('componentsAtPoint is front-to-back by priority', (
      game,
    ) async {
      final bottom = _HittablePositionComponent(priority: 0);
      final middle = _HittablePositionComponent(priority: 1);
      final top = _HittablePositionComponent(priority: 2);
      // Added in an order that differs from the priority order.
      await game.world.ensureAddAll([middle, top, bottom]);

      final hits = game.componentsAtPoint(Vector2(405, 305)).toList();
      final hitComponents = hits
          .whereType<_HittablePositionComponent>()
          .toList();
      expect(hitComponents, [top, middle, bottom]);
    });

    testWithFlameGame('children hit before their parents', (game) async {
      final parent = _HittablePositionComponent(priority: 0);
      final child = _HittablePositionComponent(priority: 0);
      parent.add(child);
      await game.world.ensureAdd(parent);

      final hits = game
          .componentsAtPoint(Vector2(405, 305))
          .whereType<_HittablePositionComponent>()
          .toList();
      expect(hits, [child, parent]);
    });

    testWithFlameGame('equal-priority siblings hit in reverse add order', (
      game,
    ) async {
      final first = _HittablePositionComponent(priority: 0);
      final second = _HittablePositionComponent(priority: 0);
      final third = _HittablePositionComponent(priority: 0);
      await game.world.ensureAddAll([first, second, third]);

      final hits = game
          .componentsAtPoint(Vector2(405, 305))
          .whereType<_HittablePositionComponent>()
          .toList();
      expect(hits, [third, second, first]);
    });
  });

  group('Equal-priority ordering', () {
    testWithFlameGame('insertion order is kept through mounting', (
      game,
    ) async {
      final children = List.generate(10, (i) => Component());
      final parent = Component(children: children);
      await game.world.ensureAdd(parent);
      expect(parent.children.toList(), children);
    });

    testWithFlameGame('insertion order survives a sibling priority change', (
      game,
    ) async {
      final children = List.generate(10, (i) => Component());
      final parent = Component(children: children);
      await game.world.ensureAdd(parent);

      // Push the first child to the back; everyone else keeps their order.
      children.first.priority = 1;
      game.update(0);
      await game.ready();

      expect(
        parent.children.toList(),
        [...children.skip(1), children.first],
      );

      // Return it to the same priority as the others: it must now sort after
      // them (a fresh sort key, not its original insertion position).
      children.first.priority = 0;
      game.update(0);
      await game.ready();

      expect(
        parent.children.toList(),
        [...children.skip(1), children.first],
      );
    });

    testWithFlameGame('insertion order is kept when the parent remounts', (
      game,
    ) async {
      final children = List.generate(10, (i) => Component());
      final parent = Component(children: children);
      await game.world.ensureAdd(parent);

      parent.removeFromParent();
      game.update(0);
      await game.ready();
      expect(parent.isMounted, isFalse);

      await game.world.ensureAdd(parent);
      expect(parent.children.toList(), children);
    });

    testWithFlameGame('update and render visit equal priorities in add order', (
      game,
    ) async {
      final order = <int>[];
      final children = List.generate(
        5,
        (i) => _UpdateLogComponent(i, order),
      );
      final parent = Component(children: children);
      await game.world.ensureAdd(parent);

      game.update(0);
      expect(order, [0, 1, 2, 3, 4]);
    });
  });
}

class _EventLogComponent extends Component {
  final List<String> events = [];

  @override
  void onMount() {
    events.add('onMount');
  }

  @override
  void onRemove() {
    events.add('onRemove');
  }
}

class _HittablePositionComponent extends PositionComponent {
  _HittablePositionComponent({super.priority}) : super(size: Vector2.all(10));
}

class _UpdateLogComponent extends Component {
  _UpdateLogComponent(this.id, this.order);

  final int id;
  final List<int> order;

  @override
  void update(double dt) {
    order.add(id);
  }
}
