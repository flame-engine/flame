#version 460 core

// One camera-facing quad per particle, drawn instanced: the vertices are the
// corners of a unit quad, the instance inputs hold the particle (see
// ParticleMaterial and ParticleSystem3D, which write them):
//
// - instanceModel0: the center (xyz, world space) and the width (w);
// - instanceModel1: the velocity (xyz, world space) and the height (w);
// - instanceModel2: the rotation in radians (x), the flipbook frame (y, its
//   fraction blends to the next frame), a random seed in [0, 1) (z) and the
//   stretch along the velocity (w);
// - instanceModel3: the life progress in [0, 1] (x);
// - instanceColor: the color, straight alpha.

in vec3 vertexPosition;
in vec2 vertexTexCoord;

#include <flame_3d/instancing.glsl>
#include <flame_3d/camera.glsl>

// Written by ParticleMaterial for each render pass.
uniform ParticleBillboard {
  // xyz: the world direction that points right on screen; w: the billboard
  // mode (0 spherical, 1 cylindrical, 2 velocity, 3 flat).
  vec4 right;
  // xyz: the world direction that points up on screen; w: 1 when the camera
  // has a perspective projection.
  vec4 up;
  // xyz: the unit vector towards the viewer of an orthographic camera.
  vec4 back;
  // xyz: the position of the camera.
  vec4 eye;
  // xyz: the locked axis of cylindrical billboards.
  vec4 axis;
  // xyz: the axes of the plane of flat billboards.
  vec4 flatX;
  vec4 flatY;
  // x: columns, y: rows, z: frames of the flipbook; w: 1 to blend frames.
  vec4 flipbook;
} billboard;

out vec2 fragTexCoord;
out vec2 fragNextTexCoord;
out vec2 fragCorner;
out vec4 fragColor;
out vec4 fragParams;
out vec4 fragClipPos;

vec2 frameTexCoord(float frame, vec2 texCoord) {
  float columns = billboard.flipbook.x;
  float rows = billboard.flipbook.y;
  float column = mod(frame, columns);
  float row = floor(frame / columns);
  return (vec2(column, row) + texCoord) / vec2(columns, rows);
}

void main() {
  // Reads every instance input, see instancing.glsl.
  mat4 particle = instanceModelMatrix();
  vec3 center = particle[0].xyz;
  vec2 size = vec2(particle[0].w, particle[1].w);
  vec3 velocity = particle[1].xyz;
  float rotation = particle[2].x;
  float frame = particle[2].y;
  float seed = particle[2].z;
  float stretch = particle[2].w;

  float mode = billboard.right.w;
  vec3 right = billboard.right.xyz;
  vec3 toViewer = billboard.up.w > 0.5
      ? normalize(billboard.eye.xyz - center)
      : billboard.back.xyz;
  vec3 xAxis = right;
  vec3 yAxis = billboard.up.xyz;
  float shift = 0.0;
  if (mode > 2.5) {
    // Flat: in a fixed plane, such as the ground.
    xAxis = billboard.flatX.xyz;
    yAxis = billboard.flatY.xyz;
  } else if (mode > 1.5) {
    // Velocity: stretched along the velocity seen on screen, the leading edge
    // half a size ahead of the particle.
    vec3 along = velocity - dot(velocity, toViewer) * toViewer;
    float alongLength = length(along);
    if (alongLength > 1e-6) {
      yAxis = along / alongLength;
      xAxis = normalize(cross(yAxis, toViewer));
      if (dot(xAxis, right) < 0.0) {
        xAxis = -xAxis;
      }
    }
    shift = size.y * (stretch - 1.0) * 0.5;
    size.y *= stretch;
    rotation = 0.0;
  } else if (mode > 0.5) {
    // Cylindrical: turns about the locked axis only.
    yAxis = billboard.axis.xyz;
    vec3 side = cross(yAxis, toViewer);
    float sideLength = length(side);
    if (sideLength > 1e-6) {
      xAxis = side / sideLength;
      if (dot(xAxis, right) < 0.0) {
        xAxis = -xAxis;
      }
    }
  }

  vec2 corner = vertexPosition.xy * size;
  float c = cos(rotation);
  float s = sin(rotation);
  vec2 turned = vec2(c * corner.x - s * corner.y, s * corner.x + c * corner.y);
  vec3 worldPosition = center + xAxis * turned.x + yAxis * (turned.y - shift);
  gl_Position = camera.viewProjection * vec4(worldPosition, 1.0);

  float frames = billboard.flipbook.z;
  float frame0 = mod(floor(frame), frames);
  float frame1 = mod(frame0 + 1.0, frames);
  fragTexCoord = frameTexCoord(frame0, vertexTexCoord);
  fragNextTexCoord = frameTexCoord(frame1, vertexTexCoord);
  fragCorner = vertexPosition.xy * 2.0;
  fragColor = instanceColor;
  fragParams = vec4(
    fract(frame) * billboard.flipbook.w,
    seed,
    particle[3].x,
    0.0
  );
  fragClipPos = gl_Position;
}
