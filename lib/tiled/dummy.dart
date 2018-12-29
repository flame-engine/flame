
import 'dart:async';
import 'dart:io';
import 'package:tmx/tmx.dart';

void main() {
  new File('lib/tiled/jb-32.tmx').readAsString().then((String contents) {
    var parser = new TileMapParser();
    TileMap map = parser.parse(contents);    
    var x = map.layers[0].tileMatrix[126][31];
    var tileset = map.getTileset('jb-32-Tileset');    
    // var tile = map.getTileByLocalID('jb-32-Tileset', x)
    var tile = map.layers[0].tiles[30];
    var prop = tileset.tileProperties[tile.tileId];
    print('value: ${tile.x}');
  });
}
