import 'package:flame/flame.dart';
import 'package:tiled/tiled.dart';
import 'package:xml/xml.dart';

/// A implementation of [TsxProvider] use by RenderableTileMap.
///
/// It uses [Flame.bundle] and has a built-in cache for the file read.
class FlameTsxProvider implements TsxProvider {
  /// Parsed data for this tsx file.
  final String data;

  /// Stored filename for corresponding tsx file.
  final String _filename;

  FlameTsxProvider._(this.data, this._filename);

  @override
  String get filename => _filename;

  @override
  Parser getSource(String key) {
    final node = XmlDocument.parse(data).rootElement;
    return XmlParser(node);
  }

  @override
  Parser? getCachedSource() {
    if (data.isEmpty) {
      return null;
    }
    return getSource('');
  }

  /// Parses a file returning a [FlameTsxProvider].
  ///
  /// NOTE: this method looks for files under the path "assets/tiles/".
  static Future<FlameTsxProvider> parse(String key) async {
    final data = await Flame.bundle.loadString('assets/tiles/$key');
    return FlameTsxProvider._(data, key);
  }
}
