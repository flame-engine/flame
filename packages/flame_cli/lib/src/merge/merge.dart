import 'package:flame_cli/src/merge/tree_match.dart';

/// One step on the way from a component to a value inside of it.
sealed class PathSegment() {
  /// Identifies the segment within a [Leaf.key].
  String get key;

  /// How the segment is shown in messages.
  String get display;
}

/// A field of an object, which is identified by the library and the class
/// that declare it, since private fields of different libraries can have the
/// same name.
class FieldSegment({
  required final String libraryUri,

  /// The id of the declaring library in the Dart VM Service, which
  /// expressions that access private fields are evaluated in.
  required final String libraryId,
  required final String className,
  required final String name,
}) extends PathSegment {
  @override
  String get key => '$libraryUri#$className.$name';

  @override
  String get display => name;
}

/// An element of a list or a set.
class IndexSegment(final int index) extends PathSegment {
  @override
  String get key => '[$index]';

  @override
  String get display => '[$index]';
}

/// A value of a map, under a key that is described by [entryKey].
class EntrySegment(final String entryKey) extends PathSegment {
  @override
  String get key => '{$entryKey}';

  @override
  String get display => '[$entryKey]';
}

/// A value that can't be read further, at a [path] from a component.
///
/// The [value] is a string that is equal for equal values, such as
/// `int:3`, `bytes:<base64>` for typed data, `type:<class>` for the class of
/// an object, `identity:<hash>` for objects that are only compared by their
/// identity, and `component:<id>` for references to components in the tree.
class Leaf(final List<PathSegment> path, final String value) {
  late final String key = path.map((segment) => segment.key).join('/');

  bool get isComponent => value.startsWith('component:');
}

/// The leaves of a component, by their [Leaf.key].
typedef Leaves = Map<String, Leaf>;

/// The trees that a merging reload works with, see [TreeMatch].
enum Slot() {
  old,
  check,
  updated,
  live,
}

/// Reads the leaves of the component [id] in the tree [slot].
///
/// References to components are given as `component:<id>`, with the id of
/// the component in the same tree.
typedef LeafReader = Future<Leaves> Function(Slot slot, int id);

/// Where a value that a [MergeWriter] writes comes from.
sealed class WriteSource();

/// The value at the same path in the component [newId] of the new tree.
class CopyFrom(final int newId) extends WriteSource;

/// The component [id] in the tree [slot].
class ComponentValue(final Slot slot, final int id) extends WriteSource;

/// Changes the live game on behalf of [merge].
abstract interface class MergeWriter() {
  /// Writes [source] to the field at the end of [path] in the component [id]
  /// of the tree [slot], and returns whether that worked.
  Future<bool> write(
    Slot slot,
    int id,
    List<PathSegment> path,
    WriteSource source,
  );

  /// Moves the component [newId] of the new tree to the live component
  /// [liveParent].
  Future<void> adopt(int newId, int liveParent);

  /// Removes the live component [liveId].
  Future<void> remove(int liveId);

  /// Sets the declaration index of the live component [liveId].
  Future<void> setDeclarationIndex(int liveId, int declarationIndex);
}

/// What [merge] did, as lines for the user.
class MergeReport() {
  final updated = <String>[];
  final conflicts = <String>[];
  final skipped = <String>[];
  final added = <String>[];
  final removed = <String>[];
  final warnings = <String>[];

  bool get isEmpty =>
      updated.isEmpty &&
      conflicts.isEmpty &&
      skipped.isEmpty &&
      added.isEmpty &&
      removed.isEmpty &&
      warnings.isEmpty;

  /// The lists of lines with their titles, in the order they are printed.
  List<(String, List<String>)> get sections => [
    ('Updated', updated),
    ('Added', added),
    ('Removed', removed),
    ('Conflicts', conflicts),
    ('Skipped', skipped),
    ('Warnings', warnings),
  ];

