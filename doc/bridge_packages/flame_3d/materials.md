# Materials and Lighting

A `Material` decides how the surfaces drawn with it look: its shaders, the values it gives them and
its render state (see [Rendering](rendering.md)). This page describes the built-in materials, the
lights they respond to, and textures.


## Built-in materials

- `SpatialMaterial` is physically based (metallic-roughness PBR), lit by every kind of light
  (including `SpotLight`s and directional PCF shadows on native), atmospheric fog, tangent-free
  cotangent `normalTexture` (`normalScale`), `metallicRoughnessTexture` (glTF `G` = roughness,
  `B` = metallic), `occlusionTexture` (`occlusionStrength`), `emissiveTexture` + `emissiveColor` /
  `emissiveStrength`, equirectangular `environmentTexture` (`environmentIntensity`) + `SH9` diffuse
  irradiance `EnvironmentProbe3D` (`environmentProbe`, `EnvironmentProbe3D.skyDome` /
  `fromEquirectangular`), `uvScale` / `uvOffset` / `uvRotation`, `alphaCutoff` cutout, `doubleSided`,
  `ditherFade` (Bayer 4x4 screen-door opacity), `singlePieceTranslucent` (`RenderState.depthPrepass`),
  and `instanceData` (`x` = emissive boost, `y` = highlight, `w` = fade).
- `UnlitMaterial` outputs `albedoTexture` times `albedoColor`, times the vertex color, times the
  per-instance color, without lighting. It blends with premultiplied alpha and draws as translucent
  by default; set its `renderState` to `RenderState.opaque` for opaque content.
