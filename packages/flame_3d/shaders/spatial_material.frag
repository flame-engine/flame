#version 460 core

// Physically-based Cook-Torrance metallic-roughness shader with normal mapping
// (derivative cotangent TBN), ORM / occlusion maps, emissive maps, equirect
// environment reflections, directional PCF shadows, spot lights, fog, alpha
// cutout, Bayer dither fade, and translucent alpha support.

#define PI 3.14159265359
#define EPSILON 0.0001

in vec2 fragTexCoord;
in vec4 fragColor;
in vec3 fragPosition;
smooth in vec3 fragNormal;
in vec4 fragInstanceColor;
in vec4 fragInstanceData;

out vec4 outColor;

uniform sampler2D albedoTexture;
uniform sampler2D normalTexture;
uniform sampler2D metallicRoughnessTexture;
uniform sampler2D occlusionTexture;
uniform sampler2D emissiveTexture;
uniform sampler2D environmentTexture;

uniform Material {
  vec4 albedoColor;
  // rgb: emissiveColor * emissiveStrength, a: alphaCutoff
  vec4 emissiveColor;
  // xy: uvScale, zw: uvOffset
  vec4 uvTransform;
  // x: metallic, y: roughness, z: normalScale, w: occlusionStrength
  vec4 params;
  // x: hasNormalTex, y: hasOrmTex, z: hasOcclusionTex, w: environmentIntensity
  vec4 flags;
  // x: doubleSided, y: ditherFade, z: premultiplyAlpha, w: hasEmissiveTex
  vec4 flags2;
  // L0..L2 Spherical Harmonics diffuse irradiance (shCoeffs[0].w > 0 enables)
  vec4 shCoeffs[9];
} material;

#include <flame_3d/lights.glsl>

uniform Camera {
  mat4 view;
  mat4 projection;
  vec3 position;
} camera;

#include <flame_3d/shadows.glsl>
#include <flame_3d/fog.glsl>
#include <flame_3d/dither.glsl>

