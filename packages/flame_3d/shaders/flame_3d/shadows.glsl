#ifndef FLAME_SHADOWS_GLSL_
#define FLAME_SHADOWS_GLSL_

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
//
// A shader that reads these values from a block of its own (as
// StylizedMaterial does, to bind fewer blocks) defines
// `FLAME_SHADOWS(member)` to the expression of the member named `member`
// before including this file, which then declares no Shadows block.
#ifndef FLAME_SHADOWS
uniform Shadows {
  mat4 lightViewProjection;
  mat4 cascadeViewProjection;
  vec4 toLight;
  vec4 color;
  vec4 map;
  vec4 bias;
  vec4 decode;
  // x: cascade count (1 or 2), y: cascade 1 world texel size
  vec4 cascadeParams;
} shadows;
#define FLAME_SHADOWS(member) shadows.member
#endif

float sampleShadowPcfBox(
  vec2 uv,
  float depth,
  int radius,
  float minU,
  float maxU
) {
  vec2 mapSize = FLAME_SHADOWS(map).xy;
  vec2 invMap = FLAME_SHADOWS(map).zw;
  vec2 texelPosition = uv * mapSize - 0.5;
  vec2 base = floor(texelPosition);
  vec2 f = texelPosition - base;
  float lit = 0.0;
  for (int y = -radius; y <= radius + 1; y++) {
    float wy = y == -radius ? 1.0 - f.y : (y == radius + 1 ? f.y : 1.0);
    for (int x = -radius; x <= radius + 1; x++) {
      float wx = x == -radius ? 1.0 - f.x : (x == radius + 1 ? f.x : 1.0);
      vec2 sampleUv = (base + vec2(float(x), float(y)) + 0.5) * invMap;
      sampleUv.x = clamp(sampleUv.x, minU, maxU);
      float stored = dot(texture(shadowMap, sampleUv), FLAME_SHADOWS(decode));
      lit += wx * wy * step(depth, stored);
    }
  }
  float side = float(2 * radius + 1);
  return lit / (side * side);
}

// The fraction of the light that casts shadows reaching a surface at
// `worldPosition` whose unit normal is `normal`: from 0 (in shadow) to 1
// (lit), with soft edges, and 1 when the pass has no shadows.
float shadowVisibility(vec3 worldPosition, vec3 normal) {
  if (FLAME_SHADOWS(toLight).w < 0.0) {
    return 1.0;
  }
  int radius = int(FLAME_SHADOWS(bias).w);
  vec3 l = FLAME_SHADOWS(toLight).xyz;
  float cosine = clamp(dot(normal, l), 0.0, 1.0);
  float sine = sqrt(1.0 - cosine * cosine);
  float texel = FLAME_SHADOWS(bias).x;
  float reach = FLAME_SHADOWS(bias).z + 1.4142 * float(radius + 1);
  vec3 position = worldPosition +
    normal * (texel * reach * sine) +
    l * (texel * FLAME_SHADOWS(bias).y);

  // Two-cascade directional shadow atlas (`[0..0.5]` near, `[0.5..1.0]` far).
  if (FLAME_SHADOWS(cascadeParams).x > 1.5) {
    vec4 clip0 = FLAME_SHADOWS(lightViewProjection) * vec4(position, 1.0);
    vec3 ndc0 = clip0.xyz / clip0.w;
    vec2 uv0 = vec2(0.5 + 0.5 * ndc0.x, 0.5 - 0.5 * ndc0.y);
    if (uv0.x >= 0.03 && uv0.x <= 0.97 && uv0.y >= 0.03 && uv0.y <= 0.97 &&
        ndc0.z >= 0.0 && ndc0.z <= 1.0) {
      vec2 atlasUv0 = vec2(uv0.x * 0.5, uv0.y);
      float halfTexU = FLAME_SHADOWS(map).z * 0.5;
      return sampleShadowPcfBox(
        atlasUv0,
        ndc0.z,
        radius,
        halfTexU,
        0.5 - halfTexU
      );
    }
    float texel1 = FLAME_SHADOWS(cascadeParams).y;
    vec3 pos1 = worldPosition +
      normal * (texel1 * reach * sine) +
      l * (texel1 * FLAME_SHADOWS(bias).y);
    vec4 clip1 = FLAME_SHADOWS(cascadeViewProjection) * vec4(pos1, 1.0);
    vec3 ndc1 = clip1.xyz / clip1.w;
    vec2 uv1 = vec2(0.5 + 0.5 * ndc1.x, 0.5 - 0.5 * ndc1.y);
    if (uv1.x >= 0.0 && uv1.x <= 1.0 && uv1.y >= 0.0 && uv1.y <= 1.0 &&
        ndc1.z >= 0.0 && ndc1.z <= 1.0) {
      vec2 atlasUv1 = vec2(0.5 + uv1.x * 0.5, uv1.y);
      float halfTexU = FLAME_SHADOWS(map).z * 0.5;
      return sampleShadowPcfBox(
        atlasUv1,
        ndc1.z,
        radius,
        0.5 + halfTexU,
        1.0 - halfTexU
      );
    }
    return 1.0;
  }

  vec4 clip = FLAME_SHADOWS(lightViewProjection) * vec4(position, 1.0);
  if (FLAME_SHADOWS(toLight).w >= 99.0 && clip.w <= 0.0) {
    return 1.0;
  }
  vec3 ndc = clip.xyz / clip.w;
  vec2 uv = vec2(0.5 + 0.5 * ndc.x, 0.5 - 0.5 * ndc.y);
  float depth = ndc.z;
  if (FLAME_SHADOWS(toLight).w >= 99.0 && depth < 0.0) {
    return 1.0;
  }
  bool inside = uv.x >= 0.0 && uv.x <= 1.0 && uv.y >= 0.0 && uv.y <= 1.0 &&
    depth <= 1.0;
  if (!inside) {
    return 1.0;
  }

  vec2 texelPosition = uv * FLAME_SHADOWS(map).xy - 0.5;
  vec2 base = floor(texelPosition);
  vec2 f = texelPosition - base;
  float lit = 0.0;
  for (int y = -radius; y <= radius + 1; y++) {
    float wy = y == -radius ? 1.0 - f.y : (y == radius + 1 ? f.y : 1.0);
    for (int x = -radius; x <= radius + 1; x++) {
      float wx = x == -radius ? 1.0 - f.x : (x == radius + 1 ? f.x : 1.0);
      vec2 sampleUv =
        (base + vec2(float(x), float(y)) + 0.5) * FLAME_SHADOWS(map).zw;
      float stored =
        dot(texture(shadowMap, sampleUv), FLAME_SHADOWS(decode));
      lit += wx * wy * step(depth, stored);
    }
  }
  float side = float(2 * radius + 1);
  return lit / (side * side);
}

// What the light that casts shadows is multiplied by where `visibility` of
// it reaches a surface: 1 where it is lit, `mix(1, color, strength)` where it
// is in shadow.
vec3 shadowFactor(float visibility) {
  return mix(
    vec3(1.0),
    FLAME_SHADOWS(color).rgb,
    FLAME_SHADOWS(color).a * (1.0 - visibility)
  );
}

// Whether the directional light at `index` is the one that casts shadows.
bool castsShadows(int index) {
  return float(index) == FLAME_SHADOWS(toLight).w;
}

// Whether the spot light at `index` is the one that casts shadows.
bool spotCastsShadows(int index) {
  return abs(FLAME_SHADOWS(toLight).w - (100.0 + float(index))) < 0.25;
}

#endif
