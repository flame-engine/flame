import 'package:flame/flame.dart';
import 'package:tiled/tiled.dart';
import 'package:xml/xml.dart';

/// A implementation of [TsxProvider] use by RenderableTileMap.
///
/// It uses [Flame.bundle] and has a built-in cache for the file read.
class FlameTsxProvider implements TsxProvider {
  @override
  Parser getSource(String key) {
    throw UnimplementedError();
  }

  @override
  Future<Parser> loadSource(String filename) async {
    final data = await Flame.bundle.loadString('assets/tiles/$filename');
    final node = XmlDocument.parse(data).rootElement;
    return XmlParser(node);
  }
}
