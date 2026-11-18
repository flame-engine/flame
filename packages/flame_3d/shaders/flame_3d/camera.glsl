#ifndef FLAME_CAMERA_GLSL_
#define FLAME_CAMERA_GLSL_

// The camera of the render pass, filled by flame_3d once per pass.
uniform CameraMatrices {
  mat4 view;
  mat4 projection;
  mat4 viewProjection;
} camera;

#endif
