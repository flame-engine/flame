#version 460 core
// The curved screen shader from https://github.com/stilnat/shader-flame-test,
// the reproduction for https://github.com/flame-engine/flame/issues/3766.
// It is used by the post process golden tests, so keep it unchanged.
#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 uResolution;
uniform sampler2D uTexture;

out vec4 fragColor;

// you must pass uv in range [-1, 1] for it to work
// you should see a radius black point middle and going towards white
void lenghtDebug(vec2 uv)
{
    float r = length(uv);
    fragColor = vec4(vec3(r), 1.0);
}

// you must pass uv in range [-1, 1] for it to work
void angleDebug(vec2 uv)
{
    float theta = atan(uv.y, uv.x); // -π to +π
    // normalize to [0,1]
    float normalized = (theta + 3.14159265) / (2.0 * 3.14159265);

    fragColor = vec4(vec3(normalized), 1.0);
}


// create a regular grid to help visualize deformation and such
vec3 debugGrid(vec2 uv) {
    float lineX = smoothstep(0.0, 0.05, abs(fract(uv.x * 10.0) - 0.5));
    float lineY = smoothstep(0.0, 0.05, abs(fract(uv.y * 10.0) - 0.5));
    float grid = 1.0 - min(lineX, lineY);
    return vec3(grid);
}

// the actual coordinate deformation happens here, 
// you must pass uv in range [-1, 1] for it to work
vec2 crt(vec2 uv)
{
    float theta = atan(uv.y, uv.x);
    float r = length(uv);
    r /= (1.0 - 0.1 * r * r);
    uv.x = r * cos(theta);
    uv.y = r * sin(theta);
    return 0.5 * (uv + 1.0);
}

void draw_crt_grid(vec2 uv){
    uv = crt(2*uv-1);
    vec3 grid = debugGrid(uv);
    fragColor = vec4(grid, 1.0);
}


void main() {
    vec2 fragCoord = FlutterFragCoord().xy;

    // Convert to [0,1] UV, invert Y to match texture coordinates
    vec2 uv = fragCoord / uResolution.xy;
    uv.y = 1.0 - uv.y;

    // draw_crt_grid(uv);

    uv = crt(2*uv-1);
    vec3 col = texture(uTexture, uv).rgb;
    fragColor = vec4(col, 1.0);
}
   

