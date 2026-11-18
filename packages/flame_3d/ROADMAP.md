# Roadmap

In the interest of transparency, we provide a high-level detail of the roadmap for adding 3D
support to Flame. We hope this roadmap will help others in making plans and priorities based on the
work we are doing and potentially contribute back to the project itself.

The goal of the package can be split up into two sections, the primary goal is to provide an API for
Flame developers so they can create 3D environments without having to learn new Flame concepts. This
means the package will tie into the existing [FCS](https://docs.flame-engine.org/latest/flame/components.html#component)
and provide the tools needed, like a [`CameraComponent`](https://docs.flame-engine.org/latest/flame/camera_component.html),
`World` and similar components.

In a perfect world this API does not depend or even know about the Flutter GPU, which brings us
to our secondary goal: to abstract the Flutter GPU into an API that is user-friendly for 3D
development. That includes simplifying things like creating render targets, setting up the color
and depth textures and configuring depth stencils. But it also includes higher level APIs like
geometric shapes, texture/material rendering and creating Meshes that can use those shapes and
materials.


## Goals


### Abstracting the Flutter GPU into a user-friendly API for 3D

- [x] Abstract the GPU setup into a class that represents the graphics device
  - [x] Setup binding logic for meshes, geometry and materials.
  - [x] Bind pipelines, render state and resources only when they change.
  - [x] Upload data shared by a render pass (camera, lights) once per pass.
  - [x] Report frame statistics (draw calls, instances, triangles, state changes).
- [x] Batch draws of the same surface and material into instanced draws.
  - [x] Sort opaque draws to batch and limit state changes, translucent draws back to front.
- [x] Give materials their own render state (blending, depth test and writes, culling).
  - [x] Keep back-face culling right for mirroring cameras and mirrored objects.
- [x] Real-time shadows from a directional light.
  - [x] Fit the shadow map to what the camera sees, aligned with its texels.
  - [x] Soft edges, tinted shadows, and a shadow catcher for 2D ground.
  - [ ] Cascaded shadow maps for large scenes, and shadows from point lights.
- [ ] Provide a `Mesh` API
  - [x] Provide `Surface`s that can hold geometric shapes.
  - [x] Build `Surface`s straight from typed arrays, with custom vertex layouts.
  - [x] Support 32-bit indices for large surfaces.
  - [x] Provide a `Material` API
    - [x] Define a `Texture` API to be used with the `Material` API
      - [x] Support images as textures
      - [x] Support single color textures
      - [x] Support generated textures
    - [x] Provide a standard `Material`
  - [ ] Support custom shaders
    - [ ] Add a more dev friendly way to set uniforms
  - [x] Support multiple `Material`s by defining surfaces on a mesh.


### Providing a familiar API for developers to use 3D with Flame

- [x] Use the existing `CameraComponent` API for 3D rendering
  - [x] Provide a custom `World`
  - [x] Support existing and custom viewports
  - [ ] Support existing and custom viewfinders
- [x] Create a new core component for 3D rendering (`Component3D`)
  - [x] Implement a `Transform3D` for 3D transformations
    - [x] Implement a notifying `Vector3` and `Quaternion` for 3D positioning and rotation
  - [ ] Add support for gesture event callbacks
- [x] Create a component that can show meshes (`MeshComponent`)
  - [x] Ensure materials can be set outside of construction (in the `onLoad` for instance)
