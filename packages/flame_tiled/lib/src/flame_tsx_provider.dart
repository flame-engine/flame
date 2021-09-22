import 'package:xml/xml.dart';

import 'package:flame/flame.dart';
import 'package:tiled/tiled.dart';

class FlameTsxProvider implements TsxProvider {
  late String data;
  final String key;

  Future<void> initialize() async {
    this.data = await Flame.bundle.loadString('assets/tiles/$key');
  }

  FlameTsxProvider(this.key);

  @override
  Parser getSource(String key) {
    final node = XmlDocument.parse(this.data).rootElement;
    return XmlParser(node);
  }
}
