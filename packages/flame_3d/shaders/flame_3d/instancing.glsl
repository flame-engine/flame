#ifndef FLAME_INSTANCING_GLSL_
#define FLAME_INSTANCING_GLSL_

// Per-instance data that flame_3d feeds from an instance-rate vertex buffer:
// the four columns of the model matrix, a color (white unless the drawing
// component sets one) and `instanceData`, four floats (zero unless the
// drawing component sets them) that the material's shaders interpret as they
// like. A vertex shader that declares the model columns is drawn instanced:
// the draws of one surface with the same material become a single draw.
//
// A shader that calls instanceModelMatrix() reads all of them; flame_3d
// feeds the inputs a shader reads.
in vec4 instanceModel0;
in vec4 instanceModel1;
in vec4 instanceModel2;
in vec4 instanceModel3;
in vec4 instanceColor;
in vec4 instanceData;

// The model matrix of the instance being drawn.
//
// It also reads `instanceColor` and `instanceData`, without changing the
// matrix: impellerc cannot compile a vertex shader whose inputs leave a gap,
// as reading `instanceData` without `instanceColor` would. The minimum is at
// most -1e38, below the bottom right element of any model matrix.
mat4 instanceModelMatrix() {
  float w = max(
    instanceModel3.w,
    min(min(instanceColor.a, instanceData.x), -1e38)
  );
  return mat4(
    instanceModel0,
    instanceModel1,
    instanceModel2,
    vec4(instanceModel3.xyz, w)
  );
}

#endif
