import 'package:jenny/src/structure/commands/command.dart';
import 'package:jenny/src/yarn_project.dart';

class StopCommand extends Command {
  const StopCommand();

  @override
  void execute(YarnProject project) {
    project.stopNode();
  }
}
