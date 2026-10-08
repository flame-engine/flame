import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/src/sprite.dart';
import 'package:flame/src/sprite_warp/warp_grid.dart';
import 'package:flame/src/sprite_warp/warp_mesh.dart';
import 'package:meta/meta.dart';

final Float64List _identityMatrix = Float64List.fromList([
  1, 0, 0, 0, //
  0, 1, 0, 0, //
  0, 0, 1, 0, //
  0, 0, 0, 1, //
]);

/// Offset, in texels, added to all the texture coordinates.
///
/// When a pixel samples the image exactly on the boundary between two texels
/// (e.g. every third pixel when a sprite is scaled by 1.5 with nearest
/// filtering), each triangle of the mesh would round the tie in its own way,
/// because of tiny floating point differences, and lines of the image would
/// show 1-texel steps along the triangles' edges. Nudging the coordinates
/// towards the lower texel makes every triangle round ties the same way as
/// drawImageRect does, while staying well above the float32 precision of the
/// coordinates of large textures and well below any visible effect with
/// linear filtering.
const double _texelOffset = -1 / 1024;

/// Renders a [Sprite] warped by a [WarpGrid], caching everything that does
/// not change between frames.
///
/// The mesh is rebuilt only when the grid or the interpolation change, the
/// vertices only when the mesh, the sprite's source rectangle or the
/// destination size change, and the image shader only when the sprite's image
/// changes.
@internal
class SpriteWarpRenderer() {
  WarpGrid? _grid;
  WarpInterpolation? _interpolation;
  WarpMesh? _mesh;

  Rect? _src;
  double _width = 0;
  double _height = 0;
  double _bleed = 0;
  Vertices? _vertices;
  Rect _bounds = Rect.zero;

  Image? _image;
  ImageShader? _shader;

  final Paint _paint = Paint();
  final Paint _layerPaint = Paint();

  /// The number of times the mesh was built.
  @visibleForTesting
  int meshBuilds = 0;

  /// The number of times the vertices were built.
  @visibleForTesting
  int verticesBuilds = 0;

  /// Renders [sprite] warped by [grid] into a rectangle of the given [width]
  /// and [height] at the origin, expanded by [bleed] on every side, using the
  /// properties of [paint] (except its shader).
  void render(
    Canvas canvas, {
    required Sprite sprite,
    required WarpGrid grid,
    required WarpInterpolation interpolation,
    required double width,
    required double height,
    required Paint paint,
    double bleed = 0,
  }) {
    _updateMesh(grid, interpolation);
    _updateShader(sprite.image);
    _updateVertices(sprite.src, width, height, bleed);

    _paint
      ..shader = _shader
      ..color = paint.color
      ..filterQuality = paint.filterQuality
      ..isAntiAlias = paint.isAntiAlias
      ..imageFilter = paint.imageFilter
      ..maskFilter = paint.maskFilter
      ..invertColors = paint.invertColors;

    // The blend mode passed to drawVertices only combines vertex colors (which
    // are not used) with the shader, but Impeller crashes with some modes
    // (e.g. BlendMode.dst), so it is always srcOver.
    final colorFilter = paint.colorFilter;
    if (colorFilter == null) {
      _paint.blendMode = paint.blendMode;
      canvas.drawVertices(_vertices!, BlendMode.srcOver, _paint);
    } else {
      // Impeller ignores the paint's color filter in drawVertices, so it is
      // applied through a layer instead, on every backend for consistency.
      _paint.blendMode = BlendMode.srcOver;
      _layerPaint
        ..colorFilter = colorFilter
        ..blendMode = paint.blendMode;
      final hasFilters = paint.imageFilter != null || paint.maskFilter != null;
      canvas.saveLayer(hasFilters ? null : _bounds, _layerPaint);
      canvas.drawVertices(_vertices!, BlendMode.srcOver, _paint);
      canvas.restore();
    }
  }

  /// Releases the cached resources.
  ///
  /// The image shader is not disposed but only dereferenced, since on the
  /// CanvasKit web renderer disposing an image shader also disposes its image,
  /// which belongs to the sprite and may be shared.
  void dispose() {
    _vertices?.dispose();
    _vertices = null;
    _shader = null;
    _image = null;
    _paint.shader = null;
    _mesh = null;
    _grid = null;
    _interpolation = null;
    _src = null;
  }

  void _updateMesh(WarpGrid grid, WarpInterpolation interpolation) {
    if (identical(grid, _grid) && interpolation == _interpolation) {
      return;
    }
    _grid = grid;
    _interpolation = interpolation;
    _mesh = WarpMesh.fromGrid(grid, interpolation);
    meshBuilds++;
    _src = null;
  }

  void _updateShader(Image image) {
    if (identical(image, _image)) {
      return;
    }
    _image = image;
    _shader = ImageShader(
      image,
      TileMode.clamp,
      TileMode.clamp,
      _identityMatrix,
    );
  }

  void _updateVertices(Rect src, double width, double height, double bleed) {
    if (src == _src &&
        width == _width &&
        height == _height &&
        bleed == _bleed) {
      return;
    }
    _src = src;
    _width = width;
    _height = height;
    _bleed = bleed;

    final mesh = _mesh!;
    final scaleX = width + 2 * bleed;
    final scaleY = height + 2 * bleed;
    final positions = Float32List(mesh.positions.length);
    final textureCoordinates = Float32List(mesh.textureCoordinates.length);
    for (var k = 0; k < positions.length; k += 2) {
      positions[k] = mesh.positions[k] * scaleX - bleed;
      positions[k + 1] = mesh.positions[k + 1] * scaleY - bleed;
      textureCoordinates[k] =
          src.left + mesh.textureCoordinates[k] * src.width + _texelOffset;
      textureCoordinates[k + 1] =
          src.top + mesh.textureCoordinates[k + 1] * src.height + _texelOffset;
    }
    _vertices?.dispose();
    _vertices = Vertices.raw(
      VertexMode.triangles,
      positions,
      textureCoordinates: textureCoordinates,
      indices: mesh.indices,
    );
    verticesBuilds++;
    final bounds = mesh.bounds;
    _bounds = Rect.fromLTRB(
      bounds.left * scaleX - bleed,
      bounds.top * scaleY - bleed,
      bounds.right * scaleX - bleed,
      bounds.bottom * scaleY - bleed,
    );
  }
}
