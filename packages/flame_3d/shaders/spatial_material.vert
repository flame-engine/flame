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

uniform JointMatrices {
  mat4 joints[16];
} jointMatrices;

mat4 computeSkinMatrix() {
  if (vertexWeights.x == 0.0 && vertexWeights.y == 0.0 && vertexWeights.z == 0.0 && vertexWeights.w == 0.0) {
    return mat4(1.0);
  }

  return vertexWeights.x * jointMatrices.joints[int(vertexJoints.x)] +
    vertexWeights.y * jointMatrices.joints[int(vertexJoints.y)] +
    vertexWeights.z * jointMatrices.joints[int(vertexJoints.z)] +
    vertexWeights.w * jointMatrices.joints[int(vertexJoints.w)];
}

void main() {
  mat4 skinMatrix = computeSkinMatrix();
  vec3 position = (skinMatrix * vec4(vertexPosition, 1.0)).xyz;
  vec3 normal = normalize((skinMatrix * vec4(vertexNormal, 0.0)).xyz);

  // Calculate the modelview projection matrix
  mat4 modelViewProjection = vertex_info.projection * vertex_info.view * vertex_info.model;

  // Transform the vertex position
  gl_Position = modelViewProjection * vec4(position, 1.0);

  // Pass the interpolated values to the fragment shader
  fragTexCoord = vertexTexCoord;
  fragColor = vertexColor;

  // Calculate the world-space position and normal
  fragPosition = vec3(vertex_info.model * vec4(position, 1.0));
  fragNormal = mat3(transpose(inverse(vertex_info.model))) * normal;
}
