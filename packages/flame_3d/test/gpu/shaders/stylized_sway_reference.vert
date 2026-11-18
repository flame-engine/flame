#version 460 core

// StylizedMaterial's vertex stage with one float of sway per vertex, see
// reference/stylized_sway_vertex.glsl.

#include <reference/stylized_sway_vertex.glsl>

void main() {
  emitStylizedVertex(vertexPosition, vertexNormal);
}
