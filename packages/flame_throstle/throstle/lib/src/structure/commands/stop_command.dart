import 'package:flame_yarn/src/structure/commands/command.dart';
import 'package:flame_yarn/src/yarn_project.dart';

class StopCommand extends Command {
  const StopCommand();

  @override
  void execute(YarnProject project) {
    project.stopNode();
  }
}
