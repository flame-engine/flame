#version 460 core

// Unified final scene compositor: combines optional 5-tap edge-aware FXAA,
// additive Kawase bloom, exposure, ACES/AgX/Reinhard tone mapping, contrast,
// saturation, color tint, and vignette in a single pass while preserving
// `base.a` for Porter-Duff srcOver 2D layer compositing.

in vec2 fragUv;

out vec4 outColor;

uniform sampler2D sceneTexture;
uniform sampler2D bloomTexture;
uniform sampler2D depthNormalTexture;

uniform BloomComposite {
  // x: bloomIntensity, y: exposure, z: contrast, w: saturation
  vec4 params;
  // x: toneMapMode (0=none, 1=reinhard, 2=aces, 3=agx),
  // y: vignetteIntensity, z: vignetteSmoothness, w: fxaa (1=on, 0=off)
  vec4 grading;
  // rgb: color tint, a: unused
  vec4 tint;
  // xy: 1 / resolution, zw: unused
  vec4 texel;
  // x: ssaoIntensity, y: ssaoRadius (in pixels), z: hasDepthNormal, w: unused
  vec4 ssao;
  // x: dofBlurStrength, y: dofFocusDepth [0..1], z: dofFocusRange, w: unused
  vec4 dof;
} composite;

float decodeDepth16(vec4 dn) {
  return (dn.r * 255.0 * 256.0 + dn.g * 255.0) / 65535.0;
}

vec3 decodeViewNormal(vec4 dn) {
  vec2 xy = dn.ba * 2.0 - 1.0;
  float z = sqrt(max(0.0, 1.0 - dot(xy, xy)));
  return normalize(vec3(xy, z));
}

float computeSpiralSsao(vec2 uv, vec2 invRes, float dCenter, vec3 nCenter) {
  if (composite.ssao.x <= 1e-4 || composite.ssao.z < 0.5 || dCenter >= 0.999) {
    return 1.0;
  }
  float radiusPx = max(composite.ssao.y, 0.5) * 4.0;
  float occ = 0.0;
  for (int i = 0; i < 8; i++) {
    float fi = float(i) + 0.5;
    float ang = fi * 2.39996323;
    float r = (fi / 8.0) * radiusPx;
    vec2 sUv = clamp(
      uv + vec2(cos(ang), sin(ang)) * invRes * r,
      vec2(0.001),
      vec2(0.999)
    );
    vec4 sDn = texture(depthNormalTexture, sUv);
    float dSample = decodeDepth16(sDn);
    float diff = dCenter - dSample;
    // Sample is closer to viewer than center within local thickness band.
    if (diff > 0.0006 && diff < 0.065) {
      vec3 sNorm = decodeViewNormal(sDn);
      float crease = clamp(1.0 - dot(nCenter, sNorm), 0.15, 1.0);
      float rangeW = 1.0 - smoothstep(0.015, 0.065, diff);
      occ += crease * rangeW;
    }
  }
  float ao = 1.0 - clamp((occ / 8.0) * composite.ssao.x * 2.4, 0.0, 0.88);
  return ao;
}

vec4 sampleDofBokeh(vec2 uv, vec2 invRes, vec4 sharpColor, float dCenter) {
  if (composite.dof.x <= 1e-4 || composite.ssao.z < 0.5) {
    return sharpColor;
  }
  float distFromFocus = abs(dCenter - composite.dof.y);
  float coc = clamp(
    (distFromFocus - composite.dof.z) / max(composite.dof.z, 0.02),
    0.0,
    1.0
  ) * composite.dof.x;
  if (coc <= 0.01) {
    return sharpColor;
  }
  float radiusPx = coc * 5.5;
  vec4 acc = sharpColor;
  float wSum = 1.0;
  for (int i = 0; i < 8; i++) {
    float fi = float(i) + 1.0;
    float ang = fi * 2.39996323;
    float r = sqrt(fi / 8.0) * radiusPx;
    vec2 bUv = clamp(
      uv + vec2(cos(ang), sin(ang)) * invRes * r,
      vec2(0.001),
      vec2(0.999)
    );
    acc += texture(sceneTexture, bUv);
    wSum += 1.0;
  }
  return vec4((acc / wSum).rgb, sharpColor.a);
}

float luma(vec3 rgb) {
  return dot(rgb, vec3(0.299, 0.587, 0.114));
}

