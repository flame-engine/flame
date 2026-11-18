#version 460 core

// Inverted-hull silhouette contour (`OutlineMaterial`): pushes vertices out
// along their normals in either world space (`params.z < 0.5`) or clip/screen
// space (`params.z > 0.5`), modulated per instance by `instanceColor` and
// `instanceData` (`x`: thickness multiplier `1 + x`, `y`: extra clip depth
// bias). Drawn with front faces culled (`CullMode.frontFace`), only the outer
// back-face rim appears around the object's silhouette.

in vec3 vertexPosition;
in vec3 vertexNormal;

#include <flame_3d/instancing.glsl>
#include <flame_3d/camera.glsl>

uniform Outline {
  vec4 color;
  // x: thickness, y: clip depth bias, z: 1 for screen-space thickness, w: aspect (height / width).
  vec4 params;
} outline;

out vec4 fragColor;

void main() {
  mat4 model = instanceModelMatrix();
  float scale = max(0.0, 1.0 + instanceData.x);
  float thickness = outline.params.x * scale;
  float depthBias = outline.params.y + instanceData.y;

  vec3 worldPos = (model * vec4(vertexPosition, 1.0)).xyz;
  mat3 normalMat = mat3(model);
  vec3 worldNormal = normalMat * vertexNormal;
  float nLen = length(worldNormal);
  worldNormal = nLen > 1e-6 ? worldNormal / nLen : vec3(0.0, 1.0, 0.0);

  vec4 clipPos;
  if (outline.params.z > 0.5) {
    clipPos = camera.viewProjection * vec4(worldPos, 1.0);
    vec4 clipNormal = camera.viewProjection * vec4(worldNormal, 0.0);
    vec2 dir = clipNormal.xy;
    // Compensate for aspect ratio so horizontal and vertical strokes match.
    float aspect = max(outline.params.w, 1e-4);
    vec2 metric = vec2(dir.x / aspect, dir.y);
    float mLen = length(metric);
    if (mLen > 1e-6) {
      vec2 unit = metric / mLen;
      clipPos.xy += vec2(unit.x * aspect, unit.y) * thickness * clipPos.w;
    }
  } else {
    clipPos = camera.viewProjection * vec4(worldPos + worldNormal * thickness, 1.0);
  }

  clipPos.z = clamp(clipPos.z + depthBias * clipPos.w, 0.0, clipPos.w);
  gl_Position = clipPos;
  fragColor = outline.color * instanceColor;
}
