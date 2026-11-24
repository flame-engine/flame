#version 460 core

precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uPixels;
uniform vec2 uSize;
uniform sampler2D uTexture;

out vec4 fragColor;

// Samples the subtree at uPixels evenly spaced points in each direction.
void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  vec2 pixelatedUv = round(uv * uPixels) / uPixels;
  fragColor = texture(uTexture, pixelatedUv);
}
