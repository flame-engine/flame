#version 460 core

precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform vec2 uLightSource;
uniform vec2 uBallVelocity;
uniform float uBrightness;
uniform float uRadius;

out vec4 fragColor;


float dfLine(vec2 start, vec2 end, vec2 uv) {
    vec2 line = end - start;
    float frac = dot(uv - start, line) / dot(line, line);
    return distance(start + line * clamp(frac, 0.0, 1.0), uv);
}


vec3 trace(vec2 uv) {
    vec2 v = vec2(uBallVelocity.x*2, pow(uBallVelocity.y, 1)) / 30;
    float dist = dfLine(uLightSource, uLightSource+v, uv);

    dist = 1.0/dist;
    dist *= 0.008;
    float ddist = pow(dist, 2);

    float distanceToLight = length(uLightSource - uv) / 0.1;

    vec3 col = ddist * vec3(1.0, 0.8, 0.6) * pow(distanceToLight, 0.1);
    col = 1.0 - exp(-col);

    return col;
}

void fragment(vec2 uv, inout vec4 color) {
    float ballSize = 0.1;
    vec2 pos = uLightSource - uv;
    pos.y /= uSize.x/uSize.y;

    float dist = 1.0/length(pos);
    dist *= uRadius;
    dist = dist * uBrightness /2;
    float ddist = pow(dist, 1.1);

    vec3 col = ddist * vec3(0.8, 0.4, 1.0);
    col = 1.0 - exp(-col);
    color = vec4(col, pow(ddist* 0.01, 3));
    color.rgb += trace(uv);
}

void main() {
    vec2 pos = FlutterFragCoord().xy;
    vec2 uv = pos / uSize;
    vec4 color;

    fragment(uv, color);

    fragColor = color;
}
