# Rendering

This page describes how `flame_3d` turns the components of a `World3D` into GPU work, and what
you can control along the way.


## Draws are recorded, then sorted

While the world is traversed, every visible `Object3D` records its draws into the
`RenderContext3D` (a `MeshComponent` records one draw per surface of its mesh). Nothing reaches the
GPU until the end of the render pass, when the recorded draws are submitted:

- Opaque draws are grouped by pipeline, material and surface, then roughly ordered front to back.
  Consecutive draws of the same `Surface` with the same `Material` instance become a single
  instanced draw. Components that share a `Mesh` therefore cost one draw call per surface, however
  many of them there are.
- Translucent draws come after all the opaque ones, ordered back to front. Consecutive translucent
  draws of the same `Surface` with the same `Material` instance also become a single instanced draw,
  whose instances are drawn in that back to front order.
- Skinned draws are never batched.

Because materials are applied when the draws are submitted, a material must not change its values
between the draws of one frame to make objects look different: use distinct materials, or the
per-instance color and data.

When a directional light casts shadows (see [Shadows](shadows.md)), the world is traversed twice
per frame: first with the light's view as the camera (`RenderContext3D.isShadowPass` is `true`),
to render the shadow map from the draws of the objects and materials that cast shadows, then for
the main pass. In the shadow pass, draws of one surface become a single instanced draw whatever
their materials, drawn with depth-only shaders.


## Per-instance color and data

Each draw carries a color besides its model matrix, `MeshComponent.color` (white by default). The
built-in materials multiply their base color by it (`StylizedMaterial` only on the vertices of its
tint mask), so many tinted copies of a mesh still batch:

```dart
for (final (i, color) in playerColors.indexed) {
  world.add(
    MeshComponent(mesh: pawn, position: Vector3(i * 2.0, 0, 0), color: color),
  );
}
```