- `StylizedMaterial` is made for stylized, vertex-colored art without textures, see
  [below](#stylizedmaterial). It receives shadows, `SpotLight`s and atmospheric fog, supports Bayer
  4x4 `ditherFade` and `singlePieceTranslucent`, and packs up to 16 per-instance palette accent
  colors in a single instanced draw.
- `WaterMaterial` renders animated 4-wave Gerstner water surfaces with Schlick Fresnel sky/deep
  absorption, sun specular glints, crest foam, shore fade and atmospheric fog.
- `SkyboxMaterial3D` (paired with `SkyboxComponent3D`) renders procedural atmospheric sky domes
  (zenith/horizon/ground gradient + sun disc) or `2:1` equirectangular sky panoramas at clip depth
  `1.0` behind all opaque and translucent geometry.
- `BillboardMaterial3D` (paired with `BillboardBatch3D` and `Text3DComponent`) renders instanced
  spherical, cylindrical (`upAxis`) or tilted HD-2D standees with atlas sub-rects, alpha cutout,
  depth writes and wrap lighting from directional, point and spot lights.
- `ShadowCatcherMaterial` makes a surface invisible except for the shadows falling on it, so that
  3D objects cast shadows onto 2D art, see [Shadows](shadows.md#shadows-on-2d-art).
- `OutlineMaterial` draws an instanced inverted-hull silhouette contour around static or 64-joint
  skinned meshes (in world units or constant screen-space fraction).
- `DecalMaterial` (paired with `DecalBatch3D` or `PlaneMesh`, including `DecalBatch3D.addBlobShadow`)
  draws procedural soft discs/rings, contact blob shadows or atlas-textured surface decals with
  clip-space depth bias so coplanar decals never Z-fight.
- `RibbonMaterial3D` draws camera-facing 3D polylines and motion trails for `StrokeBatch3D` and
  `RibbonTrail3D`, see [Particles](particles.md#3d-ribbons-and-strokes).

Vertices built from `Vertex` objects, the built-in meshes and parsed models have white vertex
colors, so the vertex color only changes the look of meshes that set it.


## Lights

The lights of a world come from its `LightComponent`s, and are read once per render pass, so their
values can be animated:

| Light              | Component                    | Lights a surface with                        |
| ------------------ | ---------------------------- | -------------------------------------------- |
| `AmbientLight`     | `LightComponent.ambient`     | `color * intensity`, everywhere              |
| `HemisphereLight`  | `LightComponent.hemisphere`  | the sky color above, the ground below        |
| `DirectionalLight` | `LightComponent.directional` | parallel rays along a direction (a sun)      |
| `PointLight`       | `LightComponent.point`       | light from a position, fading out            |
| `SpotLight`        | `LightComponent.spot`        | cone (`innerConeAngle`..`outerConeAngle`)    |

- The first `AmbientLight` and the first `HemisphereLight` of a scene are used. A scene with
  neither gets a white ambient light of intensity `0.2`; a hemisphere light replaces that default.
- `SpatialMaterial` receives `intensity * mix(groundColor, skyColor, hemi)` from a hemisphere
  light, with `hemi = 0.5 + 0.5 * n·up`.
- A directional light travels along its `direction` when it has one, otherwise along the -Z axis
  of its component's world rotation, so rotating the component turns it. Its `specular` factor
  (from `0` to `1`) scales the highlights it makes. Up to `RenderContext3D.maxDirectionalLights`
  (4) are used. With `shadows`, a `ShadowSettings`, it casts shadows, see [Shadows](shadows.md).
- Without a `range`, a point light falls off with the inverse square of the distance `d`:
  `intensity / d²`. With one, it fades out smoothly and reaches no further:
  `intensity * (1 - d / range)²`. Up to `RenderContext3D.maxPointLights` (8) are used.
- A `SpotLight` (`LightComponent.spot`) shines from its component's world position along `direction`
  (or `-Z` of its world rotation when `direction` is `null`), attenuating smoothly between
  `innerConeAngle` and `outerConeAngle` and over `range`. Up to `RenderContext3D.maxSpotLights` (4)
  are used per pass.
- Setting `world.prioritizeNearestLights = true` activates zero-allocation camera/focus-priority
  light culling: scenes with dozens of active `PointLight`s or `SpotLight`s automatically select the
  brightest/nearest `8` point lights and `4` spot lights within range of the camera focus each pass.

```dart
world.addAll([
  LightComponent.hemisphere(
    skyColor: const Color(0xFF9CC2F0),
    groundColor: const Color(0xFF7A6A50),
    intensity: 0.5,
  ),
  LightComponent.directional(
    direction: Vector3(-0.5, -0.8, -0.3),
    intensity: 3,
  ),
  LightComponent.point(
    position: Vector3(0, 1.5, 0),
    color: const Color(0xFFFFA040),
    intensity: 2,
    range: 4,
  ),
]);
```

`SpatialMaterial` is physically based: a directional light needs an intensity of about `3` to light
a white surface facing it fully.


## StylizedMaterial

`StylizedMaterial` lights low-poly meshes whose vertices carry a color, a baked ambient occlusion
and a few masks that pick per-vertex effects: which vertices take the per-instance tint or the
material's accent color, which ones glow, how glossy they are, and how they move in the wind.


### Vertex layout

It reads `StylizedMaterial.vertexLayout`, 18 floats per vertex:

| Attribute         | Floats | Meaning                                                    |
| ----------------- | ------ | ---------------------------------------------------------- |
| `vertexPosition`  | 3      | the position                                               |
| `vertexNormal`    | 3      | the normal                                                 |
| `vertexColor`     | 4      | the color (rgb) and alpha                                  |
| `vertexMasks`     | 4      | the tint, accent and emissive masks, and the gloss         |
| `vertexOcclusion` | 1      | the ambient occlusion: `1` unoccluded, `0` fully occluded  |
| `vertexWind`      | 3      | the sway weight, the phase (in turns), the flutter weight  |

The masks blend from `0` (none) to `1` (fully). The gloss is the strength of the vertex's
highlights; it may exceed `1` for extra bright ones (gems, for instance). The wind of a vertex is
how much it sways, the phase of its sway and flutter in turns (`0` to `1` is a full turn, so that
the vertices of one object need not move in step) and how much it flutters, see [Wind](#wind).

`StylizedMaterial.buildSurface` packs per-vertex arrays into this layout; arrays left out take
their defaults (white, unoccluded, no mask, no sway, phase `0`, no flutter):

```dart
final material = StylizedMaterial(
  accentColor: const Color(0xFF3FA796),
);

final surface = StylizedMaterial.buildSurface(
  positions: positions, // 3 floats per vertex
  normals: normals, // 3 floats per vertex
  colors: colors, // 4 floats per vertex (RGBA)
  occlusion: occlusion, // 1 float per vertex
  tint: tintMask,
  accent: accentMask,
  emissive: emissiveMask,
  gloss: gloss,
  sway: sway, // the sway weight
  windPhase: phase, // in turns, 0 by default
  windFlutter: flutter, // the flutter weight, 0 by default
  indices: indices,
  material: material,
);

world.add(
  MeshComponent(
    mesh: Mesh()..addSurface(surface),
    color: playerColor, // the tint of the tint-masked vertices
  ),
);
```

It also draws surfaces in the standard layout, such as the built-in meshes, parsed models and
skinned meshes: their vertex color is used, and they are unoccluded, tinted by the per-instance
color everywhere, with no accent, emission, gloss nor wind.


### Skinning

Surfaces in `StylizedMaterial.skinnedVertexLayout`, 26 floats per vertex, are skinned: the 18
floats above followed by `vertexJoints` (up to four joint indices) and `vertexWeights` (their
weights), 4 floats each. Each vertex is moved by the weighted sum of the joint matrices of its draw,
`sum(weight * joint) * position` (and its normal by the same matrix), then shaded like any other
vertex; its wind is added in model space after the skinning. A vertex whose weights are all
`0` keeps its position, and weights need not add up to `1` when the joints are built for it (for
example two joints that differ only in a translation, weighted `1 - w` and `w`, move a vertex by
`w` times the difference).

`buildSurface` lays the surface out this way when given `joints` and `weights`, both together; the
indices must be whole numbers below `StylizedMaterial.maxJoints` (64). Every draw of a skinned
surface gives its joint matrices, which can be updated in place every frame:

```dart
final surface = StylizedMaterial.buildSurface(
  positions: positions,
  normals: normals,
  colors: colors,
  joints: joints, // 4 joint indices per vertex
  weights: weights, // 4 weights per vertex
  indices: indices,
  material: material,
  // Culling uses the bounds of the rest pose unless given wider ones.
  aabb: boundsOfEveryPose,
);

final arm = Matrix4.identity();
final figure = MeshComponent(
  mesh: Mesh()..addSurface(surface),
  jointTransforms: {
    0: [Matrix4.identity(), arm], // the joint matrices of surface 0
  },
);

// Every frame: swing the arm about its shoulder.
arm
  ..setIdentity()
  ..translate(shoulder)
  ..rotateY(swing)
  ..translate(-shoulder);
```

A custom `Object3D` gives them to `RenderContext3D.drawSurface(jointTransforms: ...)` instead. A
skinned draw is never batched with another: each costs one draw call, whatever its material.


### Per-instance data

Besides the per-instance color, which tints the vertices of the tint mask, each object can vary
through the four floats of its per-instance data (`MeshComponent.instanceData`, zero by default,
see [Rendering](rendering.md#per-instance-color-and-data)):

| Component | Meaning                                                                       |
| --------- | ----------------------------------------------------------------------------- |
| `x`       | emissive boost: added to `emissiveStrength`, moves the glow color (see below) |
| `y`       | highlight: `highlightColor` times it is added to every vertex                 |
| `z`       | wind strength, added to 1: `-1` stills the object's wind, `1` doubles it      |
| `w`       | fade: the object's opacity is `1 - w`, shown by a translucent material        |

From `0` to `1`, the emissive boost also moves the color of the glowing vertices from
`emissiveColor` towards `emissiveBoostColor` (by default the same color).

Objects that differ only in these values still cost one draw call per surface, so a hovered building
can glow more, or a tree sway less, without a material of its own:

```dart
final ghost = StylizedMaterial(translucent: true);

final house = MeshComponent(mesh: houseMesh); // drawn with an opaque material
final preview = MeshComponent(
  mesh: nextStageMesh, // its surfaces drawn with `ghost`
  instanceData: Vector4(0, 0, 0, 0.6), // 40 % opaque
);

// When the pointer is over the house, it glows and lightens:
house.instanceData
  ..x = 0.4
  ..y = 0.15;
```


### Shading

With `n` the normal, `v` the direction to the viewer, `up`, `sky` and `ground` those of the
hemisphere light, `hemi = 0.5 + 0.5 * n·up`, `bounce = max(0, -n·up)` and `boost`, `highlight` and
`fade` from the instance data:

```text
base = albedoColor * vertexColor * mix(1, instance color, tint mask)
       * mix(1, accentColor, accent mask)
lit  = occlusion * (ambient light
         + hemisphere intensity * (ambientBase
                                   + skyFill * skyFillWeight * sky * hemi
                                   + groundBounce * ground * bounce))
       + Σ directional: max(0, n·l) * intensity * color * shadow
       + Σ point: intensity * color * falloff * max(pointLightWrap, n·l)
spec = only where gloss > specularThreshold:
       Σ directional: (n·h)^specularPower * specular factor
         * gloss * specularStrength * mean(shadow)
rim  = (1 - n·v)^rimPower * rimStrength * (sky + rimColor)
cap  = where gloss > gemThreshold (with a gemMatCapTexture):
         gemMatCapTexture(view-space normal) * gemMatCapStrength
       elsewhere, where gloss > matCapThreshold:
         matCapTexture(view-space normal) * matCapStrength
         * mix(1, gloss, matCapGlossWeight)
surface = base * lit + rim
shaded  = mix(surface + cap, min(surface, 1) * reflected, matCapMetallic)
          + spec + highlight * highlightColor
glow = clamp(emissive mask * (emissiveStrength + boost), 0, 1)
lit  = clamp(mix(shaded,
                 mix(emissiveColor, emissiveBoostColor, clamp(boost, 0, 1)),
                 glow), 0, 1)
out  = mix(mix(luminosity(lit), lit, saturation), overlayColor.rgb,
           overlayColor.a)
alpha = albedoColor.a * vertex alpha * (1 - fade)
```

`falloff` is the point light's (see [Lights](#lights)). `shadow` is `1`, except for the directional
light that casts shadows, where it is `mix(white, color, strength * (1 - visibility))` with the
light's shadow `color` and `strength` and `visibility` from `0` (in its shadow) to `1` (see
[Shadows](shadows.md#receiving-shadows)). MatCap textures are sampled at
`(0.5 + 0.5 x, 0.5 - 0.5 y)` of the view-space normal, `x` pointing right and `y` up in the
picture, also when the projection mirrors the picture (as some `Scene3DProjection`s do).
`reflected` is `cap` on the vertices that get a MatCap texture and `1` on the others (see
[Metals](#metals)). Highlights are white and follow
the direction of the directional lights, not their intensity, so they keep their strength when a sun
dims. The result is clamped to `[0, 1]`, with no tone mapping, graded (see
[Color grade](#color-grade)), and output premultiplied by its alpha. For orthographic cameras, `v`
is the camera's direction. `skyFillWeight` weighs the sky fill per channel, for example
`Vector3(1, 1, 0.914)` with the default `skyFill` for a fill of `(0.35, 0.35, 0.32)` times the sky
color.

| Parameter                                     | Default                   | Meaning              |
| --------------------------------------------- | ------------------------- | -------------------- |
| `albedoColor`                                 | white                     | times vertex color   |
| `accentColor`                                 | white                     | the accent color     |
| `ambientBase`                                 | `0.65` gray               | ambient for all      |
| `skyFill`, `skyFillWeight`                    | `0.35`, `(1, 1, 1)`       | sky share            |
| `groundBounce`                                | `0.10`                    | ground share         |
| `pointLightWrap`                              | `0.18`                    | least point light    |
| `specularStrength`, `specularPower`           | `0.28`, `8`               | highlights           |
| `specularThreshold`                           | `0.12`                    | least gloss to shine |
| `rimStrength`, `rimPower`, `rimColor`         | `0.14`, `3`, black        | rim light            |
| `emissiveColor`, `emissiveStrength`           | white, `1`                | glowing vertices     |
| `emissiveBoostColor`                          | `emissiveColor`           | glow at boost 1      |
| `highlightColor`                              | white                     | instance highlight   |
| `matCapTexture`, `matCapStrength`             | none, `1`                 | MatCap sheen         |
| `matCapThreshold`, `matCapGlossWeight`        | `0`, `1`                  | least gloss, weight  |
| `gemMatCapTexture`, `gemMatCapStrength`       | none, `1`                 | MatCap of gems       |
| `gemThreshold`                                | `1`                       | least gloss of gems  |
| `matCapMetallic`                              | `0`                       | MatCap reflection    |
| `windDirection`, `windAmplitude`, `windSpace` | `(1,0,0)`, `0.032`, world | sway way and reach   |
| `windFrequency`, `windPhase`, `windTime`      | `2.3`, `(0.7,0,0.5)`, `0` | sway timing          |
| `windUpAxis`                                  | `(0, 1, 0)`               | up for `worldScaled` |
| `windFlutterAmplitude`                        | `0` (off)                 | flutter reach        |
| `windFlutterFrequency`                        | `12`                      | flutter timing       |
| `windGustAmplitude`, `windGustFrequency`      | `0` (off), `0.8`          | gusts                |
| `windGustDirection`, `windGustPhaseScale`     | `(1, 0, 0)`, `0.5`        | gusts' travel        |
| `saturation`, `overlayColor`                  | `1`, transparent          | color grade          |

With the defaults, the MatCap texture is added in proportion to the gloss of every vertex. For a
clear-coat sheen on the glossy vertices only and a separate sheen on gems, at full strength:

```dart
final material = StylizedMaterial(
  matCapTexture: clearCoat,
  matCapStrength: 0.6,
  matCapThreshold: 0.36,
  matCapGlossWeight: 0, // the same strength whatever the gloss
  gemMatCapTexture: gemSheen,
  gemThreshold: 1.5, // vertices with more gloss are gems
);
```


### Metals

An added MatCap is a sheen over the surface: a clear coat, the glint of a gem. On metals it washes
the color out, a gold tint plus a bright gold sheen reading as pale yellow. With
`matCapMetallic: 1` the MatCap is the surface's own reflection instead: the lit surface, at most `1`
per channel, multiplies it, so that a gold MatCap on a gold tint gives a deep, saturated gold, dark
where the MatCap is dark. A fully lit white vertex shows the MatCap as painted; vertices without a
MatCap (below `matCapThreshold`) keep their lit color, and values between `0` and `1` blend the
sheen and the reflection. Both tiers reflect, so one material can hold two metals picked by gloss:

```dart
final metals = StylizedMaterial(
  matCapTexture: goldMatCap, // every vertex up to the gem threshold
  matCapThreshold: -1,
  matCapGlossWeight: 0,
  gemMatCapTexture: steelMatCap, // vertices with more gloss than 1.5
  gemThreshold: 1.5,
  matCapMetallic: 1,
  specularStrength: 0, // the MatCaps paint the highlights
);
```


### Color grade

Last, the clamped color is graded. `saturation` moves it towards its luminosity,
`0.3 r + 0.59 g + 0.11 b` (the luminosity of the non-separable blend modes): `1`, the default,
leaves it as it is and `0` turns it grey. Then `overlayColor` covers it as far as its alpha goes:
transparent, the default, leaves it as it is. One material per grade greys out or tints whole
objects whatever their vertex colors, for a disabled or petrified look, or the glint of a shield:

```dart
final stunned = StylizedMaterial(saturation: 0); // grey
final shielded = StylizedMaterial(
  overlayColor: const Color(0x3864FFDA), // 22 % of a cyan glint
);
```

Graded objects still batch with each other, as long as they share their material.


### Wind

A vertex moves along `windDirection` by

```text
offset  = (sway + flutter) * gust * (1 + instanceData.z)
sway    = windAmplitude * sway weight
          * sin(windTime * windFrequency + dot(origin, windPhase) + phase)
flutter = windFlutterAmplitude * flutter weight
          * sin(windTime * windFlutterFrequency + dot(origin, windPhase)
                + phase)
gust    = 1 + windGustAmplitude
              * sin(windTime * windGustFrequency
                    - dot(origin, windGustDirection) * windGustPhaseScale)
```

where `origin` is the world position of its object, `phase` the phase of the vertex in radians
(its phase in turns times `2π`) and `1 + instanceData.z` the wind strength of its object.

- The sway is the slow swing of the whole object, more at the vertices of higher sway weight
  (the tip of a tree more than its trunk). The phase of the vertices delays some of them, so that
  branches or blades of one mesh do not swing in step.
- The flutter is a fast, small sway of the vertices with a flutter weight: leaves, a flag, grass
  tips. It takes the same phases.
- The gust is a slow wave that crosses the scene along `windGustDirection` (normalized, in world
  space), at `windGustFrequency / windGustPhaseScale` world units per second: the wind of the
  objects it reaches strengthens up to `1 + windGustAmplitude` times, and weakens down to
  `1 - windGustAmplitude` times, between its crests. A phase scale of `0` gusts the whole scene in
  unison.

The flutter and the gusts are off by default (their amplitudes are `0`), and vertices built
without a phase have a phase of `0`: a material that does not set them renders as it did before
they existed.

`windSpace` is the space of the direction and of the amplitudes:

| `windSpace`             | Direction    | Amplitudes                                  |
| ----------------------- | ------------ | ------------------------------------------- |
| `WindSpace.world`       | world        | in world units                              |
| `WindSpace.model`       | each model's | in model units: they scale with each object |
| `WindSpace.worldScaled` | world        | times each object's scale along its up axis |

With `WindSpace.world` (the default), every object sways the same way by the same distance. With
`WindSpace.model`, the sway is part of each object, as if it were in its mesh: it turns with the
object's rotation and scales with its scale, so one material serves objects of every orientation
and size, each swaying along its own axes. With `WindSpace.worldScaled`, every object sways the
same world way, whatever its rotation, by a distance scaled by its size along its up axis,
`windUpAxis` (in model space, normalized): a field of trees of every yaw and height bends as one
wind, a tree scaled twice as tall swaying twice as far. Its scale along its up axis is the length
its transform gives `windUpAxis`.

```dart
final trees = StylizedMaterial(
  windSpace: WindSpace.worldScaled,
  windDirection: Vector3(1, 0, 0.3), // the world way of the wind
  windUpAxis: Vector3(0, 1, 0), // the up axis of the tree meshes
  windAmplitude: 0.032, // for a tree of scale 1
  windPhase: Vector3(0.7, 0, 0.5), // from the world position of each tree
  windFlutterAmplitude: 0.006, // the leaves
  windFlutterFrequency: 13,
  windGustAmplitude: 0.5, // gusts from 0.5 to 1.5 times the wind
  windGustDirection: Vector3(1, 0, 0.3),
);
```

The wind moves the vertices only where they are drawn: the shadows are cast from the rest
positions, so the wind does not move them (see [Shadows](shadows.md)).

Advance `windTime` every frame, and drive `emissiveStrength` from the time of day to light
windows at dusk:

```dart
@override
void update(double dt) {
  material
    ..windTime += dt
    ..emissiveStrength = dusk;
}
```


### Batching, accent palettes, and translucency

Like the other built-in materials, it is drawn instanced: components sharing a mesh with a
`StylizedMaterial` cost one draw call per surface, whatever their tints and instance data. To vary
the accent color per instance without splitting draw calls, supply `accentPalette` (up to
`StylizedMaterial.maxAccentPalette` = 16 colors) and pack the palette index (with an optional fade)
into `instanceData.w` via `StylizedMaterial.packAccentAndFade(index, fade: 0.0)`:

```dart
final material = StylizedMaterial(
  accentPalette: const [Color(0xFFE53935), Color(0xFF1E88E5), Color(0xFF43A047)],
);
final unit = MeshComponent(
  mesh: unitMesh,
  instanceData: Vector4(0, 0, 0, StylizedMaterial.packAccentAndFade(1)),
);
```

When `instanceData.w < 2.0`, it acts purely as `fade` (`0..1`), preserving backwards compatibility.

`StylizedMaterial(translucent: true)` blends its premultiplied output over what is behind it
(`StylizedMaterial.translucentRenderState`: depth tested, without depth writes), and its draws are
sorted back to front after the opaque ones; objects then fade with the `w` of their instance data.
Consecutive translucent draws of one surface are still batched. Back-face culling
(`renderState = StylizedMaterial.translucentRenderState.copyWith(cullMode: CullMode.backFace)`)
keeps the inner faces of a closed mesh from showing through.

```{note}
`StylizedMaterial` is not available on the web yet: creating one there throws an
`UnsupportedError`.
```


## Atmospheric fog, silhouette outlines, and surface decals


### Atmospheric fog (`FogSettings`)

Assigning `world.fog = FogSettings(...)` fades surfaces smoothly towards `FogSettings.color` by
distance (`FogMode.linear`, `exponential` or `exponentialSquared`) plus optional vertical ground
mist (`heightFalloff` below `baseHeight`, along `upAxis`):

```dart
world.fog = FogSettings(
  color: const Color(0xFF9AB4D2),
  mode: FogMode.linear,
  start: 12,
  end: 48,
  heightDensity: 0.25,
  baseHeight: 0,
  heightFalloff: 0.6,
);
```

`StylizedMaterial` applies `world.fog` automatically with zero extra bindings; custom shaders
include `flame_3d/fog.glsl` and declare `RenderContext3D.fogBlock` (`'Fog'`).


### Silhouette outlines (`OutlineMaterial`)

`OutlineMaterial` extrudes front-culled backfaces along smooth vertex normals to draw crisp
cel-shaded or selection contours around static and 4-joint skinned meshes. With
`screenSpace: true`, `thickness` is scaled by clip `w` so silhouettes stay a uniform width across
distances, and `instanceData.x` scales thickness per instance (`0` defaults to `1`):

```dart
final outline = OutlineMaterial(
  color: const Color(0xFF1A1423),
  thickness: 0.025,
  screenSpace: true,
);
```


### Surface decals (`DecalMaterial` and `DecalBatch3D`)

`DecalBatch3D` batches ground rings, selection markers, footprints and scorch marks into a single
instanced draw call, nudged towards the viewer in clip space (`DecalMaterial.depthBias`) to prevent
Z-fighting on coplanar floors. Without a texture, `DecalMaterial` renders a procedural soft disc or
annular ring (`innerRadius`, `softness`); with an atlas texture, each decal can specify its own
normalized `uvRect`:

```dart
final decals = DecalBatch3D(
  material: DecalMaterial(innerRadius: 0.72, softness: 0.08),
)
  ..addFlatDecal(
    center: Vector3(3, 4, 0),
    width: 1.4,
    height: 1.4,
    normal: Vector3(0, 0, 1),
    color: const Color(0xFFFFD54F),
  );
world.add(decals);
```


## Textures

A `Texture` is uploaded from its pixels the first time it is used. How it is sampled is its
`sampler`, a `TextureSampler` value that may be changed at any time:

- `minFilter`, `magFilter` and `mipFilter`: `TextureFilter.nearest` (the default) or
  `TextureFilter.linear`, when the texture is drawn smaller, larger, and between mip levels.
- `wrapU` and `wrapV`: `TextureWrap.clamp` (the default), `TextureWrap.repeat` or
  `TextureWrap.mirror`, for coordinates outside `[0, 1]`.

`TextureSampler.linear` filters linearly, and `TextureSampler.all(filter: ..., wrap: ...)` sets
every option at once.

With `mipmaps: true`, a texture builds its mip levels on the CPU (each level averages 2x2 pixels of
the previous one) and uploads them, so that it does not shimmer when drawn small. Devices that
cannot sample mip levels uploaded by hand get the full-size level only.

```dart
final tiles = Texture(
  pixels,
  width: 256,
  height: 256,
  mipmaps: true,
  sampler: const TextureSampler.all(
    filter: TextureFilter.linear,
    wrap: TextureWrap.repeat,
  ),
);
```

`ImageTexture.create(image)` (and `Images.loadTexture`) shares the GPU memory of the image without
copying it, where the GPU backend can: on Flutter GPU, for images backed by a GPU texture, such as
decoded images and those of `Picture.toImage`. Otherwise, and when mipmaps are asked for, the
pixels are read back with `Image.toByteData` and uploaded.


## Custom shaders

A custom shader can read the lights by including `flame_3d/lights.glsl`, which declares the blocks
the `RenderContext3D` fills once per pass. List the blocks the shader uses in its material's slots:

| Block               | Members                                                     |
| ------------------- | ----------------------------------------------------------- |
| `AmbientLight`      | `color`, `intensity`                                        |
| `Lights`            | `numLights`, `positions`, `colors`, `intensities`, `ranges` |
| `DirectionalLights` | `numLights`, `directions`, `colors`                         |
| `HemisphereLight`   | `skyColor`, `groundColor`, `up`, `intensity`                |

Shaders that receive shadows include `flame_3d/shadows.glsl`, list its `Shadows` block and
`shadowMap` sampler in their slots, and call its `shadowVisibility`, see
[Shadows](shadows.md#receiving-shadows).

A point light's intensity and range are in the `x` of `intensities` and `ranges`; its range is `0`
when it falls off with the inverse square of the distance. A directional light's `directions` hold
the unit vector from a surface towards the light (`xyz`) and its specular factor (`w`), and its
`colors` hold its color (`rgb`) and intensity (`a`).

A material can draw several vertex layouts by overriding `Material.vertexShaderFor` to return a
vertex shader variant per layout, all feeding the same fragment shader; `StylizedMaterial` does so
for the standard layout.


## Web

On the web, `SpatialMaterial` and `UnlitMaterial` support the vertex color, every kind of light
and the texture sampler options, through hand-written WebGPU shaders. `StylizedMaterial` and
`ShadowCatcherMaterial` are native only for now, and so are shadows.
