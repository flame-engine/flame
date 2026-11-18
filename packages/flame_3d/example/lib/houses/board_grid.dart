import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_3d/components.dart';

/// The 2D ground of the board: a checkered grid of `cells` by `cells` cells,
/// drawn with the canvas where `projection` puts them.
///
/// It stands for the pre-rendered 2D art of a game; the 3D layer drawn above
/// it uses the same projection, so 3D objects stand exactly on its cells.
class BoardGrid({
  required int cells,
  required Scene3DProjection projection,
}) extends Component {
  this {
    Offset corner(int i, int j) {
      final point = projection.scenePointToLocal(
        Vector3(i.toDouble(), j.toDouble(), 0),
      );
      return Offset(point.x, point.y);
    }

    for (var i = 0; i < cells; i++) {
      for (var j = 0; j < cells; j++) {
        ((i + j).isEven ? _light : _dark).addPolygon([
          corner(i, j),
          corner(i + 1, j),
          corner(i + 1, j + 1),
          corner(i, j + 1),
        ], true);
      }
    }
    for (var k = 0; k <= cells; k++) {
      _lines
        ..moveTo(corner(k, 0).dx, corner(k, 0).dy)
        ..lineTo(corner(k, cells).dx, corner(k, cells).dy)
        ..moveTo(corner(0, k).dx, corner(0, k).dy)
        ..lineTo(corner(cells, k).dx, corner(cells, k).dy);
    }
  }

  final Path _light = Path();
  final Path _dark = Path();
  final Path _lines = Path();

  final Paint _lightPaint = Paint()..color = const Color(0xFF5E8C4A);
  final Paint _darkPaint = Paint()..color = const Color(0xFF527D40);
  final Paint _linePaint = Paint()
    ..color = const Color(0x66213318)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  @override
  void render(Canvas canvas) {
    canvas
      ..drawPath(_light, _lightPaint)
      ..drawPath(_dark, _darkPaint)
      ..drawPath(_lines, _linePaint);
  }
}
