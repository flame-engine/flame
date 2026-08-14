import 'dart:math';
import 'dart:ui';

import 'package:examples/stories/bridge_libraries/flame_forge2d/sprite_body_example.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/style.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class DominoExample extends Forge2DExampleGame {
  static const description = '''
    The classic domino tower: vertical dominoes carry horizontal ones as
    planks, level by level, with braces at the edges.

    The tower stands on its own until you tap the screen, which drops a pizza
    that topples it.
  ''';

  DominoExample()
    : super(
        gravity: Vector2(0, 10.0),
        world: DominoExampleWorld(),
        metersToPixels: 24,
      );
}

class DominoExampleWorld extends Forge2DWorld
    with TapCallbacks, HasGameReference<Forge2DGame> {
  static const dominoWidth = 0.2;
  static const dominoHeight = 1.0;
  static const baseCount = 12;

  int _tint = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(Ground());
    _buildTower();

    // Frame the tower, which is built upwards from the ground at y = 0.
    game.camera.viewfinder.position = Vector2(0, -towerHeight / 2);
  }

  /// How tall the finished tower is, in world units.
  static double get towerHeight =>
      dominoHeight * 0.5 + (dominoHeight + 2 * dominoWidth) * (baseCount - 1);

  /// Adds a domino [height] above the ground, standing up or lying down.
  void _addDomino(
    double x,
    double height, {
    required bool horizontal,
    required double density,
  }) {
    add(
      Domino(
        // The tower is built upwards, which is the negative y direction.
        initialPosition: Vector2(x, -height),
        horizontal: horizontal,
        density: density,
        color: ExampleColors.dynamicColor(_tint++),
      ),
    );
  }

  void _buildTower() {
    var density = 10.0;

    for (var i = 0; i < baseCount; i++) {
      final x = i * 1.5 * dominoHeight - 1.5 * dominoHeight * baseCount / 2;
      _addDomino(x, dominoHeight / 2, horizontal: false, density: density);
      _addDomino(
        x,
        dominoHeight + dominoWidth / 2,
        horizontal: true,
        density: density,
      );
    }

    for (var level = 1; level < baseCount; level++) {
      if (level > 3) {
        density *= 0.8;
      }
      final height =
          dominoHeight * 0.5 + (dominoHeight + 2 * dominoWidth) * 0.99 * level;
      final count = baseCount - level;
      for (var i = 0; i < count; i++) {
        final x = i * 1.5 * dominoHeight - 1.5 * dominoHeight * count / 2;
        // The braces at both ends of a level are heavier, which is what
        // keeps the tower standing.
        density *= 2.5;
        if (i == 0) {
          _addDomino(
            x - 1.25 * dominoHeight + 0.5 * dominoWidth,
            height - dominoWidth,
            horizontal: false,
            density: density,
          );
        }
        if (i == count - 1) {
          _addDomino(
            x + 1.25 * dominoHeight - 0.5 * dominoWidth,
            height - dominoWidth,
            horizontal: false,
            density: density,
          );
        }
        density /= 2.5;

        _addDomino(x, height, horizontal: false, density: density);
        _addDomino(
          x,
          height + 0.5 * (dominoWidth + dominoHeight),
          horizontal: true,
          density: density,
        );
        _addDomino(
          x,
          height - 0.5 * (dominoWidth + dominoHeight),
          horizontal: true,
          density: density,
        );
      }
    }
  }

  @override
  void onTapDown(TapDownEvent info) {
    final position = info.localPosition;
    add(Pizza(position));
  }
}

class Domino extends BodyComponent with GlowingBody {
  Domino({
    required this.initialPosition,
    required this.horizontal,
    required this.density,
    required Color color,
  }) {
    paint = Paint()..color = color;
  }

  /// Where the domino starts out; [position] tracks the live body position.
  final Vector2 initialPosition;
  final bool horizontal;
  final double density;

  @override
  double get outlineWidth => 0.04;

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: BodyType.dynamic,
      position: initialPosition,
      rotation: horizontal ? Rot.fromAngle(pi / 2) : const Rot.identity(),
    );
    return world.createBody(bodyDef)..createShape(
      Polygon.box(
        DominoExampleWorld.dominoWidth / 2,
        DominoExampleWorld.dominoHeight / 2,
      ),
      // The default material is what a domino wants: plenty of grip and no
      // bounce. With less friction the tower shakes itself apart as soon as
      // the frame rate dips.
      ShapeDef(density: density),
    );
  }
}

class Ground extends BodyComponent with GlowingBody {
  Ground() {
    paint = Paint()..color = ExampleColors.slate;
  }

  @override
  Body createBody() {
    // The top of the ground is at y = 0, which the tower is built up from.
    final bodyDef = BodyDef(position: Vector2(0, 1));
    return world.createBody(bodyDef)..createShape(Polygon.box(24, 1));
  }
}
