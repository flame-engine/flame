import 'package:flame_yarn/src/structure/statement.dart';
import 'package:flame_yarn/src/yarn_project.dart';

abstract class Command extends Statement {
  const Command();

  void execute(YarnProject runtime);
}
