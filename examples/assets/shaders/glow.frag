#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform vec4 uColor;
uniform sampler2D uTexture;

out vec4 fragColor;

// Samples the subtree to find its edges, and draws a pulsing outline in
// uColor just outside of them. Inside the subtree it's transparent, so the
// subtree drawn under it shows through.
void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  if (texture(uTexture, uv).a > 0.5) {
    fragColor = vec4(0.0);
    return;
  }
  float radius = 5.0 + 2.5 * sin(uTime * 3.0);
  float edge = 0.0;
  for (int i = 0; i < 24; i++) {
    float angle = 6.2831853 * float(i) / 24.0;
    vec2 offset = vec2(cos(angle), sin(angle)) * radius / uSize;
    edge = max(edge, texture(uTexture, uv + offset).a);
  }
  fragColor = vec4(uColor.rgb * uColor.a, uColor.a) * edge;
}
