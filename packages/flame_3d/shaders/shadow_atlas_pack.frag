#version 460 core

// Packs two square shadow cascade textures side-by-side into a single `2W x H`
// shadow atlas texture (`uv.x < 0.5` -> cascade 0, `uv.x >= 0.5` -> cascade 1)
// so receivers sample both cascades through a single `shadowMap` binding.

in vec2 fragUv;

out vec4 outColor;

uniform sampler2D cascade0Texture;
uniform sampler2D cascade1Texture;

void main() {
  if (fragUv.x < 0.5) {
    outColor = texture(cascade0Texture, vec2(fragUv.x * 2.0, fragUv.y));
  } else {
    outColor = texture(cascade1Texture, vec2(fragUv.x * 2.0 - 1.0, fragUv.y));
  }
}
