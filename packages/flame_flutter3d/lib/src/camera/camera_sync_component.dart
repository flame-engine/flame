/// [CameraSyncComponent] runs a [CameraSyncController] from Flame's own
/// game loop.
library;

import 'package:flame/components.dart';
import 'package:flame_flutter3d/src/camera/camera_sync_controller.dart';
import 'package:flame_flutter3d/src/host/bridge_priority.dart';
import 'package:flame_flutter3d/src/host/updates_at_root.dart';
import 'package:flame_flutter3d/src/transform/object3d_component.dart'
    show SyncDirection;

/// Calls [controller]'s [CameraSyncController.advance] once a frame, as a
/// Flame component.
///
/// **The one-line wrapper [CameraSyncController]'s doc leaves to the
/// caller, written once.** The controller stays a plain class, testable
/// without a game, and a host that already ticks it from
/// `Flutter3dFlameWidget.onTick` keeps doing that. This is for a game that
/// would rather order the sync among its components.
///
/// **Ordered after whatever moves the authoritative side, by default.**
/// Flame updates components by ascending priority. Flowing Flame to the
/// scene, the viewfinder is moved by Flame's own camera, following its
/// target after everything else, so this runs after that camera
/// ([BridgePriority.afterFlameCamera]); synced before it, the 3D camera
/// trailed `camera.follow()` by a frame. Flowing the scene to Flame, it runs
/// after the craft and before Flame's camera reads the viewfinder
/// ([BridgePriority.camera]).
///
/// **Wherever it is added.** A priority orders siblings only, and Flame's
/// camera is a sibling of the world, not of what is in it: added to the
/// world, where a game adds its components, this ran inside the world's
/// update, before the camera, whatever its number, and the 3D camera trailed
/// `camera.follow()` by a frame again — the lag the priority had been chosen
/// to remove. Flowing Flame to the scene, it syncs from the game's root
/// wherever it is added: see [UpdatesAtRoot].
final class CameraSyncComponent extends Component with UpdatesAtRoot {
  CameraSyncComponent({required this.controller, int? priority})
    : super(
        priority:
            priority ??
            switch (controller.direction) {
              SyncDirection.flameToScene => BridgePriority.afterFlameCamera,
              SyncDirection.sceneToFlame => BridgePriority.camera,
            },
      );

  /// The controller advanced every [update].
  final CameraSyncController controller;

  /// Only flowing Flame to the scene: the other way, it runs before Flame's
  /// camera, which inside the world it does anyway.
  @override
  bool get needsRoot => controller.direction == SyncDirection.flameToScene;

  @override
  void rootUpdate(double dt) => controller.advance(dt);
}
