import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flame_bloc_example/src/game/components/bullet.dart';
import 'package:flame_bloc_example/src/game/components/enemy.dart';
import 'package:flame_bloc_example/src/game/components/explosion.dart';
import 'package:flame_bloc_example/src/game/game.dart';
import 'package:flame_bloc_example/src/game_stats/bloc/game_stats_bloc.dart';
import 'package:flame_bloc_example/src/inventory/bloc/inventory_bloc.dart';
import 'package:flutter/services.dart';

class PlayerController extends Component
    with
        HasGameRef<SpaceShooterGame>,
        FlameBlocListenable<GameStatsBloc, GameStatsState> {
  @override
  bool listenWhen(GameStatsState previousState, GameStatsState newState) {
    return previousState.status != newState.status;
  }

  @override
  void onNewState(GameStatsState state) {
    if (state.status == GameStatus.respawn ||
        state.status == GameStatus.initial) {
      gameRef.statsBloc.add(const PlayerRespawned());
      parent?.add(gameRef.player = PlayerComponent());
    }
  }
}

class PlayerComponent extends SpriteAnimationComponent
    with
        HasGameRef<SpaceShooterGame>,
        CollisionCallbacks,
        KeyboardHandler,
        FlameBlocListenable<InventoryBloc, InventoryState> {
  bool destroyed = false;
  late Timer bulletCreator;

  PlayerComponent()
      : super(size: Vector2(50, 75), position: Vector2(100, 500)) {
    bulletCreator = Timer(0.5, repeat: true, onTick: _createBullet);

    add(RectangleHitbox());
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    animation = await gameRef.loadSpriteAnimation(
      'player.png',
      SpriteAnimationData.sequenced(
        stepTime: 0.2,
        amount: 4,
        textureSize: Vector2(32, 48),
      ),
    );
  }

  InventoryState? state;

  @override
  void onNewState(InventoryState state) {
    this.state = state;
  }

  void _createBullet() {
    final bulletX = x + 20;
    final bulletY = y + 20;

    gameRef.add(
      BulletComponent(
        bulletX,
        bulletY,
        state?.weapon ?? Weapon.bullet,
      ),
    );
  }

  void beginFire() {
    bulletCreator.start();
  }

  void stopFire() {
    bulletCreator.stop();
  }

  void move(double deltaX, double deltaY) {
    x += deltaX;
    y += deltaY;
  }

  @override
  void update(double dt) {
    super.update(dt);
    bulletCreator.update(dt);
    if (destroyed) {
      removeFromParent();
    }
  }

  void takeHit() {
    gameRef.add(ExplosionComponent(x, y));
    removeFromParent();
    gameRef.statsBloc.add(const PlayerDied());
  }

  @override
  bool onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (keysPressed.contains(LogicalKeyboardKey.tab)) {
      gameRef.inventoryBloc.add(const NextWeaponEquipped());
      return true;
    }
    return false;
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    super.onCollision(points, other);
    if (other is EnemyComponent) {
      takeHit();
      other.takeHit();
    }
  }
}
