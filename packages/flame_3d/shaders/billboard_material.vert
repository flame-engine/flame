#version 460 core

// Instanced HD-2D billboard / standee vertex shader:
// - instanceModel0: center (xyz, world space) and width (w)
// - instanceModel1: locked upAxis (xyz) and height (w)
// - instanceModel2: uvRect (left, top, width, height)
// - instanceModel3: anchorY (x, 0=center, -0.5=bottom), tiltRad (y),
//                   rollRad (z), mode (w: 0=spherical, 1=cylindrical)
// - instanceColor:  RGBA tint
// - instanceData:   (emissiveBoost, shadeWeight, fade, 0)

in vec3 vertexPosition;
in vec2 vertexTexCoord;

#include <flame_3d/instancing.glsl>
#include <flame_3d/camera.glsl>

uniform BillboardFrame {
  vec4 camRight;
  vec4 camUp;
  vec4 camBack;
} bFrame;

out vec3 fragPosition;
out vec3 fragNormal;
out vec2 fragUv;
out vec4 fragColor;
out vec4 fragData;

void main() {
  mat4 inst = instanceModelMatrix();
  vec3 center = inst[0].xyz;
  float width = inst[0].w;
  vec3 lockedUp = inst[1].xyz;
  float height = inst[1].w;
  vec4 uvRect = inst[2];
  float anchorY = inst[3].x;
  float tiltRad = inst[3].y;
  float rollRad = inst[3].z;
  float mode = inst[3].w;

  vec3 right = bFrame.camRight.xyz;
  vec3 up = bFrame.camUp.xyz;
  vec3 normal = bFrame.camBack.xyz;

  if (mode > 0.5) {
    // Cylindrical / HD-2D standee locked around `lockedUp` with optional tilt.
    vec3 axisUp = length(lockedUp) > 1e-5 ? normalize(lockedUp) : up;
    vec3 side = right - axisUp * dot(right, axisUp);
    if (dot(side, side) < 1e-8) {
      side = cross(axisUp, normal);
    }
    right = normalize(side);
    vec3 faceN = normalize(cross(right, axisUp));
    if (dot(faceN, normal) < 0.0) {
      faceN = -faceN;
    }
    float ct = cos(tiltRad);
    float st = sin(tiltRad);
    up = normalize(axisUp * ct - faceN * st);
    normal = normalize(cross(right, up));
  }

  vec2 localCorner = vec2(vertexPosition.x, vertexPosition.y - anchorY);
  if (abs(rollRad) > 1e-5) {
    float cr = cos(rollRad);
    float sr = sin(rollRad);
    localCorner = vec2(
      localCorner.x * cr - localCorner.y * sr,
      localCorner.x * sr + localCorner.y * cr
    );
  }

  vec3 worldPos =
    center + right * (localCorner.x * width) + up * (localCorner.y * height);

  fragPosition = worldPos;
  fragNormal = normal;
  fragUv = uvRect.xy + vertexTexCoord * uvRect.zw;
  fragColor = instanceColor;
  fragData = instanceData;

  gl_Position = camera.viewProjection * vec4(worldPos, 1.0);
}
