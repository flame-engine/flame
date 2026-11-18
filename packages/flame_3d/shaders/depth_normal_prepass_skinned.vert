#version 460 core

in vec3 vertexPosition;

#include <flame_3d/skinning.glsl>
#include <flame_3d/instancing.glsl>
#include <flame_3d/camera.glsl>

out float fragDepth;
out vec3 fragViewPos;

void main() {
  vec4 skinnedPos = computeSkinMatrix() * vec4(vertexPosition, 1.0);
  vec4 worldPos = instanceModelMatrix() * vec4(skinnedPos.xyz, 1.0);
  vec4 viewPos = camera.view * worldPos;
  gl_Position = camera.projection * viewPos;
  fragDepth = gl_Position.z / max(gl_Position.w, 1e-6);
  fragViewPos = viewPos.xyz;
}
