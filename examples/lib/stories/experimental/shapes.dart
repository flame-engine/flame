import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';

class ShapesExample extends FlameGame {
  static const description = '''
    This example shows multiple raw `Shape`s, and random points whose color
    should match the colors of the shapes that they fall in. Points that are
    outside of any shape should be grey.
  ''';

  @override
  Future<void> onLoad() async {
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
    ];
    const colors = [
      Color(0xFFFFFF88),
      Color(0xFFff88FF),
      Color(0xFF88FFFF),
      Color(0xFF88FF88),
      Color(0xFFaaaaFF),
      Color(0xFFFF8888),
    ];
    add(ShapesComponent(shapes, colors));
    add(DotsComponent(shapes, colors));
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
