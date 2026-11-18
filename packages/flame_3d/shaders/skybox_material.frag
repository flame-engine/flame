#version 460 core

// Procedural atmospheric gradient + solar disc/halo + optional equirectangular
// panorama skybox shader.

#define PI 3.14159265359

in vec2 fragNdc;

out vec4 outColor;

uniform sampler2D panoramaTexture;

uniform Skybox {
  mat4 invViewProjection;
  vec4 zenithColor;
  vec4 horizonColor;
  vec4 groundColor;
  // rgb: sunColor, a: sunIntensity
  vec4 sunColor;
  // xyz: unit vector towards sun, w: cos(sunAngularRadius)
  vec4 sunDir;
  // xyz: unit up axis, w: hasPanorama (1 = panorama, 0 = procedural)
  vec4 upAndMode;
  // x: horizonExponent, y: sunHaloStrength, z: exposure, w: 0
  vec4 params;
} sky;

vec2 equirectUv(vec3 dir) {
  float phi = atan(dir.z, dir.x);
  float theta = asin(clamp(dir.y, -1.0, 1.0));
  return vec2(phi * (0.5 / PI) + 0.5, 0.5 - theta * (1.0 / PI));
}

void main() {
  vec4 farWorld = sky.invViewProjection * vec4(fragNdc, 1.0, 1.0);
  vec4 nearWorld = sky.invViewProjection * vec4(fragNdc, 0.0, 1.0);
  vec3 pFar = farWorld.xyz / max(abs(farWorld.w), 1e-6);
  vec3 pNear = nearWorld.xyz / max(abs(nearWorld.w), 1e-6);
  vec3 dir = normalize(pFar - pNear);

  vec3 color;
  if (sky.upAndMode.w > 0.5) {
    color = texture(panoramaTexture, equirectUv(dir)).rgb;
  } else {
    vec3 up = normalize(sky.upAndMode.xyz);
    float elev = clamp(dot(dir, up), -1.0, 1.0);
    if (elev >= 0.0) {
      float t = pow(elev, max(sky.params.x, 0.05));
      color = mix(sky.horizonColor.rgb, sky.zenithColor.rgb, t);
    } else {
      float t = pow(-elev, 0.65);
      color = mix(sky.horizonColor.rgb, sky.groundColor.rgb, t);
    }

    float sunDot = dot(dir, normalize(sky.sunDir.xyz));
    float cosDisk = sky.sunDir.w;
    float disk = smoothstep(cosDisk - 0.003, cosDisk + 0.001, sunDot);
    float halo = pow(max(sunDot, 0.0), 12.0) * sky.params.y;
    color += sky.sunColor.rgb * sky.sunColor.a * (disk + halo);
  }

  color *= sky.params.z;
  outColor = vec4(clamp(color, 0.0, 1.0), 1.0);
}
