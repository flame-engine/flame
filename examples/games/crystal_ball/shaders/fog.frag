#version 460 core

precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uGroundPos;
uniform float uGroundAdd;
uniform float uFade;
uniform float uTime;

out vec4 fragColor;


// Thanks iq:
// https://www.shadertoy.com/view/lsf3WH
// Copyright © 2013 Inigo Quilez
float hash(vec2 p) {
    p  = 50.0*fract( p*0.3183099 + vec2(0.71,0.113));
    return -1.0+2.0*fract( p.x*p.y*(p.x+p.y) );
}

float noise( in vec2 p ) {
    vec2 i = floor( p );
    vec2 f = fract( p );
    vec2 u = f*f*f*(f*(f*6.0-15.0)+10.0);

    return mix( mix( hash( i + vec2(0.0,0.0) ),
    hash( i + vec2(1.0,0.0) ), u.x),
    mix( hash( i + vec2(0.0,1.0) ),
    hash( i + vec2(1.0,1.0) ), u.x), u.y);
}

float fractalNoise(vec2 uv) {
    float f = 0.0;
    uv *= 8.0;
    mat2 m = mat2( 1.6,  1.2, -1.2,  1.6 );
    f  = 0.5000*noise( uv ); uv = m*uv;
    f += 0.2500*noise( uv ); uv = m*uv;
    f += 0.1250*noise( uv ); uv = m*uv;
    f += 0.0625*noise( uv ); uv = m*uv;

    f = 0.5 + 0.5*f;

    return f;
}


void fragment(vec2 cuv, vec2 pos, inout vec4 color, float timeMultiplier) {
    vec2 p = pos.xy / uSize.xy;
    vec2 uv = p*vec2(uSize.x/uSize.y,1.0) ;

    float waterline = uGroundPos;
    float fade = uFade;

    float tr = step(waterline - fade,uv.y);
    tr *= smoothstep(waterline - fade, waterline, uv.y);
    uv.y -= uGroundAdd;
    uv *= 1.;
    uv.x  += uTime * timeMultiplier;

    float f = fractalNoise(uv);
    f *= tr;
    f*= 0.65;

    f = pow(f, 1.8);
    color = vec4( vec3(0.8, 0.4, 1.0) * f, f);
}

void main() { 
    vec2 pos = FlutterFragCoord().xy;
    vec2 uv = pos / uSize;
    vec4 color;
    
    fragment(uv, pos, color, 0.015);


    vec4 color2;
    fragment(uv, pos, color2, -0.08 );
    
    fragColor = color + color2;
}
