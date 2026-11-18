import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flame/components.dart' show Component;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/model.dart';
import 'package:flame_3d/resources.dart' as flame_3d;
import 'package:flame_3d/src/parser/gltf/camera.dart' as gltf_cam;
import 'package:flame_3d/src/parser/gltf/camera_type.dart';
import 'package:flame_3d/src/parser/gltf/glb_chunk.dart';
import 'package:flame_3d/src/parser/gltf/gltf_extensions.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';
import 'package:flame_3d/src/parser/gltf/node.dart';
import 'package:flame_3d/src/parser/model_parser.dart';

/// Camera configuration extracted from a glTF camera node by [SceneLoader3D].
class LoadedCamera3D({
  required final int nodeIndex,
  required final int cameraIndex,
  required final String? name,
  required final CameraProjection projection,
  required final Vector3 position,
  required final Quaternion rotation,
  required final Vector3 target,
  required final Vector3 up,
  required final double fovYDegrees,
  required final double? orthographicHeight,
  required final double near,
  required final double far,
  required final double? aspectRatio,
}) {
  /// Instantiates a [CameraComponent3D] matching this glTF camera node.
  CameraComponent3D toCameraComponent({World3D? world}) {
    return CameraComponent3D(
      world: world,
      projection: projection,
      position: position.clone(),
      rotation: rotation.clone(),
      target: target.clone(),
      up: up.clone(),
      fovY: fovYDegrees,
      orthographicHeight: orthographicHeight,
      near: near,
      far: far,
    );
  }
}

/// Metadata context passed to [SceneLoader3D]'s `onNodeExtras` callback for
/// every glTF node carrying custom `extras` properties.
class LoadedNodeContext3D({
  required final int nodeIndex,
  required final String? name,
  required final Object extras,
  required final Map<String, Object?>? extensions,
  required final Matrix4 localTransform,
  required final Matrix4 worldTransform,
  required final Vector3 worldPosition,
  required final Quaternion worldRotation,
  required final Vector3 worldScale,
  final Component3D? spawnedComponent,
}) {
  /// Typed map view when [extras] is a JSON object, or `null`.
  Map<String, Object?>? get extrasMap =>
      extras is Map<String, Object?> ? extras as Map<String, Object?> : null;

  /// Gameplay components registered by `onNodeExtras` to be mounted alongside
  /// the loaded scene.
  final List<Component> customComponents = [];

  /// Queues [component] so [LoadedScene3D.mountInto] adds it to the target
  /// [World3D].
  void addComponent(Component component) {
    customComponents.add(component);
  }
}

/// Complete 3D scene assembled by [SceneLoader3D] from a glTF 2.0 / GLB asset.
class LoadedScene3D({
  required final List<LightComponent> lights,
  required final List<LoadedCamera3D> cameras,
  required final List<InstancedGroup3D> instancedGroups,
  required final List<MeshComponent> staticMeshes,
  required final List<ModelComponent> models,
  required final List<Component> customComponents,
}) {
  /// Every mountable component produced for this scene (`lights`,
  /// `instancedGroups`, `staticMeshes`, `models`, and `customComponents`).
  List<Component> get allComponents => [
    ...lights,
    ...instancedGroups,
    ...staticMeshes,
    ...models,
    ...customComponents,
  ];

  /// Mounts all spawned lights, instanced batches, static meshes, animated
  /// models, and custom `extras` components into [world].
  void mountInto(World3D world) {
    final all = allComponents;
    if (all.isNotEmpty) {
      world.addAll(all);
    }
  }
}

class _StaticPlacement({
  required final int nodeIndex,
  required final Matrix4 worldMatrix,
  required final bool fromGpuInstancing,
});

class _PendingExtrasCall({
  required final int nodeIndex,
  required final Node node,
  required final Matrix4 localTransform,
  required final Matrix4 worldTransform,
});

