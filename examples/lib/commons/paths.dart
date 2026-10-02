import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
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
class InteractiveStatePaints({
  required Color normal,
  required Color hovered,
  required Color active,
}) {
  final Paint normal = _stroke(normal);
  final Paint hovered = _stroke(hovered, 1.05);
  final Paint active = _stroke(active, 1.25);

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

final lightStrokes = InteractiveStatePaints(
  normal: const Color(0x90ffffff),
  hovered: const Color(0xd0ffffff),
  active: const Color(0xe0ffffff),
);

final greenStrokes = InteractiveStatePaints(
  normal: const Color(0xd000ff00),
  hovered: const Color(0xef00ff00),
  active: const Color(0xff00ff00),
);

final redStrokes = InteractiveStatePaints(
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
  bool? filter,
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
    filter: filter,
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
  bool? filter,
  Anchor? anchor,
}) {
  // Adjust the path such that fits within our chosen size with its
  // original aspect ratio.
  final path = resize ? srcPath.resizeTo(size, keepRatio: true) : srcPath;

  // The hitbox follows the same path as the component, so that the component
  // collides and reacts to gestures as a whole. By default, the polygons that
  // lie inside of the largest one are left out of both.
  final hitbox = PathHitbox(path: path, filter: filter ?? true);
  if (renderHitboxes ?? false) {
    hitbox
      ..renderShape = true
      ..paint = contourPaint ?? whiteStroke;
  }
  return PathComponent(
    path: path,
    priority: shapePriority,
    position: position ?? Vector2.zero(),
    anchor: anchor ?? Anchor.center,
    paint: paint ?? pathStroke,
    paintLayers: paintLayers,
    filter: filter ?? true,
    children: [hitbox],
  );
}
