#version 460 core

// Camera-facing 3D ribbon segment (`RibbonMaterial3D`, `RibbonTrail3D`,
// `StrokeBatch3D`), drawn instanced from a unit quad (`vertexPosition.x` in
// `[0, 1]` along the segment, `vertexPosition.y` in `[-1, 1]` across it):
// - `instanceModel0`: start point `p0` (xyz) and start half-width (w);
// - `instanceModel1`: end point `p1` (xyz) and end half-width (w);
// - `instanceModel2`: start join tangent `t0` (xyz) and start opacity (w);
// - `instanceModel3`: end join tangent `t1` (xyz) and end opacity (w);
// - `instanceColor`: straight RGBA segment color;
// - `instanceData`: `x` start UV `u0`, `y` end UV `u1`.

in vec3 vertexPosition;

#include <flame_3d/instancing.glsl>
#include <flame_3d/camera.glsl>

uniform RibbonView {
  // xyz: unit vector towards viewer (orthographic), w: 1 when perspective.
  vec4 viewer;
  // xyz: camera world position, w: clip depthBias.
  vec4 eye;
  // xyz: camera right fallback axis.
  vec4 right;
} ribbonView;

out vec2 fragUv;
out float fragAcross;
out vec4 fragColor;

vec3 viewRayAt(vec3 worldPos) {
  if (ribbonView.viewer.w > 0.5) {
    vec3 d = ribbonView.eye.xyz - worldPos;
    float len = length(d);
    return len > 1e-6 ? d / len : ribbonView.viewer.xyz;
  }
  return ribbonView.viewer.xyz;
}

vec3 sideAxis(vec3 tangent, vec3 fallback, vec3 toViewer) {
  vec3 side = cross(tangent, toViewer);
  float sLen = length(side);
  if (sLen > 1e-6) {
    return side / sLen;
  }
  vec3 fb = cross(fallback, toViewer);
  float fLen = length(fb);
  if (fLen > 1e-6) {
    return fb / fLen;
  }
  return ribbonView.right.xyz;
}

void main() {
  mat4 seg = instanceModelMatrix();
  vec3 p0 = seg[0].xyz;
  float w0 = seg[0].w;
  vec3 p1 = seg[1].xyz;
  float w1 = seg[1].w;
  vec3 t0 = seg[2].xyz;
  float a0 = seg[2].w;
  vec3 t1 = seg[3].xyz;
  float a1 = clamp(seg[3].w, 0.0, 1.0);

  float s = clamp(vertexPosition.x, 0.0, 1.0);
  float sideSign = vertexPosition.y;

  vec3 chord = p1 - p0;
  vec3 center = mix(p0, p1, s);
  vec3 tangent = s < 0.5 ? t0 : t1;
  float halfWidth = mix(w0, w1, s);
  float opacity = mix(a0, a1, s);

  vec3 toViewer = viewRayAt(center);
  vec3 across = sideAxis(tangent, chord, toViewer);
  vec3 worldPos = center + across * (sideSign * halfWidth);

  vec4 clipPos = camera.viewProjection * vec4(worldPos, 1.0);
  clipPos.z = clamp(clipPos.z - ribbonView.eye.w * clipPos.w, 0.0, clipPos.w);
  gl_Position = clipPos;

  float u = mix(instanceData.x, instanceData.y, s);
  fragUv = vec2(u, 0.5 + 0.5 * sideSign);
  fragAcross = sideSign;
  fragColor = vec4(instanceColor.rgb, instanceColor.a * opacity);
}