/// High-level glTF 2.0 / GLB scene loader that turns a [GltfRoot] into a
/// ready-to-mount [LoadedScene3D] with punctual lights, cameras, coalesced
/// [InstancedGroup3D] batches, animated [ModelComponent]s, and custom `extras`
/// hooks.
abstract final class SceneLoader3D() {
  /// Loads a `.glb` or `.gltf` asset path via `Flame.assets` into a
  /// [LoadedScene3D].
  static Future<LoadedScene3D> loadAsset(
    String filePath, {
    int? sceneIndex,
    bool autoBatchStaticMeshes = true,
    void Function(LoadedNodeContext3D ctx)? onNodeExtras,
  }) async {
    if (filePath.endsWith('.glb')) {
      final root = await ModelParser.glb.parseRoot(filePath);
      return fromRoot(
        root,
        sceneIndex: sceneIndex,
        autoBatchStaticMeshes: autoBatchStaticMeshes,
        onNodeExtras: onNodeExtras,
      );
    }
    if (filePath.endsWith('.gltf')) {
      final root = await ModelParser.gltf.parseGltf(filePath);
      return fromRoot(
        root,
        sceneIndex: sceneIndex,
        autoBatchStaticMeshes: autoBatchStaticMeshes,
        onNodeExtras: onNodeExtras,
      );
    }
    final model = await ModelParser.parse(filePath);
    return LoadedScene3D(
      lights: const [],
      cameras: const [],
      instancedGroups: const [],
      staticMeshes: const [],
      models: [ModelComponent(model: model)],
      customComponents: const [],
    );
  }

  /// Parses an in-memory `.glb` byte buffer into a [LoadedScene3D].
  static Future<LoadedScene3D> loadGlbBytes(
    Uint8List bytes, {
    String prefix = '',
    int? sceneIndex,
    bool autoBatchStaticMeshes = true,
    void Function(LoadedNodeContext3D ctx)? onNodeExtras,
  }) async {
    final glb = ModelParser.glb.parseGlbBytes(bytes, prefix: prefix);
    final root = await glb.parse();
    return fromRoot(
      root,
      sceneIndex: sceneIndex,
      autoBatchStaticMeshes: autoBatchStaticMeshes,
      onNodeExtras: onNodeExtras,
    );
  }

  /// Parses an in-memory glTF 2.0 JSON map (and optional binary [chunks]) into
  /// a [LoadedScene3D].
  static Future<LoadedScene3D> loadGltfJson(
    Map<String, dynamic> json, {
    String prefix = '',
    List<GlbChunk> chunks = const [],
    int? sceneIndex,
    bool autoBatchStaticMeshes = true,
    void Function(LoadedNodeContext3D ctx)? onNodeExtras,
  }) async {
    final root = await GltfRoot.from(
      prefix: prefix,
      json: json,
      chunks: chunks,
    );
    return fromRoot(
      root,
      sceneIndex: sceneIndex,
      autoBatchStaticMeshes: autoBatchStaticMeshes,
      onNodeExtras: onNodeExtras,
    );
  }

