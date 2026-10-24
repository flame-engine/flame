import 'package:flame_cli/src/merge/merge.dart';
import 'package:flame_cli/src/merge/tree_match.dart';
import 'package:test/test.dart';

TreeNode _node(
  int id,
  String type, {
  int? parent,
  int? index,
  int? key,
  String? hint,
}) {
  return TreeNode(
    id: id,
    parent: parent,
    declarationIndex: index,
    type: type,
    key: key,
    identity: 1000 + id,
    hint: hint,
  );
}

/// A game with a world that declares the given children.
ComponentTree _tree(List<(String, int?, String?)> children) {
  return ComponentTree([
    _node(0, 'MyGame'),
    _node(1, 'World', parent: 0, index: 0),
    for (final (i, (type, index, hint)) in children.indexed)
      _node(i + 2, type, parent: 1, index: index, hint: hint),
  ]);
}

FieldSegment _field(String name, {String className = 'Player'}) {
  return FieldSegment(
    libraryUri: 'package:game/player.dart',
    libraryId: 'libraries/1',
    className: className,
    name: name,
  );
}

Leaves _leaves(Map<List<PathSegment>, String> values) {
  return {
    for (final MapEntry(key: path, :value) in values.entries)
      Leaf(path, value).key: Leaf(path, value),
  };
}

class _Writer() implements MergeWriter {
  final writes = <String>[];
  final operations = <String>[];

  /// Whether a field at the end of a path with this display can be written.
  bool Function(String display) accepts = (_) => true;

  @override
  Future<bool> write(
    Slot slot,
    int id,
    List<PathSegment> path,
    WriteSource source,
  ) async {
    final display = path.map((segment) => segment.display).join('.');
    if (!accepts(display)) {
      return false;
    }
    final from = switch (source) {
      CopyFrom(:final newId) => 'new $newId',
      ComponentValue(:final slot, :final id) => '${slot.name} $id',
    };
    writes.add('${slot.name} $id $display from $from');
    return true;
  }

  @override
  Future<void> adopt(int newId, int liveParent) async {
    operations.add('adopt $newId into $liveParent');
  }

  @override
  Future<void> remove(int liveId) async => operations.add('remove $liveId');

  @override
  Future<void> setDeclarationIndex(int liveId, int declarationIndex) async {
    operations.add('index $liveId $declarationIndex');
  }
}