vec4 sampleSceneFxaa(vec2 uv, vec2 invRes) {
  vec4 cM = texture(sceneTexture, uv);
  if (composite.grading.w < 0.5) {
    return cM;
  }
  vec3 nw = texture(sceneTexture, uv + vec2(-invRes.x, -invRes.y)).rgb;
  vec3 ne = texture(sceneTexture, uv + vec2(invRes.x, -invRes.y)).rgb;
  vec3 sw = texture(sceneTexture, uv + vec2(-invRes.x, invRes.y)).rgb;
  vec3 se = texture(sceneTexture, uv + vec2(invRes.x, invRes.y)).rgb;

  float lM = luma(cM.rgb);
  float lNW = luma(nw);
  float lNE = luma(ne);
  float lSW = luma(sw);
  float lSE = luma(se);

  float lMin = min(lM, min(min(lNW, lNE), min(lSW, lSE)));
  float lMax = max(lM, max(max(lNW, lNE), max(lSW, lSE)));
  float range = lMax - lMin;
  if (range < max(0.0312, lMax * 0.125)) {
    return cM;
  }

  vec2 dir = vec2(
    -((lNW + lNE) - (lSW + lSE)),
    ((lNW + lSW) - (lNE + lSE))
  );
  float dirReduce = max((lNW + lNE + lSW + lSE) * (0.25 * 0.125), 1.0 / 128.0);
  float rcpDirMin = 1.0 / (min(abs(dir.x), abs(dir.y)) + dirReduce);
  dir = clamp(dir * rcpDirMin, vec2(-4.0), vec2(4.0)) * invRes;

  vec3 rgbA = 0.5 * (
    texture(sceneTexture, uv + dir * (1.0 / 3.0 - 0.5)).rgb +
    texture(sceneTexture, uv + dir * (2.0 / 3.0 - 0.5)).rgb
  );
  vec3 rgbB = rgbA * 0.5 + 0.25 * (
    texture(sceneTexture, uv + dir * -0.5).rgb +
    texture(sceneTexture, uv + dir * 0.5).rgb
  );
  float lB = luma(rgbB);
  vec3 aaRgb = (lB < lMin || lB > lMax) ? rgbA : rgbB;
  return vec4(aaRgb, cM.a);
}

vec3 acesFilmic(vec3 x) {
  const float a = 2.51;
  const float b = 0.03;
  const float c = 2.43;
  const float d = 0.59;
  const float e = 0.14;
  return clamp((x * (a * x + b)) / (x * (c * x + d) + e), 0.0, 1.0);
}

vec3 agxApprox(vec3 x) {
  // Inset chroma slightly before log-sigmoid S-curve to preserve hue in bright
  // highlights, then restore saturation slightly.
  mat3 inset = mat3(
    0.842479062253094, 0.0423282422610123, 0.0423756549057051,
    0.0784335999999992, 0.878468636469772, 0.0784336,
    0.0792237451477643, 0.0791661274605434, 0.879142973793104
  );
  vec3 v = max(inset * x, vec3(1e-6));
  v = clamp((log2(v) + 12.47393) / 16.5, 0.0, 1.0);
  vec3 v2 = v * v;
  vec3 s = 15.5 * v2 * v2 - 40.14 * v2 * v + 31.96 * v2 - 6.868 * v + 0.4298;
  return clamp(s, 0.0, 1.0);
}

void main() {
  vec4 base = sampleSceneFxaa(fragUv, composite.texel.xy);
  float ao = 1.0;
  if (composite.ssao.z > 0.5) {
    vec4 dn = texture(depthNormalTexture, fragUv);
    float dCenter = decodeDepth16(dn);
    vec3 nCenter = decodeViewNormal(dn);
    base = sampleDofBokeh(fragUv, composite.texel.xy, base, dCenter);
    ao = computeSpiralSsao(fragUv, composite.texel.xy, dCenter, nCenter);
  }
  vec3 glow = composite.params.x > 0.0
      ? texture(bloomTexture, fragUv).rgb * composite.params.x
      : vec3(0.0);

  vec3 color = (base.rgb * ao + glow) * composite.params.y;

  float mode = composite.grading.x;
  if (mode > 2.5) {
    color = agxApprox(max(color, vec3(0.0)));
  } else if (mode > 1.5) {
    color = acesFilmic(max(color, vec3(0.0)));
  } else if (mode > 0.5) {
    color = max(color, vec3(0.0));
    color = color / (color + vec3(1.0));
  }

  float contrast = composite.params.z;
  if (abs(contrast - 1.0) > 1e-4) {
    color = (color - 0.5) * contrast + 0.5;
  }

  float sat = composite.params.w;
  if (abs(sat - 1.0) > 1e-4) {
    float lum = luma(color);
    color = mix(vec3(lum), color, sat);
  }

  color *= composite.tint.rgb;

  float vigAmt = composite.grading.y;
  if (vigAmt > 0.0) {
    vec2 centered = fragUv * 2.0 - 1.0;
    float d = length(centered) * 0.70710678;
    float smoothW = max(composite.grading.z, 0.05);
    float vig = 1.0 - smoothstep(1.0 - smoothW, 1.05, d) * vigAmt;
    color *= clamp(vig, 0.0, 1.0);
  }

  outColor = vec4(clamp(color, 0.0, 1.0), base.a);
}
