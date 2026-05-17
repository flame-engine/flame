#ifndef FLAME_SKINNING_GLSL_
#define FLAME_SKINNING_GLSL_

in vec4 vertexJoints;
in vec4 vertexWeights;

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

#endif
