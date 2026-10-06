import 'dart:math';
import 'dart:ui';

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

    Tap the screen to add more bodies, which alternate between flames and
    pizzas.
  ''';

  this
    : super(
        gravity: Vector2(0, 10.0),
        world: SpriteBodyWorld(showPieces: showPieces),
      );
}

/// A sprite, with its size in meters, with the aspect ratio of the sprite,
/// and the convex pieces of its outline, which all the bodies of that sprite
/// share, since tracing it reads back the pixels of the image.
typedef _Shape = ({Sprite sprite, Vector2 size, List<List<Vector2>> pieces});

class SpriteBodyWorld({bool showPieces = false})
    extends Forge2DWorld
    with TapCallbacks, HasGameRef<Forge2DGame> {
  /// The images of the bodies, which the taps go through in turn, with their
  /// widths in meters.
  static const images = {'flame.png': 8.0, 'pizza.png': 6.0, 'zap.png': 9.0};

  /// The shape of each of the [images].
  late final List<_Shape> _shapes;

  /// The number of bodies added by tapping, which picks the next shape.
  int _taps = 0;

  bool _showPieces = showPieces;

  /// Whether the convex pieces of the bodies are drawn, which applies to the
  /// bodies already added too.
  bool get showPieces => _showPieces;
  set showPieces(bool value) {
    _showPieces = value;
    for (final body in children.whereType<ContourBody>()) {
      body.renderBody = value;
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    gameRef.camera.viewport.add(FpsTextComponent(position: Vector2(8, 4)));
    addAll(createBoundaries(gameRef));
    _shapes = [
      for (final MapEntry(key: image, value: width) in images.entries)
        await _loadShape(image, width),
    ];
  }

  /// The shape of the [image], scaled to the [width] in meters.
  Future<_Shape> _loadShape(String image, double width) async {
    final sprite = await gameRef.loadSprite('assets/images/$image');
    final size = sprite.srcSize..scale(width / sprite.srcSize.x);
    final pieces = await ContourBody.piecesOf(
      sprite,
      size,
      gameRef.metersToPixels,
    );
    return (sprite: sprite, size: size, pieces: pieces);
  }

  @override
  void onTapDown(TapDownEvent info) {
    super.onTapDown(info);
    final shape = _shapes[_taps++ % _shapes.length];
    add(
      ContourBody(
        info.localPosition,
        sprite: shape.sprite,
        pieces: shape.pieces,
        size: shape.size,
      )..renderBody = showPieces,
    );
  }
}

/// A body that is drawn by a [sprite] of the given [size], in meters, and
/// collides as the convex [pieces] of its outline, which are drawn on top of
/// the [sprite] when [renderBody] is true.
class ContourBody(
  final Vector2 initialPosition, {
  required final Sprite sprite,
  required final List<List<Vector2>> pieces,
  required final Vector2 size,
}) extends BodyComponent with GlowingBody {
  this
    : super(
        paint: Paint()..color = ExampleColors.sky,
        renderBody: false,
      );

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
  double get outlineWidth => 0.05;

  // The sprite is drawn here rather than by a child, since the children are
  // drawn after the body, and the sprite would hide the pieces.
  @override
  void render(Canvas canvas) {
    sprite.render(canvas, size: size, anchor: Anchor.center);
    super.render(canvas);
  }

  @override
  Body createBody() {
    final shapeDef = ShapeDef(
      userData: this, // To be able to determine object in collision
      material: SurfaceMaterial(restitution: 0.4, friction: 0.5),
    );

    final angle = (initialPosition.x + initialPosition.y) / 2 * pi;
    final bodyDef = BodyDef(
      position: initialPosition,
      rotation: Rot.fromAngle(angle),
      angularVelocity: angle / 8,
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
