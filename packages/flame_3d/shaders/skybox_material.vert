#version 460 core

// Fullscreen clip-space skybox quad drawn at far clip depth `z = w = 1.0` so
// Early-Z skips every pixel covered by opaque scene geometry.

in vec3 vertexPosition;

out vec2 fragNdc;

void main() {
  fragNdc = vertexPosition.xy;
  gl_Position = vec4(vertexPosition.xy, 1.0, 1.0);
}
