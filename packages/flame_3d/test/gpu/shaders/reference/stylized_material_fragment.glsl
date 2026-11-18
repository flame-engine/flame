#ifndef REFERENCE_STYLIZED_MATERIAL_FRAGMENT_GLSL_
#define REFERENCE_STYLIZED_MATERIAL_FRAGMENT_GLSL_

// The straightforward version of flame_3d/stylized_material_fragment.glsl, without
// its early-outs: the GPU tests check that the early-outs render the same
// pixels.

// The fragment stage of StylizedMaterial: vertex-colored surfaces lit by the
// hemisphere, directional and point lights of the scene, with per-vertex
// masks for the instance tint, the accent color, emission and gloss, and per
// instance data for an emissive boost, a highlight and a fade.
//
//   base = albedo * vertex color * mix(1, instance color, tint mask)
//          * mix(1, accent, accent mask)
//   lit  = occlusion * (ambient + hemisphere intensity * (ambientBase
//          + skyFill * sky * hemi + groundBounce * ground * bounce))
//          + sum over suns of max(0, n.l) * intensity * color * shadow
//          + sum over points of intensity * color * falloff
//            * max(pointLightWrap, n.l)
//   spec = gloss > specularThreshold:
//          sum over suns of (n.h)^specularPower * specular factor
//          * gloss * specularStrength
//   rim  = (1 - n.v)^rimPower * rimStrength * (sky + rimColor)
//   cap  = gloss > gemThreshold: gemMatCap(view-space normal)
//          * gemMatCapStrength
//          else gloss > matCapThreshold: matCap(view-space normal)
//          * matCapStrength * mix(1, gloss, matCapGlossWeight)
//   surf = base * lit + rim
//   shaded = mix(surf + cap, min(surf, 1) * reflected, matCapMetallic)
//          + spec + highlight * highlightColor
//   glow = clamp(emissive mask * (emissiveStrength + boost), 0, 1)
//   lit out = clamp(mix(shaded,
//                       mix(emissive, emissiveBoost, clamp(boost, 0, 1)),
//                       glow), 0, 1)
//   graded  = mix(luminosity(lit out), lit out, saturation)
//   out     = mix(graded, overlay rgb, overlay alpha)
//   alpha = albedo alpha * vertex alpha * (1 - fade)
//
// with hemi = 0.5 + 0.5 * n.up, bounce = max(0, -n.up), skyFill an rgb
// weight, reflected the cap on vertices that get a MatCap and 1 on the
// others, boost, highlight and fade the x, y and w of the instance data, and
// luminosity(c) = 0.3 r + 0.59 g + 0.11 b. The color is output premultiplied
// by its alpha. `shadow` is 1, except for the sun that casts shadows, where
// it is shadowFactor() of flame_3d/shadows.glsl; its highlights are scaled by
// the mean of it.

in vec3 fragPosition;
in vec3 fragNormal;
in vec4 fragColor;
in vec4 fragMasks;
in float fragOcclusion;
in vec4 fragInstanceColor;
in vec4 fragInstanceData;

out vec4 outColor;

uniform sampler2D matCapTexture;
uniform sampler2D gemMatCapTexture;

uniform Material {
  vec4 albedoColor;
  vec4 accentColor;
  vec4 emissiveColor;
  vec4 emissiveBoostColor;
  vec4 ambientBase;
  vec4 skyFill;
  vec4 rimColor;
  vec4 highlightColor;
  vec4 overlayColor;
  float emissiveStrength;
  float groundBounce;
  float pointLightWrap;
  float specularStrength;
  float specularPower;
  float specularThreshold;
  float rimStrength;
  float rimPower;
  float matCapStrength;
  float matCapThreshold;
  float matCapGlossWeight;
  float gemMatCapStrength;
  float gemThreshold;
  float matCapMetallic;
  float saturation;
} material;

#include <flame_3d/lights.glsl>
#include <reference/shadows.glsl>

uniform Camera {
  mat4 view;
  mat4 projection;
  vec3 position;
} camera;

// -1 when the projection mirrors the picture compared to a standard camera,
// 1 otherwise, as RenderContext3D.mirrors decides: the sign of the
// determinant of the x, y and w rows of the projection (x, y and depth rows
// for a parallel projection), negative for a standard camera. The view is
// rigid and does not change it.
float pictureMirror() {
  mat4 p = camera.projection;
  vec3 rowX = vec3(p[0][0], p[1][0], p[2][0]);
  vec3 rowY = vec3(p[0][1], p[1][1], p[2][1]);
  vec3 rowW = vec3(p[0][3], p[1][3], p[2][3]);
  vec3 rowZ = vec3(p[0][2], p[1][2], p[2][2]);
  vec3 rowR = dot(rowW, rowW) > 1e-12 ? rowW : rowZ;
  return dot(rowX, cross(rowY, rowR)) > 0.0 ? -1.0 : 1.0;
}

