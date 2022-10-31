import 'package:jenny/src/structure/statement.dart';
import 'package:jenny/src/yarn_project.dart';

abstract class Command extends Statement {
  const Command();

  void execute(YarnProject project);
}
