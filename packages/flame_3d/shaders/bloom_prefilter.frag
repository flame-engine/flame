#version 460 core

// Soft-knee bright-pass extraction + 4-tap bilinear downsample for GPU bloom.

in vec2 fragUv;

out vec4 outColor;

uniform sampler2D sourceTexture;

uniform BloomPrefilter {
  // x: threshold, y: threshold - knee, z: 2 * knee, w: 0.25 / max(knee, 1e-5).
  vec4 curve;
  // xy: inverse source resolution (1 / width, 1 / height).
  vec4 texel;
} prefilter;

vec3 extractBright(vec3 c) {
  float brightness = max(c.r, max(c.g, c.b));
  float soft = clamp(brightness - prefilter.curve.y, 0.0, prefilter.curve.z);
  soft = soft * soft * prefilter.curve.w;
  float contribution = max(soft, brightness - prefilter.curve.x) /
      max(brightness, 1e-4);
  return c * max(0.0, contribution);
}

void main() {
  vec2 d = prefilter.texel.xy * 0.5;
  vec3 c0 = texture(sourceTexture, fragUv + vec2(-d.x, -d.y)).rgb;
  vec3 c1 = texture(sourceTexture, fragUv + vec2( d.x, -d.y)).rgb;
  vec3 c2 = texture(sourceTexture, fragUv + vec2(-d.x,  d.y)).rgb;
  vec3 c3 = texture(sourceTexture, fragUv + vec2( d.x,  d.y)).rgb;
  vec3 avg = 0.25 * (c0 + c1 + c2 + c3);
  outColor = vec4(extractBright(avg), 1.0);
}
