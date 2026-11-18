#version 460 core

// A custom vertex layout: a position and a color, nothing else.
in vec3 vertexPosition;
in vec4 vertexColor;

#include <flame_3d/instancing.glsl>
#include <flame_3d/camera.glsl>

out vec4 fragColor;

void main() {
  vec4 worldPosition = instanceModelMatrix() * vec4(vertexPosition, 1.0);
  gl_Position = camera.viewProjection * worldPosition;
  fragColor = vertexColor * instanceColor;
}
