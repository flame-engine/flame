import 'dart:convert';
import 'dart:developer';

import 'package:flame/components.dart';
import 'package:flame/src/devtools/dev_tools_connector.dart';

/// The [DebugModeConnector] is responsible for reporting and setting the
/// `debugMode` of the game from the devtools extension.
class DebugModeConnector extends DevToolsConnector {
  @override
  void init() {
    // Get the `debugMode` for a component in the tree.
    // If no id is provided, the `debugMode` for the entire game will be
    // returned.
    registerExtension(
      'ext.flame_devtools.getDebugMode',
      (method, parameters) async {
        final id = int.tryParse(parameters['id'] ?? '') ?? game.hashCode;
        final component = findComponent<Component>(id);
        if (component == null) {
          return _unknownComponent(parameters['id']);
        }
        return ServiceExtensionResponse.result(
          json.encode({
            'id': id,
            'debug_mode': component.debugMode,
          }),
        );
      },
    );

    // Set the `debugMode` for a component in the tree.
    // If no id is provided, the `debugMode` will be set for the entire game.
    registerExtension(
      'ext.flame_devtools.setDebugMode',
      (method, parameters) async {
        final id = int.tryParse(parameters['id'] ?? '');
        final debugMode = bool.tryParse(parameters['debug_mode'] ?? '');
        if (debugMode == null) {
          return ServiceExtensionResponse.error(
            ServiceExtensionResponse.invalidParams,
            'The debug_mode parameter has to be true or false.',
          );
        }
        if (id == null) {
          game.propagateToChildren<Component>(
            (c) {
              c.debugMode = debugMode;
              return true;
            },
            includeSelf: true,
          );
        } else {
          final component = findComponent<Component>(id);
          if (component == null) {
            return _unknownComponent(parameters['id']);
          }
          component.debugMode = debugMode;
        }
        return ServiceExtensionResponse.result(
          json.encode({
            'id': id,
            'debug_mode': debugMode,
          }),
        );
      },
    );
  }

  static ServiceExtensionResponse _unknownComponent(String? id) {
    return ServiceExtensionResponse.error(
      ServiceExtensionResponse.invalidParams,
      'No component with the id $id was found.',
    );
  }
}
