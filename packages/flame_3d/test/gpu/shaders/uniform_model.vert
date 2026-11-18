#version 460 core

// No instance inputs: the model matrix comes from a uniform block, set by the
// material for every draw.
in vec3 vertexPosition;
in vec4 vertexColor;

uniform VertexInfo {
  mat4 model;
  mat4 view;
  mat4 projection;
} vertex_info;

out vec4 fragColor;

void main() {
  gl_Position = vertex_info.projection * vertex_info.view * vertex_info.model *
    vec4(vertexPosition, 1.0);
  fragColor = vertexColor;
}
