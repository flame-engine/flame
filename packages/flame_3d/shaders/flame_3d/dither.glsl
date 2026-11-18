#ifndef FLAME_DITHER_GLSL_
#define FLAME_DITHER_GLSL_

// 4x4 Bayer ordered screen-space dithering threshold in [0.03125, 0.96875], so
// opaque materials with `ditherFade` enabled can dissolve smoothly in the
// depth-buffered opaque pass with zero translucent overdraw.
float bayerDither4x4(vec2 fragCoord) {
  ivec2 p = ivec2(mod(floor(fragCoord), 4.0));
  const mat4 bayer = mat4(
    0.0,  12.0, 3.0,  15.0,
    8.0,  4.0,  11.0, 7.0,
    2.0,  14.0, 1.0,  13.0,
    10.0, 6.0,  9.0,  5.0
  );
  return (bayer[p.x][p.y] + 0.5) * (1.0 / 16.0);
}

#endif
