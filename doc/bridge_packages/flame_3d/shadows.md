# Shadows

A directional light (a sun) can cast real-time shadows. Before the main pass of a scene, the objects
that cast shadows are rendered from the light into a shadow map, the depth they have as the light
sees them; the materials that receive shadows then compare the depth of their fragments with it.


## Casting shadows

Give a `DirectionalLight` its `ShadowSettings`:

```dart
world.addAll([
  LightComponent.hemisphere(
    skyColor: const Color(0xFF9CC2F0),
    groundColor: const Color(0xFF7A6A50),
  ),
  LightComponent.directional(
    direction: Vector3(-0.4, -1, -0.3),
    shadows: ShadowSettings(
      strength: 0.85,
      color: const Color(0xFF2E3A66), // cool shadows rather than black ones
    ),
  ),
  ...buildings,
]);
```

Only the first directional light of a scene with settings casts shadows. The settings are read
every frame and may be changed at any time.

Every `Object3D` casts shadows unless its `castsShadows` is `false`, and every material does unless
its `castsShadows` says otherwise: opaque materials cast by default, translucent ones (glass,
additive glows) do not.

```dart
// An opaque glow that should not cast.
final glow = StylizedMaterial(emissiveStrength: 1)..castsShadows = false;

// A marker that receives shadows but casts none.
final marker = MeshComponent(mesh: markerMesh, castsShadows: false);
```

A caster's shadow is rendered from the positions of its vertices alone, skinned when its vertices
have joints and joint weights (`vertexJoints`, `vertexWeights`) and its draw has joint matrices.
Vertices that a material's own vertex shader moves, such as the wind sway of `StylizedMaterial`,
cast the shadow of their rest position. Draws of one surface are drawn as one instanced draw in the
shadow pass, whatever their materials.


## Receiving shadows

`StylizedMaterial` and `SpatialMaterial` (on native backends) both receive shadows: where a surface
is in shadow, the direct light of the light that casts them is multiplied by
`mix(white, color, strength)`, and its highlights by the mean of that. Ambient and hemisphere light,
point lights, spot lights and other directional lights stay, so with the default black `color` a
shadowed surface is lit by the ambient light alone, and with a colored one the shadows are tinted
with it: a cartoon look tints shadows rather than blackening them.

