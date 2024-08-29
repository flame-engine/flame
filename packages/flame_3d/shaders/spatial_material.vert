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
  mat4 joint0;
  mat4 joint1;
  mat4 joint2;
  mat4 joint3;
  mat4 joint4;
  mat4 joint5;
  mat4 joint6;
  mat4 joint7;
  mat4 joint8;
  mat4 joint9;
  mat4 joint10;
  mat4 joint11;
  mat4 joint12;
  mat4 joint13;
  mat4 joint14;
  mat4 joint15;
} joints;

mat4 jointMat(float jointIndex) {
  if (jointIndex == 0.0) {
    return joints.joint0;
  } else if (jointIndex == 1.0) {
    return joints.joint1;
  } else if (jointIndex == 2.0) {
    return joints.joint2;
  } else if (jointIndex == 3.0) {
    return joints.joint3;
  } else if (jointIndex == 4.0) {
    return joints.joint4;
  } else if (jointIndex == 5.0) {
    return joints.joint5;
  } else if (jointIndex == 6.0) {
    return joints.joint6;
  } else if (jointIndex == 7.0) {
    return joints.joint7;
  } else if (jointIndex == 8.0) {
    return joints.joint8;
  } else if (jointIndex == 9.0) {
    return joints.joint9;
  } else if (jointIndex == 10.0) {
    return joints.joint10;
  } else if (jointIndex == 11.0) {
    return joints.joint11;
  } else if (jointIndex == 12.0) {
    return joints.joint12;
  } else if (jointIndex == 13.0) {
    return joints.joint13;
  } else if (jointIndex == 14.0) {
    return joints.joint14;
  } else if (jointIndex == 15.0) {
    return joints.joint15;
  } else {
    return mat4(0.0);
  }
}

mat4 computeSkinMatrix() {
  if (vertexWeights.x == 0.0 && vertexWeights.y == 0.0 && vertexWeights.z == 0.0 && vertexWeights.w == 0.0) {
    // no weights, skip skinning
    return mat4(1.0);
  }

  return vertexWeights.x * jointMat(vertexJoints.x) +
    vertexWeights.y * jointMat(vertexJoints.y) +
    vertexWeights.z * jointMat(vertexJoints.z) +
    vertexWeights.w * jointMat(vertexJoints.w);
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
