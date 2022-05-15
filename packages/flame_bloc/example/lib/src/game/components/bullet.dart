import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_bloc_example/src/game/components/enemy.dart';
import 'package:flame_bloc_example/src/game/game.dart';
import 'package:flame_bloc_example/src/inventory/bloc/inventory_bloc.dart';

class BulletComponent extends SpriteAnimationComponent
    with HasGameRef<SpaceShooterGame>, CollisionCallbacks {
  static const bulletSpeed = -500;

  bool destroyed = false;

  double xDirection;

  final Weapon weapon;

  BulletComponent(
    double x,
    double y,
    this.weapon, {
    this.xDirection = 0.0,
  }) : super(position: Vector2(x, y)) {
    size = Vector2(_mapWidth(), 20);

    add(RectangleHitbox());
  }

  double _mapWidth() {
    switch (weapon) {
      case Weapon.bullet:
        return 10;
      case Weapon.laser:
      case Weapon.plasma:
        return 5;
    }
  }

  String _mapSpritePath() {
    switch (weapon) {
      case Weapon.bullet:
        return 'bullet.png';
      case Weapon.laser:
        return 'laser.png';
      case Weapon.plasma:
        return 'plasma.png';
    }
  }

  double _mapSpriteWidth() {
    switch (weapon) {
      case Weapon.bullet:
        return 8;
      case Weapon.laser:
      case Weapon.plasma:
        return 4;
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    animation = await gameRef.loadSpriteAnimation(
      _mapSpritePath(),
      SpriteAnimationData.sequenced(
        stepTime: 0.2,
        amount: 4,
        textureSize: Vector2(_mapSpriteWidth(), 16),
      ),
    );
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    super.onCollision(points, other);
    if (other is EnemyComponent) {
      destroyed = true;
      other.takeHit();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    y += bulletSpeed * dt;
    if (xDirection != 0) {
      x += bulletSpeed * dt * xDirection;
    }

    if (destroyed || toRect().bottom <= 0) {
      removeFromParent();
    }
  }
}
