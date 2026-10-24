import 'package:flame_cli/src/commands/game_loop_commands.dart';
import 'package:flame_cli/src/flame_connection.dart';
import 'package:flame_cli/src/merge/heap.dart';
import 'package:flame_cli/src/merge/merge.dart';
import 'package:flame_cli/src/merge/tree_match.dart';

/// Hot reloads the game through [reload], and merges the changes of the code
/// that sets up the components into the live game, keeping their state.
///
/// Hot reload replaces the code of the methods but keeps the objects, so a
/// change to a constructor or an `onLoad` normally only shows after a hot
/// restart. Here a shadow copy of the game is built with the old code before
/// the reload, twice to find values that aren't deterministic, and once more
/// with the new code after it. Then the differences between the old and the
/// new copy are applied to the live game, see [merge].
///
/// The game is paused while this happens, and resumed afterwards if it was
/// running. Returns whether the reload worked.
Future<bool> mergingReload({
  required FlameConnection connection,
  required Future<Map<String, dynamic>> Function() reload,
  required StringSink out,
  bool keepRuntime = false,
}) async {
  final heap = await Heap.connect(connection.service, connection.isolateId);
  final wasPaused = (await connection.call('getPaused'))['paused'] == true;
  if (!wasPaused) {
    await setPaused(connection, paused: true);
  }

  Future<ComponentTree> buildShadow(Slot slot) async {
    await heap.buildShadow(slot);
    final name = slot == Slot.updated ? 'new' : slot.name;
    final description = await connection.call(
      'awaitHotReloadShadow',
      args: {'slot': name},
    );
    return ComponentTree.fromJson(description);
  }

  try {
    await connection.call('getHotReloadTree');
    final old = await buildShadow(Slot.old);
    final check = await buildShadow(Slot.check);

    final response = await reload();
    final message = response['message'];
    if (response['ok'] != true) {
      final output = (response['output'] as List?) ?? const [];
      for (final line in output) {
        out.writeln(line);
      }
      if (output.isEmpty || output.last != message) {
        out.writeln(message);
      }
      return false;
    }
    out.writeln(message);

    final live = ComponentTree.fromJson(
      await connection.call('getHotReloadTree'),
    );
    final updated = await buildShadow(Slot.updated);
    final match = matchTrees(
      old: old,
      check: check,
      updated: updated,
      live: live,
    );
    final trees = {
      Slot.old: old,
      Slot.check: check,
      Slot.updated: updated,
      Slot.live: live,
    };
    final report = await merge(
      match: match,
      old: old,
      updated: updated,
      live: live,
      read: (slot, id) => heap.read(slot, id, trees[slot]!),
      writer: HeapMergeWriter(heap),
      keepRuntime: keepRuntime,
    );
    _printReport(report, out);
    return true;
  } finally {
    await connection.call('disposeHotReloadShadows');
    if (!wasPaused) {
      await setPaused(connection, paused: false);
    }
  }
}

void _printReport(MergeReport report, StringSink out) {
  if (report.isEmpty) {
    out.writeln('The code declares no changes to the components.');
    return;
  }
  void section(String title, List<String> lines) {
    if (lines.isEmpty) {
      return;
    }
    out.writeln(title);
    for (final line in lines) {
      out.writeln('  $line');
    }
  }

  section('Updated:', report.updated);
  section('Added:', report.added);
  section('Removed:', report.removed);
  section('Conflicts:', report.conflicts);
  section('Skipped:', report.skipped);
  section('Warnings:', report.warnings);
}
