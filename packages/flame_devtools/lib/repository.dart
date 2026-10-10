import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flame/devtools.dart';
import 'package:flame_devtools/behavior_tree_snapshot.dart';

abstract final class Repository() {
  static Future<ComponentTreeNode> getComponentTree() async {
    final componentTreeResponse = await serviceManager
        .callServiceExtensionOnMainIsolate(
          'ext.flame_devtools.getComponentTree',
        );
    return ComponentTreeNode.fromJson(
      componentTreeResponse.json!['component_tree'] as Map<String, dynamic>,
    );
  }

  static Future<Overlays> getOverlays() async {
    final overlaysResponse = await serviceManager
        .callServiceExtensionOnMainIsolate(
          'ext.flame_devtools.getOverlays',
        );
    return Overlays.fromJson(overlaysResponse.json!);
  }

  static Future<void> navigateToOverlay(String overlay) async {
    await serviceManager.callServiceExtensionOnMainIsolate(
      'ext.flame_devtools.navigateToOverlay',
      args: {'overlay': overlay},
    );
  }

  static Future<void> setOverlay(
    String overlay, {
    required bool active,
  }) async {
    await serviceManager.callServiceExtensionOnMainIsolate(
      'ext.flame_devtools.setOverlay',
      args: {'overlay': overlay, 'active': active.toString()},
    );
  }

  static Future<int> getComponentPriority({required int id}) async {
    final infoResponse = await serviceManager.callServiceExtensionOnMainIsolate(
      'ext.flame_devtools.getComponentInfo',
      args: {'id': id.toString()},
    );
    final attributes = infoResponse.json!['attributes'] as Map<String, dynamic>;
    return attributes['priority'] as int;
  }

  static Future<bool> swapDebugMode({int? id}) async {
    final nextDebugMode = !(await getDebugMode(id: id));
    await serviceManager.callServiceExtensionOnMainIsolate(
      'ext.flame_devtools.setDebugMode',
      args: {
        'debug_mode': nextDebugMode.toString(),
        if (id != null) 'id': id.toString(),
      },
    );
    return nextDebugMode;
  }

  static Future<bool> getDebugMode({int? id}) async {
    final debugModeResponse = await serviceManager
        .callServiceExtensionOnMainIsolate(
          'ext.flame_devtools.getDebugMode',
          args: {if (id != null) 'id': id.toString()},
        );
    return debugModeResponse.json!['debug_mode'] as bool;
  }

  // ignore: avoid_positional_boolean_parameters
  static Future<bool> setPaused(bool shouldPause) async {
    await serviceManager.callServiceExtensionOnMainIsolate(
      'ext.flame_devtools.setPaused',
      args: {'paused': shouldPause.toString()},
    );
    return shouldPause;
  }

  static Future<bool> getPaused() async {
    final getPausedResponse = await serviceManager
        .callServiceExtensionOnMainIsolate(
          'ext.flame_devtools.getPaused',
        );
    return getPausedResponse.json!['paused'] as bool;
  }

  static Future<double> step({required double stepTime}) async {
    final stepResponse = await serviceManager.callServiceExtensionOnMainIsolate(
      'ext.flame_devtools.step',
      args: {'step_time': stepTime.toString()},
    );
    return (stepResponse.json!['step_time'] as num).toDouble();
  }

  /// Gets the behavior tree of the component with the given [id], or null if
  /// the component does not have one.
  ///
  /// The service extension for this is registered by `flame_behavior_tree`, so
  /// it does not exist at all in games that do not use that package. That is
  /// not an error, those games simply have no behavior trees.
  static Future<BehaviorTreeSnapshot?> getBehaviorTree({
    required int id,
  }) async {
    try {
      final response = await serviceManager.callServiceExtensionOnMainIsolate(
        'ext.flame_devtools.getBehaviorTree',
        args: {'id': id.toString()},
      );
      final json = response.json!;
      if (json['hasBehaviorTree'] != true) {
        return null;
      }
      return BehaviorTreeSnapshot.fromJson(json);
    } on Exception {
      return null;
    }
  }

  static Future<String?> snapshot({required int id}) async {
    final snapshotResponse = await serviceManager
        .callServiceExtensionOnMainIsolate(
          'ext.flame_devtools.getComponentSnapshot',
          args: {'id': id.toString()},
        );
    return snapshotResponse.json!['snapshot'] as String?;
  }

  static Future<PositionComponentAttributes> getPositionComponentAttributes({
    required int id,
  }) async {
    final potentialPositionComponentResponse = await serviceManager
        .callServiceExtensionOnMainIsolate(
          'ext.flame_devtools.getPositionComponentAttributes',
          args: {'id': id.toString()},
        );

    return PositionComponentAttributes.fromJson(
      potentialPositionComponentResponse.json!,
    );
  }

  static Future<ImageCacheInfo> getImageCache() async {
    final imageCacheResponse = await serviceManager
        .callServiceExtensionOnMainIsolate(
          'ext.flame_devtools.getImageCache',
        );
    return ImageCacheInfo.fromJson(imageCacheResponse.json!);
  }

  /// Evicts the unused images in the game's image cache and returns the
  /// estimated number of bytes that were freed.
  static Future<int> evictUnusedImages() async {
    final evictResponse = await serviceManager
        .callServiceExtensionOnMainIsolate(
          'ext.flame_devtools.evictUnusedImages',
        );
    return evictResponse.json!['freed_bytes'] as int;
  }

  /// Sets the [attribute] of the component with the given [id], where
  /// `priority` can be set on any component and the other attributes only on
  /// position components.
  static Future<void> setComponentAttribute({
    required int id,
    required String attribute,
    required Object value,
  }) async {
    await serviceManager.callServiceExtensionOnMainIsolate(
      'ext.flame_devtools.setPositionComponentAttributes',
      args: {
        'id': id.toString(),
        'attribute': attribute,
        'value': value.toString(),
      },
    );
  }
}

class Overlays({
  required final List<String> registered,
  required final List<String> active,
}) {
  factory Overlays.fromJson(Map<String, dynamic> json) {
    return Overlays(
      registered: List<String>.from(json['overlays'] as List),
      active: List<String>.from(json['active'] as List),
    );
  }
}

class PositionComponentAttributes({
  required final double x,
  required final double y,
  required final double width,
  required final double height,
  required final double angle,
  required final double scaleX,
  required final double scaleY,
}) {
  factory PositionComponentAttributes.fromJson(Map<String, dynamic> json) {
    return PositionComponentAttributes(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      angle: (json['angle'] as num).toDouble(),
      scaleX: (json['scaleX'] as num).toDouble(),
      scaleY: (json['scaleY'] as num).toDouble(),
    );
  }
}
