#version 460 core

in vec3 vertexPosition;

out vec2 fragUv;

void main() {
  gl_Position = vec4(vertexPosition.xy, 0.0, 1.0);
  fragUv = vec2(0.5 + 0.5 * vertexPosition.x, 0.5 - 0.5 * vertexPosition.y);
}
