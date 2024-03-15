import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/layers.dart';
import 'package:flutter/material.dart' hide Image, Draggable;
import 'package:flutter/services.dart';

const tileSize = 8.0;

class QuadTreeExample extends FlameGame
    with HasQuadTreeCollisionDetection, KeyboardEvents, ScrollDetector {
  QuadTreeExample();

  static const description = '''
In this example the standard "Sweep and Prune" algorithm is replaced by  
"Quad Tree". Quad Tree is often a more efficient approach of handling collisions,
its efficiency is shown especially on huge maps with big amounts of collidable 
components.
Some bricks are highlighted when placed on an edge of a quadrant. It is
important to understand that handling hitboxes on edges requires more
resources.
Blue lines visualize the quad tree's quadrant positions.

Use WASD to move the player and use the mouse scroll to change zoom.
Hold direction button and press space to fire a bullet. 
Notice that bullet will fly above water but collides with bricks.

Also notice that creating a lot of bullets at once leads to generating new
quadrants on the map since it becomes more than 25 objects in one quadrant.

Press O button to rescan the tree and optimize it, removing unused quadrants.

Press T button to toggle player to collide with other objects.
  ''';

  static const mapSize = 300;
  static const bricksCount = 8000;
  late final Player player;
  final staticLayer = StaticLayer();

  @override
  Future<void> onLoad() async {
    super.onLoad();

    const mapWidth = mapSize * tileSize;
    const mapHeight = mapSize * tileSize;
    initializeCollisionDetection(
      mapDimensions: const Rect.fromLTWH(0, 0, mapWidth, mapHeight),
      minimumDistance: 10,
    );

    final random = Random();
    final spriteBrick = await Sprite.load(
      'retro_tiles.png',
      srcPosition: Vector2.all(0),
      srcSize: Vector2.all(tileSize),
    );

    final spriteWater = await Sprite.load(
      'retro_tiles.png',
      srcPosition: Vector2(0, tileSize),
      srcSize: Vector2.all(tileSize),
    );

    for (var i = 0; i < bricksCount; i++) {
      final x = random.nextInt(mapSize);
      final y = random.nextInt(mapSize);
      final brick = Brick(
        position: Vector2(x * tileSize, y * tileSize),
        size: Vector2.all(tileSize),
        priority: 0,
        sprite: spriteBrick,
      );
      world.add(brick);
      staticLayer.components.add(brick);
    }

    staticLayer.reRender();
    camera = CameraComponent.withFixedResolution(
      world: world,
      width: 500,
      height: 250,
    );

    player = Player(
      position: Vector2.all(mapSize * tileSize / 2),
      size: Vector2.all(tileSize),
      priority: 2,
    );
    world.add(player);
    camera.follow(player);

    final brick = Brick(
      position: player.position.translated(0, -tileSize * 2),
      size: Vector2.all(tileSize),
      priority: 0,
      sprite: spriteBrick,
    );
    world.add(brick);
    staticLayer.components.add(brick);

    final water1 = Water(
      position: player.position.translated(0, tileSize * 2),
      size: Vector2.all(tileSize),
      priority: 0,
      sprite: spriteWater,
    );
    world.add(water1);

    final water2 = Water(
      position: player.position.translated(tileSize * 2, 0),
      size: Vector2.all(tileSize),
      priority: 0,
      sprite: spriteWater,
    );
    world.add(water2);

    final water3 = Water(
      position: player.position.translated(-tileSize * 2, 0),
      size: Vector2.all(tileSize),
      priority: 0,
      sprite: spriteWater,
    );
    world.add(water3);

    world.add(QuadTreeDebugComponent(collisionDetection));
    world.add(LayerComponent(staticLayer));
    camera.viewport.add(FpsTextComponent());
  }

  final elapsedMicroseconds = <double>[];

  final _playerDisplacement = Vector2.zero();
  var _fireBullet = false;

  static const stepSize = 1.0;

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    for (final key in keysPressed) {
      if (key == LogicalKeyboardKey.keyW && player.canMoveTop) {
        _playerDisplacement.setValues(0, -stepSize);
        player.position.translate(0, -stepSize);
      }
      if (key == LogicalKeyboardKey.keyA && player.canMoveLeft) {
        _playerDisplacement.setValues(-stepSize, 0);
        player.position.translate(-stepSize, 0);
      }
      if (key == LogicalKeyboardKey.keyS && player.canMoveBottom) {
        _playerDisplacement.setValues(0, stepSize);
        player.position.translate(0, stepSize);
      }
      if (key == LogicalKeyboardKey.keyD && player.canMoveRight) {
        _playerDisplacement.setValues(stepSize, 0);
        player.position.translate(stepSize, 0);
      }
      if (key == LogicalKeyboardKey.space) {
        _fireBullet = true;
      }
      if (key == LogicalKeyboardKey.keyT) {
        final collisionType = player.hitbox.collisionType;
        if (collisionType == CollisionType.active) {
          player.hitbox.collisionType = CollisionType.inactive;
        } else if (collisionType == CollisionType.inactive) {
          player.hitbox.collisionType = CollisionType.active;
        }
      }
      if (key == LogicalKeyboardKey.keyO) {
        collisionDetection.broadphase.tree.optimize();
      }
    }
    if (_fireBullet && !_playerDisplacement.isZero()) {
      final bullet = Bullet(
        position: player.position,
        displacement: _playerDisplacement * 50,
      );
      add(bullet);
      _playerDisplacement.setZero();
      _fireBullet = false;
    }

    return KeyEventResult.handled;
  }

  @override
  void onScroll(PointerScrollInfo info) {
    camera.viewfinder.zoom += info.scrollDelta.global.y.sign * 0.08;
    camera.viewfinder.zoom = camera.viewfinder.zoom.clamp(0.05, 5.0);
  }
}

