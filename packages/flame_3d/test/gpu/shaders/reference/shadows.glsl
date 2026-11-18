#ifndef REFERENCE_SHADOWS_GLSL_
#define REFERENCE_SHADOWS_GLSL_

// The straightforward version of flame_3d/shadows.glsl, without
// its early-outs: the GPU tests check that the early-outs render the same
// pixels.

// The shadow map of the directional light that casts shadows, filled by
// flame_3d once per render pass for every fragment shader that declares it.
// A material whose shader receives shadows lists the `Shadows` block and the
// `shadowMap` sampler in its slots, and calls shadowVisibility().

// The depths of the shadow casters, seen from the light.
uniform sampler2D shadowMap;

// `lightViewProjection` maps world space to the light's clip space: x and y
// in [-1, 1] across the map, the depth from 0 to 1 along the light.
// `toLight.xyz` is the unit vector from surfaces towards the light and
// `toLight.w` the index of the light among the directional lights, or -1
// when the pass has no shadows. The shadowed light is multiplied by
// `mix(1, color.rgb, color.a)`, `color.a` being the strength. `map.xy` is the
// size of the map in texels and `map.zw` its inverse. `bias.x` is the size
// of a texel in world units, `bias.y` the depth bias and `bias.z` the normal
// bias (in texels), `bias.w` the radius of the filter in texels. `decode`
// turns a texel of the map into a depth: `dot(texel, decode)`.
uniform Shadows {
  mat4 lightViewProjection;
  vec4 toLight;
  vec4 color;
  vec4 map;
  vec4 bias;
  vec4 decode;
} shadows;

// The fraction of the light that casts shadows reaching a surface at
// `worldPosition` whose unit normal is `normal`: from 0 (in shadow) to 1
// (lit), with soft edges, and 1 when the pass has no shadows.
//
// The point is compared with the map over a box of (2 * radius + 1) texels
// blended bilinearly, (2 * radius + 2)^2 samples, after it is pushed towards
// the light by the depth bias, and along the normal by the sine of the angle
// between the normal and the light times the normal bias plus the reach of
// the filter: samples up to sqrt(2) * (radius + 1) texels away still see a
// flat surface tilted from the light behind its own depth. Outside the map,
// nothing is in shadow.
float shadowVisibility(vec3 worldPosition, vec3 normal) {
  if (shadows.toLight.w < 0.0) {
    return 1.0;
  }
  int radius = int(shadows.bias.w);
  vec3 l = shadows.toLight.xyz;
  float cosine = clamp(dot(normal, l), 0.0, 1.0);
  float sine = sqrt(1.0 - cosine * cosine);
  float texel = shadows.bias.x;
  float reach = shadows.bias.z + 1.4142 * float(radius + 1);
  vec3 position = worldPosition +
    normal * (texel * reach * sine) +
    l * (texel * shadows.bias.y);
  vec4 clip = shadows.lightViewProjection * vec4(position, 1.0);
  vec3 ndc = clip.xyz / clip.w;
  vec2 uv = vec2(0.5 + 0.5 * ndc.x, 0.5 - 0.5 * ndc.y);
  float depth = ndc.z;

  vec2 texelPosition = uv * shadows.map.xy - 0.5;
  vec2 base = floor(texelPosition);
  vec2 f = texelPosition - base;
  float lit = 0.0;
  for (int y = -radius; y <= radius + 1; y++) {
    float wy = y == -radius ? 1.0 - f.y : (y == radius + 1 ? f.y : 1.0);
    for (int x = -radius; x <= radius + 1; x++) {
      float wx = x == -radius ? 1.0 - f.x : (x == radius + 1 ? f.x : 1.0);
      vec2 sampleUv = (base + vec2(float(x), float(y)) + 0.5) * shadows.map.zw;
      float stored = dot(texture(shadowMap, sampleUv), shadows.decode);
      lit += wx * wy * step(depth, stored);
    }
  }
  float side = float(2 * radius + 1);
  lit /= side * side;

  bool inside = uv.x >= 0.0 && uv.x <= 1.0 && uv.y >= 0.0 && uv.y <= 1.0 &&
    depth <= 1.0;
  return inside ? lit : 1.0;
}

// What the light that casts shadows is multiplied by where `visibility` of
// it reaches a surface: 1 where it is lit, `mix(1, color, strength)` where it
// is in shadow.
vec3 shadowFactor(float visibility) {
  return mix(vec3(1.0), shadows.color.rgb, shadows.color.a * (1.0 - visibility));
}

// Whether the directional light at `index` is the one that casts shadows.
bool castsShadows(int index) {
  return float(index) == shadows.toLight.w;
}

#endif
