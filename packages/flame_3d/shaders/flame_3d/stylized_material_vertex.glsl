#ifndef FLAME_STYLIZED_MATERIAL_VERTEX_GLSL_
#define FLAME_STYLIZED_MATERIAL_VERTEX_GLSL_

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
// The wind of the vertex. x: how much it sways (its sway weight), y: the
// phase of its sway and flutter, in turns (1 is a full turn), z: how much it
// flutters (its flutter weight).
in vec3 vertexWind;

#include <flame_3d/instancing.glsl>
#include <flame_3d/camera.glsl>

// The wind. A vertex moves by
//
//   offset  = (sway + flutter) * gust * (1 + instanceData.z)
//   sway    = amplitude * sin(time * frequency + dot(origin, phaseScale)
//                             + vertexPhase) * sway weight
//   flutter = flutterAmplitude * sin(time * flutterFrequency
//                                    + dot(origin, phaseScale) + vertexPhase)
//             * flutter weight
//   gust    = 1 + gustAmplitude * sin(time * gustFrequency
//                                     - dot(origin, gustWave))
//
// where `origin` is the world position of its object and `vertexPhase` the
// phase of the vertex in radians. The offset goes along `direction` in world
// space and along `modelDirection` in the model space of its object (so that
// it turns and scales with the object): the material sets one of the two
// directions and zeroes the other. When `upAxis` (a unit vector in model
// space) is not zero, the world-space offset is scaled by the length the
// object's transform gives it, the scale of the object along its up axis.
// `gustWave` is the direction gusts travel in, in world space, times how fast
// their phase changes along it.
uniform Wind {
  vec3 direction;
  float amplitude;
  vec3 modelDirection;
  float frequency;
  vec3 phaseScale;
  float time;
  vec3 upAxis;
  float flutterAmplitude;
  vec3 gustWave;
  float flutterFrequency;
  float gustAmplitude;
  float gustFrequency;
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
// [normal] (the vertex's own, or skinned): the wind offset is added in model
// space, then the instance's model matrix places it in the world.
//
// With the per-vertex phase and flutter weight at 0, the flutter is 0 and,
// with the gust amplitude at 0, the gust is 1: the offset is the sway alone,
// computed as it was before they existed.
void emitStylizedVertex(vec3 position, vec3 normal) {
  mat4 model = instanceModelMatrix();
  vec3 origin = model[3].xyz;
  float objectPhase = dot(origin, wind.phaseScale);
  float vertexPhase = vertexWind.y * 6.283185307;
  float phase = wind.time * wind.frequency + objectPhase + vertexPhase;
  float sway = sin(phase) * wind.amplitude * vertexWind.x;
  float flutter = sin(
    wind.time * wind.flutterFrequency + objectPhase + vertexPhase
  ) * wind.flutterAmplitude * vertexWind.z;
  float gust = 1.0 + wind.gustAmplitude *
    sin(wind.time * wind.gustFrequency - dot(origin, wind.gustWave));
  float offset = (sway + flutter) * gust * (1.0 + instanceData.z);
  // The scale of the object along its up axis, in WindSpace.worldScaled.
  float worldScale = dot(wind.upAxis, wind.upAxis) > 0.0
    ? length(mat3(model) * wind.upAxis)
    : 1.0;

  vec4 worldPosition =
    model * vec4(position + wind.modelDirection * offset, 1.0);
  worldPosition.xyz += wind.direction * (offset * worldScale);
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
