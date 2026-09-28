import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('ComponentList queries', () {
    test('a removed component leaves the cache', () {
      final parent = Component();
      final list = parent.children..register<_Marked>();
      final marked = _Marked(1);
      parent
        ..add(marked)
        ..add(_Plain());

      expect(list.query<_Marked>(), [marked]);

      parent.remove(marked);
      expect(list.query<_Marked>(), isEmpty);
    });

    test('removing and adding back does not duplicate the cache entry', () {
      final parent = Component();
      final list = parent.children..register<_Marked>();
      final marked = _Marked(1);
      // A sibling keeps the list non-empty, so that the removal does not
      // compact the cache on its own.
      parent
        ..add(marked)
        ..add(_Marked(2));

      parent
        ..remove(marked)
        ..add(marked);

      expect(list.query<_Marked>().map((c) => c.id), [2, 1]);
    });

    test('a component moved to another list leaves the first cache', () {
      final sourceParent = Component();
      final targetParent = Component();
      final source = sourceParent.children..register<_Marked>();
      final target = targetParent.children..register<_Marked>();
      final marked = _Marked(1);
      sourceParent
        ..add(marked)
        ..add(_Marked(2));
      targetParent.add(_Marked(3));

      sourceParent.remove(marked);
      targetParent.add(marked);

      expect(source.query<_Marked>().map((c) => c.id), [2]);
      expect(target.query<_Marked>().map((c) => c.id), [3, 1]);
    });

    test('the cache keeps the list order across removals and additions', () {
      final parent = Component();
      final list = parent.children..register<_Marked>();
      final marked = List.generate(10, (i) => _Marked(i, priority: i));
      for (var i = 0; i < 10; i++) {
        parent
          ..add(marked[i])
          ..add(_Plain(priority: i));
      }

      // Removals from the front, the middle and the end, all before anything
      // reads the cache again.
      parent
        ..remove(marked[0])
        ..remove(marked[4])
        ..remove(marked[5])
        ..remove(marked[9]);
      expect(list.query<_Marked>().map((c) => c.id), [1, 2, 3, 6, 7, 8]);

      // A component that sorts into the middle lands in the right place.
      final inserted = _Marked(99, priority: 4);
      parent.add(inserted);
      expect(list.query<_Marked>().map((c) => c.id), [1, 2, 3, 99, 6, 7, 8]);
    });

    test('the cache is reordered after a rebalance that follows a removal', () {
      final parent = Component();
      final list = parent.children..register<_Marked>();
      final marked = List.generate(5, (i) => _Marked(i, priority: i));
      for (final component in marked) {
        parent.add(component);
      }

      parent.remove(marked[2]);
      marked[0].priority = 10;
      parent.rebalanceChildren();

      expect(list.query<_Marked>().map((c) => c.id), [1, 3, 4, 0]);
    });

    test('emptying the list empties the caches', () {
      final parent = Component();
      final list = parent.children..register<_Marked>();
      final marked = List.generate(3, _Marked.new);
      for (final component in marked) {
        parent.add(component);
      }

      for (final component in marked) {
        parent.remove(component);
      }

      expect(list.query<_Marked>(), isEmpty);
      expect(list, isEmpty);
    });

    testWithFlameGame(
      'mounting re-adds children without duplicating cache entries',
      (game) async {
        final parent = Component();
        final list = parent.children..register<_Marked>();
        final kept = _Marked(1);
        final removed = _Marked(2);
        parent
          ..add(kept)
          ..add(removed)
          ..add(_Plain())
          ..remove(removed);

        await game.world.ensureAdd(parent);

        expect(list.query<_Marked>().map((c) => c.id), [1]);
      },
    );

    test('removals past the tombstone compaction threshold', () {
      final parent = Component();
      final list = parent.children..register<_Marked>();
      // More than the threshold at which the backing array compacts itself.
      final marked = List.generate(100, (i) => _Marked(i, priority: i));
      for (final component in marked) {
        parent.add(component);
      }

      for (var i = 0; i < 100; i += 2) {
        parent.remove(marked[i]);
      }

      expect(
        list.query<_Marked>().map((c) => c.id),
        [for (var i = 1; i < 100; i += 2) i],
      );
    });

    test('whereType sees removals as query does', () {
      final parent = Component();
      final list = parent.children..register<_Marked>();
      final marked = _Marked(1);
      parent.add(marked);

      parent.remove(marked);

      expect(list.whereType<_Marked>(), isEmpty);
      // Unregistered types scan the backing array instead of a cache.
      expect(list.whereType<_Plain>(), isEmpty);
    });

    test('a cache of an unrelated type is unaffected by removals', () {
      final parent = Component();
      final list = parent.children
        ..register<_Marked>()
        ..register<_Plain>();
      final marked = _Marked(1);
      final plain = _Plain();
      parent
        ..add(marked)
        ..add(plain);

      parent.remove(marked);

      expect(list.query<_Plain>(), [plain]);
      expect(list.query<_Marked>(), isEmpty);
    });

    testWithFlameGame('queries follow the component lifecycle', (game) async {
      game.world.children.register<_Marked>();
      final marked = List.generate(20, (i) => _Marked(i, priority: i));
      await game.world.ensureAddAll([
        ...marked,
        ...List.generate(20, (i) => _Plain(priority: i)),
      ]);

      expect(game.world.children.query<_Marked>(), marked);

      game.world.removeAll(marked.sublist(0, 10));
      game.update(0);
      expect(game.world.children.query<_Marked>(), marked.sublist(10));

      // Removals and additions within the same tick.
      final added = _Marked(100, priority: 100);
      game.world
        ..removeAll(marked.sublist(10, 15))
        ..add(added);
      game.update(0);
      expect(game.world.children.query<_Marked>(), [
        ...marked.sublist(15),
        added,
      ]);
    });

    testWithFlameGame('hitbox queries follow removals', (game) async {
      final component = _Hitboxes();
      final hitboxes = List.generate(3, (_) => RectangleHitbox());
      await game.world.ensureAdd(component);
      await component.ensureAddAll(hitboxes);

      expect(component.hitboxes, hitboxes);

      hitboxes.first.removeFromParent();
      game.update(0);
      expect(component.hitboxes, hitboxes.sublist(1));
    });
  });
}

class _Marked extends Component {
  _Marked(this.id, {super.priority});

  final int id;
}

class _Plain extends Component {
  _Plain({super.priority});
}

class _Hitboxes extends PositionComponent with GestureHitboxes {
  _Hitboxes() : super(size: Vector2.all(10));
}
