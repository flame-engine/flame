import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flame_test/test_paths.dart';

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

/// The stroke paints of something that can be hovered and dragged.
///
/// Paints are expensive to create, so the three of them are created once
/// and picked by state with [forState] whenever they are needed.
class StatePaints {
  StatePaints({
    required Color normal,
    required Color hovered,
    required Color active,
  }) : normal = _stroke(normal),
       hovered = _stroke(hovered, 1.05),
       active = _stroke(active, 1.25);

  final Paint normal;
  final Paint hovered;
  final Paint active;

  Paint forState({required bool isDragging, required bool isHovering}) {
    if (isDragging) {
      return active;
    }
    return isHovering ? hovered : normal;
  }

  /// A hairline stroke, unless a [width] is given.
  static Paint _stroke(Color color, [double? width]) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke;
    if (width != null) {
      paint.strokeWidth = width;
    }
    return paint;
  }
}

final lightStrokes = StatePaints(
  normal: const Color(0x90ffffff),
  hovered: const Color(0xd0ffffff),
  active: const Color(0xe0ffffff),
);

final greenStrokes = StatePaints(
  normal: const Color(0xd000ff00),
  hovered: const Color(0xef00ff00),
  active: const Color(0xff00ff00),
);

final redStrokes = StatePaints(
  normal: const Color(0xd0ff0000),
  hovered: const Color(0xe0ff0000),
  active: const Color(0xffff0000),
);

Path randomPath(Size size) {
  return TestPaths.byIndex(_rnd.nextIntBetween(0, TestPaths.count), size);
}

PathComponent pathComponent(
  int index,
  Size size, {
  Vector2? position,
  Paint? paint,
  List<Paint>? paintLayers,
  Paint? contourPaint,
  bool? renderHitboxes,
  Anchor? anchor,
}) {
  // Create a standard test path that fits within our chosen size with its
  // original aspect ratio.
  final path = TestPaths.byIndex(index % TestPaths.count, size);
  return pathComponentWith(
    path,
    size,
    position: position,
    paint: paint ?? pathStroke,
    paintLayers: paintLayers,
    contourPaint: contourPaint,
    renderHitboxes: renderHitboxes,
    anchor: anchor,
  );
}

PathComponent pathComponentWith(
  Path srcPath,
  Size size, {
  bool resize = false,
  Vector2? position,
  Paint? paint,
  List<Paint>? paintLayers,
  Paint? contourPaint,
  bool? renderHitboxes,
  Anchor? anchor,
}) {
  // Adjust the path such that fits within our chosen size with its
  // original aspect ratio.
  final path = resize ? srcPath.resizeTo(size, keepRatio: true) : srcPath;

  // Create a component that displays the whole path: we filter all hitboxes
  // that are (approximately) fully enclosed in the largest one.
  return PathComponent(
    path: path,
    priority: shapePriority,
    position: position ?? Vector2.zero(),
    anchor: anchor ?? Anchor.center,
    paint: paint ?? pathStroke,
    paintLayers: paintLayers,
    hitboxesPaint: contourPaint,
    renderHitboxes: renderHitboxes ?? false,
  )..renderShape = true;
}
