#version 460 core

precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uWaterLevel;
uniform float uTime;

uniform sampler2D tGameCanvas;

out vec4 fragColor;

vec4 fragment(vec2 uv) {
    vec4 waterColor = vec4(1.0);
    vec2 reflectedUv = uv.xy;
    if (uv.y >= uWaterLevel) {
        // invert y to equivalent position above water
        reflectedUv.y = 2.0 * uWaterLevel - reflectedUv.y;
        // magnify the reflection
        reflectedUv.y = uWaterLevel + (reflectedUv.y - uWaterLevel) * 3;
        // add horizontal waves
        reflectedUv.x = reflectedUv.x +(sin((uv.y-uWaterLevel/1)+ uTime *1.0)*0.01);
        // add vertical waves
        reflectedUv.y = reflectedUv.y + cos(1./(uv.y-uWaterLevel)+ uTime *1.0)*0.03;

        // Magnification can create uv outside of [0,1] range
        if (reflectedUv.y <=0) {
            return vec4(0.0);
        }

        // fade out reflection
        waterColor = vec4(1.0);
        waterColor.rgb *= 1 - ((uv.y-uWaterLevel) / (1.0-uWaterLevel));
    }

    return texture(tGameCanvas, reflectedUv) * waterColor;
}

void main() {
    vec2 pos = FlutterFragCoord().xy;
    vec2 uv = pos / uSize;
    fragColor = fragment(uv);
}
