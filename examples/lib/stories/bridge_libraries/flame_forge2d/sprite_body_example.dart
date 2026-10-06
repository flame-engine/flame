import 'dart:math';

import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boundaries.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/style.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/geometry.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class SpriteBodyExample({bool showPieces = false})
    extends Forge2DExampleGame
    with HasGameRef<Forge2DExampleGame> {
  static const String description = '''
    In this example we show how to add a sprite on top of a `BodyComponent`
    whose shape follows the outline of the sprite.

    The outline is traced from the pixels of the image that are not
    transparent, with `Sprite.contour`, and the body collides as its convex
    pieces, which the Show pieces knob draws.

    Tap the screen to add more flames.
  ''';

  this
    : super(
        gravity: Vector2(0, 10.0),
        world: SpriteBodyWorld(showPieces: showPieces),
      );
}

class SpriteBodyWorld({bool showPieces = false})
    extends Forge2DWorld
    with TapCallbacks, HasGameRef<Forge2DGame> {
  /// The width of the flames, in meters.
  static const flameWidth = 8.0;

  late final Sprite _sprite;

  /// The size of the flames, in meters, with the aspect ratio of the
  /// [_sprite].
  late final Vector2 _size;

  /// The convex pieces of the outline of the [_sprite], which all the
  /// flames share, since tracing it reads back the pixels of the image.
  late final List<List<Vector2>> _pieces;

  bool _showPieces = showPieces;

  /// Whether the convex pieces of the flames are drawn, which applies to the
  /// flames already added too.
  bool get showPieces => _showPieces;
  set showPieces(bool value) {
    _showPieces = value;
    for (final flame in children.whereType<FlameBody>()) {
      flame.renderBody = value;
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    gameRef.camera.viewport.add(FpsTextComponent(position: Vector2(8, 4)));
    addAll(createBoundaries(gameRef));
    _sprite = await gameRef.loadSprite('assets/images/flame.png');
    _size = _sprite.srcSize..scale(flameWidth / _sprite.srcSize.x);
    _pieces = await FlameBody.piecesOf(
      _sprite,
      _size,
      gameRef.metersToPixels,
    );
  }

  @override
  void onTapDown(TapDownEvent info) {
    super.onTapDown(info);
    add(
      FlameBody(
        info.localPosition,
        sprite: _sprite,
        pieces: _pieces,
        size: _size,
      )..renderBody = showPieces,
    );
  }
}

/// A body that is drawn by a [sprite] of the given [size], in meters, and
/// collides as the convex [pieces] of its outline.
class FlameBody(
  final Vector2 initialPosition, {
  required final Sprite sprite,
  required final List<List<Vector2>> pieces,
  required final Vector2 size,
}) extends BodyComponent {
  this : super(renderBody: false);

  /// The linear slop of Box2D in meters, as `Tolerances.linearSlop` with the
  /// default length units, which is not used here as it needs the native
  /// library: the points of a polygon closer than 4 times it are welded, and
  /// the ones closer than twice it to an edge are dropped, see
  /// `b2ComputeHull`.
  static const linearSlop = 0.005;

  /// The convex pieces of the outline of the [sprite], drawn with the given
  /// [size] in meters, relative to its center.
  ///
  /// The outline is traced in pixels rather than in meters, with [pixels] per
  /// meter, so that the default sampling of the polygons of a
  /// [PathComponent] follows it closely. The parts of the sprite that are
  /// apart give separate polygons, and so separate pieces.
  static Future<List<List<Vector2>>> piecesOf(
    Sprite sprite,
    Vector2 size,
    double pixels,
  ) async {
    final pixelSize = size * pixels;
    final outline = await sprite.contour(size: pixelSize);
    // The outline is relative to the top left corner of the sprite, while the
    // pieces are relative to its center.
    final center = pixelSize / 2;
    return [
      for (final polygon in PathComponent.polygonsOf(outline))
        ...convexPieces(
          [for (final vertex in polygon) (vertex - center) / pixels],
          minDistance: 4 * linearSlop,
          minWidth: 2 * linearSlop,
        ),
    ];
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(SpriteComponent(sprite: sprite, size: size, anchor: Anchor.center));
  }

  @override
  Body createBody() {
    final shapeDef = ShapeDef(
      userData: this, // To be able to determine object in collision
      material: SurfaceMaterial(restitution: 0.4, friction: 0.5),
    );

    final bodyDef = BodyDef(
      position: initialPosition,
      rotation: Rot.fromAngle((initialPosition.x + initialPosition.y) / 2 * pi),
      type: BodyType.dynamic,
    );
    final body = world.createBody(bodyDef);
    for (final piece in pieces) {
      body.createShape(Polygon(piece), shapeDef);
    }
    return body;
  }
}

class Pizza(
  final Vector2 initialPosition, {
  Vector2? size,
}) extends BodyComponent {
  final Vector2 size = size ?? Vector2(2, 3);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final sprite = await gameRef.loadSprite('assets/images/pizza.png');
    renderBody = false;
    add(
      SpriteComponent(
        sprite: sprite,
        size: size,
        anchor: Anchor.center,
      ),
    );
  }

  @override
  Body createBody() {
    final vertices = [
      Vector2(-size.x / 2, size.y / 2),
      Vector2(size.x / 2, size.y / 2),
      Vector2(0, -size.y / 2),
    ];

    final shapeDef = ShapeDef(
      userData: this, // To be able to determine object in collision
      material: SurfaceMaterial(restitution: 0.4, friction: 0.5),
    );

    final bodyDef = BodyDef(
      position: initialPosition,
      rotation: Rot.fromAngle((initialPosition.x + initialPosition.y) / 2 * pi),
      type: BodyType.dynamic,
    );
    return world.createBody(bodyDef)..createShape(Polygon(vertices), shapeDef);
  }
}
