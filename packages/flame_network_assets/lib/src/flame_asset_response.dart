import 'dart:typed_data';

/// {@template flame_assets_response}
/// A class containing the relevant http attributes to
/// Flame Assets Network package.
/// {@endtemplate}
class const FlameAssetResponse({
  /// Http status code.
  required final int statusCode,

  /// response bytes.
  required final Uint8List bytes,
}) {
  /// {@macro flame_assets_response}
  this;
}
