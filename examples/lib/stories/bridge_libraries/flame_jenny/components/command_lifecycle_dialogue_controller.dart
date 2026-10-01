import 'dart:async';

import 'package:examples/stories/bridge_libraries/flame_jenny/components/dialogue_controller_component.dart';
import 'package:jenny/jenny.dart';

class CommandLifecycleDialogueController({
  required final FutureOr<void> Function(UserDefinedCommand command)
  onCommandOverride,
  required final FutureOr<void> Function(UserDefinedCommand command)
  onCommandFinishOverride,
}) extends DialogueControllerComponent {
  @override
  FutureOr<void> onCommand(UserDefinedCommand command) async {
    await onCommandOverride(command);
    await super.onCommand(command);
  }

  @override
  FutureOr<void> onCommandFinish(UserDefinedCommand command) async {
    await onCommandFinishOverride(command);
    await super.onCommandFinish(command);
  }
}
