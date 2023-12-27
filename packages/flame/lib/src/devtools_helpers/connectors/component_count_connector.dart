import 'dart:convert';
import 'dart:developer';

import 'package:flame/src/devtools_helpers/dev_tools_connector.dart';

/// The [ComponentCountConnector] is responsible for reporting the component
/// count of the game to the devtools extension.
class ComponentCountConnector extends DevToolsConnector {
  @override
  void init() {
    // Get the amount of components in the tree.
    registerExtension(
      'ext.flame_devtools.getComponentCount',
      (method, parameters) async {
        var componentCount = 0;
        game.propagateToChildren((p0) {
          componentCount++;
          return true;
        });

        return ServiceExtensionResponse.result(
          json.encode({
            'component_count': componentCount,
          }),
        );
      },
    );
  }
}
