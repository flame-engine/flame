import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flame/devtools.dart';

sealed class Repository {
  Repository._();

  static Future<int> getComponentCount() async {
    final componentCountResponse =
        await serviceManager.callServiceExtensionOnMainIsolate(
      'ext.flame_devtools.getComponentCount',
    );
    return componentCountResponse.json!['component_count'] as int;
  }

  static Future<ComponentTreeNode> getComponentTree() async {
    final componentTreeResponse =
        await serviceManager.callServiceExtensionOnMainIsolate(
      'ext.flame_devtools.getComponentTree',
    );
    return ComponentTreeNode.fromJson(
      componentTreeResponse.json!['component_tree'] as Map<String, dynamic>,
    );
  }

  static Future<bool> swapDebugMode() async {
    final nextDebugMode = !(await getDebugMode());
    await serviceManager.callServiceExtensionOnMainIsolate(
      'ext.flame_devtools.setDebugMode',
      args: {'debug_mode': nextDebugMode},
    );
    return nextDebugMode;
  }

  static Future<bool> getDebugMode() async {
    final debugModeResponse =
        await serviceManager.callServiceExtensionOnMainIsolate(
      'ext.flame_devtools.getDebugMode',
    );
    return debugModeResponse.json!['debug_mode'] as bool;
  }

  // ignore: avoid_positional_boolean_parameters
  static Future<bool> setPaused(bool shouldPause) async {
    await serviceManager.callServiceExtensionOnMainIsolate(
      'ext.flame_devtools.setPaused',
      args: {'paused': shouldPause},
    );
    return shouldPause;
  }

  static Future<bool> getPaused() async {
    final getPausedResponse =
        await serviceManager.callServiceExtensionOnMainIsolate(
      'ext.flame_devtools.getPaused',
    );
    return getPausedResponse.json!['paused'] as bool;
  }

  static Future<double> step({required double stepTime}) async {
    final stepResponse = await serviceManager.callServiceExtensionOnMainIsolate(
      'ext.flame_devtools.step',
      args: {'step_time': stepTime.toString()},
    );
    return stepResponse.json!['step_time'] as double;
  }
}
