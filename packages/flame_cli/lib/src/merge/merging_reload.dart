import 'package:flame_cli/src/flame_connection.dart';
import 'package:flame_cli/src/merge/heap.dart';
import 'package:flame_cli/src/merge/merge.dart';
import 'package:flame_cli/src/merge/tree_match.dart';
import 'package:flame_cli/src/run_controller.dart';

/// What [mergingReload] did.
class const MergingReloadResult(
  /// The response of `flame run` to the hot reload.
  final RunResponse response,

  /// What the merge changed, or null when the hot reload failed.
  final MergeReport? report,
);

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
/// running.
Future<MergingReloadResult> mergingReload({
  required FlameConnection connection,
  required Future<RunResponse> Function() reload,
  bool keepRuntime = false,
}) async {
  final heap = await Heap.connect(connection.service, connection.isolateId);
  final wasPaused = await connection.getPaused();
  if (!wasPaused) {
    await connection.setPaused(paused: true);
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
    if (!response.ok) {
      return MergingReloadResult(response, null);
    }

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
    return MergingReloadResult(response, report);
  } finally {
    try {
      await connection.call('disposeHotReloadShadows');
    } finally {
      if (!wasPaused) {
        await connection.setPaused(paused: false);
      }
    }
  }
}