void main() {
  vec3 n = normalize(fragNormal);
  // Towards the viewer. Orthographic cameras look along one direction.
  vec3 v;
  if (camera.projection[3][3] > 0.5) {
    v = normalize(vec3(camera.view[0][2], camera.view[1][2], camera.view[2][2]));
  } else {
    v = normalize(camera.position - fragPosition);
  }

  float tintMask = fragMasks.x;
  float accentMask = fragMasks.y;
  float emissiveMask = fragMasks.z;
  float gloss = fragMasks.w;

  float boost = fragInstanceData.x;
  float highlight = fragInstanceData.y;
  float fade = fragInstanceData.w;

  vec3 base = material.albedoColor.rgb * fragColor.rgb;
  base *= mix(vec3(1.0), fragInstanceColor.rgb, tintMask);
  base *= mix(vec3(1.0), material.accentColor.rgb, accentMask);

  float nUp = clamp(dot(n, hemisphereLight.up), -1.0, 1.0);
  float hemi = 0.5 + 0.5 * nUp;
  float bounce = max(-nUp, 0.0);
  vec3 ambient = ambientLight.color.rgb * ambientLight.intensity +
    hemisphereLight.intensity * (
      material.ambientBase.rgb +
      material.skyFill.rgb * hemi * hemisphereLight.skyColor.rgb +
      material.groundBounce * bounce * hemisphereLight.groundColor.rgb
    );
  vec3 lit = fragOcclusion * ambient;

  float specular = 0.0;
  bool glossy = gloss > material.specularThreshold;
  vec3 sunShadow = shadowFactor(shadowVisibility(fragPosition, n));
  for (int i = 0; i < int(directionalLights.numLights); i++) {
    vec4 direction = directionalLights.directions[i];
    vec4 lightColor = directionalLights.colors[i];
    vec3 shadow = castsShadows(i) ? sunShadow : vec3(1.0);
    lit += max(dot(n, direction.xyz), 0.0) * lightColor.a * lightColor.rgb *
      shadow;
    if (glossy) {
      float ndoth = max(dot(n, normalize(direction.xyz + v)), 0.0);
      specular += pow(ndoth, material.specularPower) * direction.w *
        (shadow.r + shadow.g + shadow.b) / 3.0;
    }
  }
  specular *= gloss * material.specularStrength;

  for (int i = 0; i < int(lights.numLights); i++) {
    vec3 toLight = lights.positions[i] - fragPosition;
    float dist = length(toLight);
    vec3 l = toLight / max(dist, 0.0001);
    float range = lights.ranges[i].x;
    float falloff;
    if (range > 0.0) {
      float rangeFade = max(1.0 - dist / range, 0.0);
      falloff = rangeFade * rangeFade;
    } else {
      falloff = 1.0 / max(dist * dist, 0.00000001);
    }
    float wrapped = max(material.pointLightWrap, dot(n, l));
    lit += lights.intensities[i].x * falloff * wrapped * lights.colors[i].rgb;
  }

  float ndotv = clamp(dot(n, v), 0.0, 1.0);
  float fresnel = pow(1.0 - ndotv, material.rimPower);
  vec3 rim = fresnel * material.rimStrength *
    (hemisphereLight.skyColor.rgb + material.rimColor.rgb);

  // Both MatCap textures are sampled outside of any branch, so that their
  // texture coordinates' derivatives are defined. A MatCap is a sphere as
  // seen in the picture: when the projection mirrors the picture, the x axis
  // of the (rigid) view points to the left of it, and is mirrored back.
  vec3 viewNormal = normalize(mat3(camera.view) * n);
  viewNormal.x *= pictureMirror();
  vec2 matCapUv = vec2(0.5 + 0.5 * viewNormal.x, 0.5 - 0.5 * viewNormal.y);
  vec3 coat = texture(matCapTexture, matCapUv).rgb * material.matCapStrength *
    mix(1.0, gloss, material.matCapGlossWeight);
  vec3 gem = texture(gemMatCapTexture, matCapUv).rgb *
    material.gemMatCapStrength;
  float gemWeight = gloss > material.gemThreshold ? 1.0 : 0.0;
  float coatWeight = gloss > material.matCapThreshold ? 1.0 - gemWeight : 0.0;
  vec3 matCap = coatWeight * coat + gemWeight * gem;

  // The MatCap is a sheen added to the lit surface, or, as far as the
  // material is metallic, the surface's own reflection: the lit surface, at
  // most 1, scales it. Vertices without a MatCap keep their lit color.
  vec3 surface = base * lit + rim;
  vec3 reflected = mix(vec3(1.0), matCap, coatWeight + gemWeight);
  vec3 color = mix(
    surface + matCap,
    min(surface, vec3(1.0)) * reflected,
    material.matCapMetallic
  ) + vec3(specular) + highlight * material.highlightColor.rgb;
  vec3 emissive = mix(
    material.emissiveColor.rgb,
    material.emissiveBoostColor.rgb,
    clamp(boost, 0.0, 1.0)
  );
  float glow = clamp(
    emissiveMask * (material.emissiveStrength + boost),
    0.0,
    1.0
  );
  color = clamp(mix(color, emissive, glow), 0.0, 1.0);

  // The color grade, on the final color: desaturated towards its luminosity
  // (the luminosity of the non-separable blend modes), then covered by the
  // overlay color as far as its alpha goes. The defaults leave it unchanged.
  if (material.saturation != 1.0) {
    float luminosity = dot(color, vec3(0.3, 0.59, 0.11));
    color = clamp(mix(vec3(luminosity), color, material.saturation), 0.0, 1.0);
  }
  if (material.overlayColor.a > 0.0) {
    color = mix(color, material.overlayColor.rgb, material.overlayColor.a);
  }

  float alpha = material.albedoColor.a * fragColor.a *
    clamp(1.0 - fade, 0.0, 1.0);
  outColor = vec4(color * alpha, alpha);
}

#endif
