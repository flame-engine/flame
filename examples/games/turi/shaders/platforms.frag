#version 460 core

precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform vec4[18] platformsAB;
uniform vec3[18] colorsL;
uniform vec3[18] colorsR;
uniform float[18] glowGamas;


//uniform sampler2D tTexture;

out vec4 fragColor;

const float PI = 3.1415926;

float getLuma(vec3 color) {
    vec3 weights = vec3(0.299, 0.587, 0.114);
    return dot(color, weights);
}

float random(float x) {
    return fract(sin(x) * 43758.5453);
}

vec3 addNoiseToGradient(vec3 colorL, vec3 colorR, float distanceToA, float distanceToB) {

    // Calculate the interpolation factor with noise
    float t = distanceToA / (distanceToA + distanceToB);

    float luma = getLuma(mix(colorL, colorR, t));
    float noiseFactor = 0.1 * (pow(luma, luma));

    // Add noise to the interpolation factor
    t += (random(gl_FragCoord.x) - 0.5) * noiseFactor;

    // Ensure the factor is within the [0, 1] range
    t = clamp(t, 0.0, 1.0);

    // Interpolate the colors with the noisy factor
    vec3 gradient = mix(colorL, colorR, t);


    return gradient;
}

vec4 processPlatform(vec2 uv, vec2 a, vec2 b, vec3 colorL, vec3 colorR, float glowGama) {
    float distanceToA = distance(a, uv);
    float distanceToB = distance(b, uv);

    vec3 gradient = addNoiseToGradient(colorL, colorR, distanceToA, distanceToB);

    float gama = glowGama;

    if (uv.y > a.y) {
        gama  = 3.0;
    }

    float light = acos(dot(normalize(a - uv), normalize(b - uv))) / PI;

    light = clamp(light, 0.0, 1.0);

    if (uv.y > a.y) {
        light *= 0.7;
    }
    gama = clamp(gama, 0.0, 100.0);

    vec3 col = pow(light, gama) * gradient;

    float alpha = pow(light* 0.1, gama);

    return vec4(col, alpha);
}

void fragment(vec2 uv, vec2 pos, inout vec4 color) {
    color = vec4(0, 0, 0, 0);

    for (int i = 0; i < 18; i++) {
        vec4 platform = platformsAB[i];

        vec2 a = platform.xy;
        vec2 b = platform.zw;

        if (a==b) {
            continue;
        }

        vec3 colorL = colorsL[i];
        vec3 colorR = colorsR[i];

        color.rgba += processPlatform(uv, a, b, colorL, colorR, glowGamas[i]);
    }
}

void main() {
    vec2 pos = FlutterFragCoord().xy;
    vec2 uv = pos / uSize;
    vec4 color;

    fragment(uv, pos, color);

    // post process
    float mdf = 0.07;
    float noise = (fract(sin(dot(uv, vec2(12.9898, 78.233)*2.0)) * 43758.5453));
    float luma = getLuma(color.rgb);

    if (luma > 0.01) {
        float llm = smoothstep(0.0, 0.4, luma);
        mdf *= llm * 0.3;
        color += noise * mdf;
    }

    fragColor = color;
}
