import 'dart:math';
import 'dart:ui';

import 'package:examples/commons/path_component.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flame_test/flame_test.dart';

final _rnd = Random();

const shapePriority = 1;

final whiteStroke = Paint()
  ..color = const Color(0xffffffff)
  ..style = PaintingStyle.stroke;

final pathStroke = Paint()
  ..color = BasicPalette.blue.color
  ..style = PaintingStyle.stroke
  ..strokeWidth = 3
  ..strokeCap = .round
  ..strokeJoin = .bevel;

final lightStroke = Paint()
  ..color = const Color(0x90ffffff)
  ..style = PaintingStyle.stroke;

final hoveredLightStroke = Paint()
  ..color = const Color(0xd0ffffff)
  ..style = PaintingStyle.stroke
  ..strokeWidth = 1.05;

final activeLightStroke = Paint()
  ..color = const Color(0xe0ffffff)
  ..style = PaintingStyle.stroke
  ..strokeWidth = 1.25;

final greenStroke = Paint()
  ..color = const Color(0xd000ff00)
  ..style = PaintingStyle.stroke;

final hoveredGreenStroke = Paint()
  ..color = const Color(0xef00ff00)
  ..style = PaintingStyle.stroke
  ..strokeWidth = 1.05;

final activeGreenStroke = Paint()
  ..color = const Color(0xff00ff00)
  ..style = PaintingStyle.stroke
  ..strokeWidth = 1.25;

final redStroke = Paint()
  ..color = const Color(0xd0ff0000)
  ..style = PaintingStyle.stroke;

final hoveredRedStroke = Paint()
  ..color = const Color(0xe0ff0000)
  ..style = PaintingStyle.stroke
  ..strokeWidth = 1.05;

final activeRedStroke = Paint()
  ..color = const Color(0xffff0000)
  ..style = PaintingStyle.stroke
  ..strokeWidth = 1.25;

Path randomPath(Size size) {
  return TestPaths.byIndex(_rnd.nextIntBetween(0, TestPaths.count), size);
}

PathComponent pathComponent(
  int index,
  Size size, {
  Vector2? position,
  Paint? paint,
  Paint? contourPaint,
  bool? renderHitboxes,
  Anchor? anchor,
}) {
  // Create a standard test path with our chosen size but the original
  // aspect ratio; this is centered by default.
  final path = TestPaths.byIndex(index % TestPaths.count, size);

  // Create a component that displays the whole path: we filter all hitboxes
  // that are (approximately) fully enclosed in the largest one.
  return PathComponent(
    path: path,
    priority: shapePriority,
    position: position ?? Vector2.zero(),
    size: size.toVector2(),
    anchor: anchor,
    paint: paint ?? pathStroke,
    hitboxesPaint: contourPaint,
    renderHitboxes: renderHitboxes ?? false,
  )..renderShape = true;
}
