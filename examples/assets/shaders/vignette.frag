#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform vec4 uColor;

out vec4 fragColor;

// Darkens the edges in uColor, pulsing with uTime.
void main() {
  vec2 uv = FlutterFragCoord().xy / uSize - 0.5;
  float strength = 0.55 + 0.15 * sin(uTime * 3.0);
  float alpha = smoothstep(0.2, 0.75, length(uv) / strength * 0.5) * uColor.a;
  fragColor = vec4(uColor.rgb * alpha, alpha);
}