`ShadowCatcherMaterial` is for invisible surfaces that show only the shadows falling on them, see
[Shadows on 2D art](#shadows-on-2d-art). `UnlitMaterial` does not receive shadows.

Custom shaders receive shadows by including `flame_3d/shadows.glsl` and listing its `Shadows`
block and `shadowMap` sampler (`RenderContext3D.shadowsBlock` and
`RenderContext3D.shadowMapSampler`) in their material's slots; the render context fills them once
per pass:

```glsl
#include <flame_3d/shadows.glsl>

// ...
float visibility = shadowVisibility(fragPosition, normal); // 0 in shadow, 1 lit
for (int i = 0; i < int(directionalLights.numLights); i++) {
  vec3 shadow = castsShadows(i) ? shadowFactor(visibility) : vec3(1.0);
  // ... multiply the light of sun i by shadow
}
```

Without shadows, `shadowVisibility` returns `1`.

A shader that holds the values of the `Shadows` block in a block of its own, to bind fewer blocks
per draw (see [Rendering](rendering.md#shaders)), defines `FLAME_SHADOWS(member)` to the expression
that reads the member of `Shadows` named `member` before including the chunk, which then declares
no `Shadows` block; `StylizedMaterial` does so.


## The shadow map

The shadow map is a square texture of `resolution` by `resolution` texels (1024 by default, which
suits phones), created once and reused from frame to frame. The light renders it through an
orthographic projection, `DirectionalShadowProjection`, fitted to the region that receives shadows:

- With `ShadowFit.view` (the default), the part of the bounds of the scene (`World3D.sceneBounds`,
  or the settings' `bounds`) that the camera sees: the shadows are as sharp as the map allows, and
  the map follows the camera. `maxDistance` limits how far from the camera shadows reach, which
  sharpens them for a perspective camera that sees far.
- With `ShadowFit.scene`, the whole region, whatever the camera sees: the map only changes when the
  region does.

Either way, the map reaches from the receivers back towards the light over the whole scene, so that
every object between the light and the visible receivers casts its shadow, even when it is not on
screen itself.

The light's view looks along its direction from the world origin, and does not move with the
camera. With `stabilize` (the default), the width and height of the map only take sizes on a ladder
(steps of `2^(1/8)`, about 9 %, kept while they still fit) and its edges are snapped to whole texels
of the light's view: as the camera pans, a point of the world keeps landing on the same spot of a
texel, and the edges of the shadows stay still instead of shimmering.

With `ShadowSettings(cacheWhenStatic: true)` (most effective alongside `ShadowFit.scene`), the world
skips both the shadow caster traversal and the shadow GPU pass (`shadowPasses == 0`) whenever no
shadow-casting component has mounted, unmounted, moved or animated (`World3D.castersVersion`), and
the sun direction, shadow settings and fitted light projection match the cached map. Call
`world.markShadowsDirty()` if custom vertex buffers mutate in place.


### How depths are stored

Flutter GPU cannot sample the depth attachment of a render pass on every backend (on Vulkan,
Impeller's views of depth-stencil textures cover both aspects, which a sampler may not read), so the
shadow pass writes the depth into a color texture instead, through its own shaders:

- `ShadowMapEncoding.float32`: one 32-bit float per texel (`r32Float`), where the GPU can render
  into 32-bit float textures. Flutter GPU has no query for that: `flame_3d` uses it on Metal and
  Vulkan, which render into them, and not on OpenGL ES, which needs an extension.
- `ShadowMapEncoding.rgba8`: 24 bits of depth packed into the red, green and blue channels of an
  8-bit texel, which every GPU renders into.

`ShadowMapEncoding.auto` (the default) picks the first where it can. Both take 4 bytes per texel and
give the same shadows. The texture is sampled with nearest filtering, and the receivers filter the
comparisons themselves.


### Soft edges and biases

A receiver compares its depth with the map over a box of `2 * softness + 1` texels, blended
bilinearly: `(2 * softness + 2)²` samples, 16 with the default `softness` of `1`, 4 with `0`.

Two biases keep surfaces from shadowing themselves (shadow acne) without detaching shadows from
their casters (peter-panning). Both are in texels of the map, so they follow its resolution and the
size of the region it covers:

- `depthBias` (`1` by default) pushes the receiving point towards the light.
- The point is also pushed along its normal, in proportion to the sine of the angle between the
  normal and the light: by what the filter needs (`sqrt(2) * (softness + 1)` texels), plus
  `normalBias` (`0.5` by default). This keeps surfaces lit at grazing angles free of acne.

With the defaults, a 1024 texel map over a board of ten units moves shadows by at most a few
hundredths of a unit.


## Shadows on 2D art

In a `Scene3DComponent`, the 3D layer is drawn over the 2D components below it. A ground of
`ShadowCatcherMaterial` under the 3D objects draws the shadows falling on it, with soft edges, as
`color` blended over the 2D art (its alpha the opacity at full strength), and is fully transparent
elsewhere: 3D objects cast shadows onto pre-rendered 2D ground.

```dart
final layer = Scene3DComponent(projection: boardProjection, priority: 1);
world.addAll([GroundArt(), layer]); // the 2D ground is drawn below the layer

layer.world.addAll([
  LightComponent.directional(
    direction: Vector3(-0.3, -0.5, -1), // z is up in this scene
    shadows: ShadowSettings(),
  ),
  MeshComponent(
    mesh: PlaneMesh(
      size: Vector2(12, 12),
      material: ShadowCatcherMaterial(color: const Color(0x8C1B2440)),
    ),
    position: Vector3(6, 6, 0),
    // The PlaneMesh faces +y: turned to face +z.
    rotation: Quaternion.axisAngle(Vector3(1, 0, 0), pi / 2),
  ),
  ...houses,
]);
```

The catcher needs a position and a normal on its vertices, as the standard layout and the layout of
`StylizedMaterial` have. It is translucent, writes no depth and casts no shadows; the 3D objects
drawn in front of it hide it as they hide the ground. The `shadows` scenario of the example shows
3D buildings casting tinted shadows onto a 2D board under a sun that circles around it.


## One shadow map for several layers

Each `Scene3DComponent` is a scene of its own, rendered in its own pass at its own priority among
the 2D components: buildings below some 2D labels and characters above them, for instance. Its
objects only shadow each other. To let the objects of several layers shadow one another, as if they
were one scene, put their worlds in one `ShadowGroup`:

```dart
final shadows = ShadowGroup();
buildings.world.shadowGroup = shadows;
characters.world.shadowGroup = shadows;
```

The group has one shadow map, rendered once per frame by the first of its worlds that renders, with
the objects of every world of the group: a character's shadow falls on a building of the other
layer, and a building's on the character. The worlds that render after it in the frame reuse the
map (`RenderContext3D.reuseShadowMap`), so the group costs one shadow pass, not one per layer; a
world renders the group's map again only when another shadow map was rendered in between.

The light, the `ShadowSettings` and, with `ShadowFit.view`, the camera the map is fitted to are
those of the world that renders first:

- give the worlds of a group the same lights, in the same order: a shader tells the light that
  casts the shadows by its index among the directional lights;
- render first the layer that covers the most of the screen (the one whose shadow catchers cover
  the ground), or fit the map to `ShadowSettings.bounds` that cover what every layer shows, with
  `ShadowFit.scene`: receivers outside the map are lit.

A ground of `ShadowCatcherMaterial` belongs in the lowest layer of the group, below the objects of
every layer.


## Costs

A scene with shadows costs one more render pass per frame, and one more traversal of its
components (recording their draws a second time, `ModelComponent`s posing their nodes again):

- the shadow pass draws one draw call per caster surface, objects sharing a surface in one
  instanced draw, with depth-only shaders; draws whose material casts no shadows are not even
  recorded, and particle systems that cast none skip the shadow pass altogether;
- the receivers sample the map `(2 * softness + 2)²` times per fragment, where the shadow can show:
  not outside of the map, and, for `StylizedMaterial`, not where the surface faces away from the
  sun and has no highlights;
- the map takes `resolution² * 4` bytes, plus a depth attachment that lives in tile memory where
  the GPU has it.

`RenderStats.shadowPasses` and `RenderStats.shadowDrawCalls` count the shadow passes and their draw
calls, which are also counted in `renderPasses` and `drawCalls`. The layers of a `ShadowGroup` that
reuse its map count no shadow pass. In a headless test, a hundred cubes
sharing a mesh on a ground in a `Scene3DComponent` render with 2 draw calls in 1 pass without
shadows, and 4 draw calls in 2 passes with them (2 of them in the shadow pass).


## Two-cascade directional shadow atlas and spot-light shadows

- **2-Cascade Directional Shadow Maps (`ShadowSettings(cascades: 2, cascadeSplitRatio: 0.28)`):**
  setting `cascades: 2` renders a crisp high-texel-density near cascade (`Cascade 0`) and a full
  scene/view far cascade (`Cascade 1`), packing them side-by-side into a `2 * resolution x resolution`
  shadow atlas (`shaders/shadow_atlas_pack`) sampled seamlessly with zero extra texture bindings.
- **Perspective `SpotLight` Shadows:** giving a `SpotLight` (`LightComponent.spot(shadows: ShadowSettings(...))`)
  shadow settings renders a perspective spot shadow map along its cone when no directional light is
  claiming the pass's shadow map (or when directional lights are masked out via `LightComponent.lightMask`).


## Limitations

- One shadow-casting light (either a 1- or 2-cascade `DirectionalLight`, or a perspective
  `SpotLight`) casts a shadow map per pass; point lights cast no shadow maps (use
  `DecalBatch3D.addBlobShadow` for grounded contact shadows).
- `UnlitMaterial` receives no shadows, and shadows are not available on the web yet.