  /// Builds a [LoadedScene3D] from an already parsed [GltfRoot].
  static LoadedScene3D fromRoot(
    GltfRoot root, {
    int? sceneIndex,
    bool autoBatchStaticMeshes = true,
    void Function(LoadedNodeContext3D ctx)? onNodeExtras,
  }) {
    final activeSceneIdx = sceneIndex ?? root.scene;
    if (root.scenes.isEmpty ||
        activeSceneIdx < 0 ||
        activeSceneIdx >= root.scenes.length) {
      return LoadedScene3D(
        lights: const [],
        cameras: const [],
        instancedGroups: const [],
        staticMeshes: const [],
        models: const [],
        customComponents: const [],
      );
    }

    final scene = root.scenes[activeSceneIdx];

    // 1. Identify nodes participating in skeletal skinning or keyframe
    //    animations.
    final directDynamicNodes = <int>{};
    for (final anim in root.animations) {
      for (final ch in anim.channels) {
        directDynamicNodes.add(ch.target.node.index);
      }
    }
    for (var idx = 0; idx < root.nodes.length; idx++) {
      final n = root.nodes[idx];
      if (n.skin != null) {
        directDynamicNodes.add(idx);
      }
      final meshRef = n.mesh;
      if (meshRef != null &&
          meshRef.get().primitives.any((p) => p.targets.isNotEmpty)) {
        directDynamicNodes.add(idx);
      }
    }
    for (final skin in root.skins) {
      for (final joint in skin.joints) {
        directDynamicNodes.add(joint.index);
      }
    }

    final parentByNode = <int, int>{};
    for (var i = 0; i < root.nodes.length; i++) {
      for (final child in root.nodes[i].children) {
        parentByNode[child.index] = i;
      }
    }

    bool allMeshDescendantsDynamic(int idx) {
      final n = root.nodes[idx];
      if (n.mesh != null && !directDynamicNodes.contains(idx)) {
        return false;
      }
      for (final c in n.children) {
        if (!allMeshDescendantsDynamic(c.index)) {
          return false;
        }
      }
      return true;
    }

    bool hasDynamicDescendant(int idx) {
      if (directDynamicNodes.contains(idx)) {
        return true;
      }
      for (final c in root.nodes[idx].children) {
        if (hasDynamicDescendant(c.index)) {
          return true;
        }
      }
      return false;
    }

    bool shouldSpawnRigAt(int idx) {
      if (directDynamicNodes.contains(idx)) {
        return true;
      }
      final n = root.nodes[idx];
      if (n.mesh == null &&
          n.punctualLight == null &&
          n.camera == null &&
          hasDynamicDescendant(idx) &&
          allMeshDescendantsDynamic(idx)) {
        return true;
      }
      return false;
    }

    final lights = <LightComponent>[];
    final cameras = <LoadedCamera3D>[];
    final models = <ModelComponent>[];
    final staticByMesh = <int, List<_StaticPlacement>>{};
    final meshCache = <int, flame_3d.Mesh>{};
    final spawnedByNode = <int, Component3D>{};
    final pendingExtras = <_PendingExtrasCall>[];

    flame_3d.Mesh resolveSharedMesh(int meshIdx) {
      return meshCache.putIfAbsent(
        meshIdx,
        () => root.meshes[meshIdx].toFlameMesh(),
      );
    }

    void extractNodeAttachments(int nodeIdx, Node node, Matrix4 worldMatrix) {
      if (node.punctualLight case final pLight?) {
        final lightComp = _buildLightComponent(pLight, worldMatrix);
        lights.add(lightComp);
        spawnedByNode[nodeIdx] ??= lightComp;
      }
      if (node.camera case final camRef?) {
        cameras.add(
          _buildLoadedCamera(
            nodeIndex: nodeIdx,
            cameraIndex: camRef.index,
            nodeName: node.name,
            gltfCamera: camRef.get(),
            worldMatrix: worldMatrix,
          ),
        );
      }
      if (node.extras != null && onNodeExtras != null) {
        pendingExtras.add(
          _PendingExtrasCall(
            nodeIndex: nodeIdx,
            node: node,
            localTransform: node.transform,
            worldTransform: worldMatrix.clone(),
          ),
        );
      }
    }

    final claimedDynamicNodes = <int>{};

    void spawnRigSubtree(int rigRootIdx, Matrix4 parentWorld) {
      if (claimedDynamicNodes.contains(rigRootIdx)) {
        return;
      }
      final modelNodes = <int, ModelNode>{};

      void collectSubtree(int idx, int? parentIdx, Matrix4 accWorld) {
        claimedDynamicNodes.add(idx);
        final gltfNode = root.nodes[idx];
        final worldMat = accWorld.clone()..multiply(gltfNode.transform);
        extractNodeAttachments(idx, gltfNode, worldMat);

        final mesh = gltfNode.mesh?.get().toFlameMesh();
        if (mesh != null &&
            gltfNode.weights != null &&
            gltfNode.weights!.isNotEmpty) {
          for (final s in mesh.surfaces) {
            if (s.morphTargets.isNotEmpty) {
              s.applyMorphWeights(gltfNode.weights!);
            }
          }
        }

        final skin = gltfNode.skin?.get();
        final ibms = skin?.inverseBindMatrices?.get().typedData();
        final joints = skin?.joints ?? const [];
        final modelJoints = <int, ModelJoint>{};
        for (final (i, joint) in joints.indexed) {
          modelJoints[i] = ModelJoint(
            nodeIndex: joint.index,
            inverseBindMatrix: ibms != null && i < ibms.length
                ? ibms[i]
                : Matrix4.identity(),
          );
        }

        modelNodes[idx] = ModelNode(
          name: gltfNode.name,
          nodeIndex: idx,
          parentNodeIndex: parentIdx,
          transform: gltfNode.transform,
          mesh: mesh,
          joints: modelJoints,
        );

        for (final child in gltfNode.children) {
          collectSubtree(child.index, idx, worldMat);
        }
      }

      collectSubtree(rigRootIdx, null, parentWorld);

      // Ensure any external skin joints (e.g. sibling bone trees) are included.
      final neededJoints = <int>[
        for (final mn in modelNodes.values)
          for (final j in mn.joints.values)
            if (!modelNodes.containsKey(j.nodeIndex)) j.nodeIndex,
      ];
      for (final jIdx in neededJoints) {
        final chain = <int>[];
        int? cur = jIdx;
        while (cur != null && !modelNodes.containsKey(cur)) {
          chain.add(cur);
          cur = parentByNode[cur];
        }
        for (final cIdx in chain.reversed) {
          claimedDynamicNodes.add(cIdx);
          final gn = root.nodes[cIdx];
          final pIdx = parentByNode[cIdx];
          modelNodes[cIdx] = ModelNode(
            name: gn.name,
            nodeIndex: cIdx,
            parentNodeIndex: pIdx != null && modelNodes.containsKey(pIdx)
                ? pIdx
                : null,
            transform: gn.transform,
            mesh: gn.mesh?.get().toFlameMesh(),
            joints: const {},
          );
        }
      }

      final relevantAnims = <ModelAnimation>[];
      for (final anim in root.animations) {
        final touchesRig = anim.channels.any(
          (ch) => modelNodes.containsKey(ch.target.node.index),
        );
        if (touchesRig) {
          final full = anim.toFlameAnimation();
          final filteredNodes = <int, NodeAnimation>{
            for (final entry in full.nodes.entries)
              if (modelNodes.containsKey(entry.key)) entry.key: entry.value,
          };
          relevantAnims.add(
            ModelAnimation(
              name: full.name,
              nodes: filteredNodes,
              events: full.events,
            ),
          );
        }
      }

      final pos = Vector3.zero();
      final rot = Quaternion.identity();
      final scl = Vector3.all(1.0);
      parentWorld.decompose(pos, rot, scl);

      final modelComp = ModelComponent(
        model: Model(nodes: modelNodes, animations: relevantAnims),
        position: pos,
        rotation: rot,
        scale: scl,
      );
      models.add(modelComp);
      spawnedByNode[rigRootIdx] = modelComp;
    }

    void visitSceneNode(int nodeIdx, Matrix4 parentWorld) {
      if (claimedDynamicNodes.contains(nodeIdx)) {
        return;
      }
      if (shouldSpawnRigAt(nodeIdx)) {
        spawnRigSubtree(nodeIdx, parentWorld);
        return;
      }

      final node = root.nodes[nodeIdx];
      final worldMatrix = parentWorld.clone()..multiply(node.transform);
      extractNodeAttachments(nodeIdx, node, worldMatrix);

      final meshRef = node.mesh;
      if (meshRef != null) {
        final meshIdx = meshRef.index;
        final placements = staticByMesh.putIfAbsent(meshIdx, () => []);
        final gpuInstances = node.gpuInstanceTransforms;
        if (gpuInstances.isNotEmpty) {
          for (var i = 0; i < gpuInstances.length; i++) {
            final combined = worldMatrix.clone()..multiply(gpuInstances[i]);
            placements.add(
              _StaticPlacement(
                nodeIndex: nodeIdx,
                worldMatrix: combined,
                fromGpuInstancing: true,
              ),
            );
          }
        } else {
          placements.add(
            _StaticPlacement(
              nodeIndex: nodeIdx,
              worldMatrix: worldMatrix,
              fromGpuInstancing: false,
            ),
          );
        }
      }

      for (final child in node.children) {
        visitSceneNode(child.index, worldMatrix);
      }
    }

    final identity = Matrix4.identity();
    for (final rootRef in scene.nodes) {
      visitSceneNode(rootRef.index, identity);
    }

    // 2. Materialize static meshes: coalesce `EXT_mesh_gpu_instancing` or
    //    `>= 2` shared static meshes into `InstancedGroup3D`, else spawn
    //    individual `MeshComponent`s.
    final instancedGroups = <InstancedGroup3D>[];
    final staticMeshes = <MeshComponent>[];
    final posScratch = Vector3.zero();
    final rotScratch = Quaternion.identity();
    final sclScratch = Vector3.all(1.0);

    for (final entry in staticByMesh.entries) {
      final meshIdx = entry.key;
      final placements = entry.value;
      if (placements.isEmpty) {
        continue;
      }
      final flameMesh = resolveSharedMesh(meshIdx);
      final hasExtInstancing = placements.any((p) => p.fromGpuInstancing);
      if (hasExtInstancing ||
          (autoBatchStaticMeshes && placements.length >= 2)) {
        final group = InstancedGroup3D(
          mesh: flameMesh,
          initialCapacity: placements.length,
        );
        for (final p in placements) {
          group.addInstance(transform: p.worldMatrix);
          spawnedByNode[p.nodeIndex] ??= group;
        }
        instancedGroups.add(group);
      } else {
        for (final p in placements) {
          p.worldMatrix.decompose(posScratch, rotScratch, sclScratch);
          final comp = MeshComponent(
            mesh: flameMesh,
            position: posScratch.clone(),
            rotation: rotScratch.clone(),
            scale: sclScratch.clone(),
          );
          staticMeshes.add(comp);
          spawnedByNode[p.nodeIndex] ??= comp;
        }
      }
    }

    // 3. Fire `onNodeExtras` callbacks with resolved world transforms &
    //    spawned components.
    final customComponents = <Component>[];
    if (onNodeExtras != null && pendingExtras.isNotEmpty) {
      for (final item in pendingExtras) {
        final wPos = Vector3.zero();
        final wRot = Quaternion.identity();
        final wScl = Vector3.all(1.0);
        item.worldTransform.decompose(wPos, wRot, wScl);
        final ctx = LoadedNodeContext3D(
          nodeIndex: item.nodeIndex,
          name: item.node.name,
          extras: item.node.extras!,
          extensions: item.node.extensions,
          localTransform: item.localTransform.clone(),
          worldTransform: item.worldTransform,
          worldPosition: wPos,
          worldRotation: wRot,
          worldScale: wScl,
          spawnedComponent: spawnedByNode[item.nodeIndex],
        );
        onNodeExtras(ctx);
        if (ctx.customComponents.isNotEmpty) {
          customComponents.addAll(ctx.customComponents);
        }
      }
    }

    return LoadedScene3D(
      lights: List<LightComponent>.unmodifiable(lights),
      cameras: List<LoadedCamera3D>.unmodifiable(cameras),
      instancedGroups: List<InstancedGroup3D>.unmodifiable(instancedGroups),
      staticMeshes: List<MeshComponent>.unmodifiable(staticMeshes),
      models: List<ModelComponent>.unmodifiable(models),
      customComponents: List<Component>.unmodifiable(customComponents),
    );
  }

