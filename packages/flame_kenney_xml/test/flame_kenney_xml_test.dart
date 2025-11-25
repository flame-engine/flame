import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame_kenney_xml/flame_kenney_xml.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class _MockImage extends Mock implements Image {
  @override
  int get width => 100;

  @override
  int get height => 100;
}

class _MockImages extends Mock implements Images {
  @override
  Future<Image> load(String fileName, {String? key}) async {
    return _MockImage();
  }
}

class _MockAssetsCache extends Mock implements AssetsCache {
  @override
  Future<String> readFile(String fileName) async {
    return '''
    <TextureAtlas imagePath="spritesheet.png">
      <SubTexture name="sprite1" x="0" y="0" width="32" height="32"/>
      <SubTexture name="sprite2" x="32" y="0" width="32" height="32"/>
    </TextureAtlas>
    ''';
  }
}

void main() {
  group('XmlSpriteSheet', () {
    test('creation from constructor', () {
      final spritesheet = XmlSpriteSheet(
        image: _MockImage(),
        xml: '''
        <TextureAtlas imagePath="spritesheet.png">
          <SubTexture name="sprite1" x="0" y="0" width="32" height="32"/>
          <SubTexture name="sprite2" x="32" y="0" width="32" height="32"/>
        </TextureAtlas>
        ''',
      );

      expect(spritesheet.spriteNames, equals(['sprite1', 'sprite2']));
      final sprite1 = spritesheet.getSprite('sprite1');
      expect(sprite1.src, equals(const Rect.fromLTWH(0, 0, 32, 32)));
      final sprite2 = spritesheet.getSprite('sprite2');
      expect(sprite2.src, equals(const Rect.fromLTWH(32, 0, 32, 32)));
    });

    test('creation from load method', () async {
      final mockImages = _MockImages();
      final mockAssetsCache = _MockAssetsCache();

      final spritesheet = await XmlSpriteSheet.load(
        imagePath: 'spritesheet_stone.png',
        xmlPath: 'spritesheet_stone.xml',
        imageCache: mockImages,
        assetsCache: mockAssetsCache,
      );

      expect(spritesheet.spriteNames, equals(['sprite1', 'sprite2']));
      final sprite1 = spritesheet.getSprite('sprite1');
      expect(sprite1.src, equals(const Rect.fromLTWH(0, 0, 32, 32)));
      final sprite2 = spritesheet.getSprite('sprite2');
      expect(sprite2.src, equals(const Rect.fromLTWH(32, 0, 32, 32)));
    });
  });
}
