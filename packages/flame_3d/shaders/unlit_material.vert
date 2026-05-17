#version 460 core

in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec4 vertexColor;
in vec3 vertexNormal;

#include <flame_3d/skinning.glsl>

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
  mat4 skinMatrix = computeSkinMatrix();
  vec3 position = (skinMatrix * vec4(vertexPosition, 1.0)).xyz;
  vec3 normal = normalize((skinMatrix * vec4(vertexNormal, 0.0)).xyz);

  mat4 modelViewProjection = vertex_info.projection * vertex_info.view * vertex_info.model;
  gl_Position = modelViewProjection * vec4(position, 1.0);

  fragTexCoord = vertexTexCoord;
  fragColor = vertexColor;
  fragPosition = vec3(vertex_info.model * vec4(position, 1.0));
  fragNormal = mat3(transpose(inverse(vertex_info.model))) * normal;
}
