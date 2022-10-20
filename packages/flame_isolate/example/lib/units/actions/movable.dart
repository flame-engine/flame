import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolates_example/colonists_game.dart';
import 'package:flutter_isolates_example/standard/int_vector2.dart';

enum MoveDirection {
  idle(isLeft: false), // 0
  up(isLeft: false), // 1
  down(isLeft: false), // 2
  upRight(isLeft: false), // 3
  right(isLeft: false), // 4
  downLeft(isLeft: true), // 5
  upLeft(isLeft: true), // 6
  left(isLeft: true), // 7
  downRight(isLeft: false); // 8

  final bool isLeft;

  const MoveDirection({
    required this.isLeft,
  });

  /// Returns the horizontally mirrored direction
  MoveDirection get mirrored {
    if (index >= 3 && index <= 5) {
      return MoveDirection.values[index + 3];
    }
    if (index >= 6 && index <= 8) {
      return MoveDirection.values[index - 3];
    }
    return this;
  }
}

mixin Movable on PositionComponent, HasGameRef<ColonistsGame> {
  double get speed;

  void reachedDestination();

  @override
  @mustCallSuper
  Future<void>? onLoad() {
    anchor = Anchor.center;
    return super.onLoad();
  }

  PathLine? pathLine;

  void _removePathLine() {
    pathLine?.getGone();
  }

  void _walkAlongPath(List<Vector2> path) {
    if (path.isEmpty) {
      setCurrentDirection(MoveDirection.idle);
      _removePathLine();
      // Reached last position, make available again
      reachedDestination();
      return;
    }

    final nextPoint = path.removeAt(0);

    final normalizedDirection = (nextPoint - position).normalized();
    normalizedDirection.round();
    setCurrentDirection(directions[normalizedDirection] ?? MoveDirection.idle);

    add(
      MoveToEffect(
        nextPoint,
        EffectController(speed: speed),
        onComplete: () => _walkAlongPath(path),
      ),
    );
  }

  void walkPath(List<IntVector2> path) {
    final absolutePath = path.map((e) {
      return gameRef.tileAtPosition(e.x, e.y).positionOfAnchor(Anchor.center);
    }).toList();

    _walkAlongPath(absolutePath);

    if (path.length > 2) {
      gameRef.add(pathLine = PathLine(absolutePath));
    }
  }

  void setCurrentDirection(MoveDirection direction);

  final Map<Vector2, MoveDirection> directions = {
    Vector2(0, 0): MoveDirection.idle,
    Vector2(0, -1): MoveDirection.up,
    Vector2(1, -1): MoveDirection.upRight,
    Vector2(1, 0): MoveDirection.right,
    Vector2(1, 1): MoveDirection.downRight,
    Vector2(0, 1): MoveDirection.down,
    Vector2(-1, 1): MoveDirection.downLeft,
    Vector2(-1, 0): MoveDirection.left,
    Vector2(-1, -1): MoveDirection.upLeft,
  };
}

class PathLine extends ShapeComponent with HasGameRef<ColonistsGame> {
  final Path path;

  PathLine(List<Vector2> path) : path = _toPath(path) {
    paint = Paint()
      ..color = const Color(0x30ffffff)
      ..style = PaintingStyle.stroke;
  }

  static Path _toPath(List<Vector2> points) {
    return Path()
      ..addPolygon(
        points.map((p) => p.toOffset()).toList(growable: false),
        false,
      );
  }

  void getGone() {
    parent?.remove(this);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawPath(path, paint);
    super.render(canvas);
  }
}
