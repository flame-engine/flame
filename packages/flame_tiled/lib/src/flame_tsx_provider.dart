import 'package:flame/flame.dart';
import 'package:flutter/services.dart';
import 'package:tiled/tiled.dart';

/// A [ParserProvider] for a single external tileset file loaded from
/// [Flame.bundle] or a custom asset bundle.
///
/// `RenderableTiledMap` resolves external tilesets on its own, this is only
/// needed when parsing a map manually, for example through
/// [TiledMap.parseTmx].
class FlameTsxProvider._(
  /// Parsed data for this tsx file.
  final String data,

  /// Stored filename for corresponding tsx file.
  final String filename,
) implements ParserProvider {
  @override
  bool canProvide(String path) => path == filename;

  @override
  Parser getSource(String path) => Parser.fromString(data);

  /// Parsed tileset source, or `null` when [data] is empty.
  Parser? getCachedSource() {
    if (data.isEmpty) {
      return null;
    }
    return getSource(filename);
  }

  /// Parses a file returning a [FlameTsxProvider].
  ///
  /// The [key] is resolved against [tsxDirectory], which is the directory of
  /// the map that references this tileset.
  static Future<FlameTsxProvider> parse(
    String key, [
    AssetBundle? bundle,
    String tsxDirectory = '',
  ]) async {
    final data = await (bundle ?? Flame.bundle).loadString('$tsxDirectory$key');
    return FlameTsxProvider._(data, key);
  }
}
