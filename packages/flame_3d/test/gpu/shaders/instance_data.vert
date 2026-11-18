#version 460 core

// Draws the instance data as a color: the per-instance inputs a material can
// interpret as it likes.
in vec3 vertexPosition;

#include <flame_3d/instancing.glsl>
#include <flame_3d/camera.glsl>

out vec4 fragColor;

void main() {
  gl_Position = camera.viewProjection * instanceModelMatrix() *
    vec4(vertexPosition, 1.0);
  fragColor = instanceData;
}
