#version 460 core

precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uGroundPos;
uniform float uGroundAdd;
uniform float uFade;
uniform float uTime;

out vec4 fragColor;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

vec4 circle(vec2 uv, vec2 center, float radius) {

    vec2 pos = center - uv;
    pos.y /= uSize.x / uSize.y;

    float dist = 1.0 / length(pos);
    dist *= radius;
    dist = dist * 0.9 / 2;
    float ddist = pow(dist, 1.1);

    vec3 col = ddist * vec3(0.3, 0.9, 0.2);
    col = 1.0 - exp(-col);
    return vec4(col, pow(ddist * 0.01, 3));
}

void fragment(vec2 cuv, vec2 pos, inout vec4 color) {
    vec2 p = pos.xy / uSize.xy;
    vec2 uv = p * vec2(uSize.x / uSize.y, 1.0);

    float waterline = uGroundPos;
    float fade = 9.2;

    float tr = step(waterline - fade, uv.y);
    tr *= smoothstep(waterline - fade, waterline, uv.y);
    uv.y -= 0.2;
    uv.y -= uGroundAdd * 0.4;

    vec2 aspect = vec2(uSize.x / uSize.y, 1.0);

    color = vec4(0.0, 0.0, 0.0, 0.0);
    for(int i = 0; i < 10; i++) {
        float t = i * 0.5 + uTime * 0.2;

        vec2 base = vec2(random(vec2(float(i), 1.234)) * aspect.x, random(vec2(float(i), 5.678)) * 0.5);

        vec2 pos = base + vec2(sin(uTime + float(i)) * 0.02, cos(uTime * 0.7 + float(i)) * 0.02);

        float size = 0.001 + random(vec2(float(i), 9.012)) * 0.005;

        vec4 firefly = circle(uv, pos, size * 3);

        color += firefly;
    }

    float f = 1.0;
    f *= tr;
    f *= 0.65;

    color.rgb *= f;

}

void main() {
    vec2 pos = FlutterFragCoord().xy;
    vec2 uv = pos / uSize;
    vec4 color;

    fragment(uv, pos, color);

    fragColor = color;

}
