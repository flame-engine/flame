import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:flame/camera.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/services.dart' show CachingAssetBundle;
import 'package:flutter_test/flutter_test.dart';

const _tileSize = 16.0;
const _viewport = (width: 800.0, height: 600.0);

/// Renders a map of [mapTiles] x [mapTiles] tiles, which is orthogonal unless
/// [orientation] says otherwise, through a
/// camera that shows [_viewport] worth of it, in the middle of the map.
///
/// With a map much bigger than the view, almost all of the tiles are
/// off-screen, which is the case that culling is meant to help.
class TileLayerBenchmark({
  required final String label,
  required final int mapTiles,
  required final bool useAtlas,
  final bool infinite = false,
  final int? chunkSize,
  final String orientation = 'orthogonal',
  final String attributes = '',
  final bool rasterize = false,
}) extends AsyncBenchmarkBase {
  late final FlameGame _game;

  this : super('Tile Layer Benchmark ($label)');

  @override
  Future<void> setup() async {
    // The atlas is cached by image, so it would be reused with the wrong
    // `useAtlas` setting by the next benchmark.
    // ignore: invalid_use_of_visible_for_testing_member
    TiledAtlas.atlasMap.clear();
    Flame.bundle = _BenchmarkBundle(
      _mapXml(
        mapTiles,
        infinite: infinite,
        orientation: orientation,
        attributes: attributes,
      ),
    );
    final map = await TiledComponent.load(
      'assets/tiles/map.tmx',
      Vector2.all(_tileSize),
      useAtlas: useAtlas,
      chunkSize: chunkSize,
    );

    final world = World();
    final camera = CameraComponent(
      world: world,
      viewport: FixedSizeViewport(_viewport.width, _viewport.height),
    )..viewfinder.position = map.size / 2;
    _game = await initializeGame(
      () => FlameGame(world: world, camera: camera),
    );
    await world.ensureAdd(map);
    _game.update(0);
  }

  @override
  Future<void> run() async {
    // A real recording canvas, so that the draw calls have a realistic CPU
    // cost.
    final recorder = PictureRecorder();
    _game.render(Canvas(recorder));
    final picture = recorder.endRecording();
    if (rasterize) {
      // Includes the cost of drawing the picture into an image, which is the
      // closest this test environment gets to the work of the raster thread.
      final image = await picture.toImage(
        _viewport.width.toInt(),
        _viewport.height.toInt(),
      );
      image.dispose();
    }
    picture.dispose();
  }
}

String _mapXml(
  int tiles, {
  required bool infinite,
  String orientation = 'orthogonal',
  String attributes = '',
}) {
  final String data;
  if (infinite) {
    // Chunks of 16x16 tiles, like Tiled writes them. [tiles] is rounded up
    // to whole chunks.
    final chunks = StringBuffer();
    final row = List.filled(16, '1').join(',');
    final chunk = List.filled(16, row).join(',\n');
    for (var y = 0; y < tiles; y += 16) {
      for (var x = 0; x < tiles; x += 16) {
        chunks.writeln(
          '<chunk x="$x" y="$y" width="16" height="16">\n$chunk\n</chunk>',
        );
      }
    }
    data = chunks.toString();
  } else {
    final row = List.filled(tiles, '1').join(',');
    data = List.filled(tiles, row).join(',\n');
  }
  return '''
<?xml version="1.0" encoding="UTF-8"?>
<map version="1.8" orientation="$orientation" renderorder="right-down" width="$tiles" height="$tiles" tilewidth="16" tileheight="16" infinite="${infinite ? 1 : 0}" $attributes nextlayerid="2" nextobjectid="1">
 <tileset firstgid="1" name="4_color_sprite" tilewidth="16" tileheight="16" tilecount="1" columns="1">
  <image source="4_color_sprite.png" width="16" height="16"/>
 </tileset>
 <layer id="1" name="Tile Layer 1" width="$tiles" height="$tiles">
  <data encoding="csv">
$data
  </data>
 </layer>
</map>
''';
}

class _BenchmarkBundle(final String map) extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final bytes = await File(
      'test/assets/4_color_sprite.png',
    ).readAsBytes();
    return ByteData.view(Uint8List.fromList(bytes).buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async => map;
}

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final useAtlas in [true, false]) {
    final path = useAtlas ? 'atlas' : 'no atlas';
    for (final (kind, infinite, chunkSize) in [
      ('finite', false, null),
      ('finite, culled', false, 16),
      ('infinite', true, null),
    ]) {
      // 48 tiles fit the view (nothing can be culled), 208 and 496 do not.
      // The sizes are whole chunks, so that all kinds hold the same tiles.
      for (final tiles in [48, 208, 496]) {
        await TileLayerBenchmark(
          label: '$tiles x $tiles tiles, $kind, $path',
          mapTiles: tiles,
          useAtlas: useAtlas,
          infinite: infinite,
          chunkSize: chunkSize,
        ).report();
      }
    }
  }
  // Same maps, but the picture is also drawn into an image.
  for (final tiles in [48, 496]) {
    await TileLayerBenchmark(
      label: '$tiles x $tiles tiles, finite, atlas, rasterized',
      mapTiles: tiles,
      useAtlas: true,
      rasterize: true,
    ).report();
  }
  // The other orientations, with the tiles that are as big as the cells.
  for (final (name, orientation, attributes) in [
    ('isometric', 'isometric', ''),
    ('staggered', 'staggered', 'staggeraxis="y" staggerindex="odd"'),
    (
      'hexagonal',
      'hexagonal',
      'hexsidelength="8" staggeraxis="y" staggerindex="odd"',
    ),
  ]) {
    for (final useAtlas in [true, false]) {
      final path = useAtlas ? 'atlas' : 'no atlas';
      for (final (kind, chunkSize) in [('', null), (', culled', 16)]) {
        for (final tiles in [208, 496]) {
          await TileLayerBenchmark(
            label: '$tiles x $tiles tiles, $name$kind, $path',
            mapTiles: tiles,
            useAtlas: useAtlas,
            chunkSize: chunkSize,
            orientation: orientation,
            attributes: attributes,
          ).report();
        }
      }
    }
  }
}
