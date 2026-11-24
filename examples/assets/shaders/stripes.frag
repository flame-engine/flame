#version 460 core

#include <flutter/runtime_effect.glsl>

uniform float uTime;

out vec4 fragColor;

// Ignores the subtree and draws moving diagonal stripes.
void main() {
  vec2 position = FlutterFragCoord().xy;
  float band = step(0.5, fract((position.x + position.y) / 40.0 - uTime * 0.5));
  vec3 blue = vec3(0.13, 0.59, 0.95);
  vec3 yellow = vec3(0.98, 0.75, 0.18);
  fragColor = vec4(mix(blue, yellow, band), 1.0);
}