  static LightComponent _buildLightComponent(
    KhrPunctualLight light,
    Matrix4 worldMatrix,
  ) {
    final pos = Vector3.zero();
    final rot = Quaternion.identity();
    final scl = Vector3.all(1.0);
    worldMatrix.decompose(pos, rot, scl);

    // glTF `KHR_lights_punctual` lights emit along the local `-Z` axis.
    final tip = worldMatrix.transformed3(Vector3(0, 0, -1));
    final dir = tip - pos;
    if (dir.length2 > 1e-12) {
      dir.normalize();
    } else {
      dir.setValues(0, 0, -1);
    }

    return switch (light.type) {
      KhrPunctualLightType.directional => LightComponent.directional(
        color: light.color,
        intensity: light.intensity,
        direction: dir,
        rotation: rot,
      ),
      KhrPunctualLightType.point => LightComponent.point(
        position: pos,
        color: light.color,
        intensity: light.intensity,
        range: light.range,
      ),
      KhrPunctualLightType.spot => LightComponent.spot(
        position: pos,
        rotation: rot,
        direction: dir,
        color: light.color,
        intensity: light.intensity,
        range: light.range,
        innerConeAngle: light.innerConeAngle,
        outerConeAngle: light.outerConeAngle,
      ),
    };
  }

