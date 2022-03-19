import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/services.dart';

import './bullet.dart';
import '../../game_stats/bloc/game_stats_bloc.dart';
import '../../inventory/bloc/inventory_bloc.dart';
import '../game.dart';
import 'enemy.dart';
import 'explosion.dart';

class PlayerController extends Component
    with
        HasGameRef<SpaceShooterGame>,
        BlocComponent<GameStatsBloc, GameStatsState> {
  @override
  bool listenWhen(GameStatsState? previousState, GameStatsState newState) {
    return previousState?.status != newState.status;
  }

  @override
  void onNewState(GameStatsState state) {
    if (state.status == GameStatus.respawn ||
        state.status == GameStatus.initial) {
      gameRef.read<GameStatsBloc>().add(const PlayerRespawned());
      gameRef.add(gameRef.player = PlayerComponent());
    }
  }
}

class PlayerComponent extends SpriteAnimationComponent
    with
        HasGameRef<SpaceShooterGame>,
        CollisionCallbacks,
        KeyboardHandler,
        BlocComponent<InventoryBloc, InventoryState> {
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
    gameRef.read<GameStatsBloc>().add(const PlayerDied());
  }

  @override
  bool onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (keysPressed.contains(LogicalKeyboardKey.tab)) {
      gameRef.read<InventoryBloc>().add(const NextWeaponEquipped());
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
