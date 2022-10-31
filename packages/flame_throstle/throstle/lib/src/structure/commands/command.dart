import 'package:throstle/src/structure/statement.dart';
import 'package:throstle/src/yarn_project.dart';

abstract class Command extends Statement {
  const Command();

  void execute(YarnProject project);
}