void main() {
  group('alignChildren', () {
    test('pairs the old children with the moved ones after an insertion', () {
      final old = [
        _node(1, 'Enemy', index: 0, hint: 'a'),
        _node(2, 'Enemy', index: 1, hint: 'b'),
      ];
      final updated = [
        _node(1, 'Enemy', index: 0, hint: 'new'),
        _node(2, 'Enemy', index: 1, hint: 'a'),
        _node(3, 'Enemy', index: 2, hint: 'b'),
      ];

      final alignment = alignChildren(old, updated);

      expect(
        alignment.pairs.map((pair) => (pair.$1.id, pair.$2.id)),
        [(1, 2), (2, 3)],
      );
      expect(alignment.added.map((node) => node.id), [1]);
      expect(alignment.removed, isEmpty);
    });

    test('pairs children by their named key first', () {
      final old = [
        _node(1, 'Enemy', index: 0, key: 7),
        _node(2, 'Enemy', index: 1),
      ];
      final updated = [
        _node(1, 'Enemy', index: 0),
        _node(2, 'Enemy', index: 1, key: 7),
      ];

      final alignment = alignChildren(old, updated);

      expect(
        alignment.pairs.map((pair) => (pair.$1.id, pair.$2.id)),
        containsAll([(1, 2), (2, 1)]),
      );
    });

    test('reports removed children and children of a new type', () {
      final alignment = alignChildren(
        [_node(1, 'Tree', index: 0), _node(2, 'Rock', index: 1)],
        [_node(1, 'Rock', index: 0), _node(2, 'Bush', index: 1)],
      );

      expect(alignment.pairs.map((pair) => pair.$1.type), ['Rock']);
      expect(alignment.removed.map((node) => node.type), ['Tree']);
      expect(alignment.added.map((node) => node.type), ['Bush']);
    });
  });

  group('matchTrees', () {
    test('matches live components by their declaration index', () {
      final old = _tree([('Player', 0, null), ('Enemy', 1, null)]);
      final live = _tree([
        ('Bullet', null, null),
        ('Enemy', 1, null),
        ('Player', 0, null),
      ]);

      final match = matchTrees(
        old: old,
        check: old,
        updated: old,
        live: live,
      );

      expect(match.oldToLive, {0: 0, 1: 1, 2: 4, 3: 3});
      expect(match.added, isEmpty);
      expect(match.removed, isEmpty);
    });

    test('skips declared components that are gone from the live game', () {
      final old = _tree([('Player', 0, null), ('Enemy', 1, null)]);
      final live = _tree([('Player', 0, null)]);

      final match = matchTrees(
        old: old,
        check: old,
        updated: old,
        live: live,
      );

      expect(match.oldToNew[3], 3);
      expect(match.oldToLive.containsKey(3), isFalse);
    });

    test('finds added, removed and reindexed components', () {
      final old = _tree([('Tree', 0, null), ('Player', 1, null)]);
      final updated = _tree([('Player', 0, null), ('Enemy', 1, null)]);

      final match = matchTrees(
        old: old,
        check: old,
        updated: updated,
        live: old,
      );

      expect(match.added, [(newId: 3, liveParent: 1)]);
      expect(match.removed, [2]);
      expect(match.reindexed, [(liveId: 3, declarationIndex: 0)]);
    });

    test('warns about a live component of another type', () {
      final old = _tree([('Player', 0, null)]);
      final live = _tree([('Enemy', 0, null)]);

      final match = matchTrees(
        old: old,
        check: old,
        updated: old,
        live: live,
      );

      expect(match.oldToLive.containsKey(2), isFalse);
      expect(match.warnings.single, contains('is a Enemy'));
    });
  });

  group('merge', () {
    final tree = _tree([('Player', 0, null)]);
    final speed = [_field('speed')];
    final position = [
      _field('transform', className: 'PositionComponent'),
      _field('_position', className: 'Transform2D'),
    ];
    final storage = [...position, _field('_v2storage', className: 'Vector2')];

    late _Writer writer;
    setUp(() => writer = _Writer());

    Future<MergeReport> run(
      Map<Slot, Map<List<PathSegment>, String>> player, {
      bool keepRuntime = false,
      ComponentTree? updated,
      ComponentTree? live,
      Map<(Slot, int), Map<List<PathSegment>, String>> others = const {},
    }) {
      final newTree = updated ?? tree;
      final liveTree = live ?? tree;
      return merge(
        match: matchTrees(
          old: tree,
          check: tree,
          updated: newTree,
          live: liveTree,
        ),
        old: tree,
        updated: newTree,
        live: liveTree,
        read: (slot, id) async {
          final values = id == 2 ? player[slot] : others[(slot, id)];
          return _leaves(values ?? player[Slot.old] ?? const {});
        },
        writer: writer,
        keepRuntime: keepRuntime,
      );
    }

    test('writes a value that the code changed', () async {
      final report = await run({
        Slot.old: {speed: 'Double:1.0'},
        Slot.updated: {speed: 'Double:2.0'},
      });

      expect(writer.writes, ['live 2 speed from new 2']);
      expect(report.updated, ['World #0 > Player #0 speed']);
      expect(report.conflicts, isEmpty);
    });

    test('ignores a value that differs between two builds', () async {
      final report = await run({
        Slot.old: {speed: 'Double:1.0'},
        Slot.check: {speed: 'Double:3.0'},
        Slot.updated: {speed: 'Double:2.0'},
      });

      expect(writer.writes, isEmpty);
      expect(report.isEmpty, isTrue);
    });

    test('lets the code win a conflict and reports it', () async {
      final report = await run({
        Slot.old: {speed: 'Double:1.0'},
        Slot.updated: {speed: 'Double:2.0'},
        Slot.live: {speed: 'Double:5.0'},
      });

      expect(writer.writes, hasLength(1));
      expect(report.conflicts.single, contains('replaced it'));
    });

    test('keeps the runtime value of a conflict when asked to', () async {
      final report = await run(
        {
          Slot.old: {speed: 'Double:1.0'},
          Slot.updated: {speed: 'Double:2.0'},
          Slot.live: {speed: 'Double:5.0'},
        },
        keepRuntime: true,
      );

      expect(writer.writes, isEmpty);
      expect(report.conflicts.single, contains('kept its runtime value'));
    });

    test('writes through the deepest field that can be written', () async {
      writer.accepts = (display) => display == 'transform._position';

      final report = await run({
        Slot.old: {storage: 'bytes:AAAA', position: 'type:Vector2'},
        Slot.updated: {storage: 'bytes:BBBB', position: 'type:Vector2'},
      });

      expect(writer.writes, ['live 2 transform._position from new 2']);
      expect(report.skipped, isEmpty);
    });

    test('reports a value that could not be written', () async {
      writer.accepts = (_) => false;

      final report = await run({
        Slot.old: {speed: 'Double:1.0'},
        Slot.updated: {speed: 'Double:2.0'},
      });

      expect(report.skipped.single, contains('could not be written'));
    });

    test('writes the live component that a reference now points to', () async {
      final target = [_field('target')];
      final updated = _tree([('Player', 0, null), ('Enemy', 1, null)]);

      await run(
        {
          Slot.old: {target: 'null'},
          Slot.updated: {target: 'component:1'},
        },
        updated: updated,
      );

      expect(writer.writes, ['live 2 target from live 1']);
    });

    test('skips an object that holds references to components', () async {
      final targets = [_field('targets')];
      final report = await run({
        Slot.old: {targets: 'length:0'},
        Slot.updated: {
          targets: 'length:1',
          [...targets, IndexSegment(0)]: 'component:1',
        },
      });

      expect(writer.writes, isEmpty);
      expect(report.skipped.single, contains('references to components'));
    });

    test('adopts, removes and reindexes declared components', () async {
      final old = _tree([('Tree', 0, null), ('Player', 1, null)]);
      final updated = _tree([('Player', 0, null), ('Enemy', 1, null)]);
      final world = [_field('_world', className: 'HasWorldRef')];

      final report = await merge(
        match: matchTrees(
          old: old,
          check: old,
          updated: updated,
          live: old,
        ),
        old: old,
        updated: updated,
        live: old,
        read: (slot, id) async {
          if (slot == Slot.updated && id == 3) {
            return _leaves({world: 'component:1'});
          }
          return const {};
        },
        writer: writer,
      );

      expect(writer.operations, [
        'adopt 3 into 1',
        'remove 2',
        'index 3 0',
      ]);
      expect(writer.writes, ['updated 3 _world from live 1']);
      expect(report.added, ['World #0 > Enemy #1']);
      expect(report.removed, ['World #0 > Tree #0']);
    });
  });
}
