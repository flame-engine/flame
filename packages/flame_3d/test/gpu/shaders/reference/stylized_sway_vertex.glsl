#ifndef REFERENCE_STYLIZED_SWAY_VERTEX_GLSL_
#define REFERENCE_STYLIZED_SWAY_VERTEX_GLSL_

// flame_3d/stylized_material_vertex.glsl as it was before the per-vertex
// phase and flutter and the gusts: one float of sway weight per vertex
// (`vertexSway`, 16 floats per vertex, 24 skinned) and a Wind block without
// the flutter, the gusts and the up axis. The GPU tests check that the
// vertex stage renders the same pixels as this one when they are unused.
//
// The vertex stage of StylizedMaterial for its own vertex layout
// (StylizedMaterial.vertexLayout): stylized_material.vert draws the vertices
// as they are, stylized_material_skinned.vert skins them first. Both feed
// flame_3d/stylized_material_fragment.glsl.

in vec3 vertexPosition;
in vec3 vertexNormal;
// rgb: the vertex color, a: its alpha.
in vec4 vertexColor;
// x: tint mask, y: accent mask, z: emissive mask, w: gloss.
in vec4 vertexMasks;
// Ambient occlusion: 1 is unoccluded, 0 fully occluded.
in float vertexOcclusion;
// How much the vertex sways in the wind.
in float vertexSway;

#include <flame_3d/instancing.glsl>
#include <flame_3d/camera.glsl>

// The wind sway: a vertex moves by
// `amplitude * sin(time * frequency + dot(origin, phaseScale))` times its sway
// weight and the strength of its instance (`1 + instanceData.z`), along
// `direction` in world space and along `modelDirection` in the model space of
// its object (so that it turns and scales with the object), where `origin` is
// the world position of its object. The material sets one of the two
// directions and zeroes the other.
uniform Wind {
  vec3 direction;
  float amplitude;
  vec3 modelDirection;
  float frequency;
  vec3 phaseScale;
  float time;
} wind;

out vec3 fragPosition;
out vec3 fragNormal;
out vec4 fragColor;
out vec4 fragMasks;
out float fragOcclusion;
out vec4 fragInstanceColor;
out vec4 fragInstanceData;

// Transforms normals by the model matrix: its cofactor matrix, which is the
// inverse transpose up to a scale, keeps them perpendicular to the surface
// under any scale.
vec3 transformNormal(mat4 model, vec3 normal) {
  vec3 x = model[0].xyz;
  vec3 y = model[1].xyz;
  vec3 z = model[2].xyz;
  mat3 cofactor = mat3(cross(y, z), cross(z, x), cross(x, y));
  float side = dot(x, cross(y, z)) < 0.0 ? -1.0 : 1.0;
  return cofactor * normal * side;
}

// Emits the vertex whose model-space position and normal are [position] and
// [normal] (the vertex's own, or skinned): the wind sway is added in model
// space, then the instance's model matrix places it in the world.
void emitStylizedVertex(vec3 position, vec3 normal) {
  mat4 model = instanceModelMatrix();
  float phase = wind.time * wind.frequency + dot(model[3].xyz, wind.phaseScale);
  float sway = sin(phase) * wind.amplitude * vertexSway *
    (1.0 + instanceData.z);
  vec4 worldPosition = model * vec4(position + wind.modelDirection * sway, 1.0);
  worldPosition.xyz += wind.direction * sway;
  gl_Position = camera.viewProjection * worldPosition;

  fragPosition = worldPosition.xyz;
  fragNormal = transformNormal(model, normal);
  fragColor = vertexColor;
  fragMasks = vertexMasks;
  fragOcclusion = vertexOcclusion;
  fragInstanceColor = instanceColor;
  fragInstanceData = instanceData;
}

#endif
