/// The pieces of an endless world built as they come into view and let go
/// as they leave it.
library;

import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<int> built;
  late List<(int, String)> dropped;
  late ChunkStreamer<String> streamer;

  setUp(() {
    built = <int>[];
    dropped = <(int, String)>[];
    streamer = ChunkStreamer<String>(
      build: (index) {
        built.add(index);
        return 'piece $index';
      },
      drop: (index, chunk) => dropped.add((index, chunk)),
    );
  });

  test('builds the window in order, and each piece once', () {
    streamer
      ..cover(2, 5)
      ..cover(2, 5);
    expect(built, <int>[2, 3, 4, 5]);
    expect(dropped, isEmpty);
    expect(streamer[4], 'piece 4');
    expect(streamer[6], isNull);
  });

  test('moving on drops what fell behind and builds what came ahead', () {
    streamer
      ..cover(0, 3)
      ..cover(2, 5);
    expect(built, <int>[0, 1, 2, 3, 4, 5]);
    expect(dropped, <(int, String)>[(0, 'piece 0'), (1, 'piece 1')]);
    expect(streamer.indices.toSet(), <int>{2, 3, 4, 5});
    expect(streamer.chunks, hasLength(4));
  });

  test('clear drops everything, and the next cover builds it afresh', () {
    streamer
      ..cover(0, 1)
      ..clear();
    expect(dropped.map((d) => d.$1).toSet(), <int>{0, 1});
    expect(streamer.chunks, isEmpty);
    streamer.cover(0, 1);
    expect(built, <int>[0, 1, 0, 1]);
  });
}