  Map<String, List<String>> toJson() {
    return {
      for (final (title, lines) in sections) title.toLowerCase(): lines,
    };
  }
}

/// Applies the changes that the code made between the old and the new tree
/// to the live tree, as a three way merge.
///
/// A leaf that is equal in the old and the new tree wasn't changed by the
/// code, so the live value is kept. A leaf that is different was changed by
/// the code, unless it is also different between the old and the check tree,
/// which were built by the same code, since then it isn't deterministic, for
/// example because it is random. A changed leaf is written to the live
/// component, which is a conflict when the live value under the written field
/// also changed while the game was running. A conflict is resolved in favor
/// of the code, unless [keepRuntime] is set.
///
/// A leaf is written through the deepest field above it that the [writer]
/// manages to write, since a value such as a vector is often held in a final
/// field and has to be set through a setter of the object that holds it.
Future<MergeReport> merge({
  required TreeMatch match,
  required ComponentTree old,
  required ComponentTree updated,
  required ComponentTree live,
  required LeafReader read,
  required MergeWriter writer,
  bool keepRuntime = false,
}) async {
  final report = MergeReport()..warnings.addAll(match.warnings);

  String canonical(Slot slot, String value) {
    if (!value.startsWith('component:')) {
      return value;
    }
    final id = int.parse(value.substring('component:'.length));
    final oldId = switch (slot) {
      Slot.old => id,
      Slot.check => match.checkToOld[id],
      Slot.updated => match.newToOld[id],
      Slot.live => match.liveToOld[id],
    };
    return oldId != null ? 'component:$oldId' : 'component:${slot.name}:$id';
  }

  Future<Leaves> readCanonical(Slot slot, int id) async {
    final leaves = await read(slot, id);
    return {
      for (final leaf in leaves.values)
        leaf.key: Leaf(leaf.path, canonical(slot, leaf.value)),
    };
  }

  final adoptedIds = {
    for (final (:newId, liveParent: _) in match.added)
      ...updated.subtree(newId),
  };

  WriteSource? componentSource(String value) {
    final reference = value.substring('component:'.length);
    if (reference.startsWith('${Slot.updated.name}:')) {
      final newId = int.parse(
        reference.substring(Slot.updated.name.length + 1),
      );
      return adoptedIds.contains(newId)
          ? ComponentValue(Slot.updated, newId)
          : null;
    }
    final liveId = match.oldToLive[int.tryParse(reference)];
    return liveId == null ? null : ComponentValue(Slot.live, liveId);
  }

  for (final MapEntry(key: oldId, value: newId) in match.oldToNew.entries) {
    final oldLeaves = await readCanonical(Slot.old, oldId);
    final newLeaves = await readCanonical(Slot.updated, newId);
    final changed = {
      for (final key in {...oldLeaves.keys, ...newLeaves.keys})
        if (oldLeaves[key]?.value != newLeaves[key]?.value) key,
    };
    if (changed.isEmpty) {
      continue;
    }

    final liveId = match.oldToLive[oldId];
    final checkId = match.oldToCheck[oldId];
    final label = old.label(oldId);
    if (liveId == null) {
      continue;
    }
    if (checkId == null) {
      report.warnings.add(
        '$label was skipped, since the second build of the old code '
        "didn't declare it.",
      );
      continue;
    }

    final checkLeaves = await readCanonical(Slot.check, checkId);
    final noisy = {
      for (final key in {...oldLeaves.keys, ...checkLeaves.keys})
        if (oldLeaves[key]?.value != checkLeaves[key]?.value) key,
    };
    changed.removeAll(noisy);
    if (changed.isEmpty) {
      continue;
    }
    final liveLeaves = await readCanonical(Slot.live, liveId);

    Iterable<String> under(Iterable<String> keys, String prefix) {
      return keys.where((key) => key == prefix || key.startsWith('$prefix/'));
    }

    final pending = changed.where(newLeaves.containsKey).toList()
      ..sort((a, b) {
        return newLeaves[b]!.path.length.compareTo(
          newLeaves[a]!.path.length,
        );
      });
    final done = <String>{};
    for (final key in pending) {
      if (done.contains(key)) {
        continue;
      }
      final path = newLeaves[key]!.path;
      var handled = false;
      for (var length = path.length; length > 0; length--) {
        if (path[length - 1] is! FieldSegment) {
          continue;
        }
        final prefix = path.sublist(0, length);
        final prefixKey = Leaf(prefix, '').key;
        final display = prefix.map((segment) => segment.display).join('.');
        final changedUnder = under(changed, prefixKey).toList();
        final leafAtPrefix = newLeaves[prefixKey];
        final isComponentField = leafAtPrefix?.isComponent ?? false;
        final referencesComponents =
            !isComponentField &&
            under(newLeaves.keys, prefixKey).any(
              (key) => newLeaves[key]!.isComponent,
            );
        if (referencesComponents) {
          report.skipped.add(
            '$label $display, since it holds references to components.',
          );
          done.addAll(changedUnder);
          handled = true;
          break;
        }

        final compared = {...oldLeaves.keys, ...liveLeaves.keys};
        final conflict = under(compared, prefixKey)
            .where((key) => !noisy.contains(key))
            .any((key) => oldLeaves[key]?.value != liveLeaves[key]?.value);
        if (conflict && keepRuntime) {
          report.conflicts.add('$label $display kept its runtime value.');
          done.addAll(changedUnder);
          handled = true;
          break;
        }

        final source = isComponentField
            ? componentSource(leafAtPrefix!.value)
            : CopyFrom(newId);
        if (source == null) {
          report.skipped.add(
            '$label $display, since it refers to a component that the live '
            'game does not have.',
          );
          done.addAll(changedUnder);
          handled = true;
          break;
        }
        if (await writer.write(Slot.live, liveId, prefix, source)) {
          report.updated.add('$label $display');
          if (conflict) {
            report.conflicts.add(
              '$label $display had changed while the game was running, the '
              'value from the code replaced it.',
            );
          }
          done.addAll(changedUnder);
          handled = true;
          break;
        }
      }
      if (!handled) {
        final display = path.map((segment) => segment.display).join('.');
        report.skipped.add('$label $display, since it could not be written.');
        done.add(key);
      }
    }
  }

  for (final (:newId, :liveParent) in match.added) {
    final references = <(int, Leaf, WriteSource)>[];
    final adopted = updated.subtree(newId).toSet();
    for (final id in adopted) {
      final leaves = await readCanonical(Slot.updated, id);
      for (final leaf in leaves.values) {
        if (!leaf.isComponent ||
            leaf.value.startsWith('component:${Slot.updated.name}:')) {
          continue;
        }
        final source = componentSource(leaf.value);
        final display = leaf.path.map((segment) => segment.display).join('.');
        if (leaf.path.last is! FieldSegment || source == null) {
          report.warnings.add(
            '${updated.label(id)} $display still refers to the copy of the '
            'game that it was built in.',
          );
          continue;
        }
        references.add((id, leaf, source));
      }
    }

    await writer.adopt(newId, liveParent);
    report.added.add(updated.label(newId));
    for (final (id, leaf, source) in references) {
      if (!await writer.write(Slot.updated, id, leaf.path, source)) {
        final display = leaf.path.map((segment) => segment.display).join('.');
        report.warnings.add(
          '${updated.label(id)} $display still refers to the copy of the '
          'game that it was built in.',
        );
      }
    }
  }

  for (final liveId in match.removed) {
    await writer.remove(liveId);
    report.removed.add(live.label(liveId));
  }
  for (final (:liveId, :declarationIndex) in match.reindexed) {
    await writer.setDeclarationIndex(liveId, declarationIndex);
  }

  return report;
}
