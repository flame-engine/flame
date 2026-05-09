#version 460 core

in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec4 vertexColor;
in vec3 vertexNormal;
in vec4 vertexJoints;
in vec4 vertexWeights;

out vec2 fragTexCoord;
out vec4 fragColor;
out vec3 fragPosition;
out vec3 fragNormal;

uniform VertexInfo {
  mat4 model;
  mat4 view;
  mat4 projection;
} vertex_info;

void main() {
  mat4 mvp = vertex_info.projection * vertex_info.view * vertex_info.model;
  gl_Position = mvp * vec4(vertexPosition, 1.0);

  fragTexCoord = vertexTexCoord;
  fragColor = vertexColor;

  // Pass through all vertex attributes so the compiler doesn't strip them,
  // which would break the vertex buffer layout.
  fragPosition = vertexPosition + vertexJoints.xyz * vertexWeights.x;
  fragNormal = vertexNormal;
}
