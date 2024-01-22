import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_isolate_example/colonists_game.dart';
import 'package:flame_isolate_example/constants.dart';
import 'package:flame_isolate_example/objects/colonists_object.dart';
import 'package:flame_isolate_example/standard/int_vector2.dart';
import 'package:flame_isolate_example/standard/pair.dart';
import 'package:flame_isolate_example/units/actions/movable.dart';

class Worker extends SpriteAnimationGroupComponent<MoveDirection>
    with ColonistsObject, HasGameReference<ColonistsGame>, Movable {
  @override
  final double speed;

  Worker(num x, num y, {this.speed = 50}) {
    super.y = y * Constants.tileSize;
    super.x = x * Constants.tileSize;
    height = Constants.tileSize;
    width = Constants.tileSize;
    current = MoveDirection.idle;
    anchor = Anchor.center;

    final downRightAnimation = getSpriteAnimation(5);
    animations = {
      MoveDirection.idle: SpriteAnimation.spriteList(
        // Use the second frame from down-right animation
        [downRightAnimation.frames[1].sprite],
        stepTime: 1,
      ),
      MoveDirection.up: getSpriteAnimation(0),
      MoveDirection.upRight: getSpriteAnimation(7),
      MoveDirection.right: getSpriteAnimation(6),
      MoveDirection.downRight: downRightAnimation,
      MoveDirection.down: getSpriteAnimation(4),
      MoveDirection.upLeft: getSpriteAnimation(1),
      MoveDirection.left: getSpriteAnimation(2),
      MoveDirection.downLeft: getSpriteAnimation(3),
    };
  }

  SpriteAnimation getSpriteAnimation(int row) {
    return SpriteAnimation.fromFrameData(
      Flame.images.fromCache('ant_walk.png'),
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.1,
        textureSize: Vector2(64, 64),
        amountPerRow: 4,
        texturePosition: Vector2(0, 64.0 * row),
      ),
    );
  }

  @override
  void setCurrentDirection(MoveDirection direction) {
    current = direction;
  }

  Pair<StaticColonistsObject, List<IntVector2>>? _currentTask;

  bool get isIdle => _currentTask == null;

  @override
  void reachedDestination() => _currentTask = null;

  void issueWork(StaticColonistsObject objectToMove, List<IntVector2> path) {
    walkPath(path);
    _currentTask = Pair(objectToMove, path);
  }

  @override
  IntVector2 tileSize = const IntVector2(1, 1);
}
