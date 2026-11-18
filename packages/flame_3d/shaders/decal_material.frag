#version 460 core

in vec2 fragTexCoord;
in vec2 fragLocalUv;
in vec4 fragColor;

out vec4 outColor;

uniform sampler2D albedoTexture;

uniform Decal {
  vec4 albedoColor;
  // x: clip depth bias, y: radial softness, z: inner ring radius, w: 1 when procedural.
  vec4 params;
  // x: alphaCutoff.
  vec4 cutoff;
} decal;

void main() {
  vec4 sampled = vec4(1.0);
  float softness = clamp(decal.params.y, 0.0, 1.0);
  if (decal.params.w > 0.5) {
    float r = length(fragLocalUv * 2.0 - 1.0);
    float outerEdge = max(softness, 1e-4);
    float outerMask = 1.0 - smoothstep(1.0 - outerEdge, 1.0, r);
    float innerRadius = clamp(decal.params.z, 0.0, 0.999);
    float innerMask = innerRadius > 0.0
        ? smoothstep(max(0.0, innerRadius - outerEdge), innerRadius, r)
        : 1.0;
    sampled.a = outerMask * innerMask;
  } else {
    sampled = texture(albedoTexture, fragTexCoord);
    if (softness > 0.0) {
      float r = length(fragLocalUv * 2.0 - 1.0);
      sampled.a *= 1.0 - smoothstep(1.0 - softness, 1.0, r);
    }
  }

  vec4 color = sampled * fragColor;
  if (color.a < decal.cutoff.x) {
    discard;
  }
  float alpha = clamp(color.a, 0.0, 1.0);
  outColor = vec4(color.rgb * alpha, alpha);
}
