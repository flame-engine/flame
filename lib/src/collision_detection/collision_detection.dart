import 'dart:math' as math;

import '../components/mixins/collidable.dart';
import '../../extensions.dart';
import 'line_segment.dart';

/// Check whether any [Collidable] in [collidables] collide with each other
/// or [screenSize] (if defined), and call callbacks accordingly
void collisionDetection(List<Collidable> collidables, {Vector2 screenSize}) {
  print("=================================");
  for (int x = 0; x < collidables.length - 1; x++) {
    final collidableX = collidables[x];
    for (int y = x + 1; y < collidables.length; y++) {
      final collidableY = collidables[y];
      final points =
          hitboxIntersections(collidableX.hitbox, collidableY.hitbox);
      if (points.isNotEmpty) {
        print("booom");
        collidableX.collisionCallback(points, collidableY);
        collidableY.collisionCallback(points, collidableX);
      }
    }

    if (screenSize != null && collidableX.hasScreenCollision) {
      final intersectionPoints =
          hitboxSizeIntersections(collidableX.hitbox, screenSize);
      if (intersectionPoints.isNotEmpty) {
        print("kabooom $intersectionPoints");
        collidableX.screenCollisionCallback(intersectionPoints);
      }
    }
  }
}

/// Returns the intersection points of the [hitboxA] and [hitboxB]
/// The two hitboxes are required to be convex
/// If they share a segment of a line, both end points and the center point of
/// that line segment will be counted as collision points
Set<Vector2> hitboxIntersections(List<Vector2> hitboxA, List<Vector2> hitboxB) {
  assert(
    hitboxA.isNotEmpty && hitboxB.isNotEmpty,
    "Both hitboxes need to have elements",
  );
  final intersectionPoints = <Vector2>{};

  int a = 0;
  int b = 0;
  var segmentA = LineSegment(hitboxA[a], hitboxA[(a + 1) % hitboxA.length]);
  var segmentB = LineSegment(hitboxB[b], hitboxB[(b + 1) % hitboxB.length]);
  var lineA = segmentA.toLine();
  var lineB = segmentB.toLine();

  // Advance point if it isn't already at where it started
  void advance(bool isA) {
    if ((isA || b == hitboxB.length) && a != hitboxA.length) {
      a++;
      segmentA = LineSegment(
        hitboxA[a % hitboxA.length],
        hitboxA[(a + 1) % hitboxA.length],
      );
      lineA = segmentA.toLine();
    } else if (b != hitboxB.length) {
      b++;
      segmentB = LineSegment(
        hitboxB[b % hitboxB.length],
        hitboxB[(b + 1) % hitboxB.length],
      );
      lineB = segmentB.toLine();
    }
  }

  void advanceA() => advance(true);
  void advanceB() => advance(false);

  void advanceOutsideLine() {
    if (segmentA.isOutside(hitboxB)) {
      print("advance outside A");
      advanceA();
    } else {
      print("advance outside B");
      advanceB();
    }
  }

  bool isADone = false;
  bool isBDone = false;
  while (!(isADone && isBDone)) {
    isADone = a == hitboxA.length;
    isBDone = b == hitboxB.length;
    print("A: $segmentA");
    print("B: $segmentB");
    if (segmentB.pointsAt(lineA)) {
      if (segmentB.pointsAt(lineB)) {
        // Both lines point at each other, advance outside line
        print("advance outside line");
        advanceOutsideLine();
      } else {
        // The ray formed by the B points are pointing at [lineA]
        print("advance B");
        advanceB();
      }
    } else if (segmentA.pointsAt(lineB)) {
      // The ray formed by the X points are pointing at [lineA]
      print("advance A");
      advanceA();
    } else {
      // The lines are not pointing towards each other, advance the outside one
      // and check for an intersection
      final intersection = segmentA.intersections(segmentB);
      if (intersection.isNotEmpty) {
        print("intersection!");
        intersectionPoints.addAll(intersection);
      }
      print("Advance outside line because they are not pointing at each other");
      advanceOutsideLine();
    }
  }
  return intersectionPoints;
}

/// Checks whether the [hitbox] represented by the list of [Vector2] contains
/// the [point].
bool containsPoint(Vector2 point, List<Vector2> hitbox) {
  for (int i = 0; i < hitbox.length; i++) {
    final previousNode = hitbox[i];
    final node = hitbox[(i + 1) % hitbox.length];
    final isOutside = (node.x - previousNode.x) * (point.y - previousNode.y) -
            (point.x - previousNode.x) * (node.y - previousNode.y) >
        0;
    if (isOutside) {
      // Point is outside of convex polygon
      return false;
    }
  }
  return true;
}

// Rotates the [point] with [radians] around [position]
Vector2 rotatePoint(Vector2 point, double radians, Vector2 position) {
  return Vector2(
    math.cos(radians) * (point.x - position.x) -
        math.sin(radians) * (point.y - position.y) +
        position.x,
    math.sin(radians) * (point.x - position.x) +
        math.cos(radians) * (point.y - position.y) +
        position.y,
  );
}

/// Returns where the hitbox edges of the [hitbox] intersects the box
/// defined by [size] (usually the screen size).
Set<Vector2> hitboxSizeIntersections(List<Vector2> hitbox, Vector2 size) {
  final screenBounds = [
    Vector2(0, 0),
    Vector2(size.x, 0),
    size,
    Vector2(0, size.y),
  ];
  final intersectionPoints = <Vector2>{};
  for (int i = 0; i < hitbox.length; ++i) {
    final hitboxSegment = LineSegment(
      hitbox[i],
      hitbox[(i + 1) % hitbox.length],
    );
    for (int j = 0; j < screenBounds.length; ++j) {
      final screenSegment = LineSegment(
        screenBounds[j],
        screenBounds[(j + 1) % screenBounds.length],
      );
      intersectionPoints.addAll(hitboxSegment.intersections(screenSegment));
    }
  }
  return intersectionPoints;
}
