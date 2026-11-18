#version 460 core

in vec2 fragUv;
in float fragAcross;
in vec4 fragColor;

out vec4 outColor;

uniform sampler2D albedoTexture;

uniform RibbonLook {
  vec4 albedoColor;
  // x: edgeSoftness, y: 1 when premultiplied/additive, z: 1 when textured,
  // w: alphaCutoff.
  vec4 params;
} ribbon;

void main() {
  vec4 sampled = vec4(1.0);
  if (ribbon.params.z > 0.5) {
    sampled = texture(albedoTexture, fragUv);
  }
  float edge = clamp(ribbon.params.x, 0.0, 1.0);
  float across = abs(fragAcross);
  float fade = edge > 1e-4
      ? 1.0 - smoothstep(1.0 - edge, 1.0, across)
      : 1.0;
  vec4 color = sampled * ribbon.albedoColor * fragColor;
  float alpha = clamp(color.a * fade, 0.0, 1.0);
  if (alpha < ribbon.params.w) {
    discard;
  }
  if (ribbon.params.y > 0.5) {
    outColor = vec4(color.rgb * alpha, alpha);
  } else {
    outColor = vec4(color.rgb, alpha);
  }
}
