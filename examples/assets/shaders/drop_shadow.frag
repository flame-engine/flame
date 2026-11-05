#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform vec2 uOffset;
uniform vec4 uColor;
uniform sampler2D uTexture;

out vec4 fragColor;

// The silhouette of the subtree in uColor, moved by uOffset logical pixels.
void main() {
  vec2 uv = (FlutterFragCoord().xy - uOffset) / uSize;
  float alpha = texture(uTexture, uv).a * uColor.a;
  fragColor = vec4(uColor.rgb * alpha, alpha);
}
