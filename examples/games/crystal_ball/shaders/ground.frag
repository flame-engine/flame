#version 460 core

precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uPixelSize;
uniform float uWaterLevel;
uniform float uTime;

uniform sampler2D tGameCanvas;

out vec4 fragColor;

vec4 fragment(vec2 uv) {
    vec4 waterColor = vec4(1.0);
    vec2 reflectedUv = uv.xy;

    float fogIntensity = 0.0;
    vec4 fogColor = vec4(1, 0.6, 1.0, 0.2);

    if(uv.y >= uWaterLevel) {
        reflectedUv.y = 2.0 * uWaterLevel - reflectedUv.y;
        float distFromWater = (reflectedUv.y - uWaterLevel);
        float magnification = 2.0 + distFromWater * 1.0;

        reflectedUv.y = uWaterLevel + distFromWater * magnification;
        reflectedUv.x = reflectedUv.x + (sin((uv.y - uWaterLevel / 1.0) + uTime * 1.0) * 0.01);
        reflectedUv.y = reflectedUv.y + cos(1.0 / (uv.y - uWaterLevel) + uTime * 1.0) * 0.03;

        if(reflectedUv.y <= 0.0) {
            return vec4(0.0);
        }

        waterColor = vec4(1.0);
        waterColor.rgb *= 1.0 - ((uv.y - uWaterLevel) / (1.0 - uWaterLevel));

        float waterProximity = 1.0 - min(1.0, (uv.y - uWaterLevel) * 23.0);
        fogIntensity = waterProximity * 0.1;
    } else {
        float waterProximity = 1.0 - min(1.0, (uWaterLevel - uv.y) * 5.0);
        fogIntensity = waterProximity * 0.1;
    }

    vec4 baseColor = texture(tGameCanvas, reflectedUv / uPixelSize) * waterColor;

    return mix(baseColor, fogColor, fogIntensity);
}

void main() {
    vec2 pos = FlutterFragCoord().xy;
    vec2 uv = pos / uSize;
    fragColor = fragment(uv);
}