//#region Player

class Player extends SpriteComponent
    with CollisionCallbacks, HasGameReference<QuadTreeExample> {
  Player({
    required super.position,
    required super.size,
    required super.priority,
  });

  bool canMoveLeft = true;
  bool canMoveRight = true;
  bool canMoveTop = true;
  bool canMoveBottom = true;
  final hitbox = RectangleHitbox();

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(
      'retro_tiles.png',
      srcSize: Vector2.all(tileSize),
      srcPosition: Vector2(tileSize * 3, tileSize),
    );

    add(hitbox);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    final myCenter =
        Vector2(position.x + tileSize / 2, position.y + tileSize / 2);
    if (other is GameCollidable) {
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

class Bullet extends PositionComponent with CollisionCallbacks, HasPaint {
  Bullet({required super.position, required this.displacement}) {
    paint.color = Colors.deepOrange;
    priority = 10;
    size = Vector2.all(1);
    add(RectangleHitbox());
  }

  final Vector2 displacement;

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset.zero, 1, paint);
  }

  @override
  void update(double dt) {
    final d = displacement * dt;
    position = Vector2(position.x + d.x, position.y + d.y);
    super.update(dt);
  }

  @override
  bool onComponentTypeCheck(PositionComponent other) {
    if (other is Player || other is Water) {
      return false;
    }
    return super.onComponentTypeCheck(other);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is Brick) {
      removeFromParent();
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}

//#endregion

//#region Environment

class Brick extends SpriteComponent
    with CollisionCallbacks, GameCollidable, UpdateOnce {
  Brick({
    required super.position,
    required super.size,
    required super.priority,
    required super.sprite,
  }) {
    initCenter();
    initCollision();
  }

  bool rendered = false;

  @override
  void renderTree(Canvas canvas) {
    if (!rendered) {
      super.renderTree(canvas);
    }
  }
}

class Water extends SpriteComponent
    with CollisionCallbacks, GameCollidable, UpdateOnce {
  Water({
    required super.position,
    required super.size,
    required super.priority,
    required super.sprite,
  }) {
    initCenter();
    initCollision();
  }
}

mixin GameCollidable on PositionComponent {
  void initCollision() {
    add(RectangleHitbox(collisionType: CollisionType.passive));
  }

  void initCenter() {
    cachedCenter =
        Vector2(position.x + tileSize / 2, position.y + tileSize / 2);
  }

  late final Vector2 cachedCenter;
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

class QuadTreeDebugComponent extends PositionComponent with HasPaint {
  QuadTreeDebugComponent(QuadTreeCollisionDetection cd) {
    dbg = QuadTreeNodeDebugInfo.init(cd);
    paint.color = Colors.blue;
    paint.style = PaintingStyle.stroke;
    priority = 10;
  }

  late final QuadTreeNodeDebugInfo dbg;

  final _boxPaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = Colors.lightGreenAccent
    ..strokeWidth = 1;

  @override
  void render(Canvas canvas) {
    final nodes = dbg.nodes;
    for (final node in nodes) {
      canvas.drawRect(node.rect, paint);
      final nodeElements = node.ownElements;

      final shouldPaint = !node.noChildren && nodeElements.isNotEmpty;
      for (final box in nodeElements) {
        if (shouldPaint) {
          canvas.drawRect(box.aabb.toRect(), _boxPaint);
        }
      }
    }
  }
}
//#endregion
