library flame_texturepacker;

import 'dart:convert';

import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flame_texturepacker/atlas/texture_packer_atlas.dart';

export 'package:flame_texturepacker/atlas/model/texture_packer_sprite.dart';

extension TexturepackerLoader on Game {
  /// Loads the specified pack file, using the parent directory of the pack file
  /// to find the page images.
  Future<TexturePackerAtlas> fromAtlas(String assetsPath) async =>
      TexturePackerAtlas().load(assetsPath);

  @Deprecated('Please use fromAtlas() and files with extension .atlas')
  Future<List<Sprite>> fromJSONAtlas(String imagePath, String dataPath) async {
    final jsonFrames = await _loadJsonFrames(dataPath);
    final image = await Flame.images.load(imagePath);

    final sprites = jsonFrames.values.map((value) {
      return _createSprite(value as Map<String, dynamic>, image);
    });

    return sprites.toList();
  }

  @Deprecated('Please use fromAtlas() and files with extension .atlas')
  Future<Map<String, Sprite>> fromJSONAtlasAsMap(
    String imagePath,
    String dataPath,
  ) async {
    final jsonFrames = await _loadJsonFrames(dataPath);
    final image = await Flame.images.load(imagePath);
    final map = <String, Sprite>{};

    jsonFrames.forEach((filename, value) {
      final id = _filenameWithoutExtension(filename);
      map[id] = _createSprite(value as Map<String, dynamic>, image);
    });

    return map;
  }

  String _filenameWithoutExtension(String filename) {
    if (!filename.contains('.')) {
      return filename;
    } else {
      return filename.substring(0, filename.lastIndexOf('.'));
    }
  }

  Future<Map<String, dynamic>> _loadJsonFrames(String dataPath) async {
    final content = await Flame.assets.readFile(dataPath);
    final json = jsonDecode(content) as Map<String, dynamic>;
    return json['frames'] as Map<String, dynamic>;
  }

  Sprite _createSprite(Map<String, dynamic> value, Image image) {
    final frameData = value['frame'] as Map<String, dynamic>;
    final x = frameData['x'] as int;
    final y = frameData['y'] as int;
    final width = frameData['w'] as int;
    final height = frameData['h'] as int;

    return Sprite(
      image,
      srcPosition: Vector2(x.toDouble(), y.toDouble()),
      srcSize: Vector2(width.toDouble(), height.toDouble()),
    );
  }
}
