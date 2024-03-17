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
        return ServiceExtensionResponse.result(
          json.encode({
            'id': id,
            'debug_mode': _getDebugMode(id),
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
        final debugMode = bool.parse(parameters['debug_mode'] ?? 'false');
        _setDebugMode(debugMode, id: id);
        return ServiceExtensionResponse.result(
          json.encode({
            'id': id,
            'debug_mode': debugMode,
          }),
        );
      },
    );
  }

  bool _getDebugMode(int id) {
    var debugMode = false;
    game.propagateToChildren<Component>(
      (c) {
        if (c.hashCode == id) {
          debugMode = c.debugMode;
          return false;
        }
        return true;
      },
      includeSelf: true,
    );
    return debugMode;
  }

  void _setDebugMode(bool debugMode, {int? id}) {
    game.propagateToChildren<Component>(
      (c) {
        if (id == null) {
          c.debugMode = debugMode;
          return true;
        } else if (c.hashCode == id) {
          c.debugMode = debugMode;
          return false;
        }
        return true;
      },
      includeSelf: true,
    );
  }
}