vec3 fresnelSchlick(float cosTheta, vec3 f0) {
  return f0 + (1.0 - f0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
}

float distributionGGX(vec3 normal, vec3 halfwayDir, float roughness) {
  float a = roughness * roughness;
  float a2 = a * a;
  float NdotH = max(dot(normal, halfwayDir), 0.0);
  float NdotH2 = NdotH * NdotH;
  float b = (NdotH2 * (a2 - 1.0) + 1.0);
  return a2 / max(PI * b * b, EPSILON);
}

float geometrySchlickGGX(float NdotV, float roughness) {
  float r = (roughness + 1.0);
  float k = (r * r) / 8.0;
  return NdotV / (NdotV * (1.0 - k) + k);
}

float geometrySmith(vec3 normal, vec3 viewDir, vec3 lightDir, float roughness) {
  float NdotV = max(dot(normal, viewDir), 0.0);
  float NdotL = max(dot(normal, lightDir), 0.0);
  return geometrySchlickGGX(NdotV, roughness) * geometrySchlickGGX(NdotL, roughness);
}

// Tangent-free screen-space cotangent frame normal perturbation.
vec3 perturbNormal(vec3 n, vec3 worldPos, vec2 uv, vec3 mapSample, float scale) {
  vec3 dp1 = dFdx(worldPos);
  vec3 dp2 = dFdy(worldPos);
  vec2 duv1 = dFdx(uv);
  vec2 duv2 = dFdy(uv);

  vec3 dp2perp = cross(dp2, n);
  vec3 dp1perp = cross(n, dp1);
  vec3 t = dp2perp * duv1.x + dp1perp * duv2.x;
  vec3 b = dp2perp * duv1.y + dp1perp * duv2.y;
  float maxLen2 = max(dot(t, t), dot(b, b));
  if (maxLen2 < 1e-10) {
    return n;
  }
  float invMax = inversesqrt(maxLen2);
  mat3 tbn = mat3(t * invMax, b * invMax, n);
  vec3 localN = mapSample * 2.0 - 1.0;
  localN.xy *= scale;
  return normalize(tbn * localN);
}

vec2 equirectUv(vec3 dir) {
  float phi = atan(dir.z, dir.x);
  float theta = asin(clamp(dir.y, -1.0, 1.0));
  return vec2(phi * (0.5 / PI) + 0.5, 0.5 - theta * (1.0 / PI));
}

vec3 processLight(
  vec3 lightDir,
  vec3 radiance,
  float specularFactor,
  vec3 baseColor,
  vec3 normal,
  vec3 viewDir,
  vec3 f0,
  float metallic,
  float roughness
) {
  vec3 halfwayDir = normalize(viewDir + lightDir);
  float ndf = distributionGGX(normal, halfwayDir, roughness);
  float g = geometrySmith(normal, viewDir, lightDir, roughness);
  vec3 f = fresnelSchlick(max(dot(halfwayDir, viewDir), 0.0), f0);

  vec3 kS = f;
  vec3 kD = (vec3(1.0) - kS) * (1.0 - metallic);

  vec3 numerator = ndf * g * f;
  float denominator =
    4.0 * max(dot(normal, viewDir), 0.0) * max(dot(normal, lightDir), 0.0) +
    EPSILON;
  vec3 specular = numerator / denominator;

  float NdotL = max(dot(normal, lightDir), 0.0);
  return (kD * baseColor / PI + specular * specularFactor) * radiance * NdotL;
}

void main() {
  vec2 uv = fragTexCoord * material.uvTransform.xy + material.uvTransform.zw;

  vec4 albedoTexel = texture(albedoTexture, uv);
  vec3 geomNormal = normalize(fragNormal);
  if (material.flags2.x > 0.5 && !gl_FrontFacing) {
    geomNormal = -geomNormal;
  }

  vec3 normal = geomNormal;
  if (material.flags.x > 0.5) {
    vec3 nSample = texture(normalTexture, uv).rgb;
    normal = perturbNormal(geomNormal, fragPosition, uv, nSample, material.params.z);
  }

  float metallic = material.params.x;
  float roughness = material.params.y;
  float ao = 1.0;
  if (material.flags.y > 0.5) {
    vec3 orm = texture(metallicRoughnessTexture, uv).rgb;
    roughness *= orm.g;
    metallic *= orm.b;
  }
  roughness = clamp(roughness, 0.04, 1.0);
  metallic = clamp(metallic, 0.0, 1.0);

  if (material.flags.z > 0.5) {
    float occTex = texture(occlusionTexture, uv).r;
    ao = mix(1.0, occTex, clamp(material.params.w, 0.0, 1.0));
  }

  vec3 emissive = material.emissiveColor.rgb;
  if (material.flags2.w > 0.5) {
    emissive *= texture(emissiveTexture, uv).rgb;
  }

  float fade = clamp(fragInstanceData.w, 0.0, 1.0);
  float alpha =
    material.albedoColor.a *
    fragInstanceColor.a *
    fragColor.a *
    albedoTexel.a *
    (1.0 - fade);

  if (material.emissiveColor.a > 0.0 && alpha < material.emissiveColor.a) {
    discard;
  }
  if (material.flags2.y > 0.5 && alpha < bayerDither4x4(gl_FragCoord.xy)) {
    discard;
  }

  vec3 viewDir = camera.projection[3][3] > 0.5
      ? normalize(vec3(camera.view[0][2], camera.view[1][2], camera.view[2][2]))
      : normalize(camera.position - fragPosition);

  vec3 baseColor =
    material.albedoColor.rgb *
    fragInstanceColor.rgb *
    fragColor.rgb *
    albedoTexel.rgb;

  vec3 f0 = mix(vec3(0.04), baseColor, metallic);
  vec3 kS = fresnelSchlick(max(dot(normal, viewDir), 0.0), f0);
  vec3 kD = (vec3(1.0) - kS) * (1.0 - metallic);

  vec3 ambient = kD * baseColor * ambientLight.color.rgb * ambientLight.intensity;
  float hemi = 0.5 + 0.5 * dot(normal, hemisphereLight.up);
  vec3 sky = mix(hemisphereLight.groundColor.rgb, hemisphereLight.skyColor.rgb, hemi);
  ambient += kD * baseColor * sky * hemisphereLight.intensity;

  if (material.shCoeffs[0].w > 0.0) {
    float nx = normal.x;
    float ny = normal.y;
    float nz = normal.z;
    vec3 shIrr =
      material.shCoeffs[0].rgb * 0.886227 +
      material.shCoeffs[1].rgb * (1.023327 * ny) +
      material.shCoeffs[2].rgb * (1.023327 * nz) +
      material.shCoeffs[3].rgb * (1.023327 * nx) +
      material.shCoeffs[4].rgb * (0.858086 * nx * ny) +
      material.shCoeffs[5].rgb * (0.858086 * ny * nz) +
      material.shCoeffs[6].rgb * (0.247708 * (3.0 * nz * nz - 1.0)) +
      material.shCoeffs[7].rgb * (0.858086 * nx * nz) +
      material.shCoeffs[8].rgb * (0.429043 * (nx * nx - ny * ny));
    ambient += kD * baseColor * max(shIrr, vec3(0.0)) * material.shCoeffs[0].w;
  }

  if (material.flags.w > 0.0) {
    vec3 refl = reflect(-viewDir, normal);
    vec3 envSample = texture(environmentTexture, equirectUv(refl)).rgb;
    float glossFactor = 1.0 - roughness * 0.75;
    ambient += kS * envSample * material.flags.w * glossFactor;
  }
  ambient *= ao;

  vec3 lo = vec3(0.0);

  for (int i = 0; i < int(lights.numLights); i++) {
    vec3 lightDirVec = lights.positions[i] - fragPosition;
    float distance = length(lightDirVec) + EPSILON;
    float intensity = lights.intensities[i].x;
    float range = lights.ranges[i].x;
    float attenuation;
    if (range > 0.0) {
      float falloff = max(1.0 - distance / range, 0.0);
      attenuation = intensity * falloff * falloff;
    } else {
      attenuation = intensity / (distance * distance);
    }
    lo += processLight(
      normalize(lightDirVec),
      lights.colors[i].rgb * attenuation,
      1.0,
      baseColor,
      normal,
      viewDir,
      f0,
      metallic,
      roughness
    );
  }

  vec3 sunShadow = vec3(1.0);
  int shadowed = int(FLAME_SHADOWS(toLight).w);
  if (shadowed >= 0 && shadowed < int(directionalLights.numLights) &&
      dot(geomNormal, directionalLights.directions[shadowed].xyz) > -0.05) {
    sunShadow = shadowFactor(shadowVisibility(fragPosition, geomNormal));
  }

  for (int i = 0; i < int(directionalLights.numLights); i++) {
    vec4 direction = directionalLights.directions[i];
    vec4 lightColor = directionalLights.colors[i];
    vec3 shadow = castsShadows(i) ? sunShadow : vec3(1.0);
    lo += processLight(
      direction.xyz,
      lightColor.rgb * lightColor.a * shadow,
      direction.w,
      baseColor,
      normal,
      viewDir,
      f0,
      metallic,
      roughness
    );
  }

  for (int i = 0; i < int(spotLights.numLights); i++) {
    vec3 toLight = spotLights.positions[i] - fragPosition;
    float dist = length(toLight) + EPSILON;
    vec3 l = toLight / dist;
    vec4 spotDir = spotLights.directions[i];
    vec4 spotCone = spotLights.cones[i];
    float cosTheta = dot(l, spotDir.xyz);
    float angular = clamp((cosTheta - spotCone.x) * spotCone.y, 0.0, 1.0);
    angular *= angular;
    if (angular > 0.0) {
      float range = spotCone.z;
      float attenuation;
      if (range > 0.0) {
        float rf = max(1.0 - dist / range, 0.0);
        attenuation = rf * rf;
      } else {
        attenuation = 1.0 / (dist * dist);
      }
      vec4 spotColor = spotLights.colors[i];
      vec3 spotSh = spotCastsShadows(i)
          ? shadowFactor(shadowVisibility(fragPosition, geomNormal))
          : vec3(1.0);
      lo += processLight(
        l,
        spotColor.rgb * (spotColor.a * attenuation * angular) * spotSh,
        spotDir.w,
        baseColor,
        normal,
        viewDir,
        f0,
        metallic,
        roughness
      );
    }
  }

  float boost = max(0.0, fragInstanceData.x);
  float highlight = clamp(fragInstanceData.y, 0.0, 1.0);
  vec3 color = ambient + lo + emissive * (1.0 + boost) + vec3(highlight);

  color = color / (color + vec3(1.0));
  color = pow(max(color, vec3(0.0)), vec3(1.0 / 2.2));

  color = applyFog(
    color,
    fragPosition,
    camera.view,
    camera.projection,
    camera.position
  );

  if (material.flags2.y > 0.5) {
    outColor = vec4(color, 1.0);
  } else if (material.flags2.z > 0.5) {
    outColor = vec4(color * alpha, alpha);
  } else {
    outColor = vec4(color, alpha);
  }
}
