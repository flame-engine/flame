import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:examples/commons/paths.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart' show Aabb2Extension, PathExtension;
import 'package:flame/game.dart';
import 'package:flame/palette.dart';

class ShapesExample extends FlameGame {
  static const description = '''
    This example shows multiple raw `Shape`s, and random points whose color
    should match the colors of the shapes that they fall in. Points that are
    outside of any shape should be grey.
  ''';

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    const flameSize = Size(200, 200);
    final flame = randomPath(flameSize).shift(const Offset(300, 350));
    final contours = flame.contours;
    final polygons = [
      for (var index = 0; index < contours.length; ++index)
        Polygon.fromPath(flame, contour: index),
    ];
    final disjoint = _findDisjoint(polygons);
    final disjointColor = BasicPalette.lightOrange.color;
    final overlapColor = BasicPalette.yellow.color.withValues(alpha: 0.8);
    final shapes = [
      Circle(Vector2(50, 30), 20),
      Circle(Vector2(700, 500), 50),
      Rectangle.fromLTRB(100, 30, 260, 100),
      RoundedRectangle.fromLTRBR(40, 300, 120, 550, 30),
      Polygon([Vector2(10, 70), Vector2(180, 200), Vector2(220, 150)]),
      Polygon([
        Vector2(400, 160),
        Vector2(550, 400),
        Vector2(710, 350),
        Vector2(540, 170),
        Vector2(710, 100),
        Vector2(710, 320),
        Vector2(730, 315),
        Vector2(750, 60),
        Vector2(590, 30),
      ]),
      ...polygons,
    ];
    final colors = [
      const Color(0xFFFFFF88),
      const Color(0xFFff88FF),
      const Color(0xFF88FFFF),
      const Color(0xFF88FF88),
      const Color(0xFFaaaaFF),
      const Color(0xFFFF8888),
      for (final isDisjoint in disjoint)
        if (isDisjoint) disjointColor else overlapColor,
    ];
    add(ShapesComponent(shapes, colors));
    add(DotsComponent(shapes, colors));
    add(FpsTextComponent(position: Vector2(8, size.y - 24), priority: 1));
  }

  List<bool> _findDisjoint(List<Polygon> polygons) {
    if (polygons.length < 2) {
      return polygons.isEmpty ? [] : [true];
    }
    // Sort the polygons by size: we will use the largest area
    // in order to approximate full inclusion.
    polygons.sortBy((polygon) => (polygon.aabb.max - polygon.aabb.min).length2);
    final largest = polygons.last;
    final area = largest.aabb.toRect();

    return polygons
        .map((element) {
          if (element == largest) {
            return true;
          }
          final bounds = element.aabb.toRect();
          return area.expandToInclude(bounds) != area;
        })
        .toList(growable: false);
  }
}

class ShapesComponent extends Component {
  ShapesComponent(this.shapes, List<Color> colors)
    : assert(
        shapes.length == colors.length,
        'The shapes and colors lists have to be of the same length',
      ),
      paints = colors
          .map(
            (color) => Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1
              ..color = color,
          )
          .toList();

  final List<Shape> shapes;
  final List<Paint> paints;

  @override
  void render(Canvas canvas) {
    for (var i = 0; i < shapes.length; i++) {
      canvas.drawPath(shapes[i].asPath(), paints[i]);
    }
  }
}

class DotsComponent extends Component {
  DotsComponent(this.shapes, this.shapeColors)
    : assert(
        shapes.length == shapeColors.length,
        'The shapes and shapeColors lists have to be of the same length',
      );

  final List<Shape> shapes;
  final List<Color> shapeColors;

  final Random random = Random();
  final List<Vector2> points = [];
  final List<Color> pointColors = [];
  static const pointSize = 3;

  @override
  void update(double dt) {
    generatePoint();
  }

  void generatePoint() {
    final point = Vector2(
      random.nextDouble() * 800,
      random.nextDouble() * 600,
    );
    points.add(point);
    pointColors.add(const Color(0xff444444));
    for (var i = 0; i < shapes.length; i++) {
      if (shapes[i].containsPoint(point)) {
        pointColors.last = shapeColors[i];
        break;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    const d = pointSize / 2;
    final paint = Paint();
    for (var i = 0; i < points.length; i++) {
      final x = points[i].x;
      final y = points[i].y;
      paint.color = pointColors[i];
      canvas.drawRect(Rect.fromLTRB(x - d, y - d, x + d, y + d), paint);
    }
  }
}
