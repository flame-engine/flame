#version 460 core

// StylizedMaterial for its own vertex layout (StylizedMaterial.vertexLayout).
// stylized_material_skinned.vert reads the same layout with joints and
// weights, stylized_material_standard.vert the standard layout; all of them
// feed flame_3d/stylized_material_fragment.glsl.

#include <flame_3d/stylized_material_vertex.glsl>

void main() {
  emitStylizedVertex(vertexPosition, vertexNormal);
}
