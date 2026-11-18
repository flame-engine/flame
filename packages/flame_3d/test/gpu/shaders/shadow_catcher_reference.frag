#version 460 core

// ShadowCatcherMaterial without the early-outs of flame_3d/shadows.glsl
// (see reference/shadows.glsl): where the surface is in shadow, it outputs the
// material's color (times the per-instance color) with an opacity of
// `color alpha * shadow strength * (1 - visibility)`, premultiplied; it is
// fully transparent where the surface is lit and when the pass has no
// shadows. Drawn blended over a transparent target, as a Scene3DComponent
// renders, it darkens the 2D art below the layer.

in vec3 fragPosition;
in vec3 fragNormal;
in vec4 fragInstanceColor;

out vec4 outColor;

uniform Material {
  vec4 color;
} material;

#include <reference/shadows.glsl>

void main() {
  float visibility = shadowVisibility(fragPosition, normalize(fragNormal));
  vec4 color = material.color * fragInstanceColor;
  float alpha = color.a * shadows.color.a * (1.0 - visibility);
  outColor = vec4(color.rgb * alpha, alpha);
}
