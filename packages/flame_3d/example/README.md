# flame_3d example & showcase testbed

Interactive examples and an all-in-one 16-lab engine showcase for `package:flame_3d`:

- **`showcase`** (`ShowcaseGame` / `ShowcaseView` — press `T` or run `setup showcase` in the
  console):
  - **16 feature labs (`ShowcasePreset`)** exercising retained `Scene3DComponent` layers,
    `ShadowSettings.cacheWhenStatic`, 2-cascade directional shadow atlases (`cascades: 2`),
    perspective `SpotLight` shadows, shared `ShadowGroup`, `ShadowCatcherMaterial`, 2,048-instance
    `InstancedGroup3D` batching, `LodMeshComponent`, PBR `SpatialMaterial` (`EnvironmentProbe3D`
    `SH9` IBL, normal/ORM/AO/emissive maps), `StylizedMaterial`, `WaterMaterial` (`shoreFoamDepth`),
    `TerrainMesh3D`, `TubeSplineMesh`, HD-2D `BillboardBatch3D`, `Text3DComponent`, 64-bone
    skinning, morph targets, `AnimationLayer3D`, IK/LookAt/SpringBone, `BlendSpace1D`/`BlendSpace2D`,
    `AnimationEvent3D`, `RootMotionExtractor3D`, 64-agent `SkinnedCrowdBatch3D`, background-isolate
    `AsyncModelLoader3D` + `SceneLoader3D`, `PointerRouter3D` 3D input & gizmos, 3D effects &
    `FixedTransformInterpolation3D`, `OrbitCameraController3D` / `SpringArmCamera3D` /
    `CameraDollyTrack3D` / `CameraShake3D`, `PhysicsWorld3D` (`RigidBody3D`, `HingeJoint3D`,
    `throwDice3D`), `CollisionSystem3D` + `ShapeCast3D` + `KinematicCharacterController3D`,
    `NavMesh3D` + `CrowdSteering3D`, `SpatialAudio3D`, half-res `DepthNormalPrepass` (SSAO, 3D DoF,
    soft particles), live GPU `RenderTexture3D` portals, `DebugRenderer3D`, and a **48-check**
    automated **Self-Test** (`ShowcaseDiagnostics`).
- **`boxes`**, **`colors`**, **`culling`**, **`models`**, **`particles`**, **`houses`** (`H`), and
  **`shadows`**.


## Headless GPU verification

From `packages/flame_3d/example`:

```sh
flutter test --enable-impeller --enable-flutter-gpu
```
