import 'dart:typed_data';

/// {@template flame_assets_response}
/// A class containing the relevant http attributes to
/// Flame Assets Network package.
/// {@endtemplate}
class FlameAssetResponse {
  /// {@macro flame_assets_response}
  const FlameAssetResponse({
    required this.statusCode,
    required this.bytes,
  });

  /// Http status code.
  final int statusCode;

  /// response bytes.
  final Uint8List bytes;
}
