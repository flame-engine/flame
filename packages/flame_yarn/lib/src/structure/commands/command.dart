import 'package:flame_yarn/src/structure/statement.dart';
import 'package:flame_yarn/src/yarn_ball.dart';

abstract class Command extends Statement {
  const Command();

  void execute(YarnBall runtime);
}
