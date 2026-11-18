#ifndef FLAME_SHADOW_CASTER_FRAGMENT_GLSL_
#define FLAME_SHADOW_CASTER_FRAGMENT_GLSL_

// The fragment stage that renders shadow maps: it stores the depth of the
// caster seen from the light, as a 32-bit float in the red channel, or packed
// into the 8-bit red, green and blue channels when `packDepth` is 1 (see
// RenderContext3D.shadowCasterBlock). flame_3d/shadows.glsl decodes both.

// The depth from 0 (the near plane of the light) to 1 (its far plane).
in float fragDepth;

out vec4 outColor;

uniform ShadowCaster {
  float packDepth;
} caster;

// 24 bits of depth in red, green and blue, most significant first.
vec4 packShadowDepth(float depth) {
  float d = floor(clamp(depth, 0.0, 1.0) * 16777215.0 + 0.5);
  float high = floor(d / 65536.0);
  d -= high * 65536.0;
  float middle = floor(d / 256.0);
  float low = d - middle * 256.0;
  return vec4(high, middle, low, 255.0) / 255.0;
}

void main() {
  if (caster.packDepth > 0.5) {
    outColor = packShadowDepth(fragDepth);
  } else {
    outColor = vec4(fragDepth, 0.0, 0.0, 1.0);
  }
}

#endif
