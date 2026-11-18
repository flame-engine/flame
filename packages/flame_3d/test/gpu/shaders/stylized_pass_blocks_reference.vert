#version 460 core

// StylizedMaterial's vertex stage, unchanged.

#include <flame_3d/stylized_material_vertex.glsl>

void main() {
  emitStylizedVertex(vertexPosition, vertexNormal);
}
