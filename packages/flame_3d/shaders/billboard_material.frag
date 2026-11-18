#version 460 core

// HD-2D billboard / standee fragment shader with alpha cutout, optional
// hemisphere + directional sun shading, emissive boost, and atmospheric fog.

in vec3 fragPosition;
in vec3 fragNormal;
in vec2 fragUv;
in vec4 fragColor;
in vec4 fragData;

out vec4 outColor;

uniform sampler2D albedoTexture;

uniform BillboardLook {
  vec4 albedoColor;
  // x: alphaCutoff, y: defaultShadeWeight, z: premultiplyAlpha, w: ditherFade
  vec4 params;
} bLook;

#include <flame_3d/lights.glsl>

uniform Camera {
  mat4 view;
  mat4 projection;
  vec3 position;
} camera;

#include <flame_3d/fog.glsl>
#include <flame_3d/dither.glsl>

void main() {
  vec4 tex = texture(albedoTexture, fragUv);
  float fade = clamp(fragData.z, 0.0, 1.0);
  float alpha = tex.a * bLook.albedoColor.a * fragColor.a * (1.0 - fade);

  if (bLook.params.x > 0.0 && alpha < bLook.params.x) {
    discard;
  }
  if (bLook.params.w > 0.5 && alpha < bayerDither4x4(gl_FragCoord.xy)) {
    discard;
  }

  vec3 base = tex.rgb * bLook.albedoColor.rgb * fragColor.rgb;
  float shadeW = clamp(bLook.params.y * (1.0 - fragData.y), 0.0, 1.0);

  vec3 color = base;
  if (shadeW > 0.0) {
    vec3 n = normalize(fragNormal);
    vec3 irr = ambientLight.color.rgb * ambientLight.intensity;
    float hemi = 0.5 + 0.5 * dot(n, hemisphereLight.up);
    irr += mix(
      hemisphereLight.groundColor.rgb,
      hemisphereLight.skyColor.rgb,
      hemi
    ) * hemisphereLight.intensity;
    for (int i = 0; i < int(directionalLights.numLights); i++) {
      vec4 d = directionalLights.directions[i];
      vec4 c = directionalLights.colors[i];
      float wrapNdotL = 0.35 + 0.65 * max(dot(n, d.xyz), 0.0);
      irr += c.rgb * (c.a * wrapNdotL);
    }
    for (int i = 0; i < int(lights.numLights); i++) {
      vec3 toL = lights.positions[i] - fragPosition;
      float dist = max(length(toL), 0.001);
      vec3 l = toL / dist;
      float range = lights.ranges[i].x;
      float atten = range > 0.0
          ? pow(max(1.0 - dist / range, 0.0), 2.0)
          : 1.0 / (dist * dist);
      float wrapNdotL = 0.35 + 0.65 * max(dot(n, l), 0.0);
      irr += lights.colors[i].rgb * (lights.intensities[i].x * atten * wrapNdotL);
    }
    for (int i = 0; i < int(spotLights.numLights); i++) {
      vec3 toL = spotLights.positions[i] - fragPosition;
      float dist = max(length(toL), 0.001);
      vec3 l = toL / dist;
      float cosT = dot(l, spotLights.directions[i].xyz);
      float spotMask = clamp(
        (cosT - spotLights.cones[i].x) * spotLights.cones[i].y,
        0.0,
        1.0
      );
      spotMask = spotMask * spotMask * (3.0 - 2.0 * spotMask);
      float range = spotLights.cones[i].z;
      float atten = range > 0.0
          ? pow(max(1.0 - dist / range, 0.0), 2.0)
          : 1.0 / (dist * dist);
      float wrapNdotL = 0.35 + 0.65 * max(dot(n, l), 0.0);
      irr += spotLights.colors[i].rgb *
        (spotLights.colors[i].a * atten * spotMask * wrapNdotL);
    }
    color = mix(base, base * clamp(irr, 0.0, 1.6), shadeW);
  }

  color *= (1.0 + max(0.0, fragData.x));

  color = applyFog(
    color,
    fragPosition,
    camera.view,
    camera.projection,
    camera.position
  );

  float outAlpha = bLook.params.x > 0.0 || bLook.params.w > 0.5 ? 1.0 : alpha;
  if (bLook.params.z > 0.5) {
    outColor = vec4(color * outAlpha, outAlpha);
  } else {
    outColor = vec4(color, outAlpha);
  }
}
