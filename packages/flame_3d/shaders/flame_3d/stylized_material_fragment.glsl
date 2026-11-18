#ifndef FLAME_STYLIZED_MATERIAL_FRAGMENT_GLSL_
#define FLAME_STYLIZED_MATERIAL_FRAGMENT_GLSL_

// The fragment stage of StylizedMaterial: vertex-colored surfaces lit by the
// hemisphere, directional and point lights of the scene, with per-vertex
// masks for the instance tint, the accent color, emission and gloss, and per
// instance data for an emissive boost, a highlight, wind strength, fade and an
// optional per-instance accent palette index.

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
  vec4 accentPalette[16];
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
  float accentPaletteCount;
  float ditherFade;
} material;

// The camera, the lights, the shadows and the fog of the render pass, filled
// by flame_3d once per pass.
uniform StylizedPass {
  mat4 Camera_view;
  mat4 Camera_projection;
  mat4 Shadows_lightViewProjection;
  mat4 Shadows_cascadeViewProjection;
  vec4 Shadows_toLight;
  vec4 Shadows_color;
  vec4 Shadows_map;
  vec4 Shadows_bias;
  vec4 Shadows_decode;
  vec4 Shadows_cascadeParams;
  vec4 Fog_color;
  vec4 Fog_params;
  vec4 Fog_height;
  vec4 AmbientLight_color;
  vec4 HemisphereLight_skyColor;
  vec4 HemisphereLight_groundColor;
  vec3 HemisphereLight_up;
  float HemisphereLight_intensity;
  vec3 Camera_position;
  float AmbientLight_intensity;
  vec4 DirectionalLights_directions[4];
  vec4 DirectionalLights_colors[4];
  vec3 Lights_positions[8];
  vec4 Lights_colors[8];
  vec4 Lights_intensities[8];
  vec4 Lights_ranges[8];
  vec3 SpotLights_positions[4];
  vec4 SpotLights_directions[4];
  vec4 SpotLights_colors[4];
  vec4 SpotLights_cones[4];
  float Lights_numLights;
  float DirectionalLights_numLights;
  float SpotLights_numLights;
} scene;

#define FLAME_SHADOWS(member) scene.Shadows_##member
#include <flame_3d/shadows.glsl>

#define FLAME_FOG(member) scene.Fog_##member
#include <flame_3d/fog.glsl>
#include <flame_3d/dither.glsl>

float pictureMirror() {
  mat4 p = scene.Camera_projection;
  vec3 rowX = vec3(p[0][0], p[1][0], p[2][0]);
  vec3 rowY = vec3(p[0][1], p[1][1], p[2][1]);
  vec3 rowW = vec3(p[0][3], p[1][3], p[2][3]);
  vec3 rowZ = vec3(p[0][2], p[1][2], p[2][2]);
  vec3 rowR = dot(rowW, rowW) > 1e-12 ? rowW : rowZ;
  return dot(rowX, cross(rowY, rowR)) > 0.0 ? -1.0 : 1.0;
}