  static LoadedCamera3D _buildLoadedCamera({
    required int nodeIndex,
    required int cameraIndex,
    required String? nodeName,
    required gltf_cam.Camera gltfCamera,
    required Matrix4 worldMatrix,
  }) {
    final pos = Vector3.zero();
    final rot = Quaternion.identity();
    final scl = Vector3.all(1.0);
    worldMatrix.decompose(pos, rot, scl);

    final forward = worldMatrix.transformed3(Vector3(0, 0, -1)) - pos;
    if (forward.length2 > 1e-12) {
      forward.normalize();
    } else {
      forward.setValues(0, 0, -1);
    }
    final up = worldMatrix.transformed3(Vector3(0, 1, 0)) - pos;
    if (up.length2 > 1e-12) {
      up.normalize();
    } else {
      up.setValues(0, 1, 0);
    }
    final target = pos + forward;

    final type = gltfCamera.type;
    if (type == CameraType.orthographic) {
      final ortho = gltfCamera.orthographic!;
      return LoadedCamera3D(
        nodeIndex: nodeIndex,
        cameraIndex: cameraIndex,
        name: nodeName,
        projection: CameraProjection.orthographic,
        position: pos,
        rotation: rot,
        target: target,
        up: up,
        fovYDegrees: 60.0,
        orthographicHeight: ortho.yMag * 2.0,
        near: ortho.zNear,
        far: ortho.xFar,
        aspectRatio: ortho.yMag > 1e-9 ? ortho.xMag / ortho.yMag : null,
      );
    }

    final persp = gltfCamera.perspective!;
    final yFovRad = persp.yFov;
    final near = persp.zNear;
    final far = persp.zFar ?? CameraComponent3D.distanceFar;
    return LoadedCamera3D(
      nodeIndex: nodeIndex,
      cameraIndex: cameraIndex,
      name: nodeName,
      projection: CameraProjection.perspective,
      position: pos,
      rotation: rot,
      target: target,
      up: up,
      fovYDegrees: yFovRad * (180.0 / math.pi),
      orthographicHeight: null,
      near: near,
      far: far,
      aspectRatio: persp.aspectRatio,
    );
  }
}
