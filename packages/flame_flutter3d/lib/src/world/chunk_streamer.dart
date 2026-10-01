/// The pieces of an endless world that are built right now, by index: a
/// river's stretches, a road's segments, a scrolling level's screens.
///
/// **What every game that scrolls wrote by hand.** Build what comes into
/// view, let go of what has left it, rebuild from scratch on a restart, and
/// find the one piece a point falls in. Each got the edges wrong once: a
/// piece dropped while still in view behind the player, or built twice when
/// the window moved by less than a piece. [cover] is the one place that
/// decides, and the game says only how a piece is built and let go.
///
/// A plain class rather than a component: what a piece holds (scene nodes,
/// Flame components, buffers) is the game's, and [build] and [drop] are
/// where it adds and removes them. Call [cover] from the game's `update`,
/// with the range of indices the camera can see.
final class ChunkStreamer<C> {
  ChunkStreamer({required this.build, required this.drop});

  /// Makes the piece at an index, adding whatever it holds to the game.
  final C Function(int index) build;

  /// Takes the piece at an index out of the game, and lets go of what it
  /// holds.
  final void Function(int index, C chunk) drop;

  final Map<int, C> _chunks = <int, C>{};

  /// The piece at [index], if it is built.
  C? operator [](int index) => _chunks[index];

  /// The indices built, in no particular order.
  Iterable<int> get indices => _chunks.keys;

  /// The pieces built, in no particular order.
  Iterable<C> get chunks => _chunks.values;

  /// Makes the pieces from [from] to [to] inclusive the ones built: drops
  /// every other, then builds the missing ones in order of index, so a
  /// piece's [build] can look at the one before it.
  void cover(int from, int to) {
    for (final index
        in _chunks.keys.where((i) => i < from || i > to).toList()) {
      drop(index, _chunks.remove(index) as C);
    }
    for (var index = from; index <= to; index++) {
      if (!_chunks.containsKey(index)) {
        _chunks[index] = build(index);
      }
    }
  }

  /// Drops every piece: for a restart, which [cover] then builds afresh.
  void clear() {
    for (final index in _chunks.keys.toList()) {
      drop(index, _chunks.remove(index) as C);
    }
  }
}