void main() {
  vec3 n = normalize(fragNormal);
  vec3 v;
  if (scene.Camera_projection[3][3] > 0.5) {
    mat4 view = scene.Camera_view;
    v = normalize(vec3(view[0][2], view[1][2], view[2][2]));
  } else {
    v = normalize(scene.Camera_position - fragPosition);
  }

  float tintMask = fragMasks.x;
  float accentMask = fragMasks.y;
  float emissiveMask = fragMasks.z;
  float gloss = fragMasks.w;

  float boost = fragInstanceData.x;
  float highlight = fragInstanceData.y;

  // `instanceData.w` is plain fade in `[0, 1]` unless packed via
  // `StylizedMaterial.packAccentAndFade`: `(accentIndex + 1) * 4.0 + fade`
  // (`w >= 2.0`), which lets instances pick from `material.accentPalette`
  // without breaking instanced batching.
  float rawW = fragInstanceData.w;
  vec3 instanceAccent = material.accentColor.rgb;
  float fade;
  if (rawW >= 2.0) {
    int slot = int(floor(rawW * 0.25));
    fade = clamp(rawW - float(slot) * 4.0, 0.0, 1.0);
    int idx = slot - 1;
    if (idx >= 0 && idx < int(material.accentPaletteCount) && idx < 16) {
      instanceAccent = material.accentPalette[idx].rgb;
    }
  } else {
    fade = clamp(rawW, 0.0, 1.0);
  }

  vec3 base = material.albedoColor.rgb * fragColor.rgb;
  base *= mix(vec3(1.0), fragInstanceColor.rgb, tintMask);
  base *= mix(vec3(1.0), instanceAccent, accentMask);

  float nUp = clamp(dot(n, scene.HemisphereLight_up), -1.0, 1.0);
  float hemi = 0.5 + 0.5 * nUp;
  float bounce = max(-nUp, 0.0);
  vec3 ambient =
    scene.AmbientLight_color.rgb * scene.AmbientLight_intensity +
    scene.HemisphereLight_intensity * (
      material.ambientBase.rgb +
      material.skyFill.rgb * hemi * scene.HemisphereLight_skyColor.rgb +
      material.groundBounce * bounce * scene.HemisphereLight_groundColor.rgb
    );
  vec3 lit = fragOcclusion * ambient;

  float specular = 0.0;
  bool glossy = gloss > material.specularThreshold;
  vec3 sunShadow = vec3(1.0);
  int shadowed = int(scene.Shadows_toLight.w);
  if (shadowed >= 0 && shadowed < int(scene.DirectionalLights_numLights) &&
      (glossy ||
       dot(n, scene.DirectionalLights_directions[shadowed].xyz) > 0.0)) {
    sunShadow = shadowFactor(shadowVisibility(fragPosition, n));
  }
  for (int i = 0; i < int(scene.DirectionalLights_numLights); i++) {
    vec4 direction = scene.DirectionalLights_directions[i];
    vec4 lightColor = scene.DirectionalLights_colors[i];
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

  for (int i = 0; i < int(scene.Lights_numLights); i++) {
    vec3 toLight = scene.Lights_positions[i] - fragPosition;
    float dist = length(toLight);
    vec3 l = toLight / max(dist, 0.0001);
    float range = scene.Lights_ranges[i].x;
    float falloff;
    if (range > 0.0) {
      float rangeFade = max(1.0 - dist / range, 0.0);
      falloff = rangeFade * rangeFade;
    } else {
      falloff = 1.0 / max(dist * dist, 0.00000001);
    }
    float wrapped = max(material.pointLightWrap, dot(n, l));
    lit += scene.Lights_intensities[i].x * falloff * wrapped *
      scene.Lights_colors[i].rgb;
  }

  float spotSpecular = 0.0;
  for (int i = 0; i < int(scene.SpotLights_numLights); i++) {
    vec3 toLight = scene.SpotLights_positions[i] - fragPosition;
    float dist = length(toLight);
    vec3 l = toLight / max(dist, 0.0001);
    vec4 spotDir = scene.SpotLights_directions[i];
    vec4 spotCone = scene.SpotLights_cones[i];
    float cosTheta = dot(l, spotDir.xyz);
    float angular = clamp((cosTheta - spotCone.x) * spotCone.y, 0.0, 1.0);
    angular *= angular;
    if (angular > 0.0) {
      float range = spotCone.z;
      float falloff;
      if (range > 0.0) {
        float rf = max(1.0 - dist / range, 0.0);
        falloff = rf * rf;
      } else {
        falloff = 1.0 / max(dist * dist, 0.00000001);
      }
      vec4 spotColor = scene.SpotLights_colors[i];
      vec3 spotSh = spotCastsShadows(i)
          ? shadowFactor(shadowVisibility(fragPosition, n))
          : vec3(1.0);
      float atten = spotColor.a * falloff * angular;
      float wrapped = max(material.pointLightWrap * 0.5, dot(n, l));
      lit += atten * max(wrapped, 0.0) * spotColor.rgb * spotSh;
      if (glossy && dot(n, l) > 0.0) {
        float ndoth = max(dot(n, normalize(l + v)), 0.0);
        spotSpecular += pow(ndoth, material.specularPower) * spotDir.w * atten *
          (spotSh.r + spotSh.g + spotSh.b) / 3.0;
      }
    }
  }
  specular += spotSpecular * gloss * material.specularStrength;

  float ndotv = clamp(dot(n, v), 0.0, 1.0);
  float fresnel = pow(1.0 - ndotv, material.rimPower);
  vec3 rim = fresnel * material.rimStrength *
    (scene.HemisphereLight_skyColor.rgb + material.rimColor.rgb);

  // Sample each MatCap texture in its own uniform-only branch so materials
  // without a gem MatCap (or without a coat MatCap) skip the unused texture
  // fetch completely while keeping well-defined derivatives.
  vec3 coat = vec3(0.0);
  vec3 gem = vec3(0.0);
  bool hasCoat = material.matCapStrength != 0.0;
  bool hasGem = material.gemMatCapStrength != 0.0;
  if (hasCoat || hasGem) {
    vec3 viewNormal = normalize(mat3(scene.Camera_view) * n);
    viewNormal.x *= pictureMirror();
    vec2 matCapUv = vec2(0.5 + 0.5 * viewNormal.x, 0.5 - 0.5 * viewNormal.y);
    if (hasCoat) {
      coat = texture(matCapTexture, matCapUv).rgb * material.matCapStrength *
        mix(1.0, gloss, material.matCapGlossWeight);
    }
    if (hasGem) {
      gem = texture(gemMatCapTexture, matCapUv).rgb *
        material.gemMatCapStrength;
    }
  }
  float gemWeight = gloss > material.gemThreshold ? 1.0 : 0.0;
  float coatWeight = gloss > material.matCapThreshold ? 1.0 - gemWeight : 0.0;
  vec3 matCap = coatWeight * coat + gemWeight * gem;

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

  if (material.saturation != 1.0) {
    float luminosity = dot(color, vec3(0.3, 0.59, 0.11));
    color = clamp(mix(vec3(luminosity), color, material.saturation), 0.0, 1.0);
  }
  if (material.overlayColor.a > 0.0) {
    color = mix(color, material.overlayColor.rgb, material.overlayColor.a);
  }

  color = applyFog(
    color,
    fragPosition,
    scene.Camera_view,
    scene.Camera_projection,
    scene.Camera_position
  );

  float alpha = material.albedoColor.a * fragColor.a * fragInstanceColor.a *
    (1.0 - fade);
  if (material.ditherFade > 0.5) {
    if (alpha < bayerDither4x4(gl_FragCoord.xy)) {
      discard;
    }
    outColor = vec4(color, 1.0);
  } else {
    outColor = vec4(color * alpha, alpha);
  }
}

#endif
