import 'dart:ui' as ui;
import 'package:flame/sprite.dart';
import 'package:flame_texturepacker/flame_texturepacker.dart';
import 'package:flame_texturepacker/src/experimental/bake_request.dart';
import 'package:flame_texturepacker/src/experimental/composite_atlas_impl.dart';

/// A runtime-composed texture atlas that merges multiple [BakeRequest]
/// sources into a single [ui.Image] to minimize draw calls.
///
/// It extends [TexturePackerAtlas] to be fully compatible with the Flame
/// engine.
abstract class CompositeAtlas extends TexturePackerAtlas {
  /// Internal constructor to pass through sprites to [TexturePackerAtlas].
  CompositeAtlas(super.sprites);

  /// Provides direct access to the underlying image (from the first sprite).
  ui.Image get image;

  /// Returns all sprite names present in the atlas.
  List<String> get allSpriteNames;

  /// Disposes the underlying image for baked atlases.
  void dispose();

  /// Efficiently creates a [SpriteAnimation] for a given sprite name.
  @override
  SpriteAnimation getAnimation(
    String name, {
    double stepTime = 0.1,
    bool loop = true,
    bool useIndexedSpritesOnly = false,
  });

  String generateGDXAtlasContent(String imageName);

  static Future<CompositeAtlas> bake(
    List<BakeRequest> requests, {
    double maxAtlasWidth = 1024.0,
    bool allowRotation = true,
    bool forceSquare = false,
    bool trim = true,
  }) => CompositeAtlasImpl.bake(
    requests,
    maxAtlasWidth: maxAtlasWidth,
    allowRotation: allowRotation,
    forceSquare: forceSquare,
    trim: trim,
  );

  /// Creates a simple wrapper for a regular [TexturePackerAtlas] without 
  /// baking.
  static CompositeAtlas fromAtlas(TexturePackerAtlas atlas) =>
      CompositeAtlasImpl.fromAtlas(atlas);
}
