import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flame_test/test_paths.dart';

class CollidableSvgPathsExample() extends FlameGame with HasCollisionDetection {
  static const description = '''
    Simple example with four spinning random SVG files moving similarly to
    the bird sprites in the animated collision example: here, the hitboxes
    follow the SVG path contours. When two SVG files collide they swap their
    velocities, while they turn back when they hit the walls.
  ''';

  /// The [TestPaths] with a corresponding SVG file in `assets/svgs/`.
  static const _svgNames = [
    'flame',
    'invader1',
    'invader2',
    'invader3',
    'clover',
    'abstract',
    'alien1',
    'alien2',
    'setup',
    'recycle',
  ];

  @override
  Future<void> onLoad() async {
    camera.viewport.add(FpsTextComponent(position: Vector2(8, 4)));

    final names = (_svgNames.toList()..shuffle()).take(4).toList();

    add(ScreenHitbox());
    const componentWidth = 150.0;
    // Top left component
    add(
      CollidableSvgPathsComponent(
        names[0],
        Vector2.all(200),
        componentWidth * 2 / 3,
        position: Vector2.all(100),
      ),
    );
    // Bottom right component
    add(
      CollidableSvgPathsComponent(
        names[1],
        Vector2(-100, -100),
        componentWidth / 2,
        position: size.clone()..sub(Vector2.all(200)),
      ),
    );
    // Bottom left component
    add(
      CollidableSvgPathsComponent(
        names[2],
        Vector2(100, -100),
        componentWidth,
        position: Vector2(100, size.y - 100),
        angle: pi / 4,
      ),
    );
    // Top right component
    add(
      CollidableSvgPathsComponent(
        names[3],
        Vector2(-300, 300),
        componentWidth / 3,
        position: Vector2(size.x - 100, 100),
        angle: pi / 4,
      ),
    );
  }
}

/// An SVG file called [name] in `assets/svgs/`, keeping its aspect ratio
/// but [svgWidth] wide moving with the given [velocity].
///
/// When it collides with another [CollidableSvgPathsComponent] the two swap
/// their velocities, and when it hits the walls of the screen it turns back.
class CollidableSvgPathsComponent(
  final String name,
  final Vector2 velocity,
  final double svgWidth, {
  required Vector2 position,
  double angle = -pi / 4,
}) extends PositionComponent with CollisionCallbacks {
  this
    : super(
        position: position,
        angle: angle,
        anchor: Anchor.center,
      );

  /// The largest change to the direction of the initial [velocity].
  static const _maxTurn = 12 * pi / 180;
  static final _random = Random();

  late final SvgPaths _svg;
  late final Rect _area;

  @override
  Future<void> onLoad() async {
    // Turn the velocity by a random angle, keeping its magnitude.
    velocity.rotate((_random.nextDouble() * 2 - 1) * _maxTurn);
    _svg = await SvgPaths.fromFile('assets/svgs/$name.svg');
    _area = _svg.bounds;
    size = _area.size.toVector2()..scale(svgWidth / _area.width);
    add(SvgPathsHitbox.fromSvg(_svg, size));
    add(RotateEffect.by(tau, EffectController(duration: 3, infinite: true)));
  }

  @override
  void render(Canvas canvas) {
    _svg.render(canvas, size, area: _area);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
  }

  @override
  void onCollisionStart(
    List<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is CollidableSvgPathsComponent) {
      _bounceOff(other);
    } else if (other is ScreenHitbox) {
      _bounceOffWalls(other, intersectionPoints);
    }
  }

  /// Bounces this component off the [other] one like in an elastic collision
  /// between two bodies with the same mass, where they swap their velocities.
  ///
  /// [onCollisionStart] is called for both components of a collision in no
  /// particular order, so we must ensure that the velocities are swapped
  /// only once per collision.
  void _bounceOff(CollidableSvgPathsComponent other) {
    // The velocity of this component as seen from the other one.
    final relativeVelocity = velocity - other.velocity;
    final towardsOther = other.absoluteCenter - absoluteCenter;
    if (relativeVelocity.dot(towardsOther) <= 0) {
      // The two components are already moving apart, which is always the
      // case for the second call.
      return;
    }
    final previousVelocity = velocity.clone();
    velocity.setFrom(other.velocity);
    other.velocity.setFrom(previousVelocity);
  }

  /// Turns this component back when it hits the walls of the [screen] at the
  /// [intersectionPoints], unless it is already moving away from them.
  ///
  /// A component can start a new collision with a wall while it is moving
  /// away from it: since it keeps spinning, one of its corners can leave the
  /// wall right after a bounce and then touch it again, or a component that
  /// touches a wall can get a velocity pointing away from it by colliding
  /// with another component.
  void _bounceOffWalls(ScreenHitbox screen, List<Vector2> intersectionPoints) {
    if (velocity.dot(_towardsWalls(screen, intersectionPoints)) > 0) {
      velocity.negate();
    }
  }

  /// The direction of the walls of the [screen] that the [intersectionPoints]
  /// are on: for example `(-1, 0)` for the left wall, or `(1, -1)` for the
  /// top right corner, where the points are on two walls.
  Vector2 _towardsWalls(ScreenHitbox screen, List<Vector2> intersectionPoints) {
    final towards = Vector2.zero();
    for (final point in intersectionPoints) {
      if (point.x <= 1) {
        towards.x = -1;
      } else if (point.x >= screen.size.x - 1) {
        towards.x = 1;
      }
      if (point.y <= 1) {
        towards.y = -1;
      } else if (point.y >= screen.size.y - 1) {
        towards.y = 1;
      }
    }
    return towards;
  }
}
