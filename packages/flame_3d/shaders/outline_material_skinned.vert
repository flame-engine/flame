#version 460 core

// Skinned variant of `outline_material.vert`: skins position and normal by up
// to four joints before extruding the silhouette contour.

in vec3 vertexPosition;
in vec3 vertexNormal;

#include <flame_3d/skinning.glsl>
#include <flame_3d/instancing.glsl>
#include <flame_3d/camera.glsl>

uniform Outline {
  vec4 color;
  vec4 params;
} outline;

out vec4 fragColor;

void main() {
  mat4 model = instanceModelMatrix();
  mat4 combined = model * computeSkinMatrix();

  float scale = max(0.0, 1.0 + instanceData.x);
  float thickness = outline.params.x * scale;
  float depthBias = outline.params.y + instanceData.y;

  vec3 worldPos = (combined * vec4(vertexPosition, 1.0)).xyz;
  vec3 worldNormal = mat3(combined) * vertexNormal;
  float nLen = length(worldNormal);
  worldNormal = nLen > 1e-6 ? worldNormal / nLen : vec3(0.0, 1.0, 0.0);

  vec4 clipPos;
  if (outline.params.z > 0.5) {
    clipPos = camera.viewProjection * vec4(worldPos, 1.0);
    vec4 clipNormal = camera.viewProjection * vec4(worldNormal, 0.0);
    vec2 dir = clipNormal.xy;
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
