import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/layers.dart';
import 'package:flutter/material.dart' hide Image, Draggable;
import 'package:flutter/services.dart';

//#region Game
class QuadTreeExample extends FlameGame
    with HasQuadTreeCollisionDetection, KeyboardEvents, ScrollDetector {
  QuadTreeExample();

  static const description = '''
In this example the standard "Sweep and Prune" algorithm is replaced by  
"Quad Tree". Quad Tree is more effective approach to handle collisions, it's 
effectivity reveals especially on huge maps with big amount of collideable 
components.
  ''';

  static const tileSize = 8;
  static const mapSize = 300;
  static const bricksCount = 8000;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final mapWidth = (mapSize * tileSize).toDouble();
    final mapHeight = (mapSize * tileSize).toDouble();
    initCollisionDetection(
      mapDimensions: Rect.fromLTWH(0, 0, mapWidth, mapHeight),
      minimumDistance: 10,
    );

    final random = Random();
    final sprite = await Sprite.load(
      'retro_tiles.png',
      srcPosition: Vector2.all(0),
      srcSize: Vector2.all(8),
    );
    for (var i = 0; i < bricksCount; i++) {
      final x = random.nextInt(mapSize);
      final y = random.nextInt(mapSize);
      final brick = Brick(
        position: Vector2(x.toDouble() * tileSize, y.toDouble() * tileSize),
        size: Vector2.all(8),
        priority: 0,
        sprite: sprite,
      );
      add(brick);
      staticLayer.components.add(brick);
    }

    staticLayer.reRender();
    camera.viewport = FixedResolutionViewport(Vector2(500, 250));
    final playerPoint = Vector2.all(mapSize * tileSize / 2);

    final player =
        Player(position: playerPoint, size: Vector2.all(8), priority: 2);
    add(player);
    this.player = player;
    camera.followComponent(player);

    add(LayerComponent(staticLayer));
    add(FpsTextComponent());
    camera.zoom = 1;
  }

  final elapsedMicroseconds = <double>[];

  late Player player;
  final staticLayer = StaticLayer();
  bool firstRender = true;
  static const stepSize = 1.0;

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    for (final key in keysPressed) {
      if (key == LogicalKeyboardKey.keyW && player.canMoveTop) {
        player.position = player.position.translate(0, -stepSize);
      }
      if (key == LogicalKeyboardKey.keyA && player.canMoveLeft) {
        player.position = player.position.translate(-stepSize, 0);
      }
      if (key == LogicalKeyboardKey.keyS && player.canMoveBottom) {
        player.position = player.position.translate(0, stepSize);
      }
      if (key == LogicalKeyboardKey.keyD && player.canMoveRight) {
        player.position = player.position.translate(stepSize, 0);
      }
    }

    return KeyEventResult.handled;
  }

  @override
  void onScroll(PointerScrollInfo info) {
    camera.zoom += info.scrollDelta.game.y.sign * 0.08;
    camera.zoom = camera.zoom.clamp(0.05, 5.0);
  }
}

//#endregion

//#region Player

class Player extends SpriteComponent
    with
        CollisionCallbacks,
        HasGameRef<QuadTreeExample>,
        HasQuadTreeController<QuadTreeExample> {
  Player({
    required super.position,
    required super.size,
    required super.priority,
  }) {
    Sprite.load(
      'retro_tiles.png',
      srcSize: Vector2.all(8),
      srcPosition: Vector2(24, 8),
    ).then((value) {
      sprite = value;
    });

    add(RectangleHitbox());
  }

  bool canMoveLeft = true;
  bool canMoveRight = true;
  bool canMoveTop = true;
  bool canMoveBottom = true;

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    final myCenter = Vector2(position.x + 4, position.y + 4);
    if (other is Brick) {
      final diffX = myCenter.x - other.cachedCenter.x;
      if (diffX < 0) {
        canMoveRight = false;
      } else if (diffX > 0) {
        canMoveLeft = false;
      }

      final diffY = myCenter.y - other.cachedCenter.y;
      if (diffY < 0) {
        canMoveBottom = false;
      } else if (diffY > 0) {
        canMoveTop = false;
      }
      final newPos = Vector2(position.x + diffX / 3, position.y + diffY / 3);
      position = newPos;
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    canMoveLeft = true;
    canMoveRight = true;
    canMoveTop = true;
    canMoveBottom = true;
    super.onCollisionEnd(other);
  }
}

//#endregion

//#region Brick

class Brick extends SpriteComponent
    with
        CollisionCallbacks,
        HasQuadTreeController<QuadTreeExample>,
        UpdateOnce {
  Brick({
    required super.position,
    required super.size,
    required super.priority,
    required super.sprite,
  }) {
    add(RectangleHitbox()..collisionType = CollisionType.passive);
    cachedCenter = Vector2(position.x + 4, position.y + 4);
  }

  late final Vector2 cachedCenter;
  bool rendered = false;

  @override
  void renderTree(Canvas canvas) {
    if (!rendered) {
      super.renderTree(canvas);
    }
  }
}

//#endregion

//#region Utils

mixin UpdateOnce on PositionComponent {
  bool updateOnce = true;

  @override
  void updateTree(double dt) {
    if (updateOnce) {
      super.updateTree(dt);
      updateOnce = false;
    }
  }
}

class StaticLayer extends PreRenderedLayer {
  StaticLayer();

  List<PositionComponent> components = [];

  @override
  void drawLayer() {
    for (final element in components) {
      if (element is Brick) {
        element.rendered = false;
        element.renderTree(canvas);
        element.rendered = true;
      }
    }
  }
}

class LayerComponent extends PositionComponent {
  LayerComponent(this.layer);

  StaticLayer layer;

  @override
  void render(Canvas canvas) {
    layer.render(canvas);
  }
}

extension Vector2Ext on Vector2 {
  Vector2 translate(double x, double y) {
    return Vector2(this.x + x, this.y + y);
  }
}

//#endregion
