import 'dart:typed_data' show Float32List;
import 'dart:ui' as ui;

import 'package:flame/components.dart' show Sprite, TextPaint;
import 'package:flutter3d/flutter3d.dart' as engine show Material;
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:vector_math/vector_math.dart' show Matrix4;

/// The pictures sprite billboards are drawn with, shared: one texture and
/// one material for each image, one card for each part of an image a frame
/// shows.
///
/// **Forty reeds, one texture.** A billboard alone uploads its image and
/// makes its own cards, and a bank of reeds drawn from one sprite sheet
/// uploaded the sheet once for each reed. Handed an atlas, every billboard
/// of an image draws with the one texture and the one material, and the
/// cards are made once for all of them.
///
/// What it made is the game's until [dispose], which gives it back after the
/// frames in flight when handed the renderer.
final class BillboardAtlas {
  BillboardAtlas(this.device);

  final GraphicsDevice device;

  /// Keyed by how it is sampled as well as by the picture: a caller asking
  /// for [materialOf] `smooth` after another asked for it sharp got the
  /// sharp one.
  final Map<(ui.Image, bool), Future<engine.Material?>> _materials =
      <(ui.Image, bool), Future<engine.Material?>>{};

  /// Set by [dispose]. An upload still reading its pixels when the atlas is
  /// disposed checks it before making a texture nothing would give back.
  bool _disposed = false;
  final List<TextureHandle> _textures = <TextureHandle>[];
  final Map<(ui.Image, double, double, double, double), DeviceMesh> _cards =
      <(ui.Image, double, double, double, double), DeviceMesh>{};

  static final MeshData _quad = const PlaneShape().build().transformed(
    Matrix4.translationValues(0.0, 0.5, 0.0)
      ..multiply(Matrix4.rotationX(1.5707963267948966)),
  );

  /// The material [image] is drawn with: unlit, cut out where it is clear,
  /// both sides, sampled nearest for pixel art or, [smooth], linearly for
  /// lettering and anything drawn at a finer grain. Uploaded the first time
  /// it is asked for in each sampling; null if the image cannot be read, or
  /// if the atlas was disposed while it was being read.
  Future<engine.Material?> materialOf(ui.Image image, {bool smooth = false}) =>
      _materials.putIfAbsent((image, smooth), () async {
        final pixels = await image.toByteData(
          format: ui.ImageByteFormat.rawStraightRgba,
        );
        if (pixels == null || _disposed) {
          return null;
        }
        final texture = device.createTextureFromPixels(
          width: image.width,
          height: image.height,
          format: TextureFormat.r8g8b8a8UNormInt,
          pixels: pixels,
        );
        if (texture == null) {
          return null;
        }
        _textures.add(texture);
        return engine.Material(
          name: 'sprite',
          lighting: LightingModel.unlit,
          albedo: texture,
          albedoSampler: smooth
              ? SamplerOptions.linearClamp
              : SamplerOptions.nearestClamp,
          alphaMode: MaterialAlphaMode.mask,
          doubleSided: true,
        );
      });

  /// A card showing the part of its image [sprite] is cut from: a quad a
  /// metre square facing +Z, its foot at the origin. Its own corners rather
  /// than a texture transform, which not every lighting model reads.
  DeviceMesh cardOf(Sprite sprite) {
    final image = sprite.image;
    final at = sprite.srcPosition;
    final size = sprite.srcSize;
    return _cards.putIfAbsent((image, at.x, at.y, size.x, size.y), () {
      final uv = _quad.layout.floatOffsetOf(VertexLayout.texcoord.name);
      final stride = _quad.layout.floatsPerVertex;
      final vertices = Float32List.fromList(_quad.vertices);
      for (var i = uv; i >= 0 && i < vertices.length; i += stride) {
        vertices[i] = (at.x + vertices[i] * size.x) / image.width;
        vertices[i + 1] = (at.y + vertices[i + 1] * size.y) / image.height;
      }
      return DeviceMesh.upload(
        device,
        MeshData(
          layout: _quad.layout,
          vertices: vertices,
          indices: _quad.indices,
        ),
      );
    });
  }

  /// Writes [text] with Flame's [paint] into a picture of its own, [margin]
  /// pixels clear round it, for a billboard to stand in the scene: a sign
  /// by the road, a name over a craft, a score where a target went down.
  ///
  /// **Flame's text, not a font of the bridge's.** Whatever a `TextPaint`
  /// draws on Flame's canvas, its font, weight, colour and shadows, is what
  /// the sign says; write it large, as the card is sampled from it, and
  /// draw it `smooth` in its billboard.
  static Future<Sprite> spriteOfText(
    String text,
    TextPaint paint, {
    double margin = 4.0,
  }) {
    final painter = paint.toTextPainter(text);
    final width = (painter.width + margin * 2.0).ceil();
    final height = (painter.height + margin * 2.0).ceil();
    final recorder = ui.PictureRecorder();
    painter.paint(ui.Canvas(recorder), ui.Offset(margin, margin));
    return recorder.endRecording().toImage(width, height).then(Sprite.new);
  }

  /// Gives back every texture and card, after the frames [drawing] may still
  /// have in flight when it is given.
  void dispose({Renderer? drawing}) {
    _disposed = true;
    for (final card in _cards.values) {
      if (drawing != null) {
        drawing.releaseMeshAfterFrame(card);
      } else {
        device
          ..releaseGeometry(card.vertices)
          ..releaseGeometry(card.indices);
      }
    }
    // After the frames in flight too, like the cards: a texture given back
    // at once could still be sampled by a frame the GPU has not finished.
    _textures.forEach(
      drawing?.releaseTextureAfterFrame ?? device.releaseTexture,
    );
    _cards.clear();
    _textures.clear();
    _materials.clear();
  }
}
