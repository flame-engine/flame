#version 460 core

// StylizedMaterial for its own vertex layout with joints and weights
// (StylizedMaterial.skinnedVertexLayout): every vertex is moved by the blend
// of up to four joint matrices of its draw (flame_3d/skinning.glsl, at most
// 16 joints per draw), then drawn as stylized_material.vert draws it: the
// wind offset is added to the skinned position, in model space.

#include <flame_3d/stylized_material_vertex.glsl>
#include <flame_3d/skinning.glsl>

void main() {
  mat4 skin = computeSkinMatrix();
  emitStylizedVertex(
    (skin * vec4(vertexPosition, 1.0)).xyz,
    (skin * vec4(vertexNormal, 0.0)).xyz
  );
}
