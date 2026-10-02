import 'dart:convert';
import 'dart:developer';

import 'package:flame/src/devtools/dev_tools_connector.dart';

/// The [GameLoopConnector] is responsible for reporting and setting the
/// pause/running state of the game and stepping the game forwards or backwards
/// from the devtools extension.
class GameLoopConnector() extends DevToolsConnector {
  @override
  void init() {
    // Get whether the game is currently paused or not.
    registerExtension(
      'ext.flame_devtools.getPaused',
      (method, parameters) async {
        return ServiceExtensionResponse.result(
          json.encode({
            'paused': game.isPaused,
          }),
        );
      },
    );

    // Set whether the game should be paused or not.
    registerExtension(
      'ext.flame_devtools.setPaused',
      (method, parameters) async {
        final shouldPause = bool.tryParse(parameters['paused'] ?? '');
        if (shouldPause == null) {
          return ServiceExtensionResponse.error(
            ServiceExtensionResponse.invalidParams,
            'The paused parameter has to be true or false.',
          );
        }
        if (shouldPause) {
          game.pauseEngine();
        } else {
          game.resumeEngine();
        }
        return ServiceExtensionResponse.result(
          json.encode({
            'paused': shouldPause,
          }),
        );
      },
    );

    // Step the game loop forwards, or backwards with a negative step time,
    // which only works while the game is paused.
    registerExtension(
      'ext.flame_devtools.step',
      (method, parameters) async {
        final stepTime = double.tryParse(parameters['step_time'] ?? '');
        if (stepTime == null || !stepTime.isFinite) {
          return ServiceExtensionResponse.error(
            ServiceExtensionResponse.invalidParams,
            'The step_time parameter has to be a number.',
          );
        }
        if (!game.isPaused) {
          return ServiceExtensionResponse.error(
            ServiceExtensionResponse.extensionError,
            'The game has to be paused before it can be stepped.',
          );
        }
        game.stepEngine(stepTime: stepTime);
        return ServiceExtensionResponse.result(
          json.encode({
            'step_time': stepTime,
          }),
        );
      },
    );
  }
}
