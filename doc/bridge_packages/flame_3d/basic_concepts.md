# Basic Concepts

Before delving into the details, let's explore some key concepts and terminology used in 3D
rendering and how they apply to `flame_3d`.


## Vertices, Surfaces, Meshes, and Models

A **vertex** is a point in 3D space (think `Vector3`), with a few more properties such as a normal
vector, texture coordinates, color and joint information.

Using vertices arranged in triangles, you can create a **surface**. A surface is simply a collection
of triangles that share the same material.

Then, you can group multiple surfaces into a **mesh** - a "solid" shape in 3D world. A mesh can be
as simple as a cube or a sphere, and many pre-defined options are provided by Flame, such as `Cube`,
`Sphere`, `Plane`, and `Cylinder`. You can also create custom meshes by providing your own vertices
and triangle indices.

Finally, a **model** is a collection of meshes, usually loaded from an external file. Models can
also contain animations, which can be played on the model class.

Typically, for most games, unless you are working with basic shapes and polygons, all your
components will be `ModelComponent`s loaded from external model files. Currently, `flame_3d`
supports the formats `OBJ` (for very simple models, only vertices) and `GLTF` or `GLB` (for complex
models, with custom materials and animations).


## Component Hierarchy

The main building block of a 3D scene is the `Component3D`, which is the base class for all 3D:

```{include} diagrams/flame_3d_components.md
```

Instead of extending `World` directly, your `FlameGame`'s world must be an instance `World3D`. You
can add normal Flame `Component`s to it, which will be rendered as usual, and you can also add
`Component3D`s, which will be rendered in 3D space. You can also add `LightComponent`s to the
`World3D` (note: as of now, they need to be added to the root of the world), which will add light
sources to the scene. Light sources are not rendered themselves, just change how other
`Component3D`s are rendered.

