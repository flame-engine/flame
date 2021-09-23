import 'package:flame/flame.dart';
import 'package:tiled/tiled.dart';
import 'package:xml/xml.dart';

/// A implementation of [TsxProvider] use by RenderableTileMap.
///
/// It uses [Flame.bundle] and has a built-in cache for the file read.
class FlameTsxProvider implements TsxProvider {
  final String data;

  FlameTsxProvider._(this.data);

  @override
  Parser getSource(String key) {
    final node = XmlDocument.parse(data).rootElement;
    return XmlParser(node);
  }

  static Future<FlameTsxProvider> parse(String key) async {
    final data = await Flame.bundle.loadString('assets/tiles/$key');
    return FlameTsxProvider._(data);
  }
}
