/// A bridge to the Flame 2D game engine.
///
/// Flame draws its own layer, flutter3d draws its own, and this package
/// keeps the two reconciled: transforms and lifecycle
/// ([Flutter3dFlameWidget], [BridgePlane], [Object3dComponent]), the actor
/// system ([ActorComponent], [ActorSystemComponent]), physics
/// ([RigidBodyComponent], [PhysicsStepComponent], [CollisionBridge]), input
/// ([FlameInputBridge]) and camera ([CameraSyncController],
/// [CameraSyncComponent], [ChaseCamera], [BridgeProjector]) and an endless
/// world built piece by piece ([ChunkStreamer]). The `flame_flutter3d`
/// stories in Flame's examples show one mechanism each.
library;

import 'package:flame_flutter3d/flame_flutter3d.dart'
    show
        Flutter3dFlameWidget,
        BridgePlane,
        Object3dComponent,
        ActorComponent,
        ActorSystemComponent,
        RigidBodyComponent,
        PhysicsStepComponent,
        CollisionBridge,
        FlameInputBridge,
        CameraSyncController,
        CameraSyncComponent,
        ChaseCamera,
        BridgeProjector,
        ChunkStreamer;

export 'src/animation/model_animation_component.dart';
export 'src/camera/camera_sync_component.dart';
export 'src/camera/camera_sync_controller.dart';
export 'src/camera/chase_camera.dart';
export 'src/camera/projected_viewfinder.dart';
export 'src/camera/view_camera.dart';
export 'src/debug/hitboxes3d.dart';
export 'src/ecs/actor_component.dart';
export 'src/ecs/actor_system_component.dart';
export 'src/ecs/instanced_actor_component.dart';
export 'src/host/bridge_clock.dart';
export 'src/host/bridge_priority.dart';
export 'src/host/flutter3d_flame_widget.dart';
export 'src/host/has_fixed_step.dart';
export 'src/host/has_flutter3d.dart';
export 'src/host/step_clock.dart';
export 'src/host/transparent_flame_game.dart';
export 'src/host/updates_at_root.dart';
export 'src/input/flame_input_bridge.dart';
export 'src/input/taps3d.dart';
export 'src/particles/particles3d_component.dart';
export 'src/physics/character_body_component.dart';
export 'src/physics/collider_registry.dart';
export 'src/physics/collision_bridge.dart';
export 'src/physics/kinematic_body_component.dart';
export 'src/physics/physics_step_component.dart';
export 'src/physics/rigid_body_component.dart';
export 'src/transform/billboard_atlas.dart';
export 'src/transform/bridge_space.dart';
export 'src/transform/bridged3d.dart';
export 'src/transform/instanced_object3d_component.dart';
export 'src/transform/node3d_component.dart';
export 'src/transform/object3d_component.dart';
export 'src/transform/plane.dart';
export 'src/transform/projector.dart';
export 'src/transform/sprite_billboard_component.dart';
export 'src/world/atmosphere_component.dart';
export 'src/world/cell_grid_component.dart';
export 'src/world/chunk_streamer.dart';
export 'src/world/fixture_visuals_component.dart';
export 'src/world/grid_mover.dart';
export 'src/world/tiled_world.dart';
export 'src/world/trail_component.dart';
export 'src/world/wrap_space.dart';
