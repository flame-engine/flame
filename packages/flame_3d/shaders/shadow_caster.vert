#version 460 core

// Renders the depth of shadow casters, seen from the light that casts
// shadows, into its shadow map. It reads only the position, so it draws the
// surfaces of every vertex layout that has one; shadow_caster_skinned.vert
// skins those whose vertices have joints and joint weights. The camera is the
// light's view.

in vec3 vertexPosition;

#include <flame_3d/instancing.glsl>
#include <flame_3d/camera.glsl>

out float fragDepth;

void main() {
  vec4 worldPosition = instanceModelMatrix() * vec4(vertexPosition, 1.0);
  gl_Position = camera.viewProjection * worldPosition;
  fragDepth = gl_Position.z / gl_Position.w;
}
