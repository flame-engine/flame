#version 460 core

// ShadowCatcherMaterial: an invisible surface that shows only the shadows
// falling on it. It reads the position and the normal of any vertex layout
// that has them.

in vec3 vertexPosition;
in vec3 vertexNormal;

#include <flame_3d/instancing.glsl>
#include <flame_3d/camera.glsl>

out vec3 fragPosition;
out vec3 fragNormal;
out vec4 fragInstanceColor;

// Transforms normals by the cofactor matrix of the model matrix, see
// stylized_material.vert.
vec3 transformNormal(mat4 model, vec3 normal) {
  vec3 x = model[0].xyz;
  vec3 y = model[1].xyz;
  vec3 z = model[2].xyz;
  mat3 cofactor = mat3(cross(y, z), cross(z, x), cross(x, y));
  float side = dot(x, cross(y, z)) < 0.0 ? -1.0 : 1.0;
  return cofactor * normal * side;
}

void main() {
  mat4 model = instanceModelMatrix();
  vec4 worldPosition = model * vec4(vertexPosition, 1.0);
  gl_Position = camera.viewProjection * worldPosition;

  fragPosition = worldPosition.xyz;
  fragNormal = transformNormal(model, vertexNormal);
  fragInstanceColor = instanceColor;
}
