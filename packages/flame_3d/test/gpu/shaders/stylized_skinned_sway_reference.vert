#version 460 core

// StylizedMaterial's skinned vertex stage with one float of sway per vertex,
// see reference/stylized_sway_vertex.glsl.

#include <reference/stylized_sway_vertex.glsl>
#include <flame_3d/skinning.glsl>

void main() {
  mat4 skin = computeSkinMatrix();
  emitStylizedVertex(
    (skin * vec4(vertexPosition, 1.0)).xyz,
    (skin * vec4(vertexNormal, 0.0)).xyz
  );
}
