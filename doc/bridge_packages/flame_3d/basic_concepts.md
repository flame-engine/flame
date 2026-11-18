# Basic Concepts

Before delving into the details, let's explore some key concepts and terminology used in 3D
rendering and how they apply to `flame_3d`.


## Vertices, Surfaces, Meshes, and Models

A **vertex** is a point in 3D space (think `Vector3`), with a few more properties such as a normal
vector, texture coordinates, color and joint information.

Using vertices arranged in triangles, you can create a **surface**. A surface is simply a collection
of triangles that share the same material.

Then, you can group multiple surfaces into a **mesh** - a "solid" shape in 3D world. A mesh can be
as simple as a cube or a sphere, and many procedural generators are provided out of the box:
`CuboidMesh`, `SphereMesh`, `PlaneMesh`, `CylinderMesh`, `ConeMesh`, `CapsuleMesh`, `TorusMesh`,
`TubeSplineMesh` (along a `CatmullRomSpline3D`), and `TerrainMesh3D` (heightfield or procedural fBm
island with `sampleHeight` / `sampleNormal` and automatic 32-bit indices above 65,535 vertices). You
can also create custom meshes by providing your own vertices and triangle indices, or mutate vertex
buffers dynamically via `Surface.updateVertices` and `Surface.applyMorphWeights`.

Finally, a **model** is a collection of meshes, usually loaded from an external file. Models can
also contain animations, which can be played on the model class.

Typically, for most games, unless you are working with basic shapes and polygons, all your
components will be `ModelComponent`s loaded from external model files. Currently, `flame_3d`
supports the formats `OBJ` (for very simple models, only vertices) and `GLTF` or `GLB` (for complex
models, with custom materials and animations).


## Component Hierarchy

The main building block of a 3D scene is the `Component3D`, which is the base class for all 3D:

```{include} ../../flame/diagrams/flame_3d_components.md
```

Instead of extending `World` directly, your `FlameGame`'s world must be an instance `World3D`. You
can add normal Flame `Component`s to it, which will be rendered as usual, and you can also add
`Component3D`s, which will be rendered in 3D space. You can also add `LightComponent`s to the
`World3D` (note: as of now, they need to be added to the root of the world), which will add light
sources to the scene. Light sources are not rendered themselves, just change how other
`Component3D`s are rendered.


## Camera

A `CameraComponent3D` looks at the `World3D`. By default it is a look-at camera: it sits at
`position`, looks at `target`, and keeps `up` pointing up on screen. The `projection` is either
`CameraProjection.perspective`, with a vertical field of view of `fovY` degrees, or
`CameraProjection.orthographic`, whose view volume is `orthographicHeight` world units tall (one
world unit then covers `viewport.virtualSize.y / orthographicHeight` logical pixels). Everything
between the `near` and `far` distances from the eye is drawn; an orthographic camera also accepts a
zero or negative `near`, which keeps geometry behind the eye.

```dart
final camera = CameraComponent3D(
  projection: CameraProjection.orthographic,
  orthographicHeight: 12,
  near: -50,
  far: 50,
  position: Vector3(10, 10, 10),
  target: Vector3.zero(),
  up: Vector3(0, 0, 1),
);
```

The projections target the clip space of Impeller and WebGPU: the near plane maps to depth 0 and
the far plane to depth 1. The `Matrix4` extensions `setAsPerspective`, `setAsOrthographic` and
`setAsOrthographicOffCenter` build such matrices; vector_math's `setPerspectiveMatrix` and
`setOrthographicMatrix` follow OpenGL's -1 to 1 depth range instead, and Impeller would clip the
nearer half of it away.

A `customViewMatrix` or `customProjectionMatrix` replaces the look-at view or the built-in
projection with any matrix, for example an oblique or a mirrored dimetric projection that no
look-at camera produces. Everything the camera derives follows them: the `frustum` used for
culling, the `eyePosition`, and the conversions below. A mirroring matrix reverses the winding of
the triangles on screen: the determinant of `projectionMatrix * viewMatrix` is negative for an
ordinary camera and positive for a mirrored one.

```dart
// Swaps world x and y: a mirrored view.
final swapXY = Matrix4.identity()
  ..setEntry(0, 0, 0)
  ..setEntry(0, 1, 1)
  ..setEntry(1, 0, 1)
  ..setEntry(1, 1, 0);
camera.customViewMatrix = Matrix4.zero()
  ..setAsViewMatrix(Vector3(12, 12, 10), Vector3.zero(), Vector3(0, 0, 1))
  ..multiply(swapXY);
camera.customProjectionMatrix = Matrix4.zero()
  ..setAsOrthographicOffCenter(-8, 8, -6, 6, -50, 50);
```

The camera caches its matrices and its frustum and recomputes them only after one of its inputs
changed, including changes made in place such as `camera.position.x += 1`. Its `version` increases
whenever that happens, so derived data can be kept until the version differs.

To turn a pointer position into a world-space ray, pass the point in viewport coordinates to
`viewportPointToRay`; for a viewport that fills the game that is the event's `canvasPosition`. The
opposite direction, `worldToViewportPoint`, tells where a world-space point is drawn, for example
to place a 2D label over a 3D object.

```dart
final ground = Plane.normalconstant(Vector3(0, 0, 1), 0);

@override
void onTapUp(TapUpEvent event) {
  final ray = camera.viewportPointToRay(event.canvasPosition);
  final t = ray.intersectsWithPlane(ground);
  if (t != null) {
    final groundPoint = ray.at(t);
    // ...
  }
}
```