Each draw also carries four floats of per-instance data, `MeshComponent.instanceData` (zero by
default), that materials are free to interpret: a highlight, an emissive strength, an opacity, a
wind strength... Objects that differ only in their color and data still batch.
`SpatialMaterial` and `UnlitMaterial` ignore the data; `StylizedMaterial` reads it as described in
[Materials and Lighting](materials.md#per-instance-data).

```dart
final house = MeshComponent(mesh: houseMesh, instanceData: Vector4.zero());

// Later, when the pointer is over it:
house.instanceData.x = 0.5;
```

Custom objects pass them to `RenderContext3D.drawSurface` and `drawMesh` with `color` and
`instanceData`; both are copied when the draw is recorded.

Objects that build their own instance data, such as particle systems, record it whole with
`RenderContext3D.drawInstances`: one instanced draw of a surface, whatever the number of instances,
read from a `Float32List` of 24 floats per instance (the model matrix columns, the color and the
data, or whatever the material's vertex shader makes of them) when the draws are flushed. Such a
draw is never batched with others; a translucent one is ordered by the `center` it is given. See
[Particles](particles.md).

For hundreds or thousands of static or semi-static copies of a `Mesh` (tiles, props, trees, fence
posts), `InstancedGroup3D` stores all instances in a single contiguous `Float32List` (`addInstance`,
`setTransform`, `setColor`, `setInstanceData`, `removeAtSwapLast`) and submits one `drawInstances`
call per surface with zero per-instance `Component` overhead, while still supporting BVH raycasting
returning the exact `instanceIndex`.

`LodMeshComponent` switches automatically between `MeshLodLevel`s by distance from the camera or
minimum screen-height coverage (`minScreenFraction`), and optionally casts shadows from a cheaper
`shadowMesh`.


## BVH raycasting and `SceneSpatialIndex3D`

Every `Surface` builds a flat, zero-allocation median-split Bounding Volume Hierarchy on first
query (`surface.bvh`), supporting `O(log T)` narrowphase ray-triangle intersection
(`SurfaceBvh.raycastLocal` and `raycastTransform` for arbitrary world transforms including negative
mirror scales).

`World3D.raycast` and `World3D.raycastAll` prune invisible subtrees by world `Aabb3` before testing
`MeshComponent`, `ModelComponent`, `LodMeshComponent` and `InstancedGroup3D` surfaces, returning
`RayHit3D` records (`component`, `position`, `normal`, `distance`, `barycentric`, `surfaceIndex`,
`triangleIndex`, `instanceIndex`).

For large scenes with hundreds of `Object3D`s, setting `world.spatialIndex3DEnabled = true`
maintains a version-tracked flat world-space AABB BVH (`world.spatialIndex3D`) that accelerates
broadphase frustum queries (`queryFrustum`), box overlap queries (`queryAabb`) and `O(log N)`
raycasting (`lastRaycastCandidatesTested`).


## Models, 64-bone skinning, morph targets, animation layers, and procedural IK

`ModelComponent` evaluates glTF 2.0 models and animations through a zero-allocation `AnimationState`
and `ModelPoseWorkspace` pipeline with `O(log K)` binary keyframe lookup:

- **64-bone skinning & auto-splitting:** skinned shaders support up to 64 joints per primitive
  (`JointMatrices`), and `ModelParser` automatically partitions glTF primitives referencing more
  than 64 joints into sub-surfaces with remapped joint palettes.
- **CubicSpline & Morph targets (`MorphTargetData`, `MorphWeightsChannel`):** `GltfParser` parses
  `CUBICSPLINE` Hermite tangents, sampler filter/wrap modes, PBR normal/ORM/AO/emissive maps,
  `alphaMode` (`OPAQUE`, `MASK`, `BLEND`), `doubleSided`, `COLOR_0`, and blend-shape morph targets
  (`Surface.applyMorphWeights`, `Surface.updateVertices`, `ModelComponent.setMorphWeights`).
- **Crossfades & `AnimationLayer3D`:** `playAnimationByName` and `crossFadeToByName` smoothly blend
  clips; `addOverlayLayer` stacks masked upper-body or additive `AnimationLayer3D`s (`nodeMask`,
  `weight`, `additive`) over the base locomotion clip, including layered morph weights.
- **Procedural rigging (`BoneModifier3D`):** `ModelComponent.boneModifiers` runs post-animation
  constraints in pose space before skinning: `TwoBoneIkConstraint3D` (analytical foot/hand IK),
  `LookAtConstraint3D` (clamped head/turret tracking) and `SpringBone3D` (inertial hair/cape/tail
  secondary motion), plus `BoneSocket3D` joint attachments.
- **Blend spaces, frame events, root motion, offscreen policies, crowd batching & scene streaming:**
  - `BlendSpace1D` (`playBlendSpace1D`, `blendParameter1D`) and `BlendSpace2D` (`playBlendSpace2D`,
    `blendParameter2D`) blend locomotion/strafe clips continuously with phase-locked normalized
    cycles;
  - `AnimationEvent3D` (`ModelComponent.onAnimationEvent`) dispatches boundary-exact frame events
    across `loop`, `once` and `pingPong` playback;
  - `RootMotionExtractor3D` extracts per-tick local/world root bone displacement and yaw without
    loop-wrap spikes, optionally locking horizontal root motion in place;
  - `OffscreenAnimationPolicy` (`always`, `tickOnlyEvaluateWhenVisible`, `pauseWhenOffscreen`)
    eliminates wasted offscreen skeletal matrix evaluations;
  - `SkinnedCrowdBatch3D` pre-bakes clips into `BakedClipPoseBank3D` tables so dozens or hundreds
    of animated agents advance in `O(1)` lookup time;
  - `AsyncModelLoader3D` + ref-counted `AssetScope3D` stream `.glb` / `.obj` geometry, mipmaps and
    `SurfaceBvh` hierarchies on background isolates via `TransferableTypedData`;
  - `SceneLoader3D` (`loadAsset`, `loadGlbBytes`, `loadGltfJson`, `fromRoot`) loads complete glTF
    2.0 scenes including `KHR_lights_punctual`, `KHR_materials_unlit`,
    `KHR_materials_emissive_strength`, `KHR_texture_transform`, `KHR_mesh_quantization`,
    `EXT_mesh_gpu_instancing` and `onNodeExtras` gameplay spawn hooks.
- `ModelParser` precomputes `Model.animatedAabb`, conservative local-space bounds across all
  animation keyframes, so animated `ModelComponent`s are never frustum-culled prematurely.


## 3D input, effects, physics, navigation, audio, and debug gizmos

Beyond rendering, `package:flame_3d` ships modular 3D gameplay libraries:

- **`package:flame_3d/input.dart`:** `PointerRouter3D.forScene` and `PointerRouter3D.forCamera`
  route taps, hover enter/move/exit transitions, ray-plane drags and 1D `dragAxisConstraint` gizmo
  drags to `Object3D`s mixing in `TapCallbacks3D`, `HoverCallbacks3D` and `DragCallbacks3D`
  (including `InstancedGroup3D` `instanceIndex` hits).
- **`package:flame_3d/effects.dart` & `camera.dart`:** `MoveToEffect3D`, `MoveByEffect3D`,
  `ArcMoveEffect3D`, `SplinePathEffect3D(orientToTangent: true)`, `RotateToEffect3D`,
  `RotateAroundEffect3D`, `ScaleToEffect3D`, `SquashStretchEffect3D`, `ColorTintEffect3D`,
  `InstanceDataEffect3D`, `FixedTransformInterpolation3D`, plus `OrbitCameraController3D`
  (`fitAabb`), raycast-occluded `SpringArmCamera3D`, `CameraDollyTrack3D` and 6-DOF trauma
  `CameraShake3D`.
- **`package:flame_3d/collisions.dart` & `physics.dart`:** `SphereShape3D`, `CapsuleShape3D`,
  `BoxShape3D` (OBB) and `ConvexHullShape3D` with analytical + SAT + GJK/EPA `CollisionManifold3D`,
  `CollisionSystem3D`, `TriggerVolume3D`, posed skeletal `SkinnedHitboxRig3D` (`BoneHitbox3D`),
  swept `ShapeCast3D` (`sphereCast`, `capsuleCast`, `convexCast`), stair-climbing
  `KinematicCharacterController3D` (`moveAndSlide`), and deterministic Sequential Impulse
  `PhysicsWorld3D` (`RigidBody3D`, `throwDice3D`, `DistanceJoint3D`, `BallSocketJoint3D`,
  `HingeJoint3D`).
- **`package:flame_3d/navigation.dart` & `audio.dart`:** `NavMesh3D.fromMesh` (A* + 3D Simple
  Stupid Funnel `findPath`, `sampleHeightAt`), RVO `CrowdSteering3D` (`CrowdAgent3D`), and
  `SpatialAudioListener3D` / `SpatialAudioEmitter3D` (stereo pan, rolloff, cones, raycast
  occlusion, 3D Doppler).
- **`package:flame_3d/debug.dart`, `RenderTexture3D`, `cameraMask`/`lightMask` & Depth-Normal Prepass:**
  - `Component3D.cameraMask` and `LightComponent.lightMask` filter visibility and lighting per
    pass;
  - `World3D.depthPrepassEnabled` runs a half-resolution clip-depth + view-normal prepass powering
    8-tap Spiral **SSAO** (`PostProcessSettings.ssaoIntensity`), **3D Depth of Field**
    (`dofBlurStrength`), **Soft Particles** (`ParticleMaterial.softDepthFade`) and **Shoreline
    Water Foam** (`WaterMaterial.shoreFoamDepth`);
  - `RenderTexture3D` renders live 3D portals, security monitors and mirrors directly into a
    sampleable GPU `Texture` with zero CPU readback;
  - `GraphicsDevice.warmupMaterial` pre-builds PSOs at load time and `estimatedTargetVramBytes`
    tracks pooled render-target VRAM;
  - `DebugRenderer3D` renders scene AABBs, OBBs, bone skeletons, light cones/spheres and custom
    wireframes in 1 instanced GPU draw call.


## Render state

A material declares how it is drawn with its `renderState`: the blend mode (`BlendState.opaque`,
`alpha`, `premultipliedAlpha`, `additive` or `depthOnly`), whether the depth test is on and with
which `CompareFunction`, whether depth is written, the `CullMode`, and whether the material is
translucent (by default, every blend mode other than opaque is). Additive draws add their color and
keep the alpha of the target: added light covers nothing, so in a `Scene3DComponent` a glow over an
empty part of the scene adds its color to the 2D components drawn behind the layer.

```dart
final glow = UnlitMaterial()..renderState = RenderState.additive;

final shadow = UnlitMaterial(albedoColor: const Color(0x80000000))
  ..renderState = const RenderState(
    blend: BlendState.alpha,
    depthWrite: false,
  );

final floor = SpatialMaterial()
  ..renderState = const RenderState(cullMode: CullMode.backFace);
```

A translucent object drawn with a single translucent material shows its own hidden parts through
its near ones: an arm in front of a body lets the body show through it. Setting
`singlePieceTranslucent: true` on `StylizedMaterial` or `SpatialMaterial` (which uses
`RenderState.singlePiecePremultipliedAlphaBlend` with `depthPrepass: true`) automatically emits a
depth-only prepass immediately before the color draw — and `ModelComponent` wraps multi-node
translucent models in `RenderContext3D.beginDepthPrepassGroup()` / `endDepthPrepassGroup()` so every
limb writes depth before any limb blends color. For opaque zero-sorting fades without translucency,
enable `ditherFade: true` (`flame_3d/dither.glsl` Bayer 4x4 screen-door discard).

Front faces are counter-clockwise on screen. The winding flips automatically when the camera mirrors
the scene, and for objects whose transform mirrors them (an odd number of negative scales), so
back-face culling keeps culling the faces that point away from the camera.

`SpatialMaterial` and `StylizedMaterial` are opaque by default. `UnlitMaterial` may output
translucent colors, so by default it blends with premultiplied alpha and draws as translucent; set
its `renderState` to `RenderState.opaque` for opaque content so that it batches. The built-in
materials and the lights are described in [Materials and Lighting](materials.md).


## Surfaces from typed arrays and custom vertex layouts

Besides a list of `Vertex` objects, a `Surface` can be built straight from an interleaved
`Float32List` and a `Uint16List` or `Uint32List` of indices, which avoids creating an object per
vertex. Surfaces with more than 65,535 vertices use 32-bit indices.

A surface may declare its own vertex layout. Each attribute feeds the vertex shader input with the
same name, and a material's pipeline is created for the layout of each surface it draws:

```dart
final surface = Surface.fromBuffers(
  vertices: data, // 7 floats per vertex
  indices: Uint16List.fromList(indices),
  layout: VertexLayout(const [
    VertexAttribute('vertexPosition', 3),
    VertexAttribute('vertexColor', 4),
  ]),
  material: vertexColorMaterial,
);
```

A surface must provide every input the material's vertex shader declares, except the per-instance
inputs, which `flame_3d` feeds itself. The standard layout (`VertexLayout.standard`) has a position,
texture coordinates, a color, a normal, joints and joint weights. A material can draw several
layouts with a vertex shader variant per layout, see `Material.vertexShaderFor`.


## Shaders

Custom shaders can include the chunks `flame_3d` ships:

- `flame_3d/instancing.glsl` declares the per-instance inputs: the columns of the model matrix
  (`instanceModel0` to `instanceModel3`), `instanceColor` and `instanceData`, and
  `instanceModelMatrix()`. A vertex shader that declares the model columns is drawn instanced. One
  that does not gets its model matrix from uniforms its material sets in `apply`, from
  `RenderContext3D.model`, and draws each object on its own. `instanceModelMatrix()` also reads
  `instanceColor` and `instanceData` (without changing the matrix): `impellerc` cannot compile a
  vertex shader whose inputs leave a gap, which reading `instanceData` but not `instanceColor` would
  otherwise do.
- `flame_3d/camera.glsl` declares the `CameraMatrices` block (`view`, `projection`,
  `viewProjection`).
- `flame_3d/skinning.glsl` handles vertex skinning: it declares the `vertexJoints` and
  `vertexWeights` inputs and the `JointMatrices` block (16 matrices), and `computeSkinMatrix()`.
- `flame_3d/lights.glsl` declares the light blocks: `AmbientLight`, `Lights` (point lights),
  `DirectionalLights` and `HemisphereLight`, see
  [Materials and Lighting](materials.md#custom-shaders).
- `flame_3d/shadows.glsl` declares the `Shadows` block and the `shadowMap` sampler, and
  `shadowVisibility()`, `shadowFactor()` and `castsShadows()` to receive shadows, see
  [Shadows](shadows.md#receiving-shadows).
- `flame_3d/fog.glsl` declares the `Fog` block (`RenderContext3D.fogBlock`, driven by
  `World3D.fog`) and `applyFog(color, worldPos, cameraPos)` for linear or exponential distance +
  height fog.

Blocks named `CameraMatrices`, `Camera` (`position`, and any of the `CameraMatrices` members),
`AmbientLight`, `Lights`, `DirectionalLights` and `HemisphereLight` are filled once per render pass
by the `RenderContext3D`, for every shader that declares them; the joint matrices of skinned draws
are filled for each draw, from the `jointTransforms` given to `RenderContext3D.drawSurface` (or to
`drawMesh`, by surface index, which `MeshComponent.jointTransforms` feeds), whatever the surface:
a parsed model's or one built with `Surface.fromBuffers`. The `Shadows` block and the `shadowMap`
sampler are filled once per pass too. Register your own per-pass blocks with
`RenderContext3D.registerPassUniform`, and per-pass textures with
`RenderContext3D.registerPassTexture`.

Flutter GPU binds every uniform block and texture of a pipeline again for each draw call, so each
resource a shader declares costs CPU time on every draw. `StylizedMaterial`'s fragment shader
therefore reads the camera, the lights and the shadows of the pass from one internal block, which
the writers registered for the six blocks above fill, rather than from those six blocks: a draw of
it binds seven resources (the camera matrices, its wind, its material values, that block, its two
MatCap textures and the shadow map) instead of twelve.


## Frame output and statistics

Each camera renders the world into an image of its viewport size in physical pixels, rounded to
whole pixels. `World3D.renderScale` renders it at a fraction of that size (or above `1` to
render more pixels than the viewport covers); the image is scaled to the viewport when drawn.

The render targets of a `GraphicsDevice` are pooled by size: a size that is not used in a frame
stays pooled for `GraphicsDevice.targetRetainFrames` frames. A render target owns up to three color
textures, created once, which its passes take turns rendering into; the image of a pass is drawn by
Flutter straight from its texture. A texture is rendered into again only once Flutter can no longer
draw its previous image: Flutter rasterizes at most the frame it is building and the one before, so
two frames later the image has been drawn, and the draws that read it were submitted to the GPU
before the new pass is. A scene rendered every frame therefore uses two textures; when Flutter draws
no frames (passes rendered outside of frames), the texture rendered the longest ago of the three is
reused.

Shadow maps render into textures that later passes sample (`GraphicsDevice.textureTarget`), created
once for each size and format and kept while they are used.

Setting `World3D.bloom = const BloomSettings(...)` renders the scene into a texture target, extracts
bright pixels at half resolution with a soft threshold knee, blurs them with a multi-pass 5-tap
Kawase filter, and composites the additive glow back while preserving target alpha. Calling
`World3D.renderToImage(size, view: ..., projection: ...)` renders a standalone snapshot into a
dedicated render target (even when the world is not mounted in a game).

`FlameGame3D.renderStats` holds the statistics of the last rendered frame: render passes, draw
calls, instances, triangles, pipeline changes, render state changes, material changes, uniform
uploads, uploaded bytes, the particles drawn by particle systems, and how many of the passes and
draw calls rendered shadow maps (`shadowPasses` and `shadowDrawCalls`).


### Profiling

Built with `--dart-define=FLAME_3D_PROFILE=true`, the renderer times its phases on the CPU into
`RenderProfile.active`: walking the components, culling, recording draws, particles, sorting,
batching, render state, `Material.apply`, the uniform blocks of the pass, uploads, bindings,
gathering instances, draw calls, and beginning and ending passes, the shadow pass apart. Without
the define, the timing is compiled out.

```dart
final profile = RenderProfile.active = RenderProfile();
// ... render some frames ...
for (final phase in RenderPhase.values) {
  print('${phase.name}: ${profile.microseconds(phase)} us, '
      'shadow pass ${profile.microseconds(phase, shadow: true)} us');
}
```

Timing every draw costs a little, so compare its totals with a build without the define. The
package's `benchmark/` renders a board-like scene (a few hundred instanced objects, skinned
characters, shadows, particles) and reports these phases, the objects allocated per frame and the
`RenderStats`, under `flutter test` or in a profile build: see its README.
