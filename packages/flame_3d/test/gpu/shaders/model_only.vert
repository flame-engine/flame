#version 460 core

// Includes the instancing chunk and uses only the model matrix, neither the
// instance color nor the instance data.
in vec3 vertexPosition;

#include <flame_3d/instancing.glsl>
#include <flame_3d/camera.glsl>

out vec4 fragColor;

void main() {
  gl_Position = camera.viewProjection * instanceModelMatrix() *
    vec4(vertexPosition, 1.0);
  fragColor = vec4(1.0, 0.5, 0.0, 1.0);
}
