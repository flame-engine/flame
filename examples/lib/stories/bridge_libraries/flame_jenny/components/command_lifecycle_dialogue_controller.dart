import 'dart:async';

import 'package:examples/stories/bridge_libraries/flame_jenny/components/dialogue_controller_component.dart';
import 'package:jenny/jenny.dart';

class CommandLifecycleDialogueController extends DialogueControllerComponent {
  CommandLifecycleDialogueController({
    required this.onCommandOverride,
    required this.onCommandFinishOverride,
  });
  final FutureOr<void> Function(UserDefinedCommand command) onCommandOverride;
  final FutureOr<void> Function(UserDefinedCommand command)
      onCommandFinishOverride;

  @override
  FutureOr<void> onCommand(UserDefinedCommand command) async {
    await onCommandOverride(command);
    return super.onCommand(command);
  }

  @override
  FutureOr<void> onCommandFinish(UserDefinedCommand command) async {
    await onCommandFinishOverride(command);
    return super.onCommandFinish(command);
  }
}
