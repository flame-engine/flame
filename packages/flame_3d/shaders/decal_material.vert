#version 460 core

// Instanced 3D surface decal (`DecalMaterial` / `DecalBatch3D`):
// - `instanceModel0..3`: 3D model matrix placing and scaling the decal quad;
// - `instanceColor`: per-decal color and alpha;
// - `instanceData`: atlas UV sub-rect `(u0, v0, uWidth, vHeight)` when
//   `z > 0 && w > 0`, otherwise full `(0, 0, 1, 1)` texture coordinates.
// Clip-space depth is nudged towards the camera by `decal.params.x` so flat
// decals on floors or walls do not Z-fight with coplanar geometry.

in vec3 vertexPosition;
in vec2 vertexTexCoord;

#include <flame_3d/instancing.glsl>
#include <flame_3d/camera.glsl>

uniform Decal {
  vec4 albedoColor;
  // x: clip depth bias, y: radial softness, z: inner ring radius, w: 1 when using procedural disc/ring.
  vec4 params;
  // x: alphaCutoff.
  vec4 cutoff;
} decal;

out vec2 fragTexCoord;
out vec2 fragLocalUv;
out vec4 fragColor;

void main() {
  mat4 model = instanceModelMatrix();
  vec4 clipPos = camera.viewProjection * (model * vec4(vertexPosition, 1.0));
  clipPos.z = clamp(clipPos.z - decal.params.x * clipPos.w, 0.0, clipPos.w);
  gl_Position = clipPos;

  vec4 uvRect = (instanceData.z > 0.0 && instanceData.w > 0.0)
      ? instanceData
      : vec4(0.0, 0.0, 1.0, 1.0);
  fragLocalUv = vertexTexCoord;
  fragTexCoord = uvRect.xy + vertexTexCoord * uvRect.zw;
  fragColor = decal.albedoColor * instanceColor;
}
