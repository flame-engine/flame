#ifndef FLAME_LIGHTS_GLSL_
#define FLAME_LIGHTS_GLSL_

// The lights of the render pass, filled by flame_3d once per pass for every
// shader that declares them. A material lists the blocks its shader uses in
// its slots.

#define MAX_POINT_LIGHTS 8
#define MAX_DIRECTIONAL_LIGHTS 4
#define MAX_SPOT_LIGHTS 4

// The first ambient light of the scene, `color.rgb * intensity`. Its
// intensity is 0 when a hemisphere light replaces the default ambient light.
uniform AmbientLight {
  vec4 color;
  float intensity;
} ambientLight;

// The point lights of the scene. `intensities[i].x` is the intensity and
// `ranges[i].x` the distance at which the light fades out, or 0 for an
// inverse-square falloff.
uniform Lights {
  float numLights;
  vec3 positions[MAX_POINT_LIGHTS];
  vec4 colors[MAX_POINT_LIGHTS];
  vec4 intensities[MAX_POINT_LIGHTS];
  vec4 ranges[MAX_POINT_LIGHTS];
} lights;

// The directional lights of the scene. `directions[i].xyz` is the unit vector
// from a surface towards the light and `directions[i].w` how strongly it makes
// specular highlights; `colors[i].rgb` is its color and `colors[i].a` its
// intensity.
uniform DirectionalLights {
  float numLights;
  vec4 directions[MAX_DIRECTIONAL_LIGHTS];
  vec4 colors[MAX_DIRECTIONAL_LIGHTS];
} directionalLights;

// Cone spot lights of the scene: `directions[i].xyz` points from the spot
// towards the light (`-spotDir`), `directions[i].w` is specular factor,
// `colors[i]` is `(rgb, intensity)`, and `cones[i]` is
// `(cosOuter, invAngleSpan, range, 0)`.
uniform SpotLights {
  float numLights;
  vec3 positions[MAX_SPOT_LIGHTS];
  vec4 directions[MAX_SPOT_LIGHTS];
  vec4 colors[MAX_SPOT_LIGHTS];
  vec4 cones[MAX_SPOT_LIGHTS];
} spotLights;

// The hemisphere light of the scene: light from the sky (towards the unit
// vector `up`) and from the ground. Its intensity is 0 when there is none.
uniform HemisphereLight {
  vec4 skyColor;
  vec4 groundColor;
  vec3 up;
  float intensity;
} hemisphereLight;

#endif
