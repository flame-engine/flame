#version 460 core

#include <flame_3d/alpha_discard.glsl>

in vec2 fragTexCoord;
in vec4 fragColor;
in vec3 fragPosition;
in vec3 fragObjectPosition;
in vec3 fragNormal;

out vec4 outColor;

uniform sampler2D albedoTexture;

uniform Material {
  vec4 albedoColor;
  float alphaScissorThreshold;
  float alphaHashScale;
  float alphaBlend;
} material;

void main() {
  vec4 color =
    texture(albedoTexture, fragTexCoord) * material.albedoColor * fragColor;

  alphaDiscard(
    color.a,
    fragObjectPosition,
    material.alphaScissorThreshold,
    material.alphaHashScale
  );

  // Blended output is premultiplied, opaque output ignores alpha.
  outColor = material.alphaBlend > 0.0
    ? vec4(color.rgb * color.a, color.a)
    : vec4(color.rgb, 1.0);
}
