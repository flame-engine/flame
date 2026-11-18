#ifndef FLAME_FOG_GLSL_
#define FLAME_FOG_GLSL_

// Atmospheric distance and height fog (`FogSettings`), filled by `flame_3d`
// once per render pass for every fragment shader that declares the `Fog`
// uniform block (or folds its members into a merged pass block via
// `#define FLAME_FOG(member) ...` before including this file).

#ifndef FLAME_FOG
uniform Fog {
  // rgb: fog color; a: maxOpacity (0 when the pass has no fog).
  vec4 color;
  // x: start distance, y: 1 / max(end - start, 1e-4), z: exponential density,
  // w: heightFalloff.
  vec4 params;
  // xyz: unit up axis, w: baseHeight.
  vec4 height;
} fog;
#define FLAME_FOG(member) fog.member
#endif

// Blends `surfaceColor` (straight RGB) towards the fog color at `worldPosition`
// for a camera with `viewMatrix`, `projectionMatrix` and `cameraPosition`.
vec3 applyFog(
  vec3 surfaceColor,
  vec3 worldPosition,
  mat4 viewMatrix,
  mat4 projectionMatrix,
  vec3 cameraPosition
) {
  float maxOpacity = FLAME_FOG(color).a;
  if (maxOpacity <= 0.0) {
    return surfaceColor;
  }

  float dist;
  if (projectionMatrix[3][3] > 0.5) {
    // Orthographic / affine parallel projection: measure eye-space depth.
    dist = max(0.0, -(viewMatrix * vec4(worldPosition, 1.0)).z);
  } else {
    dist = length(worldPosition - cameraPosition);
  }

  vec4 p = FLAME_FOG(params);
  float pastStart = max(0.0, dist - p.x);
  float distFactor = p.z > 0.0
      ? 1.0 - exp(-p.z * pastStart)
      : clamp(pastStart * p.y, 0.0, 1.0);

  float heightFactor = 1.0;
  if (p.w > 0.0) {
    vec4 h = FLAME_FOG(height);
    float elevation = dot(worldPosition, h.xyz) - h.w;
    heightFactor = exp(-p.w * max(0.0, elevation));
  }

  float amount = clamp(distFactor * heightFactor, 0.0, 1.0) * maxOpacity;
  return mix(surfaceColor, FLAME_FOG(color).rgb, amount);
}

#endif
