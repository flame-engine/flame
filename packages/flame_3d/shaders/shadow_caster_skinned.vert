#version 460 core

// shadow_caster.vert for surfaces whose vertices have joints and joint
// weights: they are skinned first, as the materials skin them.

in vec3 vertexPosition;

#include <flame_3d/skinning.glsl>
#include <flame_3d/instancing.glsl>
#include <flame_3d/camera.glsl>

out float fragDepth;

void main() {
  vec4 position = computeSkinMatrix() * vec4(vertexPosition, 1.0);
  vec4 worldPosition = instanceModelMatrix() * vec4(position.xyz, 1.0);
  gl_Position = camera.viewProjection * worldPosition;
  fragDepth = gl_Position.z / gl_Position.w;
}
